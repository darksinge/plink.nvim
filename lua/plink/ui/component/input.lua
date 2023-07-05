local Text = require('nui.text')
local defaults = require('nui.utils').defaults
local is_type = require('nui.utils').is_type
local event = require('nui.utils.autocmd').event
local BasePopup = reload('plink.ui.component.popup')
local Spinner = reload('plink.ui.component.spinner')
local Config = reload('plink.config')

vim.cmd([[sign define plink-search text= texthl=Pmenu]])

local SearchInput = BasePopup:extend('SearchInput')

function SearchInput:init(options, layout_opts)
  -- vim.fn.sign_define('multiprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })
  -- vim.fn.sign_define('singleprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })

  if not is_type('boolean', options.enter) then
    options.enter = true
  end

  if not is_type('table', options.size) then
    options.size = { width = options.size }
  end

  options.buf_options = defaults(options.buf_options, {})
  options.win_options = defaults(options.win_options, {})
  options.size.height = defaults(options.size.height, 1)

  SearchInput.super.init(self, options, layout_opts)

  self._.default_value = defaults(options.default_value, '')
  self._.prompt = Text(defaults(options.prompt, ''))
  self._.disable_cursor_position_patch = defaults(options.disable_cursor_position_patch, false)

  self.spinner = Spinner:new(vim.schedule_wrap(function(state)
    self:display_input_suffix(state)
  end), { animation_type_name = 'points' })

  local props = {}

  self.input_props = props

  props.on_submit = function(value)
    self:stopinsert()
    if options.on_submit then
      options.on_submit(value)
    end
  end

  props.on_close = function()
    self:unmount()

    if vim.fn.mode() == 'i' then
      self:stopinsert(options.on_close)
    elseif options.on_close then
      vim.schedule(function()
        options.on_close()
      end)
    end
  end

  if options.on_change then
    local bufnr = self.bufnr
    props.on_change = function()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      -- vim.fn.sign_place(0, 'my_group', 'singleprompt_sign', bufnr, { lnum = 1, priority = 10 })
      options.on_change(table.concat(lines, '\n'))
    end
  end

  self._.on_move_cursor = options.on_move_cursor
end

function SearchInput:set_lines(start_idx, end_idx, strict_indexing, lines)
  if self:is_buf_exists() then
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(self.bufnr, start_idx, end_idx, strict_indexing, lines)
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)
  end
end

function SearchInput:mount()
  local props = self.input_props

  SearchInput.super.mount(self)

  local cmp_ok, cmp = pcall(require, 'cmp')
  if cmp_ok then
    pcall(cmp.setup.buffer, { enabled = false })
  end

  if props.on_change then
    vim.api.nvim_buf_attach(self.bufnr, false, {
      on_lines = props.on_change,
    })
  end

  if #self._.default_value then
    self:on(event.InsertEnter, function()
      vim.api.nvim_feedkeys(self._.default_value, 'n', false)
    end, { once = true })
  end

  self:on(event.CursorMoved, function()
    self:on_move_cursor()
  end)

  self:map('n', 'k', function()
    self:on_move_cursor('up')
  end, { noremap = true })

  self:map('n', 'j', function()
    self:on_move_cursor('down')
  end, { noremap = true })

  self:toggle_placeholder()
  vim.api.nvim_buf_attach(self.bufnr, false, {
    on_lines = function()
      self:toggle_placeholder()
      if not self.loading and props.on_change then
        local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
        local text = table.concat(lines, '\n')
        props.on_change(text)
      end
    end,
  })

  vim.api.nvim_command('startinsert!')
  vim.fn.sign_place(0, 'plink-search', 'plink-search', self.bufnr, { lnum = 1, priority = 100 })
end

local i = 0
---@param direction 'up' | 'down' | nil
function SearchInput:on_move_cursor(direction)
  if self._.on_move_cursor then
    self._.on_move_cursor(direction)
  end

  if self.extmark then
    vim.api.nvim_buf_del_extmark(self.bufnr, Config.namespace_id, self.extmark)
  end

  if self.output then
    self.extmark = vim.api.nvim_buf_set_extmark(self.bufnr, Config.namespace_id, 0, -1, {
      virt_text = {
        { '' .. self.output.active_line .. ' / ' .. #self.output.lines, 'MsgArea' },
      },
      virt_text_pos = 'right_align',
    })
  end
end

function SearchInput:toggle_placeholder()
  local has_illuminate, illuminate = pcall(require, 'illuminate')
  if has_illuminate then
    illuminate.pause_buf()
  end

  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  local text = table.concat(lines, '\n')
  if self.extmark_id then
    vim.api.nvim_buf_del_extmark(self.bufnr, self.ns_id, self.extmark_id)
  end
  if #text == 0 then
    local ok, extmark_id = vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, 0, -1, {
      virt_text = {
        {
          'Search phrase...',
          'NonText',
        },
      },
      virt_text_pos = 'overlay',
    })
    self.extmark_id = ok and extmark_id or nil
  end
end

function SearchInput:start_spinner()
  if not self.spinner:is_running() then
    self.spinner:start()
  end
end

function SearchInput:stop_spinner()
  if self.spinner:is_running() then
    self.spinner:stop()
  end
  vim.schedule(function()
    self:display_input_suffix(nil)
  end)
end

local function nvim_buf_del_extmark(bufnr, nsid, extid)
  return pcall(vim.api.nvim_buf_del_extmark, bufnr, nsid, extid)
end

local function nvim_buf_set_extmark(bufnr, nsid, line, col, opts)
  return pcall(vim.api.nvim_buf_set_extmark, bufnr, nsid, line, col, opts)
end

function SearchInput:display_input_suffix(suffix)
  if self.extmark_id then
    nvim_buf_del_extmark(self.bufnr, Config.namespace_id, self.extmark_id)
  end

  if suffix then
    local ok, extmark_id = nvim_buf_set_extmark(self.bufnr, Config.namespace_id, 0, -1, {
      virt_text = {
        { "",        "PlinkLoadingPillEdge" },
        { "" .. suffix, "PlinkLoadingPillCenter" },
        { "",        "PlinkLoadingPillEdge" },
        { " ",          "" },
      },
      virt_text_pos = "right_align",
    })

    self.extmark_id = ok and extmark_id or nil
  end
end

return SearchInput
