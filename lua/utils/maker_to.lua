---@param self NekoVim
---@param maker (fun(self: NekoVim): string)|string
---@return string?
function Maker_tostring(maker, self)
  local res = type(maker) == 'function' and maker(self) or maker

  if type(res) == 'string' and #res > 0 then
    return res
  end
end

---@param self NekoVim
---@param maker (fun(self: NekoVim): integer)|integer
---@return integer?
function Maker_tonumber(maker, self)
  local res = type(maker) == 'function' and maker(self) or maker

  if type(res) == 'number' and res ~= 0 then
    return res
  end
end

---@param self NekoVim
---@param maker (fun(self: NekoVim) : boolean)|boolean
---@return boolean?
function Maker_toboolean(maker, self)
  local res = type(maker) == 'function' and maker(self) or maker
  return not not res
end

---@param self NekoVim
---@param maker (fun(self: NekoVim): table)|table
---@return table?
function Maker_totable(maker, self)
  local res = type(maker) == 'function' and maker(self) or maker

  if type(res) == 'table' and #res > 0 then
    return res
  end
end
