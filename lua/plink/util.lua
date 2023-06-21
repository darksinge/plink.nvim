local log = require 'plink.log'

local M = {}

local loggers = {}
for _, mode in pairs(log.modes) do
  loggers[mode.name] = log[mode.name]
end

---@param level string|nil
---@return function<string>
local get_logger = function(level)
  if not level or not loggers[level] then
    level = log.level
  end

  return loggers[level] or log.trace
end

M.assert_type = function(values, expected_type)
  for key, value in pairs(values) do
    local t = type(value)
    assert(t == expected_type, 'expected "' .. key .. '" to be a ' .. expected_type .. ', got ' .. t .. ' instead')
  end
end

---time how long it takes `fn` to run
---@param fn function
---@param opts {name: string|nil, level: string|nil}|nil
---@param ... any
---@return unknown
M.time = function(fn, opts, ...)
  opts = opts or {}
  local logger = get_logger(opts.level)
  local name = opts.name or 'fn'

  logger('invoke: ' .. name)
  local start = os.clock()
  local result = fn(...)
  local stop = os.clock()
  local time = (stop - start)
  logger(name .. ' time: ' .. time .. 's')

  return result
end

return M
