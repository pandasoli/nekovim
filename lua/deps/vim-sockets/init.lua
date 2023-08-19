local msgpack = require 'vim-sockets.deps.msgpack'

require 'vim-sockets.lib.list_to_argv'
require 'vim-sockets.std'


---@class ReceiverProps
---@field event string
---@field socket_emmiter string
---@field data any

---@class VimSockets
---@field socket string
---@field instance_path string
---@field logger Logger
---@field sockets string[]
---@field receivers table<string, fun(props: ReceiverProps)>
local Sockets = {
  socket = vim.v.servername,
  instance_path = '',
  logger = {
    log = function()end
  },
  sockets = {},
  receivers = {}
}
Sockets.__index = Sockets

---@param instance_path string
---@param logger Logger
---@param vim_events? boolean
function Sockets:setup(instance_path, logger, vim_events)
  self.instance_path = instance_path
  self.logger = logger

  if vim_events then
    vim.api.nvim_create_user_command('PrintSockets', function() self:print_sockets() end, { nargs = 0 })
    vim.api.nvim_create_user_command('PrintLogs', function() self.logger:print() end, { nargs = 0 })
  end

  vim.api.nvim_create_autocmd('ExitPre', {
    callback = function() self:unregister_self() end
  })

  self:register_self()
end

---@param instance_path string
---@param logger Logger
---@param vim_events? boolean
function Sockets.new(instance_path, logger, vim_events)
  local instance = setmetatable({}, Sockets)
  instance:setup(instance_path, logger, vim_events)

  return instance
end

function Sockets:print_sockets()
  print(vim.fn.json_encode(self.sockets))
end

---@param event string
---@param data any
function Sockets:emit(event, data)
  self.logger:debug('emmit', 'Emmiting event', event, 'to', #self.sockets, 'sockets')

  for _, socket in ipairs(self.sockets) do
    self:emit_to(socket, event, data, function(err)
      if err then
        self.logger:error('emmit', 'Error emmiting to', socket .. ':', err)
      end
    end)
  end
end

---@param socket string
---@param event string
---@param data any
---@param callback? fun(err: string?)
function Sockets:emit_to(socket, event, data, callback)
  local props = {
    socket_emmiter = self.socket,
    event = event,
    data = data
  }

  self.logger:debug('emmit_to', 'Emmiting event', event, 'to socket', socket)
  self:call_remote_method(socket, 'receive_data', { props }, callback)
end

---@param event string
---@param fn fun(props: ReceiverProps)
function Sockets:on(event, fn)
  self.receivers[event] = fn
end

---@private
function Sockets:register_self()
  self.sockets = self.get_socket_paths()

  self.logger:debug('register_self', 'Registered self for', #self.sockets - 1, 'sockets')

  for i, socket in ipairs(self.sockets) do
    if socket == self.socket then
      self.sockets[i] = nil
    else
      local err = self:call_remote_method(socket, 'register_socket', { self.socket })

      if err then
        self.logger:error('register_self', 'Error registering for', socket .. ':', err)
      end
    end
  end
end

function Sockets:unregister_self()
  self.logger:debug('unregister_self', 'Unregistering self for', #self.sockets, 'sockets')

  for _, socket in ipairs(self.sockets) do
    local err = self:call_remote_method(socket, 'unregister_socket', { self.socket })

    if err then
      self.logger:error('unregister_self', 'Error unregistering for socket', socket .. ':', err)
    end
  end
end

---@private
---@return string[]
function Sockets.get_socket_paths()
  local function handle(lines)
    local sockets = {}

    for i = 1, #lines do
      local socket = lines[i]:match '%s(/.-)%s'

      if socket then
        table.insert(sockets, socket)
      end
    end

    return sockets
  end

  local f = assert(io.popen('ss -lx | grep vim'))
  local data = f:read('*a')
  f:close()

  return handle(data:split '\n')
end

---@private
---@param socket string
---@param name string
---@param args any[]
---@param callback? fun(err: string?)
function Sockets:call_remote_method(socket, name, args, callback)
  local cmd_fmt = 'lua %s:%s(%s)'

  local arglist = ListToArgv(args)
  local cmd = string.format(cmd_fmt, self.instance_path, name, arglist)

  self:call_remote_instance(socket, cmd, callback)
end

---@private
---@param socket string
---@param cmd string
---@param callback? fun(err: string?)
function Sockets:call_remote_instance(socket, cmd, callback)
  local pipe = assert(vim.loop.new_pipe(true))

  pipe:connect(socket, function()
    local packed = msgpack.pack({ 0, 0, 'nvim_command', { cmd } })

    pipe:write(packed, callback)
  end)
end

--- End client methods ---
--- Start server methods ---

---@private
---@param socket string
function Sockets:register_socket(socket)
  self.logger:info('register_socket', 'Registering socket', socket)
  table.insert(self.sockets, socket)
end

---@private
---@param socket string
function Sockets:unregister_socket(socket)
  self.logger:info('unregister_socket', 'Unregistering socket', socket)
  self.sockets[socket] = nil
end

---@private
---@param props ReceiverProps
function Sockets:receive_data(props)
  self.logger:info('receive_data', 'Receiving event', props.event, 'from', props.socket_emmiter)

  local fn = self.receivers[props.event]

  if fn then
    fn(props)
  end
end

return Sockets
