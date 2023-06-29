local M = {}

M.add_highlight = vim.api.nvim_buf_add_highlight

M.attach = vim.api.nvim_buf_attach

M.call = vim.api.nvim_buf_call

M.clear_namespace = vim.api.nvim_buf_clear_namespace

M.create_user_command = vim.api.nvim_buf_create_user_command

M.del_extmark = vim.api.nvim_buf_del_extmark

M.del_keymap = vim.api.nvim_buf_del_keymap

M.del_mark = vim.api.nvim_buf_del_mark

M.del_user_command = vim.api.nvim_buf_del_user_command

M.del_var = vim.api.nvim_buf_del_var

M.delete = vim.api.nvim_buf_delete

M.get_changedtick = vim.api.nvim_buf_get_changedtick

M.get_commands = vim.api.nvim_buf_get_commands

M.get_extmark_by_id = vim.api.nvim_buf_get_extmark_by_id

M.get_extmarks = vim.api.nvim_buf_get_extmarks

M.get_keymap = vim.api.nvim_buf_get_keymap

M.get_lines = vim.api.nvim_buf_get_lines

M.get_mark = vim.api.nvim_buf_get_mark

M.get_name = vim.api.nvim_buf_get_name

M.get_offset = vim.api.nvim_buf_get_offset

M.get_option = vim.api.nvim_buf_get_option

M.get_text = vim.api.nvim_buf_get_text

M.get_var = vim.api.nvim_buf_get_var

M.is_loaded = vim.api.nvim_buf_is_loaded

M.is_valid = vim.api.nvim_buf_is_valid

M.line_count = vim.api.nvim_buf_line_count

M.set_extmark = vim.api.nvim_buf_set_extmark

M.set_keymap = vim.api.nvim_buf_set_keymap

M.set_lines = vim.api.nvim_buf_set_lines

M.set_mark = vim.api.nvim_buf_set_mark

M.set_name = vim.api.nvim_buf_set_name

M.set_option = vim.api.nvim_buf_set_option

M.set_text = vim.api.nvim_buf_set_text

M.set_var = vim.api.nvim_buf_set_var

M.set_current = vim.api.nvim_set_current_buf

M.list = vim.api.nvim_list_bufs

M.current = vim.api.nvim_get_current_buf

M.create = vim.api.nvim_create_buf

M._redraw_range = vim.api.nvim__buf_redraw_range

M._stats = vim.api.nvim__buf_stats

return M
