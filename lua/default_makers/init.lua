local assets = require 'default_makers.assets'

---@class GitRepositoryMetadata
---@field owner string
---@field name string
---@field url string

---@return GitRepositoryMetadata?
local function getGitRepository()
  local f = io.popen('git remote get-url origin 2>/dev/null', 'r')
  if not f then return end

  local url = f:read('*a')
  local ok, _, status = f:close()

  if not ok or status ~= 0 or not url or url == '' then
    return
  end

  local owner, name = url:match '.*[:/]([^/]+)/(.*)'

  return {
    owner = owner,
    name = name,
    url = url
  }
end


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

      local props = self.buffers_props[self.current_buf]
      local asset = assets:test(props.filePath, props.fileType)
      return asset.key
    end,
    large_text = function(self)
      if self.presence_props.idling then return end

      local props = self.buffers_props[self.current_buf]
      local asset = assets:test(props.filePath, props.fileType)
      return 'Editing ' .. asset.name .. ' file'
    end,
    small_image = function(self)
      if self.presence_props.idling then
        return 'idle'
      end
    end,
    -- small_text = function(self)
    --   if self.presence_props.idling then return end
    --   return 'NeoVim'
    -- end
  },

  state = function(self)
    if self.presence_props.idling then return end

    local repo = getGitRepository()
    if not repo then return end

    return 'Working on '..repo.name
  end,

  details = function(self)
    if self.presence_props.idling then
      return 'Sleeping on the keyboard...'
    end

    local props = self.buffers_props[self.current_buf]
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
      local repo = getGitRepository()
      if not repo then return end

      return {
        label = 'Repository',
        url = repo.url
      }
    end
  }
}

---@type WorkPropsMakers
local props = {
  client_id = '1059272441194623126',
  multiple = true,
  events = true,
  idle_time = 120 -- 120s = 2m
}

return {
  makers = makers,
  props = props
}
