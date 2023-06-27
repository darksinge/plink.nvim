local async = require('plenary.async')
local api = require('plink.api')
local util = require('plink.util')
local log = reload 'plink.log'
-- local plugin_finder = require('plink.telescope')

local M = {}

local DELAY = 500
local TRACE_PREFIX = '#plink'

local search_async = async.wrap(function(query, callback)
  callback(M.search(query))
end, 2)

local async_runner, timer = util.debounce(search_async, DELAY)

---@generic T : any
---@param query string
---@param callback fun(value: T[]): nil
---@return nil
M.search_async = function(query, callback)
  log.trace('search_async = ' .. query)
  if type(query) ~= 'string' then
    return nil
  end

  async_runner(query, function(plugins)
    local count = plugins and #plugins or 0
    log.trace('query "' .. query .. '"' .. ' returned ' .. count .. ' results')
    callback(plugins)
    timer:stop()
  end)
end

---@param query string
M.search = function(query)
  return util.time(
    api.search,
    {
      name = TRACE_PREFIX .. '.search("' .. query .. '")',
      level = 'trace',
    },
    query
  )
end

return M
