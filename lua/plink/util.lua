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


local function td_validate(fn, ms)
  vim.validate {
    fn = { fn, "f" },
    ms = {
      ms,
      function(v)
        return type(v) == "number" and v > 0
      end,
      "number > 0",
    },
  }
end

-- local debounce_timer = vim.loop.new_timer()
-- assert(debounce_timer, 'failed to create debounce_timer')
--- Debounces a function on the trailing edge. Automatically
--- `schedule_wrap()`s.
---
--@param fn (function) Function to debounce
--@param timeout (number) Timeout in ms
--@param first (boolean, optional) Whether to use the arguments of the first
---call to `fn` within the timeframe. Default: Use arguments of the last call.
--@returns (function, timer) Debounced function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function M.debounce(fn, ms, first)
  td_validate(fn, ms)
  local timer = vim.loop.new_timer()
  assert(timer)
  local wrapped_fn

  if not first then
    function wrapped_fn(...)
      local argv = { ... }
      local argc = select("#", ...)

      timer:start(ms, 0, function()
        pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
      end)
    end
  else
    local argv, argc
    function wrapped_fn(...)
      argv = argv or { ... }
      argc = argc or select("#", ...)

      timer:start(ms, 0, function()
        pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
      end)
    end
  end
  return wrapped_fn, timer
end

return M
