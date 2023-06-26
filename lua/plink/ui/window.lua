local event = require('nui.utils.autocmd').event
local Line = require("nui.line")
local Table = require("nui.table")

local Text = require("nui.text")
local Layout = require('nui.layout')
local Popup = require("nui.popup")
local search = require('plink.search')
local Input = require('plink.ui.input')

local get_bufnr = vim.api.nvim_get_current_buf

local search_results = Popup({
  enter = false,
  border = {
    style = "rounded",
    text = {
      top = "Results",
      top_align = "center",
    },
  },
})

local details = Popup({
  enter = false,
  border = {
    style = "rounded",
    text = {
      top = "Details",
      top_align = "center",
    },
  },
})

local function get_window_id(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local win_bufnr = vim.api.nvim_win_get_buf(winid)
    if win_bufnr == bufnr then
      return winid
    end
  end
end

local set_win_by_bufnr = function(bufnr)
  local winid = get_window_id(bufnr)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
  end
end

local function handle_data(plugins)
  if plugins then
    print('fetched ' .. #plugins .. ' plugins')

    local lines = {}
    for _, plugin in ipairs(plugins) do
      local line = plugin.name .. ': ' .. plugin.description
      table.insert(lines, line)
    end

    local bufnr = search_results.bufnr
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    end
  end
end

local function on_submit(value)
  search.search_async(value, vim.schedule_wrap(handle_data))
end

local function on_change(value)
  search.search_async(value, vim.schedule_wrap(handle_data))
end

local input = Input.create({ on_submit = on_submit, on_change = on_change })

local layout = Layout(
  {
    position = "50%",
    size = {
      width = 100,
      height = "50%",
    },
    -- dir = 'row',
  },
  Layout.Box(
    {
      Layout.Box(details, { size = '50%' }),
      Layout.Box(input, { size = 3 }),
      Layout.Box(search_results, { grow = 1 }),
    },
    {
      -- grow = 1,
      dir = 'col',
      size = '50%',
    }
  )
)

search_results:on(event.BufLeave, function()
  local bufnr = get_bufnr()
  local should_exit = true
  for _, component in ipairs({ search_results, input, details }) do
    if bufnr == component.bufnr then
      should_exit = false
    end
  end

  if should_exit then
    layout:unmount()
  end
end, { once = true })

local function did_exit_layout()
  local bufnr = get_bufnr()
  local did_exit = bufnr ~= input.bufnr and bufnr ~= search_results.bufnr or false
  return did_exit
end

local prev_buf = nil
local prev_keymaps = {}

for _, km in ipairs(vim.api.nvim_get_keymap('n')) do
  if km.lhs == ' c' then
    prev_keymaps[km.lhs] = km
    print(vim.inspect(prev_keymaps[km.lhs]))
    break
  end
end


local is_mounted = false

local unmount = function()
  local ok = pcall(layout.unmount, layout)
  is_mounted = false
  if not ok then
    vim.notify_once('error unmounting layout', vim.log.levels.ERROR)
  end

  if prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
    set_win_by_bufnr(prev_buf)
  end

  local km = prev_keymaps[' c']
  if km then
    local rhs = nil
    if type(km.rhs) == 'string' then
      rhs = km.rhs
    elseif type(km.callback) == 'function' then
      rhs = km.callback
    elseif km.script ~= 0 then
      rhs = km.script
    end
    local opts = {}
    if km.silent == 1 then
      opts.silent = true
    end
    if km.noremap == 1 then
      opts.noremap = true
    end
    if rhs then
      vim.keymap.set('n', km.lhs, rhs, opts)
    end
  end
end

local mount = function()
  is_mounted = true
  prev_buf = get_bufnr()
  layout:mount()
end

local on_buf_leave = function()
  vim.schedule(function()
    if did_exit_layout() then
      unmount()
    end
  end)
end

input:on(event.BufLeave, on_buf_leave)
search_results:on(event.BufLeave, on_buf_leave)

local map_opts = { noremap = true, silent = true }

input:map('n', '<C-k>', function()
  set_win_by_bufnr(search_results.bufnr)
end, map_opts)

search_results:map('n', '<C-j>', function()
  set_win_by_bufnr(input.bufnr)
end, map_opts)

vim.keymap.set('n', '<leader>c', function()
  set_win_by_bufnr(input.bufnr)
end, map_opts)

vim.keymap.set('n', '<leader>C', function()
  set_win_by_bufnr(input.bufnr)
end, map_opts)

vim.api.nvim_create_user_command('Plink', function()
  if not is_mounted then
    mount()
  end
  pcall(layout.show, layout)
end, { force = true })


mount()
