local M = {}

local function raise_not_implemented(distro)
  error(
    'ERROR(plink.nvim) plugin loader for distribution "' .. distro .. '" not implemented',
    vim.log.levels.ERROR
  )
end

function M.lvim()
  local plugins = {}
  if type(lvim) == 'table' then
    for _, plugin in ipairs(lvim.plugins) do
      local name = plugin[1]
      if type(name) == 'string' then
        table.insert(plugins, name)
      end
    end
  end
  return plugins
end

function M.nvchad()
  raise_not_implemented('nvchad')
end

function M.lazyvim()
  raise_not_implemented('lazyvim')
end

function M.astrovim()
  raise_not_implemented('astrovim')
end

return M
