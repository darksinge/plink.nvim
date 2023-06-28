local event = require('nui.utils.autocmd').event
local defaults = require('nui.utils').defaults
local Layout = require('nui.layout')
local BasePopup = require('plink.ui.component.popup')
local Config = require('plink.config')

local SearchOutput = BasePopup:extend('SearchOuput')

local icon = ' '

function SearchOutput:init(options, layout_opts)
  options = defaults(options, Config.search_output)
  options.enter = false
  options.focusable = false

  options.buf_options = vim.tbl_deep_extend('keep', {
    modifiable = true,
    readonly = false,
    filetype = 'plink',
  }, options.buf_options or {})

  options.win_options = vim.tbl_deep_extend('keep', {
    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual",
    cursorline = true,
  }, options.win_options or {})

  SearchOutput.super.init(self, options, layout_opts)

  self._.on_move_cursor = options.on_move_cursor
  self._on_select = options.on_select
end

function SearchOutput:set_active_line(lnum)
  self:unlock_buf()
  local prev_ok, prev = pcall(vim.api.nvim_buf_get_lines, self.bufnr, lnum - 2, lnum - 1, true)
  if prev_ok and prev and #prev > 0 then
    local line = prev[1]
    if line:match(icon) then
      line = line:gsub(icon, '  ')
      pcall(vim.api.nvim_buf_set_lines, self.bufnr, lnum - 2, lnum - 1, true, { line })
    end
  end

  local curr_line = vim.api.nvim_buf_get_lines(self.bufnr, lnum - 1, lnum, false)[1]
  curr_line = curr_line:gsub('^%s+', icon)
  pcall(vim.api.nvim_buf_set_lines, self.bufnr, lnum - 1, lnum, true, { curr_line })

  local next_ok, next = pcall(vim.api.nvim_buf_get_lines, self.bufnr, lnum, lnum + 1, true)
  if next_ok and next and #next > 0 then
    local line = next[1]
    if line:match(icon) then
      line = line:gsub(icon, '  ')
      pcall(vim.api.nvim_buf_set_lines, self.bufnr, lnum + 0, lnum + 1, true, { line })
    end
  end
  self:lock_buf()
end

function SearchOutput:mount()
  local hl_info = vim.api.nvim_get_hl(self.ns_id, { name = 'Cursor' })
  local blend_prev = defaults(hl_info and hl_info.blend, 0)
  local termguicolors_prev = vim.api.nvim_get_option_value('termguicolors', { scope = 'global' })
  local guicursor_prev = vim.api.nvim_get_option_value('guicursor', { scope = 'global' })

  self:map('n', 'L', ':Lazy<cr>', { silent = true, noremap = true })

  self:map('n', '<cr>', function()
    self:on_select()
  end, { silent = true, noremap = true })

  self:on(event.BufEnter, function()
    vim.cmd([[set termguicolors]])
    vim.cmd([[hi Cursor blend=100]])
    vim.cmd([[set guicursor+=a:Cursor/lCursor]])

    self:lock_buf()
  end)

  self:on(event.BufLeave, function()
    if termguicolors_prev == false then
      vim.cmd([[set notermguicolors]])
    end

    vim.cmd('hi Cursor blend=' .. blend_prev)
    vim.cmd('set guicursor=' .. guicursor_prev)

    self:unlock_buf()
  end)

  self:on(event.CursorMoved, function()
    self:on_move_cursor()
  end)

  self.line_count = 0

  SearchOutput.super.mount(self)
end

function SearchOutput:set_lines(lines)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
  self:set_active_line(1)
  self.line_count = #lines
  -- local title = 'Results 1 / ' .. #lines
  -- self:set_title(title)
  self.border:set_text('bottom', ' Lazy (L) ', 'center')
end

function SearchOutput:set_title(title)
  pcall(self.border.set_text, self.border, 'top', title, 'center')
end

local function is_fun(fn)
  return type(fn) == 'function'
end

function SearchOutput:on_select()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local on_select = self._on_select
  if is_fun(on_select) then
    on_select(lnum)
  end
end

function SearchOutput:on_move_cursor()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  self:set_active_line(lnum)

  -- local title = '1 / ' .. self.line_count
  -- self:set_title(title)

  local on_move_cursor = self._.on_move_cursor
  if is_fun(on_move_cursor) then
    on_move_cursor(lnum)
  end
end

return SearchOutput
