local pickers = require('telescope.pickers')
local previewers = require('telescope.previewers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local api = require('plink.api')

local function format_entry_for_preview(bufnr, entry)
  local desc = {}
  local i = 1
  while i <= #entry.description do
    local to = i + 60
    local char = string.sub(entry.description, to, to)
    while char ~= ' ' and to <= #entry.description do
      to = to + 1
      char = string.sub(entry.description, to, to)
      if not char then
        break
      end
    end

    table.insert(desc, entry.description:sub(i, to))
    i = to + 1
  end
  local lines = {
    '# ' .. entry.name,
    'url: ' .. entry.url,
    '',
  }
  for _, line in ipairs(desc) do
    table.insert(lines, line)
  end
  table.insert(lines, '')
  table.insert(lines, 'Stars on GitHub: ' .. entry.stars)
  table.insert(lines, '')
  table.insert(lines, 'tags:')
  for _, tag in ipairs(entry.tags) do
    table.insert(lines, ' - ' .. tag)
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'md')
end

local json_previewer = previewers.new_buffer_previewer({
  define_preview = function(self, entry, status)
    format_entry_for_preview(self.state.bufnr, entry.value)
  end
})

-- our picker function: colors
local plugin_finder = function(opts)
  opts = opts or {}

  local entry_maker = function(entry)
    if not entry or entry.name == nil then
      return nil
    end

    local name = entry.name or ''
    local desc = entry.description or ''
    return {
      value = entry,
      ordinal = name .. ' ' .. desc,
      display = name .. ' ' .. desc,
    }
  end

  pickers.new(opts, {
    prompt_title = 'Plugin Finder',
    finder = finders.new_dynamic({
      fn = function(prompt)
        local results = api.search(prompt)
        if not results or #results == 0 then
          return { prompt }
        end
        for i, result in ipairs(results) do
          result.idx = i
        end
        return results
      end,
      entry_maker = entry_maker,
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_put({ selection[1] }, "", false, true)
      end)
      return true
    end,
    previewer = json_previewer,
    -- previewer = previewers.new({
    --   preview_fn = function(entry, status)
    --   end
    -- }),
  }):find()
end

return plugin_finder
