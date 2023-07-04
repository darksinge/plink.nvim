local async = require('plenary.async')
local api = reload('plink.api')
local util = require('plink.util')
local log = reload 'plink.log'

local M = {}

local DELAY = 500
local TRACE_PREFIX = '#plink'

local search_async = async.wrap(function(query, callback)
  callback(M.search(query))
end, 2)

local async_runner, timer = util.debounce(search_async, DELAY)

local base_url = 'https://3051j7te1j.execute-api.us-east-1.amazonaws.com'

---@generic T : any
---@param query string
---@param handler fun(value: T[]): nil
---@return nil
M.search_async = function(query, handler)
  log.trace('search_async = ' .. query)
  if type(query) ~= 'string' then
    return nil
  end

  api.search_job(query, handler)
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

M.fake_search = function(_, handler)
  api.fake_search(_, handler)
end

return M
