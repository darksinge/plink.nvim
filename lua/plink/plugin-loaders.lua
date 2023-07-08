local e = reload('plink.errors')

local M = {}

---@alias Plugin { name: string, enabled: boolean, installed: boolean }

local function raise_not_implemented(distro)
  e.raise_not_implemented(
    'plugin loader for distribution "' .. distro .. '" not implemented'
  )
end

---@return Plugin[]
function M.from_lazy()
  local has_lazy, lazy = pcall(require, 'lazy')
  if not has_lazy then
    e.raise('lazy.nvim not installed')
  end

  local plugins = {}
  for _, plugin in ipairs(lazy.plugins()) do
    table.insert(plugins, {
      name = plugin[1],
      installed = plugin.installed,
      enabled = plugin.enabled,
    })
  end
  return plugins
end

---@return Plugin[]
function M.from_packer()
  e.raise_not_implemented('#from_packer() not implemented')

  local has_packer, _ = pcall(require, 'packer')
  if not has_packer then
    e.raise('packer.nvim not installed')
  end
  return {}
end

---@return Plugin[]
function M.nvchad()
  raise_not_implemented('nvchad')
  return {}
end

---@return Plugin[]
function M.lazyvim()
  raise_not_implemented('lazyvim')
  return {}
end

---@return Plugin[]
function M.astrovim()
  raise_not_implemented('astrovim')
  return {}
end

---@return Plugin[]
function M.lvim()
  return M.from_lazy()
end

return M
