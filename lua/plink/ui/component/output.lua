local BasePopup = require('plink.ui.component.popup')
local defaults = require('nui.utils').defaults
local Config = require('plink.config')
local Layout = require('nui.layout')

local SearchOuput = BasePopup:extend('SearchOuput')

function SearchOuput:init(options, layout_opts)
  options = defaults(options, Config.search_output)
  options.enter = false
  options.focusable = false

  options.buf_options = vim.tbl_deep_extend('keep', {
    modifiable = true,
    readonly = false,
  }, options.buf_options or {})

  options.win_options = vim.tbl_deep_extend('keep', {
    winblend = 10,
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
  }, options.win_options or {})

  SearchOuput.super.init(self, options, layout_opts)
end

return SearchOuput
