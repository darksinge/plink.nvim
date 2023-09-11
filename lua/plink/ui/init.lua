local SearchLayout = require('plink.ui.component.search_layout')
local Config = require('plink.config')
local Manager = require('plink.manager')

local M = {}

function M.force_close(layout)
  if not layout then
    return
  end

  local did_unmount = pcall(layout.unmount, layout)
  if did_unmount then
    return
  end

  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(winid) then
      local var_ok, is_plink_component = pcall(vim.api.nvim_win_get_var, winid, 'is_plink_window')
      if var_ok and is_plink_component == true then
        pcall(vim.api.nvim_win_close, winid, true)
      end
    end
  end
end

---@param opts? ManagerOpts
M.open = function(opts)
  opts = opts or {}
  local manager = Manager(opts)
  local layout = SearchLayout()
  manager:load_plugin_list()
  layout:mount()
  local plugins = {}
  for _, name in ipairs(manager.plugins) do
    table.insert(plugins, name.name)
  end
  layout.output:display_installed(plugins)
end

M.open()

return M
