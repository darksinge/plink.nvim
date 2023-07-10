local _ = require('neodash')
local event = require('nui.utils.autocmd').event
local defaults = require('nui.utils').defaults
-- local Layout = require('nui.layout')
local Line = reload('plink.ui.component.line')
local Text = reload('plink.ui.component.text')
local BasePopup = reload('plink.ui.component.popup')
local Config = reload('plink.config')
local u = reload('plink.util')
local icons = reload('plink.ui.icons')

---@alias MoveDirection 'down' | 'up'

---@param dir MoveDirection
local function dir_to_num(dir)
  return dir == 'up' and -1 or 1
end

vim.cmd('sign define plink_active_line text=' .. icons.select_arrow .. ' texthl=Pmenu')

local SearchOutput = BasePopup:extend('SearchOuput')

function SearchOutput:init(options)
  local layout_opts = options.layout
  options = defaults(options, Config.search_output)
  options.enter = false
  options.focusable = false

  options.buf_options = vim.tbl_deep_extend('keep', {
    modifiable = true,
    readonly = false,
    filetype = 'plink',
  }, options.buf_options or {})

  options.win_options = vim.tbl_deep_extend('keep', {
    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:NormalFloat",
    cursorline = true,
  }, options.win_options or {})

  SearchOutput.super.init(self, options, layout_opts)

  ---@type string[]
  self.installed_plugins = {}
  self.active_line = 0
  self.lines = {}
end

function SearchOutput:set_active_line(lnum)
  if lnum < 1 then
    lnum = #self.lines - lnum
  elseif lnum > #self.lines then
    lnum = lnum - #self.lines
  end
  self.active_line = u.clamp(lnum, 1, #self.lines)
  self:update()
end

function SearchOutput:mount()
  local hl_info = vim.api.nvim_get_hl(self.ns_id, { name = 'Cursor' })
  local blend_prev = defaults(hl_info and hl_info.blend, 0)
  local termguicolors_prev = vim.api.nvim_get_option_value('termguicolors', { scope = 'global' })
  local guicursor_prev = vim.api.nvim_get_option_value('guicursor', { scope = 'global' })

  self:map('n', '<space>', function()
    self:on_select()
  end, { silent = true, noremap = true })

  self:on(event.BufEnter, function()
    self:lock_buf()
    vim.cmd([[set termguicolors]])
    vim.cmd([[hi Cursor blend=100]])
    vim.cmd([[set guicursor+=a:Cursor/lCursor]])
  end)

  self:on(event.BufLeave, function()
    self:unlock_buf()
    if termguicolors_prev == false then
      vim.cmd([[set notermguicolors]])
    end
    vim.cmd('hi Cursor blend=' .. blend_prev)
    vim.cmd('set guicursor=' .. guicursor_prev)
  end)

  SearchOutput.super.mount(self)
end

---@param lines string[]
function SearchOutput:set_lines(lines)
  if not lines or #lines == 0 then
    return
  end

  self.lines = {}
  for _, text in ipairs(lines) do
    local line = Line()
    line:append(text)
    table.insert(self.lines, line)
  end

  self:unlock_buf()
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, { '' })
  self:set_active_line(1)
  self:update()
end

function SearchOutput:update()
  self:unlock_buf()

  -- self.border:set_text('top', 'Pluginsss', 'center')
  for lnr, line in ipairs(self.lines) do
    line:render(self.bufnr, self.ns_id, lnr)
    if lnr == self.active_line then
      line:set_line_highlight('Visual')
      line:line_highlight(self.bufnr, self.ns_id, lnr)
      vim.fn.sign_place(0, 'my_group', 'plink_active_line', self.bufnr, { lnum = lnr, priority = 10 })
    end
  end

  self:lock_buf()
end

function SearchOutput:on_select()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  SearchOutput.super.on_select(self, lnum)
end

---@param dir MoveDirection
function SearchOutput:move_selected(dir)
  if type(dir) ~= 'string' then
    return
  end

  local delta = dir_to_num(dir)
  self:set_active_line(self.active_line + delta)

  local winid = self:get_winid()
  vim.api.nvim_win_call(winid, function()
    vim.cmd([[normal! ]] .. self.active_line .. 'gg')
  end)

  return self.active_line
end

function SearchOutput:display_installed(plugins)
  if not plugins then
    return
  end
  local lines = {}
  for _, plugin in ipairs(plugins) do
    if type(plugin) == 'string' then
      table.insert(lines, icons.checkbox .. ' ' .. plugin)
    end
  end

  self:set_title('Installed Plugins')
  self:set_lines(lines)
end

function SearchOutput:display_search_results(plugins)
  local lines = _.map(function(plugin)
    return plugin.name
  end, plugins)

  self:set_title('Search Results')
  self:set_lines(lines)
end

return SearchOutput
