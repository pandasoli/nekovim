---@param data table
---@return boolean
local function IsArray(data)
  local count = 0

  for key, _ in pairs(data) do
    if type(key) ~= 'number' then return false end

    count = count + 1
    if key ~= count then return false end
  end

  return true
end

---@param list table
---@return string
function ListToArgv(list)
  local function convert_data(data)
    if
      type(data) == 'nil'
      or type(data) == 'boolean'
      or type(data) == 'number'
    then
      return tostring(data)
    elseif type(data) == 'string' then
      local str = data
        :gsub('"', '\\"')
        :gsub('\n', '\\n')
        :gsub('\r', '\\r')
        :gsub('\t', '\\t')
        :gsub('\027', '\\027')

      return '"' .. str .. '"'
    elseif type(data) == 'table' then
      local res = '{'
      local lkeys = 1

      for _, _ in pairs(data) do lkeys = lkeys + 1 end

      if IsArray(data) then
        for i, v in ipairs(data) do
          res = res .. convert_data(v)
          if i < lkeys - 1 then res = res .. ', ' end
        end
      else
        local i = 1

        for k, v in pairs(data) do
          res = res
            .. ('[' .. convert_data(tostring(k)) .. '] = ')
            .. convert_data(v)

          if i < lkeys - 1 then res = res .. ', ' end
          i = i + 1
        end
      end

      return res .. '}'
    end

    return 'nil'
  end

  local res = ''

  for i, val in ipairs(list) do
    res = res .. convert_data(val)
    if i < #list then res = res .. ', ' end
  end

  return res
end
