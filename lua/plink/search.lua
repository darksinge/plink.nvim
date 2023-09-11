local async = require('plenary.async')
local api = require('plink.api')
local util = require('plink.util')
local log = require('plink.log')

local M = {}

local DELAY = 250
local TRACE_PREFIX = '#plink'

local search_async = async.wrap(api.search_job, 2)
local search_async_debounced, debounce_timer = util.debounce(search_async, DELAY)

---@generic T : any
---@param query string
---@param handler fun(value: T[]): nil
---@return nil
M.search_async = function(query, handler)
  log.trace('search_async = ' .. query)
  if type(query) ~= 'string' or #query <= 2 then
    return
  end

  search_async_debounced(query, function(results)
    debounce_timer:stop()
    handler(results)
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
