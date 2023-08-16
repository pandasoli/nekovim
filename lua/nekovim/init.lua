require 'nekovim.std'
require 'utils.maker_to'

local DefaultMakers = require 'default_makers'
local EventHandlers = require 'nekovim.event_handlers'
local VimUtils = require 'nekovim.vim_utils'
local Logger = require 'lib.log'

local VimSockets = require 'deps.vim-sockets'
local Discord = require 'deps.discord'


---@class NekoVim
---@field presence_makers PresenceMakers
---@field presence_props  PresenceProps
---@field buffer_props    BufferProps
---@field vim_sockets     VimSockets
---@field logger Logger
local NekoVim = {}

---@param makers PresenceMakers
function NekoVim:setup(makers)
  self.logger = Logger
  self.presence_makers = JoinTables(DefaultMakers, makers)
  self.presence_props = {}
  self.presence_props.startTimestamp = os.time()

  self.vim_sockets = VimSockets.new('package.loaded.nekovim.vim_sockets', Logger)

  self.vim_sockets:on('update presence', function(props)
    Logger:log('NekoVim:on update presence', 'Received presence:', props.data ~= nil)
    self:update(props.data)
  end)

  self.vim_sockets:on('make connection', function(props)
    Logger:log('NekoVim:on make connection', 'Received from', props.socket_emmiter)
    self:connect()
  end)

  if #self.vim_sockets.sockets == 0 then
    self:connect()
  end

  EventHandlers:setup(self, true)

  VimUtils.CreateUserCommand('PrintNekoLogs', 'lua package.loaded.nekovim.logger:print()', { nargs = 0 })
  VimUtils.SetVar('loaded_nekovim', 1)
end

function NekoVim:connect()
  local makers = self.presence_makers
  if type(makers) ~= 'table' then
    return Logger:log('NekoVim:connect', "Could not get cliend_id; Presence Makers are not a table")
  end

  local client_id = Maker_tostring(makers.client_id, self)
  if type(client_id) ~= 'string' then
    return Logger:log('NekoVim:connect', "cliend_id is not a string")
  end

  Discord:setup(client_id, Logger)
end

-- // Data Makers // --

function NekoVim:make_buf_props()
  local projectPath = VimUtils.GetCWD()
  local filePath = VimUtils.GetBufName()

  ---@type string|nil
  local fileName, fileExtension

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

  self.buffer_props = {
    mode = VimUtils.GetMode(),
    projectPath = projectPath,
    filePath = filePath,
    fileType = VimUtils.GetFileType(),
    repoName = projectPath:match '[^/\\]+$',

    fileName = fileName,
    fileExtension = fileExtension
  }
end

---@return Presence?
function NekoVim:make_presence()
  if type(self.presence_makers) ~= 'table' then return end

  local makers = self.presence_makers
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
      table.insert(presence.buttons, Maker_totable(maker, self))
    end

    presence.buttons = #presence.buttons > 0 and presence.buttons or nil
  end

  return presence
end

-- // Events // --

---@param presence? Presence
function NekoVim:update(presence)
  if not presence then
    presence = self:make_presence()
    if not presence then return end

    if Discord.tried_connection then
      Logger:log('NekoVim:update', 'Setting presence')
      Discord:set_activity(presence)
    else
      Logger:log('NekoVim:update', 'Emitting update event')
      self.vim_sockets:emmit('update presence', presence)
    end
  elseif Discord.tried_connection then
    Discord:set_activity(presence)
  end
end

function NekoVim:shutdown()
  if #self.vim_sockets.sockets > 0 then
    local next_socket = self.vim_sockets.sockets[0]

    if Discord.tried_connection then
      self.vim_sockets:emmit_to(next_socket, 'make connection')
    end

    self.vim_sockets:emmit_to(next_socket, 'update presence')
  end

  self.vim_sockets:unregister_self()
end

return NekoVim
