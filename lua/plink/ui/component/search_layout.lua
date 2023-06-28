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

local SearchLayout = Layout:extend('SearchLayout')

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
      this:toggle_active()

      this:update()
    end)
  end

  local input_layout_opts = input_opts.layout
  input_opts.layout = nil
  self.input = Input(input_opts, input_layout_opts)
  self.input.active = true
  self.input.hidden = false

  local output_opts = defaults(options.search_output, Config.options.search_output)
  local output_layout_opts = output_opts.layout
  output_opts.layout = nil
  self.output = Output(output_opts, output_layout_opts)
  self.output.active = false
  self.output.hidden = false

  -- TODO: Add default options for `details` instead of borrowing `output`'s options
  self.details = Details(output_opts, output_layout_opts)
  self.details.active = false
  self.details.hidden = false

  self.layout_opts = defaults(options.search_layout, Config.options.search_layout)
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

function SearchLayout:toggle_active()
  local temp = self.input.active
  self.input.active = not temp
  self.output.active = temp
end

function SearchLayout:update(callback)
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

  if type(callback) == 'function' then
    callback()
  end
end

function SearchLayout:mount()
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

  SearchLayout.super.mount(self)
end

local layout = SearchLayout()

local force_close = vim.schedule_wrap(function()
  layout:unmount()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ok, opts = pcall(vim.api.nvim_win_get_config, winid)
    if ok and opts and opts.zindex and opts.anchor and opts.relative then
      if vim.api.nvim_win_is_valid(winid) then
        pcall(vim.api.nvim_win_close, winid, true)
      end
    end
  end
end)

vim.keymap.set('n', '<leader>bc', force_close, {
  silent = true,
  noremap = true,
  buffer = true,
})

layout:mount(layout)

return SearchLayout
