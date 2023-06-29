local Layout = require('nui.layout')
local defaults = require('nui.utils').defaults
local event = require('nui.utils.autocmd').event
local search = reload('plink.search')
local Config = reload('plink.config')
local Input = reload('plink.ui.component.input')
local Output = reload('plink.ui.component.output')
local Details = reload('plink.ui.component.details')
local BasePopup = reload('plink.ui.component.popup')
local util = reload('plink.util')
local _ = require('neodash')

-- local icons = lvim.icons.ui

local SearchLayout = Layout:extend('SearchLayout')

---@param size number | string | { width: number | string }
local function calc_width(size)
  local width

  if type(size) == 'table' then
    width = size.width
  else
    width = size
  end

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

function SearchLayout:init(options)
  local this = self
  self.loading = false
  self.previous_winid = vim.api.nvim_get_current_win()
  options = options or {}

  local input_opts = defaults(options.search_input, Config.options.search_input)
  input_opts.on_submit = function(value)
    vim.api.nvim_command('stopinsert')
    self.input:start_spinner()
    search.search_async(value, function(plugins)
      self.plugins = plugins

      if not plugins then
        self.input:stop_spinner()
        return
      end

      local lines = _.map(function(plugin)
        return '  ' .. plugin.name
      end, plugins)

      self.output:set_lines(lines)
      self.details:set_plugin(plugins[1])
      self.input:stop_spinner()
      this:set_active(self.output)

      this:update()
    end)
  end

  local search_details = defaults(options.search_details, Config.options.search_details)
  local search_details_layout_opts = search_details.layout
  search_details.layout = nil
  self.details = Details(search_details, search_details_layout_opts)
  self.details.active = false
  self.details.hidden = false

  local input_layout_opts = input_opts.layout
  input_opts.layout = nil
  self.input = Input(input_opts, input_layout_opts)
  self.input.active = true
  self.input.hidden = false

  local output_opts = defaults(options.search_output, Config.options.search_output)
  local output_layout_opts = output_opts.layout
  output_opts.layout = nil
  output_opts.on_move_cursor = function(row)
    if self.plugins and row then
      local plugin = self.plugins[row]
      if plugin then
        self.details:set_plugin(plugin)
      end
    end
  end

  output_opts.on_select = function(_)
    self:set_active(self.details)
  end

  self.output = Output(output_opts, output_layout_opts)
  self.output.active = false
  self.output.hidden = false

  self.layout_opts = defaults(options.search_layout, Config.options.search_layout)
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
  self.layout_opts.inner_layout = nil

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

function SearchLayout:update()
  local layouts = {}
  if not self.input.hidden then
    table.insert(layouts, self.input.layout)
  end

  if not self.output.hidden then
    table.insert(layouts, self.output.layout)
  end

  assert(not (self.input.active == true and self.output.active == true), 'only one component can be active at a time')

  SearchLayout.super.update(
    self,
    self.layout_opts,
    self.inner_layout
  )

  for _, component in ipairs({ self.input, self.output }) do
    if component.hidden then
      pcall(component.hide, component)
    elseif component.active then
      pcall(component.focus, component)
    end
  end
end

function SearchLayout:mount()
  SearchLayout.super.mount(self)

  self.details:map('n', '<C-j>', function()
    self.input:focus()
  end, { noremap = true, silent = true })

  self.input:map('n', '<C-k>', function()
    self.details:focus()
  end, { noremap = true, silent = true })

  self.input:map('n', '<C-j>', function()
    self.output:focus()
  end, { noremap = true, silent = true })

  self.output:map('n', '<C-k>', function()
    self.input:focus()
  end, { noremap = true, silent = true })
end

return SearchLayout
