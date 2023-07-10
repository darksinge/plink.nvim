local nvim = reload('plink.nvim-api')
local SearchLayout = reload('plink.ui.component.search_layout')
local Config = require('plink.config')

local M = {}

local layout = nil


function M.open()
  if not layout then
    layout = SearchLayout()
  end

  if layout and layout._.mounted then
    return
  end

  layout:mount()


  if Config.options.keymaps.close then
    vim.keymap.set('n', Config.options.keymaps.close, function()
      pcall(layout.unmount, layout)
    end, {
      silent = true,
      noremap = true,
    })
  end

  if Config.options.keymaps.force_close then
    vim.keymap.set('n', Config.options.keymaps.force_close, M.force_close, {
      silent = true,
      noremap = true,
    })
  end
end

return M
