local _ = require('neodash')
local event = require('nui.utils.autocmd').event
local defaults = require('nui.utils').defaults
local Layout = require('nui.layout')
local Line = require('nui.line')
local Text = require('nui.text')
local BasePopup = require('plink.ui.component.popup')
local Config = require('plink.config')
local u = reload('plink.util')
local icons = reload('plink.ui.icons')

local Details = BasePopup:extend('Details')

local floatTitleOpts = vim.api.nvim_get_hl(0, { name = 'FloatTitle' })
vim.api.nvim_set_hl(0, "PlinkTitle",
  { fg = floatTitleOpts.fg, bg = floatTitleOpts.bg, bold = true, default = true })

vim.api.nvim_set_hl(0, "PlinkTitleLink",
  { fg = floatTitleOpts.fg, bg = floatTitleOpts.bg, underline = true, bold = true, default = true })

local function part_text_to_width(text, width)
  local min_width = 30
  local max_width = vim.api.nvim_get_option_value('textwidth', { scope = 'global' })
  width = u.clamp(
    width,
    min_width,
    max_width == 0 and 80 or max_width
  ) - 5

  local lines = {}
  local i = 1
  while i <= #text do
    local to = i + width
    local char = string.sub(text, to, to)
    while char ~= ' ' and to <= #text do
      to = to + 1
      char = string.sub(text, to, to)
      if not char then
        break
      end
    end

    local line = text:sub(i, to)
    table.insert(lines, line)
    i = to + 1
  end
  return lines
end

function Details:init(opts)
  local layout_opts = opts.layout

  opts = defaults(opts, Config.search_details)
  opts.enter = false
  opts.focusable = false

  opts.buf_options = vim.tbl_deep_extend('keep', {
    modifiable = true,
    readonly = false,
  }, opts.buf_options or {})

  opts.win_options = vim.tbl_deep_extend('keep', {
    cursorline = false,
  }, opts.win_options or {})

  Details.super.init(self, opts, layout_opts)

  self:on(event.BufEnter, function()
    self:lock_buf()
  end)
end

function Details:set_lines(lines)
  self:unlock_buf()
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, { '' })

  for i, line in ipairs(lines) do
    line:render(self.bufnr, self.ns_id, i)
  end
  self:lock_buf()
end

---@param plugin PluginResult
function Details:set_plugin(plugin)
  local url_icon = plugin.url:match('github.com') and icons.github or icons.url

  local lines = {
    Line({ Text(icons.package_fancy .. ' ' .. plugin.name, 'PlinkTitle') }),
    Line({ Text(url_icon .. ' ', 'PlinkTitle'), Text(plugin.url, 'PlinkTitleLink') }),
    Line({ Text('') }),
    Line({ Text(icons.sparkles_fancy .. ' Description', 'PlinkTitle') }),
  }

  local winid = u.buf_get_win(self.bufnr)
  local width = vim.api.nvim_win_get_width(winid)
  for _, line in ipairs(part_text_to_width(plugin.description, width)) do
    table.insert(lines, Line({ Text(line) }))
  end

  table.insert(lines, Line({ Text('') }))

  table.insert(lines, Line {
    Text(icons.star_fancy .. ' Stargazers', 'PlinkTitle'),
    Text(' ' .. plugin.stars),
  })
  table.insert(lines, Line({ Text('') }))
  table.insert(lines, Line({ Text(icons.lightning_fancy .. ' Tags', 'PlinkTitle') }))
  for _, tag in ipairs(plugin.tags) do
    table.insert(lines, Line { Text('- ' .. tag) })
  end

  for i = 1, #lines do
    if lines[i] == nil then
      lines[i] = Line({ Text('') })
    end
  end

  self:set_lines(lines)
end

return Details
