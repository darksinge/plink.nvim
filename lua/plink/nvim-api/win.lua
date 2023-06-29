local M = {}

M.call = vim.api.nvim_win_call

M.close = vim.api.nvim_win_close

M.del_var = vim.api.nvim_win_del_var

M.get_buf = vim.api.nvim_win_get_buf

M.get_config = vim.api.nvim_win_get_config

M.get_cursor = vim.api.nvim_win_get_cursor

M.get_height = vim.api.nvim_win_get_height

M.get_number = vim.api.nvim_win_get_number

M.get_option = vim.api.nvim_win_get_option

M.get_position = vim.api.nvim_win_get_position

M.get_tabpage = vim.api.nvim_win_get_tabpage

M.get_var = vim.api.nvim_win_get_var

M.get_width = vim.api.nvim_win_get_width

M.hide = vim.api.nvim_win_hide

M.is_valid = vim.api.nvim_win_is_valid

M.set_buf = vim.api.nvim_win_set_buf

M.set_config = vim.api.nvim_win_set_config

M.set_cursor = vim.api.nvim_win_set_cursor

M.set_height = vim.api.nvim_win_set_height

M.set_hl_ns = vim.api.nvim_win_set_hl_ns

M.set_option = vim.api.nvim_win_set_option

M.set_var = vim.api.nvim_win_set_var

M.set_width = vim.api.nvim_win_set_width

M.set_current = vim.api.nvim_set_current_win

M.list = vim.api.nvim_list_wins

M.open = vim.api.nvim_open_win

return M
