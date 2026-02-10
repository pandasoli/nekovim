require 'discord.uuid'

local struct = require 'discord.deps.struct'
local uv = vim.uv

---@class Discord
---@field client_id string
---@field logger    Logger
---@field pipe      uv.uv_pipe_t?
---@field pid       number
---@field buf       string Used to buffer Discord responses
---@field listeners fun(opcode: number, msg: string)[]
local Discord = {}

---@param client_id string
---@param logger    Logger
---@param listener? fun(opcode: number, msg: string)
function Discord:setup(client_id, logger, listener)
  if logger then self.logger = logger end
  self.client_id = client_id

  self.pid = uv:os_getpid()
  self.listeners = {}

  if listener then
    self.listeners[1] = listener
  end

  self:test_sockets(function () self:authorize() end)
end

function Discord:is_connected()
  return self.pipe
end

---@private
---@return string[] sockets
function Discord:get_sockets()
  local files = {}
  local sys = uv.os_uname().sysname

  if sys == 'Linux' then
    local dirs = {
      vim.env.XDG_RUNTIME_DIR or '/tmp',
      '/run/user/' .. uv.getuid()
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

  elseif sys == 'Windows' then
    local cmd = [[powershell -Command (Get-ChildItem \\.\pipe\).FullName | findstr discord]]

    local f = assert(io.popen(cmd, 'r'))
    local d = assert(f:read('*a'))
    f:close()

    files = d:split '\n'

  else
    error('Unsupported system. Supported systems are Linux and Windows.')
  end

  return files
end

---@private
---@param callback? fun(self: Discord)
function Discord:test_sockets(callback)
  local sockets = self:get_sockets()

  self.logger:log('Discord:test_sockets', 'Trying to connected with '..tostring(#sockets)..' sockets')

  for i, socket in ipairs(sockets) do
    local pipe = assert(uv.new_pipe(false))
    local num = tostring(i)..'/'..tostring(#sockets)

    pipe:connect(socket, function (err)
      if self:is_connected() then
        pipe:close()
        return
      end

      if err then
        pipe:close()
        self.logger:log('Discord:test_sockets', 'Could not connect with socket', num)
        return
      end

      self.pipe = pipe
      self.pipe:read_start(function (err, chunk)
        self:read(err, chunk)
      end)

      self.logger:log('Discord:test_sockets', 'Successful connection with socket', socket, '('..num..')')

      if callback then callback(self) end
    end)
  end
end

function Discord:disconnect()
  if not self.pipe then self.pipe:shutdown() end

  self.pipe:shutdown(function ()
    if not self.pipe:is_active() then
      self.pipe:close()
    end
    self.pipe = nil
  end)
end

---@param activity Presence
function Discord:set_activity(activity)
  local payload = {
    cmd = 'SET_ACTIVITY',
    nonce = Generate_uuid(),
    args = {
      activity = activity,
      pid = self.pid
    }
  }

  self.logger:debug('Discord:set_activity', 'setting presence')
  self:call(1, payload)
end

---@private
function Discord:authorize()
  local payload = {
    client_id = self.client_id,
    v = 1
  }

  self:call(0, payload)
end

---@private
---@param err string|nil
---@param chunk? string
function Discord:read(err, chunk)
  if err then
    self.logger:error('Discord:read', err)
    return
  elseif not chunk then
    return
  end

  chunk = tostring(chunk)
  self.buf = (self.buf or '') .. chunk

  while #self.buf >= 8 do
    local opcode, len = struct.unpack('<ii', self.buf)

    if #self.buf < 8 + len then
      break
    end

    local msg = self.buf:sub(9, 8 + len)
    self.buf = self.buf:sub(9 + len)

    for _, fn in ipairs(self.listeners) do
      fn(opcode, msg)
    end
  end
end

---@private
---@param opcode    number
---@param payload   table
function Discord:call(opcode, payload)
  vim.schedule(function ()
    local body = vim.fn.json_encode(payload)
    local msg = struct.pack('<ii', opcode, #body) .. body

    self.pipe:write(msg, function (err)
      if err then
        self.logger:error('Discord:call', 'writing:', err)
      end
    end)
  end)
end

return Discord
