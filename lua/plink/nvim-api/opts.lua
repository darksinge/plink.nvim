local M = {}

M.get_all_options_info = vim.api.nvim_get_all_options_info

M.get_option = vim.api.nvim_get_option

M.get_option_info = vim.api.nvim_get_option_info

M.get_option_info2 = vim.api.nvim_get_option_info2

M.get_option_value = vim.api.nvim_get_option_value

M.get_var = vim.api.nvim_get_var

M.get_vvar = vim.api.nvim_get_vvar

M.set_option = vim.api.nvim_set_option

M.set_option_value = vim.api.nvim_set_option_value

M.set_var = vim.api.nvim_set_var

M.set_vvar = vim.api.nvim_set_vvar

return M
