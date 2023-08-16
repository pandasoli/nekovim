---@param str string
---@param sep string
---@return string[]
function string.split(str, sep)
  sep = sep or '%s'

  ---@type string[]
  local res = {}

  for part in string.gmatch(str, '([^'..sep..']+)') do
    table.insert(res, part)
  end

  return res
end
