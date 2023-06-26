local Text = require('nui.text')
local defaults = require('nui.utils').defaults
local is_type = require('nui.utils').is_type
local event = require('nui.utils.autocmd').event
local BasePopup = reload('plink.ui.component.popup')
local Spinner = reload('plink.ui.component.spinner')
local Config = reload('plink.config')

vim.cmd([[sign define plink-search text= texthl=Pmenu]])

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

local SearchInput = BasePopup:extend('SearchInput')

function SearchInput:init(options, layout_opts)
  vim.fn.sign_define('multiprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })
  vim.fn.sign_define('singleprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })

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
    local target_cursor = vim.api.nvim_win_get_cursor(self._.position.win)

    local prompt_normal_mode = vim.fn.mode() == 'n'

    vim.schedule(function()
      if prompt_normal_mode then
        -- NOTE: on prompt-buffer normal mode <CR> causes neovim to enter insert mode.
        --  ref: https://github.com/neovim/neovim/blob/d8f5f4d09078/src/nvim/normal.c#L5327-L5333
        vim.api.nvim_command('stopinsert')
      end

      if not self._.disable_cursor_position_patch then
        patch_cursor_position(target_cursor, prompt_normal_mode)
      end

      if options.on_submit then
        options.on_submit(value)
      end
    end)
  end

  props.on_close = function()
    local target_cursor = vim.api.nvim_win_get_cursor(self._.position.win)

    self:unmount()

    vim.schedule(function()
      if vim.fn.mode() == 'i' then
        vim.api.nvim_command('stopinsert')
      end

      if not self._.disable_cursor_position_patch then
        patch_cursor_position(target_cursor)
      end

      if options.on_close then
        options.on_close()
      end
    end)
  end

  if options.on_change then
    local bufnr = self.bufnr
    props.on_change = function()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      if #lines == 1 then
        vim.fn.sign_place(0, 'my_group', 'singleprompt_sign', bufnr, { lnum = 1, priority = 10 })
      else
        for i = 1, #lines do
          vim.fn.sign_place(0, 'my_group', 'multiprompt_sign', bufnr, { lnum = i, priority = 10 })
        end
      end
      options.on_change(table.concat(lines, '\n'))
    end
  end
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

  self:map('i', '<cr>', function()
    print('insert mode')
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local value = table.concat(lines, '\n')
    props.on_submit(value)
  end, { noremap = true })

  self:map('n', '<cr>', function()
    print('normal mode')
    local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local value = table.concat(lines, '\n')
    props.on_submit(value)
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
  vim.fn.sign_place(0, 'my_group', 'plink-search', self.bufnr, { lnum = 1, priority = 10 })
end

function SearchInput:toggle_placeholder()
  local bufnr = self.bufnr
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local text = table.concat(lines, '\n')
  if self.extmark then
    vim.api.nvim_buf_del_extmark(bufnr, Config.namespace_id, self.extmark)
  end
  if #text == 0 then
    self.extmark = vim.api.nvim_buf_set_extmark(bufnr, Config.namespace_id, 0, 0, {
      virt_text = {
        {
          'Search plugins...',
        },
      },
      virt_text_pos = 'overlay',
    })
  end
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
        { "", "ChatGPTTotalTokensBorder" },
        { "" .. suffix, "ChatGPTTotalTokens" },
        { "", "ChatGPTTotalTokensBorder" },
        { " ", "" },
      },
      virt_text_pos = "right_align",
    })

    if ok then
      self.extmark_id = extmark_id
    else
      self.extmark_id = nil
    end
  end
end

return SearchInput
