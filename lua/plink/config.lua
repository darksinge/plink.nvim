WELCOME_MESSAGE = [[
 
     If you don't ask the right questions,
        you don't get the right answers.
                                      ~ Robert Half
]]

local M = {}
function M.defaults()
  local defaults = {
    api_key_cmd = nil,
    yank_register = "+",
    edit_with_instructions = {
      diff = false,
      keymaps = {
        close = "<C-c>",
        accept = "<C-y>",
        toggle_diff = "<C-d>",
        toggle_settings = "<C-o>",
        cycle_windows = "<Tab>",
        use_output_as_input = "<C-i>",
      },
    },
    chat = {
      welcome_message = WELCOME_MESSAGE,
      loading_text = "Loading, please wait ...",
      question_sign = "", -- 🙂
      answer_sign = "ﮧ", -- 🤖
      max_line_length = 120,
      sessions_window = {
        border = {
          style = "rounded",
          text = {
            top = " Sessions ",
          },
        },
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      },
      keymaps = {
        close = { "<C-c>" },
        yank_last = "<C-y>",
        yank_last_code = "<C-k>",
        scroll_up = "<C-u>",
        scroll_down = "<C-d>",
        new_session = "<C-n>",
        cycle_windows = "<Tab>",
        cycle_modes = "<C-f>",
        next_message = "<C-j>",
        prev_message = "<C-k>",
        select_session = "<Space>",
        rename_session = "r",
        delete_session = "d",
        draft_message = "<C-d>",
        edit_message = "e",
        delete_message = "d",
        toggle_settings = "<C-o>",
        toggle_message_role = "<C-r>",
        toggle_system_role_open = "<C-s>",
      },
    },
    popup_layout = {
      default = "center",
      center = {
        width = "80%",
        height = "80%",
      },
      right = {
        width = "30%",
        width_settings_open = "50%",
      },
    },
    popup_window = {
      border = {
        highlight = "FloatBorder",
        style = "rounded",
        text = {
          top = " ChatGPT ",
        },
      },
      win_options = {
        wrap = true,
        linebreak = true,
        foldcolumn = "1",
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
      buf_options = {
        filetype = "markdown",
      },
    },
    system_window = {
      border = {
        highlight = "FloatBorder",
        style = "rounded",
        text = {
          top = " SYSTEM ",
        },
      },
      win_options = {
        wrap = true,
        linebreak = true,
        foldcolumn = "2",
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    },
    popup_input = {
      prompt = "  ",
      border = {
        highlight = "FloatBorder",
        style = "rounded",
        text = {
          top_align = "center",
          top = " Prompt ",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
      submit = "<C-Enter>",
      submit_n = "<Enter>",
    },
    settings_window = {
      border = {
        style = "rounded",
        text = {
          top = " Settings ",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    },
    openai_params = {
      model = "gpt-3.5-turbo",
      frequency_penalty = 0,
      presence_penalty = 0,
      max_tokens = 300,
      temperature = 0,
      top_p = 1,
      n = 1,
    },
    openai_edit_params = {
      model = "code-davinci-edit-001",
      temperature = 0,
      top_p = 1,
      n = 1,
    },
    actions_paths = {},
    show_quickfixes_cmd = "Trouble quickfix",
    predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
    search_layout = {
      position = "50%",
      size = {
        width = '33%',
        height = "50%",
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

-- M.options = {}
M.options = vim.tbl_deep_extend("force", {}, M.defaults(), {})

M.namespace_id = vim.api.nvim_create_namespace("PlinkNS")

local function setup_highlights()
  vim.api.nvim_set_hl(0, "ChatGPTQuestion", { fg = "#b4befe", italic = true, bold = false, default = true })

  vim.api.nvim_set_hl(0, "ChatGPTWelcome", { fg = "#9399b2", italic = true, bold = false, default = true })

  vim.api.nvim_set_hl(0, "ChatGPTTotalTokens", { fg = "#ffffff", bg = "#444444", default = true })
  vim.api.nvim_set_hl(0, "ChatGPTTotalTokensBorder", { fg = "#444444", default = true })

  vim.api.nvim_set_hl(0, "ChatGPTMessageAction", { fg = "#ffffff", bg = "#1d4c61", italic = true, default = true })

  vim.api.nvim_set_hl(0, "ChatGPTCompletion", { fg = "#9399b2", italic = true, bold = false, default = true })
end

local function setup_signs(options)
  vim.cmd("highlight default link ChatGPTSelectedMessage ColorColumn")

  vim.cmd([[sign define chatgpt_action_start_block text=┌ texthl=ErrorMsg linehl=BufferLineBackground]])
  vim.cmd([[sign define chatgpt_action_middle_block text=│ texthl=ErrorMsg linehl=BufferLineBackground]])
  vim.cmd([[sign define chatgpt_action_end_block text=└ texthl=ErrorMsg linehl=BufferLineBackground]])

  vim.cmd([[sign define chatgpt_chat_start_block text=┌ texthl=Constant]])
  vim.cmd([[sign define chatgpt_chat_middle_block text=│ texthl=Constant]])
  vim.cmd([[sign define chatgpt_chat_end_block text=└ texthl=Constant]])

  vim.cmd("sign define chatgpt_question_sign text=" .. options.chat.question_sign .. " texthl=ChatGPTQustion")
end

function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults(), options)
  setup_highlights()
  setup_signs(M.options)
end

-- TODO: Remove this call to setup() eventually, it should be done by the user
M.setup()

return M
