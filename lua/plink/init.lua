local Config = reload('plink.config')
local loaders = reload('plink.plugin-loaders')

local M = {}

vim.cmd([[sign define plink-search text= texthl=Pmenu]])

local function get_default_install_behavior()
  return {
    enabled = true,
    path = nil,
    distro = nil,
    plugins = {},
    on_install = function(plugin)
      vim.schedule(function()
        vim.fn.setreg('+', '{ "' .. plugin .. '" }')
        if M.path then
          vim.notify('config for ' .. plugin .. ' copied to clipboard')
          vim.cmd('edit ' .. M.path)
        end
      end)
    end
  }
end

local function get_install_behavior(opts)
  local conf = vim.tbl_extend('keep', opts, get_default_install_behavior())

  if type(conf.path) == 'string' then
    conf.path = vim.fn.expand(conf.path)
  end

  if conf.distro and loaders[conf.distro] then
    conf.plugins = loaders[conf.distro]()
  end

  return conf
end

local function setup_install_behavior(opts)
  for k, v in pairs(get_install_behavior(opts)) do
    M[k] = v
  end
end

M.setup = function(options)
  options = Config.setup(options)
  setup_install_behavior(options.install_behavior)
end

return M
