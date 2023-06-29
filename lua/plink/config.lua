local M = {}

function M.defaults()
  local defaults = {
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
      size = {
        width = '33%',
        height = "90%",
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
      border = {
        style = 'rounded',
        text = {
          top = "Results",
          top_align = "center",
        },
      },
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
  return defaults
end

M.options = M.defaults()

M.namespace_id = vim.api.nvim_create_namespace("PlinkNS")

function M.setup(options)
  options = options or {}

  M.options = vim.tbl_deep_extend("force", {}, M.defaults(), options)

  vim.api.nvim_set_hl(0, "PlinkLoadingPillCenter", { fg = "#ffffff", bg = "#444444", default = true })
  vim.api.nvim_set_hl(0, "PlinkLoadingPillEdge", { fg = "#444444", default = true })
end

-- TODO: Remove this call to setup() eventually, it should be done by the user
M.setup()

return M
