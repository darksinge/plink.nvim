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
    winblend = 10,
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    cursorline = true,
    -- modifiable = false,
  }, options.win_options or {})

  SearchOutput.super.init(self, options, layout_opts)
end

function SearchOutput:set_active_line(lnum)
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
end

function SearchOutput:before_move_cursor()
  vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_option(self.bufnr, 'readonly', false)
end

function SearchOutput:after_move_cursor()
  vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(self.bufnr, 'readonly', true)
end

---@param dir 'up' | 'down'
---@return nil
function SearchOutput:move_cusor(dir)
  if not dir then
    return
  end

  self:before_move_cursor()
  if dir == 'down' then
    vim.cmd('normal! j')
  elseif dir == 'up' then
    vim.cmd('normal! k')
  end

  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  self:set_active_line(lnum)

  self:after_move_cursor()
end

function SearchOutput:mount()
  local hl_info = vim.api.nvim_get_hl(self.ns_id, { name = 'Cursor' })
  local blend_prev = defaults(hl_info and hl_info.blend, 0)
  local termguicolors_prev = vim.api.nvim_get_option_value('termguicolors', { scope = 'global' })
  local guicursor_prev = vim.api.nvim_get_option_value('guicursor', { scope = 'global' })

  self:on(event.BufEnter, function()
    local ill_ok, illuminate = pcall(require, 'illuminate')
    if ill_ok then
      illuminate.pause_buf()
    end

    vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(self.bufnr, 'readonly', true)
    vim.cmd([[set termguicolors]])
    vim.cmd([[hi Cursor blend=100]])
    vim.cmd([[set guicursor+=a:Cursor/lCursor]])
  end)

  self:on(event.BufLeave, function()
    vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_option(self.bufnr, 'readonly', false)

    if termguicolors_prev == false then
      vim.cmd([[set notermguicolors]])
    end

    vim.cmd('hi Cursor blend=' .. blend_prev)
    vim.cmd('set guicursor=' .. guicursor_prev)
  end)

  self:map('n', 'j', function()
    self:move_cusor('down')
  end)

  self:map('n', 'k', function()
    self:move_cusor('up')
  end)


  SearchOutput.super.mount(self)
end

function SearchOutput:set_lines(lines)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
  self:set_active_line(1)
end

-- local pos = vim.api.nvim_win_get_cursor(0)
-- local lnum = pos[1]
-- local curr_line = vim.api.nvim_buf_get_lines(000000000, lnum - 1, lnum, false)[1]
-- curr_line = '   ' .. curr_line
-- curr_line = curr_line:gsub('^%s+', '')
-- print(curr_line)

return SearchOutput
