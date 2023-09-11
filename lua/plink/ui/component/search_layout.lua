local Layout = require('nui.layout')
local defaults = require('nui.utils').defaults
local search = require('plink.search')
local Config = require('plink.config')
local Input = require('plink.ui.component.input')
local SearchOutput = require('plink.ui.component.output')
local Details = require('plink.ui.component.details')
local util = require('plink.util')
local _ = require('neodash')

local SearchLayout = Layout:extend('SearchLayout')

---@param size number | string | { width: number | string }
local function calc_width(size)
  local width = type(size) == 'table' and size.width or size

  if type(width) == 'string' then
    local pct = width:match('^(%d+)%%$')
    if pct then
      pct = tonumber(pct)
      local winid = vim.api.nvim_get_current_win()
      local curr_width = vim.api.nvim_win_get_width(winid)
      return math.floor(curr_width * (pct / 100))
    end
  end

  return width
end

function SearchLayout:init(opts)
  opts = opts or {}

  self.previous_winid = vim.api.nvim_get_current_win()

  local input_opts = defaults(opts.search_input, Config.options.search_input)

  local search_details = defaults(opts.search_details, Config.options.search_details)
  local search_details_layout_opts = search_details.layout
  self.details = Details(search_details, search_details_layout_opts)

  ---@type SearchInput
  self.input = Input(input_opts)
  self.input:register_handler('on_focus', function()
    local linenr = self.output.active_line
    ---@type Plugin
    local plugin = self.plugins[linenr]
    if plugin and plugin.name and Config.options.install_behavior.on_install then
      self:unmount()
      Config.options.install_behavior.on_install(plugin.name)
    end
  end)

  self.input:register_handler('on_move_cursor', function(direction)
    local lnr = self.output:move_selected(direction)
    local plugin = lnr and self.plugins and self.plugins[lnr] or nil
    if plugin then
      self.details:set_plugin(plugin)
    end
  end)

  self.input:register_handler('on_change', function(value)
    if value and #value >= 3 then
      self.input:start_spinner()
      search.search_async(value, function(plugins)
        self.plugins = plugins

        if not plugins then
          self.input:stop_spinner()
          return
        end

        self.output:display_search_results(plugins)
        self.details:set_plugin(plugins[1])
        self.input:stop_spinner()
        self.input.output = self.output
        self.input:on_move_cursor()

        self:update()
      end)
    end
  end)

  self.input:register_handler('on_select', function()
    local linenr = self.output.active_line
    ---@type Plugin
    local plugin = self.plugins[linenr]
    if plugin and plugin.name and Config.options.install_behavior.on_install then
      self:unmount()
      Config.options.install_behavior.on_install(plugin.name)
    end
  end)
  local output_opts = defaults(opts.search_output, Config.options.search_output)

  self.output = SearchOutput(output_opts)
  self.output:register_handler('on_move_cursor', function()
    if self.plugins then
      local plugin = self.plugins[self.output.active_line]
      if plugin then
        self.details:set_plugin(plugin)
      end
    end
  end)

  self.layout_opts = defaults(opts.search_layout, Config.options.search_layout)
  if self.layout_opts.size then
    local size = self.layout_opts.size
    local width = calc_width(size)
    local type_ = type(size)
    if type_ == 'string' or type_ == 'number' then
      self.layout_opts.size = width
    elseif type_ == 'table' then
      local min = size.min_width
      local max = size.max_width
      width = util.clamp(width, min, max)
      self.layout_opts.size.width = width
    end
  end

  local inner_layout_opts = self.layout_opts.inner_layout
  self.inner_layout = Layout.Box({
    self.details.layout,
    self.input.layout,
    self.output.layout,
  }, inner_layout_opts)

  SearchLayout.super.init(
    self,
    self.layout_opts,
    self.inner_layout
  )
end

function SearchLayout:set_active(component)
  component.active = true
  for _, comp in ipairs({ self.input, self.output, self.details }) do
    if comp ~= component then
      comp.active = false
    end
  end
  component:focus()
end

function SearchLayout:mount()
  SearchLayout.super.mount(self)

  local map_opts = { noremap = true, silent = true }
  self.details:map('n', '<C-j>', function()
    self.input:focus()
  end, map_opts)

  self.input:map('n', '<C-k>', function()
    self.details:focus()
  end, map_opts)

  self.input:map('n', 'q', function()
    self:unmount()
  end, map_opts)

  self.input:map('n', '<esc>', function()
    self:unmount()
  end, map_opts)
end

-- local layout = SearchLayout()
-- layout:mount()

return SearchLayout
