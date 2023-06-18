local M = {}

M.assert_type = function(values, expected_type)
  for key, value in pairs(values) do
    local t = type(value)
    assert(t == expected_type, 'expected "' .. key .. '" to be a ' .. expected_type .. ', got ' .. t .. ' instead')
  end
end

return M
