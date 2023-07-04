local NuiText = require('nui.text')

---@class Text
local Text = NuiText:extend('Text')

function Text:init(content, extmark, line_extmark)
  self.line_extmark = line_extmark
  Text.super.init(self, content, extmark)
end

function Text:set(content, extmark, line_extmark)
  if line_extmark then
    -- preserve self.extmark.id
    local id = self.line_extmark and self.line_extmark.id or nil
    self.line_extmark = type(extmark) == "string" and { line_hl_group = line_extmark } or vim.deepcopy(extmark)
    self.line_extmark.id = id
  end

  return Text.super.set(self, content, extmark)
end

function Text:line_highlight(bufnr, ns_id, linenr)
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

return Text
