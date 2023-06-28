local _ = require('neodash')
local event = require('nui.utils.autocmd').event
local defaults = require('nui.utils').defaults
local Layout = require('nui.layout')
local Line = require('nui.line')
local Text = require('nui.text')
local BasePopup = require('plink.ui.component.popup')
local Config = require('plink.config')
local u = require('plink.util')

local Details = BasePopup:extend('Details')

local function part_text_to_width(text, width)
  width = math.max(width, 30)
  local lines = {}
  local i = 1
  while i <= #text do
    local to = i + width - 1
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

function Details:init(options, layout_opts)
  -- TODO: Create options table for this
  options = defaults(options, Config.search_details)
  options.enter = false
  options.focusable = false

  options.buf_options = vim.tbl_deep_extend('keep', {
    modifiable = true,
    readonly = false,
  }, options.buf_options or {})

  options.win_options = vim.tbl_deep_extend('keep', {
    winblend = 10,
    cursorline = false,
  }, options.win_options or {})

  Details.super.init(self, options, layout_opts)
end

function Details:set_lines(lines)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, { '' })
  lines = _.map(function(line)
    if type(line) == 'string' then
      line = Line({ Text(line) })
    end
    return line
  end, lines)

  for i, line in ipairs(lines) do
    line:render(self.bufnr, self.ns_id, i)
  end
end

---@param plugin Plugin
function Details:set_plugin(plugin)
  local lines = {
    Line({ Text(' ' .. plugin.name, 'Title') }),
    Line({ Text(' ' .. plugin.url) }),
    Line({ Text('') }),
  }

  local winid = u.buf_get_win(self.bufnr)
  local width = vim.api.nvim_win_get_width(winid)
  for _, line in ipairs(part_text_to_width(plugin.description, width)) do
    table.insert(lines, Line({ Text(line) }))
  end

  table.insert(lines, Line({ Text('') }))
  table.insert(lines, Line({ Text('GitHub Stargazers: ' .. plugin.stars) }))
  table.insert(lines, Line({ Text('') }))
  table.insert(lines, Line({ Text('Tags') }))
  for _, tag in ipairs(plugin.tags) do
    table.insert(lines, Line({ Text(' •' .. tag) }))
  end

  self:set_lines(lines)
end

return Details
