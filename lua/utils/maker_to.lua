---@param self NekoVim
---@param maker (fun(self: NekoVim): string)|string
---@return string?
function Maker_tostring(maker, self)
  if type(maker) == 'function' then
    local res = maker(self)

    if type(res) == 'string' then
      return res
    end
  elseif type(maker) == 'string' then
    return maker
  end

  return nil
end

---@param self NekoVim
---@param maker (fun(self: NekoVim): integer)|integer
---@return integer?
function Maker_tonumber(maker, self)
  if type(maker) == 'function' then
    local res = maker(self)

    if type(res) == 'number' then
      return res
    end
  elseif type(maker) == 'number' then
    return maker
  end

  return nil
end

---@param self NekoVim
---@param maker (fun(self: NekoVim): table)|table
---@return table?
function Maker_totable(maker, self)
  if type(maker) == 'function' then
    local res = maker(self)

    if type(res) == 'table' then
      return res
    end
  elseif type(maker) == 'table' then
    return maker
  end

  return nil
end
