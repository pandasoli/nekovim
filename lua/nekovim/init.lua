require 'nekovim.std'
require 'utils.maker_to'

local DefaultConfig = require 'default_makers'
local EventHandlers = require 'nekovim.event_handlers'
local VimUtils = require 'nekovim.vim_utils'
local Logger = require 'lib.log'

local VimSockets = require 'deps.vim-sockets'
local Discord = require 'deps.discord'


---@class NekoVim
---@field presence_makers PresenceMakers
---@field presence_props  PresenceProps
---@field buffer_props    BufferProps
---@field work_props      WorkProps
---@field vim_sockets?    VimSockets
---@field logger Logger
local NekoVim = {}

---@param makers     PresenceMakers
---@param work_props WorkPropsMakers
function NekoVim:setup(makers, work_props)
  self.logger = Logger
  self.presence_makers = JoinTables(DefaultConfig.makers, makers)
  self.presence_props = { startTimestamp = os.time() }
  self.work_props = self:make_work_props(JoinTables(DefaultConfig.props, work_props))

  if self.work_props.multiple then
    self.vim_sockets = VimSockets

    VimSockets:setup('package.loaded.nekovim.vim_sockets', Logger)

    VimSockets:on('update presence', function(props)
      Logger:debug('NekoVim:on update presence', 'Received presence:', props.data ~= nil)
      self:update(props.data)
    end)

    VimSockets:on('make connection', function(props)
      Logger:debug('NekoVim:on make connection', 'Received from', props.socket_emmiter)
      self:connect()
    end)

    if #VimSockets.sockets == 0 then
      self:connect()
    end
  else
    self:connect()
  end

  if self.work_props.events then
    EventHandlers:setup(self, false)
  else
    self:make_buf_props()
    self:update()
  end

  VimUtils.CreateUserCommand('PrintNekoLogs', 'lua package.loaded.nekovim.logger:print()', { nargs = 0 })
  VimUtils.SetVar('loaded_nekovim', 1)
end

function NekoVim:connect()
  local client_id = self.work_props.client_id
  if not client_id then
    Logger:error('NekoVim:connect', "cliend_id is not a string")
    return
  end

  Discord:setup(client_id, Logger)
end

-- // Data Makers // --

function NekoVim:make_buf_props()
  local projectPath = VimUtils.GetCWD()
  local filePath = VimUtils.GetBufName()

  ---@type string|nil
  local repoName, fileName, fileExtension

  -- When the terminal is open we cannot take the filepath yet, we have to wait it initialize,
  -- and there is not vim event for it so we just ignore the filePath.
  if filePath then
    -- We want filePath to be relative to the projectPath
    if filePath:sub(1, #projectPath) == projectPath then
      filePath = filePath:sub(#projectPath + 2)
    end

    fileName = filePath:match '[^/\\]+$'
    fileExtension = fileName:match '%.(.+)$'
  end

  -- repoName
  do
    local cmd = "git remote -v 2> /dev/null | grep -oP '[^/]+(?=\\.git)'"
    local f = assert(io.popen(cmd))
    local d = assert(f:read('*a')):split '\n'
    f:close()

    if #d > 0 then
      repoName = d[1]
    else
      repoName = projectPath:match '[^/\\]+$'
    end
  end

  self.buffer_props = {
    mode = VimUtils.GetMode(),
    projectPath = projectPath,
    filePath = filePath,
    fileType = VimUtils.GetFileType(),
    repoName = repoName,

    fileName = fileName,
    fileExtension = fileExtension
  }
end

---@return Presence?
function NekoVim:make_presence()
  local makers = self.presence_makers

  if type(makers) ~= 'table' then return end

  ---@type Presence
  local presence = {}

  presence.state = Maker_tostring(makers.state, self)
  presence.details = Maker_tostring(makers.details, self)

  if type(makers.timestamps) == 'table' then
    presence.timestamps = {}

    presence.timestamps.start = Maker_tonumber(makers.timestamps.start, self)
    presence.timestamps['end'] = Maker_tonumber(makers.timestamps['end'], self)
  end

  if type(makers.assets) == 'table' then
    presence.assets = {}

    presence.assets.large_image = Maker_tostring(makers.assets.large_image, self)
    presence.assets.large_text  = Maker_tostring(makers.assets.large_text , self)
    presence.assets.small_image = Maker_tostring(makers.assets.small_image, self)
    presence.assets.small_text  = Maker_tostring(makers.assets.small_text , self)
  end

  if type(makers.buttons) == 'table' then
    presence.buttons = {}

    for _, maker in ipairs(makers.buttons) do
      local res = Maker_totable(maker, self)

      if res then
        table.insert(presence.buttons, res)
      end
    end

    presence.buttons = #presence.buttons > 0 and presence.buttons or nil
  end

  return presence
end

---@param makers WorkPropsMakers
---@return WorkProps
function NekoVim:make_work_props(makers)
  ---@type WorkProps
  local props = {}

  if type(makers) ~= 'table' then return props end

  props.client_id = Maker_tostring(makers.client_id, self)
  props.multiple  = Maker_toboolean(makers.multiple, self)
  props.events    = Maker_toboolean(makers.events, self)

  return props
end

-- // Events // --

---@param presence? Presence
function NekoVim:update(presence)
  if not presence then
    presence = self:make_presence()
    if not presence then return end

    if Discord.tried_connection then
      Logger:debug('NekoVim:update', 'Setting presence')
      Discord:set_activity(presence)
    elseif self.work_props.multiple then
      Logger:debug('NekoVim:update', 'Emitting update event')
      self.vim_sockets:emit('update presence', presence)
    end
  elseif Discord.tried_connection then
    Discord:set_activity(presence)
  end
end

function NekoVim:shutdown()
  if self.work_props.multiple then
    if #VimSockets.sockets > 0 then
      local next_socket = VimSockets.sockets[1]

      if Discord.tried_connection then
        VimSockets:emit_to(next_socket, 'make connection')
      end

      VimSockets:emit_to(next_socket, 'update presence')
    end
  end
end

return NekoVim
