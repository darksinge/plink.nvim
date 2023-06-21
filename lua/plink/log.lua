local Log = require('plenary.log')

local DEFAULT_LOG_LEVEL = 'info'

local function get_level()
  local level = vim.fn.getenv('LOG_LEVEL')
  if level == vim.NIL then
    return DEFAULT_LOG_LEVEL
  end
  return level
end

return Log.new({
  plugin = 'plink',
  level = get_level(),
})
