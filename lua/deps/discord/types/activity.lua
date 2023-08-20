---@class PresenceTimestamps
---@field start? integer
---@field end? integer

---@class PresenceAssets
---@field large_image? string
---@field large_text?  string
---@field small_image? string
---@field small_text?  string

---@class PresenceButton
---@field label string
---@field url   string

---@class Presence
---@field state?      string
---@field details?    string
---@field timestamps? PresenceTimestamps
---@field assets?     PresenceAssets
---@field buttons?    PresenceButton[]
