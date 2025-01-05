require 'discord.utils.json'
require 'discord.uuid'

local struct = require 'discord.deps.struct'

---@class WaitingActivity
---@field activity  Presence?
---@field callback? fun(response: string?, err_name: string?, err_msg: string?)

---@class Discord
---@field client_id        string
---@field logger           Logger
---@field socket           string # Just for debuging
---@field pipe             uv_pipe_t?
---@field waiting_activity WaitingActivity?
---@field tried_connection boolean
local Discord = {}

---@param client_id string
---@param logger    Logger
---@param callback? fun(response: (table|string)?, opcode: number?, err: string?)
function Discord:setup(client_id, logger, callback)
  if logger then self.logger = logger end
  self.client_id = client_id

	local uname = vim.loop.os_uname()
	self.os = {
		name = self.get_osname(uname)
	}

  self:test_sockets(function() self:authorize(callback) end)
  self.tried_connection = true
end

---@param uname string
---@return 'windows'|'macos'|'linux'|'unkown' osname
function Discord.get_osname(uname)
	if uname.sysname:find('Windows') then
		return 'windows'
	elseif uname.sysname:find('Darwin') then
		return 'macos'
	elseif uname.sysname:find('Linux') then
		return 'linux'
	end

	return 'unkown'
end

---@private
---@param callback? fun(self: Discord)
function Discord:test_sockets(callback)
  local sockets = self:get_sockets()
  local sockets_len = #sockets
  local pipe = assert(vim.loop.new_pipe(false))

  local tried_connections = 0

  for i, socket in ipairs(sockets) do
    if self.pipe then break end

    self.logger:log('Discord:test_sockets', 'Trying connection with socket', tostring(i)..'/'..tostring(sockets_len))
    pipe:connect(socket, function(err)
      if err then
        pipe:close()
        tried_connections = tried_connections + 1

        if tried_connections == sockets_len then
          self.logger:log('Discord:test_sockets', 'Could not connect to any socket ('..tostring(sockets_len)..')')
        end
      else
        self.pipe = pipe
        self.socket = socket
        if callback then callback(self) end

        self.logger:log('Discord:test_sockets', 'Successful connection with', socket)
      end
    end)
  end
end

---@private
---@return string[] sockets
function Discord:get_sockets()
  local cmd

	if self.os.name == 'linux' then
		cmd = "ss -lx | grep -o '[^[:space:]]*discord[^[:space:]]*'"
	elseif self.os.name == 'windows' then
		cmd = [[powershell -Command (Get-ChildItem \\.\pipe\).FullName | findstr discord]]
	end

  local f = assert(io.popen(cmd, 'r'))
  local d = assert(f:read('*a'))
  f:close()

  return d:split '\n'
end

---@return boolean
function Discord:is_active()
  if self.pipe then
    return self.pipe:is_active() or false
  end

  return false
end

function Discord:disconnect()
  if self.pipe then
    self.pipe:shutdown()

    -- I'm not sure why close after shutting down
    if not self.pipe.is_closing then
      self.pipe:close()
    end
  end
end

---@param activity  Presence?
---@param callback? fun(response: (table|string)?, opcode: number?, err: string?)
function Discord:set_activity(activity, callback)
  if not self.pipe or not self.pipe:is_active() then
    self.logger:log('Discord:set_activity', 'adding to wait')
    self.waiting_activity = { activity = activity, callback = callback }
  else
    local payload = {
      cmd = 'SET_ACTIVITY',
      nonce = Generate_uuid(),
      args = {
        activity = activity,
        pid = vim.loop:os_getpid()
      }
    }

    self.logger:log('Discord:set_activity', 'calling')
    self:call(1, payload, callback)
  end
end

---@private
---@param callback? fun(response: (table|string)?, opcode: number?, err: string?)
function Discord:authorize(callback)
  local payload = {
    client_id = self.client_id,
    v = 1
  }

  self:call(0, payload, function(...)
    if self.waiting_activity then
      self:set_activity(self.waiting_activity.activity, self.waiting_activity.callback)
    end

    if callback then callback(...) end
  end)
end

---@private
---@param opcode    number
---@param payload   table
---@param callback? fun(response: (table|string)?, opcode: number?, err: string?)
function Discord:call(opcode, payload, callback)
  callback = callback or function() end

  local function read_fn(read_err, chunk)
    if read_err then
      callback(nil, nil, 'reading: ' .. read_err)
    elseif chunk then
      local msg = chunk:match('({.+)')
      local opcode = struct.unpack('<ii', chunk)

      DecodeJSON(msg, function(success, response)
        opcode = tonumber(opcode) or opcode
        callback(success and response or chunk, opcode)
      end)
    end
  end

  EncodeJSON(payload, function(body)
    local msg = struct.pack('<ii', opcode, #body) .. body

    self.pipe:write(msg, function(write_err)
      if write_err then
        callback(nil, nil, 'writing: ' .. write_err)
      else
        self.pipe:read_start(read_fn)
      end
    end)
  end)
end

return Discord
