local assets = require 'default_makers.assets'


---@type PresenceMakers
local makers = {
  client_id = '1059272441194623126',

  timestamps = {
    start = function(self)
      return self.presence_props.startTimestamp
    end
  },

  assets = {
    large_image = function(self)
      local props = self.buffer_props
      local asset = assets:test(props.filePath, props.fileType)
      return asset.key
    end,
    large_text = function(self)
      local props = self.buffer_props
      local asset = assets:test(props.filePath, props.fileType)
      return 'Editing ' .. asset.name .. ' file'
    end,
    small_image = 'lunarvim',
    small_text = 'LunarVim'
  },

  state = function(self)
    return 'Working on ' .. self.buffer_props.repoName
  end,

  details = function(self)
    local props = self.buffer_props
    local asset = assets:test(props.filePath, props.fileType)

    if asset.type == 'file explorer' then
      return 'Browsing between files...'
    elseif asset.type == 'plugin manager' then
      return 'Managing ' .. asset.name .. ' plugins...'
    end

    local mode = props.mode or 'n'
    local fileName = props.fileName or 'unknown'

    if mode == 'i' then
      return 'Editing ' .. fileName
    elseif mode == 'v' then
      return 'Selecting things in ' .. fileName
    elseif mode == 'n' then
      return 'Looking at ' .. fileName
    elseif mode == 'c' then
      return 'Typing vim command'
    else
      return 'Doing stuff for ' .. fileName .. ' in ' .. mode .. ' mode'
    end
  end
}

return makers
