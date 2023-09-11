local NuiLine = require('nui.line')
local Text = require('plink.ui.component.text')
local _ = require("nui.utils")._

---@class Line
---@field super { init: fun(...) }
---@field line_extmark {line_hl_group: string, id?: number} | nil
local Line = NuiLine:extend('Line')

---@alias LineOpts { [1]: string, hl?: string, line_hl?: string} | string

---@param texts string[]|Text[]
---@param line_hl? string
function Line:init(texts, line_hl)
  if line_hl then
    self.line_extmark = self:set_line_highlight(line_hl)
  end
  return Line.super.init(self, texts)
end

---@param line_extmark string|{id:number, line_hl_group: string}
function Line:set_line_highlight(line_extmark)
  local id = self.line_extmark and self.line_extmark.id or nil
  self.line_extmark = type(line_extmark) == 'string' and { line_hl_group = line_extmark } or vim.deepcopy(line_extmark)
  self.line_extmark.id = id
end

function Line:line_highlight(bufnr, ns_id, linenr)
  if not self.line_extmark then
    return
  end

  self.line_extmark.id =
      vim.api.nvim_buf_set_extmark(
        bufnr,
        _.ensure_namespace_id(ns_id),
        linenr - 1,
        0,
        self.line_extmark
      )
end

return Line
