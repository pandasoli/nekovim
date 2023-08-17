---@alias LogLevel 'debug'|'info'|'warn'|'error'

---@class Log
---@field level LogLevel
---@field from string
---@field time string
---@field msg string

---@class Logger
---@field logs Log[]
local Log = {
  logs = {},
  levels = {
    debug = 'Comment',
    info = 'None',
    warn = 'WarningMsg',
    error = 'ErrorMsg'
  }
}

---@private
---@param level LogLevel
---@param from string
---@param ... any
function Log:log(level, from, ...)
  local msg = ''
  local time = os.date('%dd %H:%M:%S')

  for i, arg in ipairs({...}) do
    if i > 0 then msg = msg .. ' ' end
    msg = msg .. tostring(arg)
  end

  local log = {
    level = level,
    from = from,
    time = time,
    msg = msg
  }

  table.insert(self.logs, log)
end

---@param from string
---@param ... any
function Log:debug(from, ...) self:log('debug', from, ...) end

---@param from string
---@param ... any
function Log:info(from, ...) self:log('info', from, ...) end

---@param from string
---@param ... any
function Log:warn(from, ...) self:log('warn', from, ...) end

---@param from string
---@param ... any
function Log:error(from, ...) self:log('error', from, ...) end


function Log:print()
  for _, log in ipairs(self.logs) do
    local level = self.levels[log.level]

    vim.api.nvim_echo({
      {log.from .. ' [', level},
      {log.time, 'Identifier'},
      {']: ' .. log.msg, level}
    }, true, {})
  end
end

-- Write logs to ./nekovim.log
function Log:write_to_file()
  local file = 'nekovim.log'
  local logs = ''

  for i, log in ipairs(self.logs) do
    if i > 0 then logs = logs .. '\n' end
    local str = string.format('%s [%s]: %s', log.from, log.time, log.msg)
    logs = logs .. str
  end

  os.remove(file)

  local f = assert(io.open(file, 'w'))
  f:write(logs)
  f:close()
end

return Log
