---@class Logger
---@field logs string[]
local Log = {
  logs = {}
}

---@param from string
---@param ... any
function Log:log(from, ...)
  local msg = ''

  for _, arg in ipairs({...}) do
    msg = msg .. ' ' .. tostring(arg)
  end

  local time = os.date('%dd %H:%M:%S')

  table.insert(
    self.logs,
    string.format('%s [%s]:%s', from, time, msg)
  )
end

-- Join all logs
---@return string
function Log:tostring()
  local result = ''

  for _, log in ipairs(self.logs) do
    result = result .. log .. '\n'
  end

  return result
end

function Log:print()
  print(self:tostring())
end

-- Write logs to ./nekovim.log
function Log:write_to_file()
  local file = 'nekovim.log'

  os.remove(file)

  local f = assert(io.open(file, 'w'))
  f:write(self:tostring())
  f:close()
end

return Log
