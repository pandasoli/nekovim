require 'nekovim.std'
require 'utils.maker_to'

local DefaultConfig = require 'default_makers'
local EventHandlers = require 'nekovim.event_handlers'
local VimUtils = require 'utils.vim'
local Logger = require 'lib.log'

local VimSockets = require 'deps.vim-sockets'
local Discord = require 'deps.discord'


---@class NekoVim
---@field presence_makers PresenceMakers
---@field presence_props  PresenceProps
---@field buffers_props   BuffersProps
---@field work_props      WorkProps
---@field vim_sockets     VimSockets?
---@field current_buf     number
---@field idle_timer      number?
local NekoVim = {}

---@param makers     PresenceMakers
---@param work_props WorkPropsMakers
function NekoVim.setup(makers, work_props)
  local self = NekoVim

  self.presence_makers = JoinTables(DefaultConfig.makers, makers)
  self.presence_props = { startTimestamp = os.time(), idling = false }
  self.work_props = self:make_work_props(JoinTables(DefaultConfig.props, work_props))
  self.idle_timer = -1
  self.buffers_props = {}
  self.current_buf = vim.api.nvim_get_current_buf()

  if self.work_props.multiple then
    self.vim_sockets = VimSockets

    VimSockets:setup('package.loaded.nekovim.vim_sockets', Logger)

    VimSockets:on('update presence', function(props)
      Logger:debug('NekoVim:on update presence', 'Received presence:', props.data ~= nil)
      self:update(props.data)
    end)

    VimSockets:on('make connection', function(props)
      Logger:debug('NekoVim:on make connection', 'Received from', props.emitter)
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
    self:restart_idle_timer()
  else
    self:make_buf_props()
    self:update()
  end

  VimUtils.CreateUserCommand('PrintNekoLogs', function() Logger:print() end, { nargs = 0 })
end

function NekoVim:connect()
  local client_id = self.work_props.client_id
  if not client_id then
    Logger:error('NekoVim:connect', "cliend_id is not a string")
    return
  end

  Discord:setup(client_id, Logger, function(res, opcode, err)
    if err then
      return Logger:error('NekoVim:connect', err)
    end

    vim.schedule(function()
      res = type(res) == 'table' and vim.fn.json_encode(res) or res
      Logger:error('NekoVim:conect', opcode, res)
    end)
  end)
end

function NekoVim:restart_idle_timer()
  self.presence_props.idling = false

  if self.idle_timer ~= -1 then
    vim.fn.timer_stop(self.idle_timer)
  end

  self.idle_timer = vim.fn.timer_start(self.work_props.idle_time * 1000, function()
    self.presence_props.idling = true
    self:update()
  end)
end

-- // Data Makers // --

function NekoVim:make_buf_props()
  -- Check history
  if self.buffers_props[self.current_buf] then
    return
  end

  local projectPath = VimUtils.GetCWD()
  local filePath = VimUtils.GetBufName()

  ---@type string|nil
  local repoOwner, repoName, fileName, fileExtension

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
    local cmd = "git remote -v 2> /dev/null | awk '{print $2}'"
    local f = assert(io.popen(cmd))
    local d = assert(f:read('*a'))
    f:close()

    if #d > 0 then
      local url = d:match '(.-)\n'
      url = url:gsub('%.git$', '')

      repoOwner, repoName = url:match '.*[:/]([^/]+)/(.*)'
    end
  end

  self.buffers_props[self.current_buf] = {
    mode = VimUtils.GetMode(),
    projectPath = projectPath,
    filePath = filePath,
    fileType = VimUtils.GetFileType(),
    repo = {
      owner = repoOwner,
      name = repoName
    },

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

  props.client_id = Maker_tostring (makers.client_id, self)
  props.multiple  = Maker_toboolean(makers.multiple , self)
  props.events    = Maker_toboolean(makers.events   , self)
  props.idle_time = Maker_tonumber (makers.idle_time, self)

  return props
end

-- // Events // --

---@param presence? Presence
function NekoVim:update(presence)
  local function set_activity()
    Discord:set_activity(presence, function(res, opcode, err)
      if err then
        return Logger:error('NekoVim:update', err)
      end

      vim.schedule(function()
        res = type(res) == 'table' and vim.fn.json_encode(res) or res
        Logger:info('NekoVim:update', opcode, res)
      end)
    end)
  end

  if not presence then
    presence = self:make_presence()
    if not presence then return end

    if Discord.tried_connection then
      Logger:debug('NekoVim:update', 'Setting presence')
      set_activity()
    elseif self.work_props.multiple then
      Logger:debug('NekoVim:update', 'Emitting update event')
      self.vim_sockets:emit('update presence', presence)
    end
  elseif Discord.tried_connection then
    set_activity()
  end
end

function NekoVim:shutdown()
  if self.work_props.multiple then
    if #VimSockets.sockets > 0 then
      local next_socket = VimSockets.sockets[1]

      VimSockets:emit_to(next_socket, 'make connection')
      VimSockets:emit_to(next_socket, 'update presence')
    end
  end

  Discord:disconnect()
end

return NekoVim
