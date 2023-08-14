local Logger = require 'lib.log'


-- Check if the presence makers is complete (has all expected fields)
---@param makers PresenceMakers
---@return boolean is_complete
function CheckPresenceMakers(makers)
  local checks = {
    ['mackers'] = 'table',

    ['mackers.state'] = 'function',
    ['mackers.details'] = 'function',

    ['mackers.timestamps'] = 'table',
    ['mackers.timestamps.start'] = 'function',
    ['mackers.timestamps.end'] = 'function',

    ['mackers.assets'] = 'table',
    ['mackers.assets.large_image'] = 'function',
    ['mackers.assets.large_text'] = 'function',
    ['mackers.assets.small_image'] = 'function',
    ['mackers.assets.small_text'] = 'function',
  }

  ---@param table table
  ---@param path string
  ---@return boolean success
  local function check_table(table, path)
    if type(table) ~= checks[path] then
      Logger:log('CheckActivityMakers', 'makers.'..path..' ~= '..checks[path])
      return false
    elseif type(table) == 'table' then
      for key, value in pairs(table) do
        local success = check_table(value, path..'.'..key)
        if not success then return false end
      end
    end

    return true
  end

  local success = check_table(makers, 'mackers')
  if not success then return false end

  -- Check buttons
  if type(makers.buttons) ~= 'table' then
    Logger:log('CheckActivityMakers', 'makers.buttons ~= table')
    return false
  end

  for i, maker in ipairs(makers.buttons) do
    if type(maker) ~= 'function' then
      Logger:log('CheckActivityMakers', 'makers.buttons['..i..'] ~= function')
      return false
    end
  end

  return true
end
