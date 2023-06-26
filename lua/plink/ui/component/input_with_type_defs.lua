local BasePopup = reload('plink.ui.component.popup')
local Text = require('nui.text')
local defaults = require('nui.utils').defaults
local is_type = require('nui.utils').is_type
local event = require('nui.utils.autocmd').event

vim.cmd([[sign define plink-search text= texthl=Pmenu]])

-- exiting insert mode places cursor one character backward,
-- so patch the cursor position to one character forward
-- when unmounting input.
---@param target_cursor number[]
---@param force? boolean
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

---@class SearchInputOptions
---@field default_value string | nil
---@field disable_cursor_position_patch boolean | nil
---@field on_change fun(v: string) | nil
---@field on_close fun() | nil
---@field on_submit fun(v: string) | nil
---@field prompt string | nil
---@field buf_options table | nil
---@field enter boolean | nil
---@field size number | table | nil

---@alias BorderStyle
---|'double'
---|'none'
---|'rounded
---|'shadow
---|'single
---|'solid'
---|{ top_left: string, top: string, top_right: string, left: string, right: string, bottom_left: string, bottom: string, bottom_right:string }

---@alias BorderText {top: string|nil, top_align: 'left'|'right'|'center'|nil, bottom: string|nil, bottom_align:'left'|'right'|'center'|nil}

---@alias BorderPaddingList table<number, number>

---@alias RelativePositionType 'cursor' | 'win' | 'editor' | 'buf'

---@class BorderOptions
---@field padding BorderPaddingList | {top: number, left: number} | nil
---@field style BorderStyle|nil
---@field text BorderText|nil

---@class NuiPopupOptions
---@field position number | string | { row: number | string, col: number | string } | nil
---@field size number | string | { height: number | string, width: number | string } | nil
---@field focusable boolean | nil
---@field zindex boolean | nil
---@field buf_options {modifiable: boolean, readonly: boolean}
---@field win_options {winblend: number, winhighlight: string}
---@field bufnr number | nil
---@field disable_cursor_position_patch boolean | nil
---@field on_change fun(v: string) | nil
---@field on_close fun() | nil
---@field on_submit fun(v: string) | nil
---@field prompt string | nil
---@field enter boolean | nil
---@field ns_id number | string | nil
---@field anchor 'NW' | 'NE' | 'SW' | 'SE' | nil
---@field relative string | { type: RelativePositionType, winid: number, position: { row: number, col: number } }

---@param options SearchInputOptions
function SearchInput:init(options, layout_opts)
  vim.fn.sign_define('multiprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })
  vim.fn.sign_define('singleprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })

  if not is_type('boolean', options.enter) then
    options.enter = true
  end

  options.buf_options = defaults(options.buf_options, {})

  if not is_type('table', options.size) then
    options.size = {
      width = options.size,
    }
  end

  options.win_options = defaults(options.win_options, {})

  options.size.height = defaults(options.size.height, 1)

  SearchInput.super.init(self, options, layout_opts)

  self._.default_value = defaults(options.default_value, '')
  self._.prompt = Text(defaults(options.prompt, ''))
  self._.disable_cursor_position_patch = defaults(options.disable_cursor_position_patch, false)

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
    props.on_change = function()
      local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
      -- if #lines == 1 then
      --   vim.fn.sign_place(0, 'my_group', 'singleprompt_sign', self.bufnr, { lnum = 1, priority = 10 })
      -- else
      --   for i = 1, #lines do
      --     vim.fn.sign_place(0, 'my_group', 'multiprompt_sign', self.bufnr, { lnum = i, priority = 10 })
      --   end
      -- end
      options.on_change(table.concat(lines, '\n'))
    end
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

  vim.api.nvim_command('startinsert!')
  vim.fn.sign_place(0, 'my_group', 'plink-search', self.bufnr, { lnum = 1, priority = 10 })
end

return SearchInput
