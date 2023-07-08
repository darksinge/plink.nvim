local loaders = reload('plink.plugin-loaders')
local Path = require('plenary.path')

local M = {}

vim.cmd([[sign define plink-search text= texthl=Pmenu]])

local function config_highlights()
  vim.api.nvim_set_hl(0, "PlinkLoadingPillCenter", { fg = "#ffffff", bg = "#444444", default = true })
  vim.api.nvim_set_hl(0, "PlinkLoadingPillEdge", { fg = "#444444", default = true })
end

local function config_signs()
  vim.fn.sign_define('multiprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })
  vim.fn.sign_define('singleprompt_sign', { text = ' ', texthl = 'LineNr', numhl = 'LineNr' })
end

local function config_install_behavior()
  local conf = M.options.install_behavior
  if type(conf.path) == 'string' then
    conf.path = vim.fn.expand(conf.path)
  end

  if conf.distro and loaders[conf.distro] then
    conf.plugins = loaders[conf.distro]()
  end

  M.options.install_behavior = conf
end

local function on_install(plugin)
  local path = Path:new(M.options.install_behavior.path)
  if not path:is_file() then
    return
  end

  vim.schedule(function()
    vim.fn.setreg('+', '{ "' .. plugin .. '" }')
    vim.notify('config for ' .. plugin .. ' copied to clipboard')
    vim.cmd('edit ' .. path.filename)
  end)
end

function M.defaults()
  return {
    install_behavior = {
      enabled = true,
      path = nil,
      distro = nil,
      plugins = {},
      on_install = on_install
    },
    keymaps = {
      close = "<leader>pc",
      force_close = "<leader>px",
      cycle_windows = "<Tab>",
      select_plugin = "<Space>",
      install_plugin = "I",
      delete_plugin = "D",
      update_plugin = "U",
      goto_plugin_config = "not implemented",
      toggle_settings = "not implemented"
    },
    search_layout = {
      position = "50%",
      -- relative = 'editor',
      size = {
        width = '33%',
        height = "75%",
        min_width = 60,
        max_width = 200,
      },
      inner_layout = {
        dir = 'col',
      },
    },
    search_input = {
      win_options = {
        spell = false,
      },
      size = {
        width = "100%",
      },
      border = {
        style = 'rounded',
        text = {
          top = "Search",
          top_align = "center",
        },
      },
      layout = {
        size = {
          height = 3,
          width = '100%',
        },
      },
    },
    search_output = {
      layout = {
        grow = 1,
      },
      buf_options = {
        filetype = "plink",
      },
    },
    search_details = {
      border = {
        style = 'rounded',
        text = {
          top = "Details",
          top_align = "center",
        },
      },
      layout = {
        grow = 1,
      },
      buf_options = {
        filetype = "plink",
      },
    }
  }
end

M.options = {}

M.namespace_id = vim.api.nvim_create_namespace("PlinkNS")

function M.setup(opts)
  opts = opts or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults(), opts)
  config_install_behavior()
  config_highlights()
  config_signs()
  return M.options
end

-- TODO: Remove this
M.setup({
  install_behavior = {
    path = '~/.config/lvim/lua/user/plugins.lua',
    distro = 'lvim',
  }
})

return M
