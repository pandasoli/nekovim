---@param data string
---@param callback fun(success: boolean, response: table?)
function DecodeJSON(data, callback)
  vim.schedule(function()
    callback(pcall(function()
      return vim.fn.json_decode(data)
    end))
  end)
end

---@param data any
---@param callback fun(body: string)
function EncodeJSON(data, callback)
  vim.schedule(function()
    local body = vim.fn.json_encode(data)
    callback(body)
  end)
end
