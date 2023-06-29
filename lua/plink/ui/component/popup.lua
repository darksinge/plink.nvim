local event = require('nui.utils.autocmd').event
local Popup = require('nui.popup')
local defaults = require('nui.utils').defaults
local Config = require('plink.config')
local Layout = require('nui.layout')
local u = reload('plink.util')
local nvim = reload('plink.nvim-api')

local BasePopup = Popup:extend('BasePopup')

function BasePopup:init(opts, layout_opts)
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

return BasePopup
