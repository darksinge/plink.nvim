local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local icons = lvim.icons

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
  prompt = icons.ui.Search .. " ",
  default_value = "",
  on_close = function()
    print("Input Closed!")
  end,
  on_submit = function(value)
    print("Input Submitted: " .. value)
  end,
})

local unmount = function()
  input:unmount()
end

input:map('n', 'q', unmount, { silent = true, noremap = true })
input:map('n', '<esc>', unmount, { silent = true, noremap = true })
input:map('i', '<esc>', unmount, { silent = true, noremap = true })


-- mount/open the component
input:mount()

-- unmount component when cursor leaves buffer
input:on(event.BufLeave, function()
  input:unmount()
end)
