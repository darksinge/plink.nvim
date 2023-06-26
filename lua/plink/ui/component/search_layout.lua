local Layout = require('nui.layout')
local defaults = require('nui.utils').defaults
local event = require('nui.utils.autocmd').event
local search = require('plink.search')
local Config = reload('plink.config')
local Input = reload('plink.ui.component.input')
local Output = reload('plink.ui.component.output')
local BasePopup = reload('plink.ui.component.popup')

local SearchLayout = Layout:extend('SearchLayout')

function SearchLayout:init(options)
  local this = self
  self.loading = false
  self.previous_winid = vim.api.nvim_get_current_win()
  options = options or {}

  local input_opts = defaults(options.search_input, Config.options.search_input)
  input_opts.on_submit = function(value)
    vim.api.nvim_command('stopinsert')
    pcall(self.input.spinner.start, self.input.spinner)
    search.search_async(value, function(plugins)
      local lines = {}
      for _, plugin in ipairs(plugins) do
        table.insert(lines, plugin.name)
      end
      local bufnr = self.output.bufnr
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      this.output.hidden = false
      pcall(this.toggle_active, this)
      pcall(this.update, this, function()
        pcall(self.input.spinner.stop, self.input.spinner)
      end)
    end)
  end

  self.input = Input(input_opts, { size = { height = 3, width = '100%' }, })
  self.input.active = true
  self.input.hidden = false

  local output_opts = defaults(options.search_output, Config.options.search_output)
  self.output = Output(output_opts, { size = { height = '50%' }, grow = 1 })
  self.output.active = false
  self.output.hidden = true

  self.layout_opts = defaults(options.search_layout, Config.options.search_layout)
  self.layout_opts.dir = 'col'
  SearchLayout.super.init(
    self,
    self.layout_opts,
    Layout.Box({
      self.input.layout,
      self.output.layout,
    }, { dir = 'col' })
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
    Layout.Box(layouts, { dir = 'col' })
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

-- function SearchLayout:mount()
--   SearchLayout.super.mount(self)
--   local this = self
--   local input = self.input
--   local output = self.output
--   for _, component in ipairs({ input, output }) do
--     component:on(event.BufLeave, function()
--       print('leaving buf!')
--       component.active = false
--       if input.active == false and output.active == false then
--         pcall(this.unmount, this)
--       end
--     end)
--   end
-- end

local layout = SearchLayout()
-- layout.input.border._.size_delta.height = 0
-- layout.input.border._.size_delta.width = 0
-- P(layout.input.border._.padding)

local force_close = vim.schedule_wrap(function()
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local opts = vim.api.nvim_win_get_config(winid)
    if opts.zindex and opts.anchor and opts.relative == 'win' then
      vim.api.nvim_win_close(winid, true)
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
