---@class BufferPropsRepo
---@field owner string
---@field name  string

---@class BufferProps
---@field mode          'n'|'i'|'v'|'c'|'R'|string
---@field repo          BufferPropsRepo
---@field fileName      string?
---@field filePath      string?
---@field fileType      string?
---@field fileExtension string?

---@class BuffersProps
---@field [number] BufferProps
