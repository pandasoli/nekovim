local msgpack = require 'vim-sockets.deps.msgpack'

require 'vim-sockets.lib.list_to_argv'


---@class ReceiverProps
---@field event   string
---@field emitter string
---@field data    any

---@class VimSockets
---@field socket    string
---@field dep_path  string
---@field sockets   string[]
---@field receivers table<string, fun(props: ReceiverProps)>
---@field logger Logger
local VimSockets = {}

---@param dep_path    string # package.loaded...
---@param logger      Logger
---@param vim_events? boolean
function VimSockets:setup(dep_path, logger, vim_events)
  self.socket = vim.v.servername
  self.dep_path = dep_path or ''
  self.logger = logger
  self.sockets = {}
  self.receivers = {}

  self:register_self()

  if vim_events then
    vim.api.nvim_create_user_command('PrintSockets', function() self:print_sockets() end, { nargs = 0 })
    vim.api.nvim_create_user_command('PrintLogs', function() self.logger:print() end, { nargs = 0 })
  end

  vim.api.nvim_create_autocmd('VimLeavePre', {
    callback = function() self:unregister_self() end
  })
end

function VimSockets:print_sockets()
  print(vim.fn.json_encode(self.sockets))
end

---@param event     string
---@param data      any
---@param callback? fun(err: string|nil)
function VimSockets:emit(event, data, callback)
  self.logger:debug('emit', 'Emitting event', event, 'to', #self.sockets, 'sockets')

  for _, socket in ipairs(self.sockets) do
    self:emit_to(socket, event, data, callback)
  end
end

---@param socket    string
---@param event     string
---@param data      any
---@param callback? fun(err: string|nil)
function VimSockets:emit_to(socket, event, data, callback)
  ---@type ReceiverProps
  local props = {
    emitter = self.socket,
    event = event,
    data = data
  }

  self:call_remote_method(socket, 'receive_data', { props }, function(err)
    if err then
      self.logger:error('emit_to', 'Error emitting to', socket .. ':', err)
    end

    if callback then callback(err) end
  end)
end

---@param event string
---@param fn    fun(props: ReceiverProps)
function VimSockets:on(event, fn)
  self.receivers[event] = fn
end

---@private
function VimSockets:register_self()
  self.sockets = self.get_socket_paths()

  self.logger:debug('register_self', 'Registered self for', #self.sockets - 1, 'sockets')

  for i, socket in ipairs(self.sockets) do
    if socket == self.socket then
      self.sockets[i] = nil
    else
      self:call_remote_method(socket, 'register_socket', { self.socket }, function(err)
        if err then
          self.logger:error('register_self', 'Error registering for', socket .. ':', err)
        end
      end)
    end
  end
end

function VimSockets:unregister_self()
  self.logger:debug('unregister_self', 'Unregistering self for', #self.sockets, 'sockets')

  for _, socket in ipairs(self.sockets) do
    self:call_remote_method(socket, 'unregister_socket', { self.socket }, function(err)
      if err then
        self.logger:error('unregister_self', 'Error unregistering for socket', socket .. ':', err)
      end
    end)
  end
end

---@private
---@return string[]
function VimSockets.get_socket_paths()
  local cmd = "ss -lx | grep -o '[^[:space:]]*vim[^[:space:]]*'"

  local f = assert(io.popen(cmd))
  local data = assert(f:read('*a'))
  f:close()

  return data:split '\n'
end

---@private
---@param socket    string
---@param name      string
---@param args      table
---@param callback? fun(err: string|nil)
function VimSockets:call_remote_method(socket, name, args, callback)
  local cmd_fmt = 'lua %s:%s(%s)'

  local arglist = ListToArgv(args)
  local cmd = string.format(cmd_fmt, self.dep_path, name, arglist)

  self:call_instance(socket, cmd, callback)
end

---@private
---@param socket    string
---@param cmd       string
---@param callback? fun(err: string|nil)
function VimSockets:call_instance(socket, cmd, callback)
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
function VimSockets:register_socket(socket)
  self.logger:info('register_socket', 'Registering socket', socket)
  table.insert(self.sockets, socket)
end

---@private
---@param socket string
function VimSockets:unregister_socket(socket)
  self.logger:info('unregister_socket', 'Unregistering socket', socket)
  self.sockets[socket] = nil
end

---@private
---@param props ReceiverProps
function VimSockets:receive_data(props)
  self.logger:info('receive_data', 'Receiving event', props.event, 'from', props.emitter)

  local fn = self.receivers[props.event]

  if fn then
    fn(props)
  end
end

return VimSockets
