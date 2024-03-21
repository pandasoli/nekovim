local VimUtils = require 'utils.vim'
local Logger = require 'lib.log'


---@class EventHandlers
---@field private nekovim NekoVim
local EventHandlers = {}

---@param nekovim NekoVim
---@param log_to_file? boolean # Write logs to file every time an event is trigged
function EventHandlers:setup(nekovim, log_to_file)
  self.nekovim = nekovim

  local events = {
    ['VimLeavePre'] = function() self.nekovim:shutdown() end,
    ['FocusGained'] = function() self.nekovim:update() end,

    ['BufEnter'] = function() self:handle_BufEnter() end,
    ['ModeChanged'] = function() self:handle_ModeChanged() end,
    ['BufWinLeave'] = function() self:handle_BufWinLeave() end
  }

  ---@param event string
  local function trigger(event)
    if log_to_file then
      Logger:write_to_file()
    end

    self.nekovim:restart_idle_timer()
    events[event]()
  end

  for event in pairs(events) do
    VimUtils.CreateAutoCmd(event, function() trigger(event) end)
  end
end

function EventHandlers:handle_ModeChanged()
  self.nekovim.buffers_props[self.nekovim.current_buf].mode = VimUtils.GetMode()
  self.nekovim:update()
end

function EventHandlers:handle_BufEnter()
  self.nekovim.current_buf = vim.api.nvim_get_current_buf()
  self.nekovim:make_buf_props()
  self.nekovim:update()
end

function EventHandlers:handle_BufWinLeave()
	self.nekovim.buffers_props[self.nekovim.current_buf] = nil
end

return EventHandlers
