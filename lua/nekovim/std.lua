require 'lib.str_utils'

ScriptPath = debug.getinfo(1, 'S').source:sub(2)

do
  local f = assert(io.popen('ls lua/deps'))
  local deps = f:read('*a'):split '\n'

  for _, dep in ipairs(deps) do
    local path = 'lua/deps/' .. dep .. '/?.lua'
    package.path = package.path .. ';' .. path
  end
end

---@param original table
---@return table
function TableCopy(original)
  local copy = {}

  for key, value in pairs(original) do
    copy[key] = value
  end

  return copy
end

---@param target table
---@param ... table
---@return table
function JoinTables(target, ...)
  target = TableCopy(target)

  for _, source in ipairs({...}) do
    for key, val in pairs(source) do
      if type(target[key]) == 'table' and type(source[key]) == 'table' then
        target[key] = JoinTables(target[key], val)
      else
        target[key] = val
      end
    end
  end

  return target
end
