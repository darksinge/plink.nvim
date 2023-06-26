local event = require('nui.utils.autocmd').event
local Popup = require('nui.popup')
local defaults = require('nui.utils').defaults
local Config = require('plink.config')
local Layout = require('nui.layout')

local BasePopup = Popup:extend('BasePopup')

---@param bufnr integer
---@return integer|nil
local function get_window_id(bufnr)
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local win_bufnr = vim.api.nvim_win_get_buf(winid)
    if win_bufnr == bufnr then
      return winid
    end
  end
end

function BasePopup:init(opts, layout_opts)
  self.previous_winid = vim.api.nvim_get_current_win()
  self.hidden = opts.hidden or true
  self.active = opts.active or false
  self.layout = Layout.Box(self, layout_opts)
  BasePopup.super.init(self, opts)
  -- print('underscore =', vim.inspect(self._))
end

function BasePopup:is_buf_exists()
  return vim.fn.bufexists(self.bufnr) == 1
end

function BasePopup:unmount()
  local winid = self.previous_winid
  BasePopup.super.unmount(self)
  vim.api.nvim_set_current_win(winid)
end

function BasePopup:focus()
  local winid = get_window_id(self.bufnr)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
  end
end

return BasePopup
