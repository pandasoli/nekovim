require 'nekovim.std'

local EventHandlers = require 'nekovim.event_handlers'
local VimUtils = require 'nekovim.vim_utils'
local Logger = require 'lib.log'

require 'nekovim.check_presence_makers'


---@class NekoVim
---@field presence_makers PresenceMakers
---@field presence_props  PresenceProps
---@field buffer_props    BufferProps
---@field logger Logger
local NekoVim = {}

---@param makers PresenceMakers
function NekoVim:setup(makers)
  self.presence_makers = makers
  self.logger = Logger

  EventHandlers:setup(self, true)

  VimUtils.CreateUserCommand('PrintNekoLogs', 'lua package.loaded.nekovim.logger:print()', { nargs = 0 })
  VimUtils.SetVar('loaded_nekovim', 1)
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

---@return Presence|nil
function NekoVim:make_activity()
  local makers = self.presence_makers

  if not CheckPresenceMakers(makers) then
    return
  end

  ---@type Presence
  local activity = {
    state   = makers.state(self),
    details = makers.details(self),

    timestamps = {
      start   = makers.timestamps.start  (self),
      ['end'] = makers.timestamps ['end'](self)
    },

    assets = {
      large_image = makers.assets.large_image(self),
      large_text  = makers.assets.large_text (self),
      small_image = makers.assets.small_image(self),
      small_text  = makers.assets.small_text (self)
    },

    buttons = {}
  }

  for _, maker in ipairs(self.presence_makers.buttons) do
    table.insert(activity.buttons, maker(self))
  end

  return activity
end

-- // Events // --

function NekoVim:update()
  local activity = self:make_activity()
  if not activity then return end
end

function NekoVim:shutdown()
end

return NekoVim
