local e = reload('plink.errors')

local M = {}

---@alias Plugin { name: string, enabled: boolean, installed: boolean }

local function raise_not_implemented(distro)
  e.raise_not_implemented(
    'plugin loader for distribution "' .. distro .. '" not implemented'
  )
end

---@return Plugin[]
function M.lazy()
  local has_lazy, lazy = pcall(require, 'lazy')
  if not has_lazy then
    e.raise('lazy.nvim not installed')
  end

  local plugins = {}
  for _, plugin in ipairs(lazy.plugins()) do
    local name = plugin[1] or plugin.name
    local installed = plugin.installed or plugin._.installed or true
    local is_local = plugin.is_local or plugin._.is_local or false
    local enabled = plugin.enabled or plugin._.enabled or true

    local dir = nil
    if is_local then
      dir = plugin.dir or plugin._.dir
    end

    if type(name) == 'string' then
      table.insert(plugins, {
        name = name,
        installed = installed,
        enabled = enabled,
        dir = dir,
        is_local = is_local,
      })
    end
  end
  return plugins
end

---@return Plugin[]
function M.packer()
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
  return M.lazy()
end

return M
