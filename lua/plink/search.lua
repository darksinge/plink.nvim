local async = require('plenary.async')
local api = require('plink.api')
local util = require('plink.util')
local log = reload 'plink.log'
-- local plugin_finder = require('plink.telescope')

local M = {}

local delay = 500
local trace_name = '#plink'

local search_async = async.wrap(function(query, callback)
  callback(M.search(query))
end, 2)

local runner, timer = util.debounce(function(query, callback)
  search_async(query, callback)
end, delay)

---@param query string
---@return nil
M.search_async = function(query, callback)
  log.trace('search_async = ' .. query)
  if type(query) ~= 'string' then
    return nil
  end

  runner(query, function(plugins)
    local count = plugins and #plugins or 0
    log.trace('query "' .. query .. '"' .. ' returned ' .. count .. ' results')
    timer:stop()
    callback(plugins)
  end)
end

---@param query string
M.search = function(query)
  return util.time(
    api.search,
    {
      name = trace_name .. '.search("' .. query .. '")',
      level = 'trace',
    },
    query
  )
end

return M
