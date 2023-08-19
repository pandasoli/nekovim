---@class WorkProps
---@field client_id? string
---@field multiple?  boolean
---@field events?    boolean

---@class WorkPropsMakers : WorkProps
---@field client_id? (fun(): string)|string
---@field mutliple?  (fun(): boolean)|boolean # Deal with multiple instances
---@field events?    (fun(): boolean)|boolean # Active vim update events
