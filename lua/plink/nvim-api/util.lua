local M = {}

M.call_dict_function = vim.api.nvim_call_dict_function

M.call_function = vim.api.nvim_call_function

M.chan_send = vim.api.nvim_chan_send

M.cmd = vim.api.nvim_cmd

M.command = vim.api.nvim_command

M.create_namespace = vim.api.nvim_create_namespace

M.create_user_command = vim.api.nvim_create_user_command

M.del_current_line = vim.api.nvim_del_current_line

M.del_mark = vim.api.nvim_del_mark

M.del_user_command = vim.api.nvim_del_user_command

M.del_var = vim.api.nvim_del_var

M.echo = vim.api.nvim_echo

M.err_write = vim.api.nvim_err_write

M.err_writeln = vim.api.nvim_err_writeln

M.eval = vim.api.nvim_eval

M.eval_statusline = vim.api.nvim_eval_statusline

M.exec2 = vim.api.nvim_exec2

M.feedkeys = vim.api.nvim_feedkeys

M.get_all_options_info = vim.api.nvim_get_all_options_info

M.get_chan_info = vim.api.nvim_get_chan_info

M.get_color_by_name = vim.api.nvim_get_color_by_name

M.get_color_map = vim.api.nvim_get_color_map

M.get_commands = vim.api.nvim_get_commands

M.get_context = vim.api.nvim_get_context

M.get_current_line = vim.api.nvim_get_current_line

M.get_current_tabpage = vim.api.nvim_get_current_tabpage

M.get_current_win = vim.api.nvim_get_current_win

M.get_hl = vim.api.nvim_get_hl

M.get_hl_id_by_name = vim.api.nvim_get_hl_id_by_name

M.get_mark = vim.api.nvim_get_mark

M.get_mode = vim.api.nvim_get_mode

M.get_namespaces = vim.api.nvim_get_namespaces

M.get_option = vim.api.nvim_get_option

M.get_option_info = vim.api.nvim_get_option_info

M.get_option_info2 = vim.api.nvim_get_option_info2

M.get_option_value = vim.api.nvim_get_option_value

M.get_proc = vim.api.nvim_get_proc

M.get_proc_children = vim.api.nvim_get_proc_children

M.get_runtime_file = vim.api.nvim_get_runtime_file

M.get_var = vim.api.nvim_get_var

M.get_vvar = vim.api.nvim_get_vvar

M.input = vim.api.nvim_input

M.input_mouse = vim.api.nvim_input_mouse

M.list_chans = vim.api.nvim_list_chans

M.list_runtime_paths = vim.api.nvim_list_runtime_paths

M.list_tabpages = vim.api.nvim_list_tabpages

M.list_uis = vim.api.nvim_list_uis

M.load_context = vim.api.nvim_load_context

M.notify = vim.api.nvim_notify

M.out_write = vim.api.nvim_out_write

M.parse_cmd = vim.api.nvim_parse_cmd

M.parse_expression = vim.api.nvim_parse_expression

M.paste = vim.api.nvim_paste

M.put = vim.api.nvim_put

M.replace_termcodes = vim.api.nvim_replace_termcodes

M.select_popupmenu_item = vim.api.nvim_select_popupmenu_item

M.set_current_dir = vim.api.nvim_set_current_dir

M.set_current_line = vim.api.nvim_set_current_line

M.set_current_tabpage = vim.api.nvim_set_current_tabpage

M.set_decoration_provider = vim.api.nvim_set_decoration_provider

M.set_hl = vim.api.nvim_set_hl

M.set_hl_ns = vim.api.nvim_set_hl_ns

M.set_hl_ns_fast = vim.api.nvim_set_hl_ns_fast

M.set_option = vim.api.nvim_set_option

M.set_option_value = vim.api.nvim_set_option_value

M.set_var = vim.api.nvim_set_var

M.set_vvar = vim.api.nvim_set_vvar

M.strwidth = vim.api.nvim_strwidth

M.tabpage_del_var = vim.api.nvim_tabpage_del_var

M.tabpage_get_number = vim.api.nvim_tabpage_get_number

M.tabpage_get_var = vim.api.nvim_tabpage_get_var

M.tabpage_is_valid = vim.api.nvim_tabpage_is_valid

M.tabpage_set_var = vim.api.nvim_tabpage_set_var

M._get_lib_dir = vim.api.nvim__get_lib_dir

M._get_runtime = vim.api.nvim__get_runtime

M._id = vim.api.nvim__id

M._id_array = vim.api.nvim__id_array

M._id_dictionary = vim.api.nvim__id_dictionary

M._id_float = vim.api.nvim__id_float

M._inspect_cell = vim.api.nvim__inspect_cell

M._runtime_inspect = vim.api.nvim__runtime_inspect

M._screenshot = vim.api.nvim__screenshot

M._stats = vim.api.nvim__stats

M._unpack = vim.api.nvim__unpack

return M
