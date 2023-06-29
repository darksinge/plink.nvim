local M = {}

M.clear_autocmds = vim.api.nvim_clear_autocmds

M.create_augroup = vim.api.nvim_create_augroup

M.create_autocmd = vim.api.nvim_create_autocmd

M.del_augroup_by_id = vim.api.nvim_del_augroup_by_id

M.del_augroup_by_name = vim.api.nvim_del_augroup_by_name

M.del_autocmd = vim.api.nvim_del_autocmd

M.exec_autocmds = vim.api.nvim_exec_autocmds

M.get_autocmds = vim.api.nvim_get_autocmds

return M
