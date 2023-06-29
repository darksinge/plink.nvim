local nvim = reload('plink.nvim-api')
local SearchLayout = reload('plink.ui.component.search_layout')
local Config = require('plink.config')

local M = {}

local layout = nil

function M.force_close()
  if not layout then
    return
  end

  local did_unmount = pcall(layout.unmount, layout)
  if did_unmount then
    return
  end

  for _, winid in ipairs(nvim.tabpage.list_wins(0)) do
    if nvim.win.is_valid(winid) then
      local var_ok, is_plink_component = pcall(nvim.win.get_var, winid, 'is_plink_window')
      if var_ok and is_plink_component == true then
        pcall(nvim.win.close, winid, true)
      end
    end
  end
end

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

