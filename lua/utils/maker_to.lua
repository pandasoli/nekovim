---@param self NekoVim
---@param maker (fun(self: NekoVim): string)|string
---@return string?
function Maker_tostring(maker, self)
  if type(maker) == 'function' then
    local res = maker(self)

    if type(res) == 'string' and #res > 0 then
      return res
    end
  elseif type(maker) == 'string' and #maker > 0 then
    return maker
  end
end

---@param self NekoVim
---@param maker (fun(self: NekoVim): integer)|integer
---@return integer?
function Maker_tonumber(maker, self)
  if type(maker) == 'function' then
    local res = maker(self)

    if type(res) == 'number' and res ~= 0 then
      return res
    end
  elseif type(maker) == 'number' and maker ~= 0 then
    return maker
  end
end

---@param self NekoVim
---@param maker (fun(self: NekoVim) : boolean)|boolean
---@return boolean?
function Maker_toboolean(maker, self)
  if type(maker) == 'function' then
    local res = maker(self)

    if type(res) == 'boolean' then
      return res
    end
  elseif type(maker) == 'boolean' then
    return maker
  end
end

---@param self NekoVim
---@param maker (fun(self: NekoVim): table)|table
---@return table?
function Maker_totable(maker, self)
  if type(maker) == 'function' then
    local res = maker(self)

    if type(res) == 'table' and #res > 0 then
      return res
    end
  elseif type(maker) == 'table' and #maker > 0 then
    return maker
  end
end
