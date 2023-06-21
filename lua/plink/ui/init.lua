local input = require('plink.ui.input')
local event = require('nui.utils.autocmd').event
local search = require('plink.search')

local M = {}

local on_submit = function(value)
  search.search_async(value, function(plugins)
    if plugins then
      print('fetched ' .. #plugins .. ' plugins')
    end
  end)
end

M._input = input.create({ on_submit = on_submit })

M.open = function()
  M._input:mount()
  M._input:on(event.BufLeave, function()
    M._input:unmount()
  end)
end

M.hide = function()
  M._input:hide()
end

M.show = function()
  M._input:show()
end

M.open()

return M
