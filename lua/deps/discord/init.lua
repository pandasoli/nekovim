require 'discord.uuid'

local struct = require 'discord.deps.struct'
local uv = vim.loop

---@class WaitingActivity
---@field activity  Presence?
---@field callback? fun(response: string?, err_name: string?, err_msg: string?)

---@class Discord
---@field client_id        string
---@field logger           Logger
---@field socket           string # Just for debuging
---@field pipe             uv.uv_pipe_t?
---@field waiting_activity WaitingActivity?
---@field tried_connection boolean
---@field reading          boolean
local Discord = {}

---@param client_id string
---@param logger    Logger
---@param callback? fun(response: (table|string)?, opcode: number?, err: string?)
function Discord:setup(client_id, logger, callback)
  if logger then self.logger = logger end
  self.client_id = client_id
  self.os = { name = self.get_osname() }

  self:test_sockets(function() self:authorize(callback) end)
  self.tried_connection = true
end

---@return 'windows'|'linux'|'unkown' osname
function Discord.get_osname()
  local uname = uv.os_uname()

  if uname.sysname:find('Windows') then
    return 'windows'
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
  local pipe = assert(uv.new_pipe(false))

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
        self:start_reading()
        if callback then callback(self) end

        self.logger:log('Discord:test_sockets', 'Successful connection with', socket)
      end
    end)
  end
end

---@private
---@return string[] sockets
function Discord:get_sockets()
  local files = {}

  if self.os.name == 'linux' then
    local dirs = {
      vim.env.XDG_RUNTIME_DIR or '/tmp',
      '/run/user/'..uv.getuid()
    }

    for _, dir in ipairs(dirs) do
      local handle = uv.fs_scandir(dir)
      if not handle then
        self.logger:error('Discord:get_sockets', 'Could not scan directory ('..dir..')')
      else
        while true do
          local name, type = uv.fs_scandir_next(handle)
          if not name then break end

          if type == 'socket' and name:match '^discord%-ipc%-' then
            table.insert(files, dir..'/'..name)
          end
        end
      end
    end
  elseif self.os.name == 'windows' then
    local cmd = [[powershell -Command (Get-ChildItem \\.\pipe\).FullName | findstr discord]]

    local f = assert(io.popen(cmd, 'r'))
    local d = assert(f:read('*a'))
    f:close()

    files = d:split '\n'
  end

  return files
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
        pid = uv:os_getpid()
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
function Discord:start_reading()
  if self.reading or not self.pipe then return end
  self.reading = true

  ---@param err string|nil
  ---@param chunk string
  local function read_fn(err, chunk)
    if err then
      self.logger:error('Discord:start_reading', err)
      return
    end

    vim.schedule(function()
      local opcode, length = struct.unpack('<ii', chunk)
      local msg = chunk:sub(9, 8 + length)

      local success, result = pcall(vim.fn.json_decode, msg)
      if success then
        if self._pending_callback then
          local callback = self._pending_callback
          self._pending_callback = nil
          callback(result, opcode)
        end
      else
        self.logger:error('Discord:start_reading', result)
      end
    end)
  end

  self.pipe:read_start(read_fn)
end

---@private
---@param opcode    number
---@param payload   table
---@param callback? fun(response: (table|string)?, opcode: number?, err: string?)
function Discord:call(opcode, payload, callback)
  callback = callback or function() end
  self._pending_callback = callback

  vim.schedule(function()
    local body = vim.fn.json_encode(payload)
    local msg = struct.pack('<ii', opcode, #body) .. body

    self.pipe:write(msg, function(err)
      if err then
        callback(nil, nil, 'writing: ' .. err)
      end
    end)
  end)
end

return Discord
