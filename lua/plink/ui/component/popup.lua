local event = require('nui.utils.autocmd').event
local Popup = require('nui.popup')
local defaults = require('nui.utils').defaults
local Config = require('plink.config')
local Layout = require('nui.layout')
local u = reload('plink.util')
local nvim = reload('plink.nvim-api')

local function patch_cursor_position(target_cursor, force)
  local cursor = vim.api.nvim_win_get_cursor(0)
  if target_cursor[2] == cursor[2] and force then
    -- didn't exit insert mode yet, but it's gonna
    vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + 1 })
  elseif target_cursor[2] - 1 == cursor[2] then
    -- already exited insert mode
    vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + 1 })
  end
end

local BasePopup = Popup:extend('BasePopup')

function BasePopup:init(opts, layout_opts)
  opts.border = vim.tbl_deep_extend('keep', opts.border or {}, {
    style = 'rounded',
    text = { top = '', top_align = 'center' },
  })

  self.previous_winid = vim.api.nvim_get_current_win()
  self.hidden = opts.hidden or true
  self.active = opts.active or false
  self.layout = Layout.Box(self, layout_opts)
  BasePopup.super.init(self, opts)
end

function BasePopup:is_buf_exists()
  return vim.fn.bufexists(self.bufnr) == 1
end

function BasePopup:mount()
  BasePopup.super.mount(self)

  self:on(event.BufEnter, function()
    local ok, illuminate = pcall(require, 'illuminate')
    if ok then
      illuminate.pause_buf()
    end

    local winid = u.buf_get_win(self.bufnr)
    nvim.win.set_var(winid, 'is_plink_window', true)
  end)
end

---@return integer|nil
function BasePopup:get_winid()
  local winid = u.buf_get_win(self.bufnr)
  if winid and vim.api.nvim_win_is_valid(winid) then
    return winid
  end
end

function BasePopup:unmount()
  local winid = self.previous_winid
  BasePopup.super.unmount(self)
  vim.api.nvim_set_current_win(winid)
end

function BasePopup:focus()
  local winid = u.buf_get_win(self.bufnr)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
  end
end

function BasePopup:lock_buf()
  vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(self.bufnr, 'readonly', true)
end

function BasePopup:unlock_buf()
  vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
  vim.api.nvim_buf_set_option(self.bufnr, 'readonly', false)
end

function BasePopup:stopinsert(callback)
  local target_cursor = vim.api.nvim_win_get_cursor(self._.position.win)

  local prompt_normal_mode = vim.fn.mode() == 'n'

  vim.schedule(function()
    vim.api.nvim_command('stopinsert')

    if not self._.disable_cursor_position_patch then
      patch_cursor_position(target_cursor, prompt_normal_mode)
    end

    if type(callback) == 'function' then
      callback()
    end
  end)
end

---@param title string
---@param opts { edge?: 'top'|'bottom', align?: 'left'|'right'|'center'}?
function BasePopup:set_title(title, opts)
  local edge = opts and opts.edge or 'top'
  local align = opts and opts.align or 'center'
  -- pcall(self.border.set_text, self.border, edge, title, align)
  vim.schedule(function()
    self.border:set_text(edge, title, align)
  end)
end

return BasePopup
