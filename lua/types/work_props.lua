---@class WorkProps
---@field client_id? string
---@field multiple?  boolean

---@class WorkPropsMakers : WorkProps
---@field client_id? (fun(): string)|string
---@field mutliple?  (fun(): boolean)|boolean # Deal with multiple instances
