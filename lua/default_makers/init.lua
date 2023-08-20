local assets = require 'default_makers.assets'


---@type PresenceMakers
local makers = {
  timestamps = {
    start = function(self)
      return self.presence_props.startTimestamp
    end
  },

  assets = {
    large_image = function(self)
      if self.presence_props.idling then
        return 'keyboard'
      end

      local props = self.buffer_props
      local asset = assets:test(props.filePath, props.fileType)
      return asset.key
    end,
    large_text = function(self)
      local props = self.buffer_props
      local asset = assets:test(props.filePath, props.fileType)
      return 'Editing ' .. asset.name .. ' file'
    end,
    small_image = function(self)
      if self.presence_props.idling then
        return 'idle'
      end

      return'lunarvim'
    end,
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
  end,

  buttons = {
    function()
      local f = assert(io.popen('git remote -v 2> /dev/null'))
      local output = assert(f:read('*a'))
      f:close()

      local err_msg = 'fatal: not a git repository'
      if output:sub(1, #err_msg) == err_msg then
        return
      end

      local repo = output:match '[:/]([%w-]+/[%w-]+)'
      if repo then
        return { label = 'GitHub repo', url = 'https://github.com/' .. repo }
      end
    end
  }
}

---@type WorkPropsMakers
local props = {
  client_id = '1059272441194623126',
  multiple = true,
  events = true
}

return {
  makers = makers,
  props = props
}
