---@param seed? number
function Generate_uuid(seed)
  local index = 0
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

  local uuid = template:gsub('[xy]', function(char)
    -- Increment an index to seed per char
    index = index + 1
    math.randomseed((seed or os.clock()) / index)

    local n = char == 'x'
      and math.random(0, 0xf)
      or math.random(8, 0xb)

    return string.format('%x', n)
  end)

  return uuid
end
