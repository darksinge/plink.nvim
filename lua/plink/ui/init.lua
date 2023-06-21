local input = require('plink.ui.input')
local event = require('nui.utils.autocmd').event
local search = require('plink.search')

local M = {}

-- local function handle_data(plugins)
--   if plugins then
--     print('fetched ' .. #plugins .. ' plugins')
--   end
-- end

-- local function on_submit(value)
--   search.search_async(value, handle_data)
-- end

-- local function on_change(value)
--   -- search_async is debounced, so this is okay
--   search.search_async(value, handle_data)
-- end

-- M._input = input.create({ on_submit = on_submit, on_change = on_change })

-- M.open = function()
--   M._input:mount()
--   M._input:on(event.BufLeave, function()
--     M._input:unmount()
--   end)
-- end

-- M.hide = function()
--   M._input:hide()
-- end

-- M.show = function()
--   M._input:show()
-- end

-- M.open()

return M
