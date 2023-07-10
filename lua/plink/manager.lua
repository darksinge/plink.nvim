local Path = require('plenary.path')
local Object = require('nui.object')

local loaders = reload('plink.plugin-loaders')

---@alias PluginManager 'lazy'|'packer'|'plug'

---@class InstallBehavior
---@field enabled boolean
---@field strategy? 'clipboard'|'treesitter'

---@class ManagerOpts
---@field install_behavior? InstallBehavior
---@field plugin_manager? PluginManager
---@field plugin_loader? fun(manager: Manager): Plugin[]
---@field config_path? string

---@return PluginManager | nil
local function try_find_plugin_manager()
  if pcall(require, 'lazy') then
    return 'lazy'
  end

  if pcall(require, 'packer') then
    return 'packer'
  end

  if vim.fn.exists(':PlugInstall') then
    return 'plug'
  end

  return nil
end

---@return InstallBehavior
local function get_default_install_behavior()
  return {
    enabled = true,
    strategy = 'treesitter',
    plugin_manager = try_find_plugin_manager(),
  }
end

---@class Manager
---@field config_path string -- path to config file with plugins
---@field install_behavior InstallBehavior
---@field plugin_manager? PluginManager
---@field plugin_loader? fun(manager: Manager): Plugin[]
---@field plugins table<string, Plugin>
local Manager = Object("PlinkManager")

---@param opts ManagerOpts
function Manager:init(opts)
  self.plugins = {}
  self.config_path = opts.config_path
  self.install_behavior = vim.tbl_deep_extend('keep', opts.install_behavior or {}, get_default_install_behavior())
  self.plugin_manager = opts.plugin_manager or try_find_plugin_manager()
  self.plugin_loader = opts.plugin_loader or loaders[self.plugin_manager]
end

function Manager:load_plugin_list()
  if type(self.plugin_loader) ~= 'function' then
    return
  end

  ---@type Plugin[]
  self.plugins = {}
  local plugin_names = {}
  local plugins_keyed_by_name = {}
  for _, plugin in ipairs(self.plugin_loader(self)) do
    table.insert(plugin_names, string.lower(plugin.name))
    plugins_keyed_by_name[string.lower(plugin.name)] = plugin
  end
  table.sort(plugin_names)

  for _, name in ipairs(plugin_names) do
    table.insert(self.plugins, plugins_keyed_by_name[string.lower(name)])
  end
end

---@param plugin string
function Manager:add_plugin(plugin)
  if type(self.config_path) ~= 'string' then
    return
  end

  local path = Path:new(vim.fn.expand(self.config_path))
  if not path:is_file() then
    return
  end

  -- TODO: Use treesitter to add plugin to correct place in plugin config file.
  vim.schedule(function()
    vim.fn.setreg('+', '{ "' .. plugin .. '" }')
    vim.notify('config for ' .. plugin .. ' copied to clipboard')
    vim.cmd('edit ' .. path.filename)
  end)
end

return Manager
