local event = require('nui.utils.autocmd').event
local Line = require("nui.line")
local Split = require("nui.split")
local Table = require("nui.table")

local Text = require("nui.text")
local Layout = require('nui.layout')
local Popup = require("nui.popup")
local search = require('plink.search')
local Input = require('plink.ui.input')

local popup = Popup({
  enter = false,
  border = "single",
})

local tbl_popup = Popup({
  enter = false,
  border = "single",
})

local function cell_id(cell)
  return cell.column.id
end

local function capitalize(value)
  return (string.gsub(value, "^%l", string.upper))
end

local grouped_columns = {
  {
    align = "center",
    header = "Name",
    footer = cell_id,
    columns = {
      {
        accessor_key = "firstName",
        cell = function(cell)
          return Text(capitalize(cell.get_value()), "DiagnosticInfo")
        end,
        header = "First",
        footer = cell_id,
      },
      {
        id = "lastName",
        accessor_fn = function(row)
          return capitalize(row.lastName)
        end,
        header = "Last",
        footer = cell_id,
      },
    },
  },
  {
    align = "center",
    header = "Info",
    footer = cell_id,
    columns = {
      {
        align = "center",
        accessor_key = "age",
        cell = function(cell)
          return Line({ Text(tostring(cell.get_value()), "DiagnosticHint"), Text(" y/o") })
        end,
        header = "Age",
        footer = "age",
      },
      {
        align = "center",
        header = "More Info",
        footer = cell_id,
        columns = {
          {
            align = "right",
            accessor_key = "visits",
            header = "Visits",
            footer = cell_id,
          },
          {
            accessor_key = "status",
            header = "Status",
            footer = cell_id,
            max_width = 6,
          },
        },
      },
    },
  },
  {
    align = "right",
    header = "Progress",
    accessor_key = "progress",
    footer = cell_id,
  },
}

local table = Table({
  bufnr = tbl_popup.bufnr,
  columns = grouped_columns,
  data = {
    {
      firstName = "tanner",
      lastName = "linsley",
      age = 24,
      visits = 100,
      status = "In Relationship",
      progress = 50,
    },
    {
      firstName = "tandy",
      lastName = "miller",
      age = 40,
      visits = 40,
      status = "Single",
      progress = 80,
    },
    {
      firstName = "joe",
      lastName = "dirte",
      age = 45,
      visits = 20,
      status = "Complicated",
      progress = 10,
    },
  },
})


local function handle_data(plugins)
  if plugins then
    print('fetched ' .. #plugins .. ' plugins')
  end
end

local function on_submit(value)
  search.search_async(value, handle_data)
end

local function on_change(value)
  -- search_async is debounced, so this is okay
  search.search_async(value, handle_data)
end

local input = Input.create({ on_submit = on_submit, on_change = on_change })

local layout = Layout(
  {
    position = "50%",
    size = {
      width = 80,
      height = "40%",
    },
  },
  Layout.Box({
    Layout.Box(popup, { size = '33%' }),
    Layout.Box(input, { size = 3 }),
    Layout.Box(tbl_popup, { size = '66%' })
  }, { dir = "col" })
)

local function get_window_id(buffer)
  -- Get the buffer number
  local bufnr = vim.fn.bufnr(buffer)

  -- Iterate through all windows in the current tabpage
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- Get the buffer number of the window
    local win_bufnr = vim.api.nvim_win_get_buf(winid)

    -- Compare the buffer numbers to find the window associated with the buffer
    if win_bufnr == bufnr then
      return winid -- Return the window ID
    end
  end

  return nil -- Return nil if the buffer is not found in any window
end

popup:on(event.BufLeave, function()
  popup:unmount()
  input:unmount()
  tbl_popup:unmount()
end, { once = true })

input:on(event.BufLeave, function()
  popup:unmount()
  input:unmount()
  tbl_popup:unmount()
end, { once = true })

table:render()

-- split:mount()

tbl_popup:map("n", "x", function()
  local cell = table:get_cell()
  if cell then
    local column = cell.column
    if column.accessor_key then
      cell.row.original[column.accessor_key] = "Poof!"
    end
    table:refresh_cell(cell)
  end
end, {})


layout:mount()
