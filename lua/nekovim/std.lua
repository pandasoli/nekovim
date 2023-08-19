require 'utils.str_utils'

ScriptPath = debug.getinfo(1, 'S').source:sub(2)
package.path = package.path .. ';' .. ScriptPath:match '(.*)/.*/' .. '/deps/?.lua'

---@param val table
---@return boolean
local function isArray(val)
  local count = 1

  for key, _ in pairs(val) do
    if key ~= count then return false end
    count = count + 1
  end

  return true
end

---@param original table
---@return table
local function copyTable(original)
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
  target = copyTable(target)

  for _, source in ipairs({...}) do
    for key, val in pairs(source) do
      if
        type(target[key]) == 'table' and type(val) == 'table' and
        not isArray(target[key]) and not isArray(val)
      then
        target[key] = JoinTables(target[key], val)
      else
        target[key] = val
      end
    end
  end

  return target
end
