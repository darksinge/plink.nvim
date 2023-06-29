local M = {}

M.current = vim.api.nvim_get_current_tabpage

M.list = vim.api.nvim_list_tabpages

M.set_current = vim.api.nvim_set_current_tabpage

M.del_var = vim.api.nvim_tabpage_del_var

M.get_number = vim.api.nvim_tabpage_get_number

M.get_var = vim.api.nvim_tabpage_get_var

M.get_win = vim.api.nvim_tabpage_get_win

M.is_valid = vim.api.nvim_tabpage_is_valid

M.list_wins = vim.api.nvim_tabpage_list_wins

M.set_var = vim.api.nvim_tabpage_set_var

return M
