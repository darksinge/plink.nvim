local async = require('plenary.async')
local debounce = require('telescope.debounce').debounce_trailing
local api = require('plink.api')
local util = require('plink.util')
local log = reload 'plink.log'
-- local plugin_finder = require('plink.telescope')

local M = {}

local delay = 500
local trace_name = '#plink'

local search_async = async.wrap(function(query, callback)
  callback(api.search(query))
end, 2)

---@param query string
---@return nil
M.search_async = function(query)
  log.trace('search_async = ' .. query)
  if type(query) ~= 'string' then
    return nil
  end

  local run_async, timer = debounce(async.run, delay)

  run_async(function()
    search_async(query, function(plugins)
      return plugins
    end)
  end, function()
    log('successfully fetched query "' .. query .. '"')
    if timer then
      timer:stop()
    end
  end)
end

---@param query string
M.search = function(query)
  return util.time(
    api.search,
    {
      name = trace_name .. '.search("' .. query .. '")',
      level = 'info',
    },
    query
  )
end

return M
