local finder = require('plink.telescope')
local search = require('plink.search')


local M = {}

---@param opts { delay: number } | nil
M.setup = function(opts)
  -- TODO: add setup
  -- opts = opts or {}
  -- if opts.delay then
  --   delay = opts.delay
  -- end

  -- TODO: Should this go in plugin/plink.lua?
  vim.cmd([[sign define plink-search text= texthl=Pmenu]])
end

M.search = search.search
M.search_async = search.search_async
M._finder = finder -- probably need to get rid of this

return M
