---@class PresenceMakersAssets : PresenceAssets
---@field large_image? (fun(self: NekoVim): string?)|string
---@field large_text?  (fun(self: NekoVim): string?)|string
---@field small_image? (fun(self: NekoVim): string?)|string
---@field small_text?  (fun(self: NekoVim): string?)|string

---@class PresenceMakersTimestamps : PresenceTimestamps
---@field start? (fun(self: NekoVim): integer?)|integer
---@field end?   (fun(self: NekoVim): integer?)|integer

---@class PresenceMakers : Presence
---@field state?      (fun(self: NekoVim): string?)|string
---@field details?    (fun(self: NekoVim): string?)|string
---@field timestamps? PresenceMakersTimestamps
---@field assets?     PresenceMakersAssets
---@field buttons?    ((fun(self: NekoVim): PresenceButton?)|PresenceButton)[]
