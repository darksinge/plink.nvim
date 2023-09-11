local _ = require('neodash')
local Event = require('nui.utils.autocmd').event
local Popup = require('nui.popup')
local defaults = require('nui.utils').defaults
local Config = require('plink.config')
local Layout = require('nui.layout')
local u = require('plink.util')
local nvim = require('plink.nvim-api')

---@alias PopupEvent 'on_select'|'on_move_cursor'|'on_focus'|'on_change'|'on_close'

local PopupEvents = {
  on_select = 'on_select',
  on_move_cursor = 'on_move_cursor',
  on_focus = 'on_focus',
  on_change = 'on_change',
  on_close = 'on_close',
}

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

local function handle_event(popup, event, ...)
  local handlers = popup._.event_handlers[event]
  if not handlers then
    return
  end
  for _, handler in ipairs(popup._.event_handlers[event]) do
    pcall(handler.call, ...)
  end
end

local BasePopup = Popup:extend('BasePopup')

---@class BasePopup
---@field register_handler fun(self: BasePopup, event: PopupEvent, fn: fun(...): nil)
---@field previous_winid integer
---@field hiiden boolean
---@field active boolean
---@field layout Layout
---@field on_move_cursor fun(self: BasePopup, direction?: string): nil
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
  self._.event_handlers = {}
end

function BasePopup:is_buf_exists()
  return vim.fn.bufexists(self.bufnr) == 1
end

function BasePopup:mount()
  BasePopup.super.mount(self)

  self:on(Event.BufEnter, function()
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
  self:on_focus()
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
  local mode = vim.fn.mode()

  if mode == 'i' then
    return pcall(callback)
  end

  local target_cursor = vim.api.nvim_win_get_cursor(self._.position.win)
  vim.schedule(function()
    vim.api.nvim_command('stopinsert')

    if not self._.disable_cursor_position_patch then
      patch_cursor_position(target_cursor, mode == 'n')
    end

    pcall(callback)
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

local _handler_id = 0

---@param event PopupEvent
---@param fn fun(...): nil
function BasePopup:register_handler(event, fn)
  if type(self._.event_handlers[event]) ~= 'table' then
    self._.event_handlers[event] = {}
  end

  local id = _handler_id
  _handler_id = _handler_id + 1
  table.insert(self._.event_handlers[event], {
    id = id,
    event = event,
    call = fn,
  })

  return function()
    for i, handler in ipairs(self._.event_handlers[event]) do
      if handler.id == id then
        table.remove(self._.event_handlers[event], i)
        break
      end
    end
  end
end

function BasePopup:on_focus(...)
  handle_event(self, PopupEvents.on_focus, ...)
end

function BasePopup:on_select(...)
  handle_event(self, PopupEvents.on_select, ...)
end

function BasePopup:on_move_cursor(...)
  handle_event(self, PopupEvents.on_move_cursor, ...)
end

function BasePopup:on_change(...)
  handle_event(self, PopupEvents.on_change, ...)
end

function BasePopup:on_close(...)
  local args = table.pack(...)
  vim.schedule(function()
    handle_event(self, PopupEvents.on_close, table.unpack(args))
    self:unmount()
  end)
end

function BasePopup:_handle_event(event, ...)
  if not self._.event_handlers[event] then
    u.raise('no "' .. event .. '" events have been registered for this component')
  end
  handle_event(self, event, ...)
end

return BasePopup
