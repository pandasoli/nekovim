setmetatable(string, {
  __index = {
    split = function(str, sep)
      local result = {}
      local pattern = string.format('([^%s]+)', sep)

      str:gsub(pattern, function(match)
        table.insert(result, match)
      end)

      return result
    end
  }
})
