local M = {}

local DEFAULT_DELAY = 300

---@param fn function
---@param delay number | nil
---@return function
M.create_debounce = function(fn, delay)
  delay = delay or DEFAULT_DELAY
  local timer = vim.loop.new_timer()
  assert(timer)
  return function(args, callback)
    timer:stop()
    timer:start(delay, 0, vim.schedule_wrap(function()
      callback(args)
    end))
  end
end

M.new_timer = function()
  local timer = vim.loop.new_timer()
  assert(timer)
  return timer
end

M.assert_type = function(values, expected_type)
  for key, value in pairs(values) do
    local t = type(value)
    assert(t == expected_type, 'expected "' .. key .. '" to be a ' .. expected_type .. ', got ' .. t .. ' instead')
  end
end

return M
