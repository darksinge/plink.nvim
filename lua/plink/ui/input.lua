local Input = require("nui.input")

local prompt = " "

local M = {}

---@param opts { on_close: fun(...)|nil, on_submit: fun(value: string)|nil} | nil
M.create = function(opts)
  opts = opts or {}
  local input = Input({
    position = "50%",
    size = {
      width = "33%",
    },
    border = {
      style = "single",
      text = {
        top = "Search Plugins",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    prompt = prompt,
    default_value = "",
    on_close = function()
      if opts.on_close then
        opts.on_close()
      end
    end,
    on_submit = function(value)
      if opts.on_submit then
        opts.on_submit(value)
      end
    end,
    on_change = function(value)
      if opts.on_change then
        opts.on_change(value)
      end
    end,
  })

  local hide = function()
    input:hide()
  end

  local map_opts = { silent = true, noremap = true }

  input:map('n', 'q', hide, map_opts)
  input:map('n', '<esc>', hide, map_opts)
  -- input:map('i', '<esc>', hide, map_opts)

  return input
end

return M
