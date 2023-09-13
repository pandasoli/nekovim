local VimUtils = {}

---@return string
function VimUtils.GetCWD()
  return vim.fn.getcwd()
end

---@return string|nil
function VimUtils.GetBufName()
  local buf = vim.api.nvim_get_current_buf()

  ---@type string|nil
  local name = vim.api.nvim_buf_get_name(buf)
  name = name ~= '' and name or nil

  return name
end

---@return string
function VimUtils.GetMode()
  return vim.api.nvim_get_mode().mode
end

---@return string|nil
function VimUtils.GetFileType()
  ---@type string|nil
  local type = vim.bo.filetype
  type = type ~= '' and type or nil

  return type
end

---@param event string
---@param callback function
function VimUtils.CreateAutoCmd(event, callback)
  vim.api.nvim_create_autocmd(event, {
    callback = callback
  })
end

---@param name string
---@param value any
function VimUtils.SetVar(name, value)
  vim.api.nvim_set_var(name, value)
end

---@param name string
---@param command string|function
---@param opts? table<string, any>
function VimUtils.CreateUserCommand(name, command, opts)
  vim.api.nvim_create_user_command(name, command, opts)
end

return VimUtils
