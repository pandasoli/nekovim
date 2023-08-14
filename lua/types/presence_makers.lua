---@class PresenceMakersAssets : PresenceAssets
---@field large_image fun(self: NekoVim)
---@field large_text  fun(self: NekoVim)
---@field small_image fun(self: NekoVim)
---@field small_text  fun(self: NekoVim)

---@class PresenceMakersTimestamps : PresenceTimestamps
---@field start fun(self: NekoVim)
---@field end   fun(self: NekoVim)

---@class PresenceMakers : Presence
---@field app_id  string
---
---@field state   fun(self: NekoVim)
---@field details fun(self: NekoVim)
---@field assets  PresenceMakersAssets
---@field buttons fun(self: NekoVim)[]
