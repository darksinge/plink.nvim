local _ = require('neodash')
local curl_ok, curl = pcall(require, 'plenary.curl')
local job_ok, Job = pcall(require, 'plenary.job')
if not curl_ok or not job_ok then
  vim.notify_once('Missing required dependency: nvim-lua/plenary.nvim')
  return
end

---@alias Plugin {description: string, name: string, score: number, stars: number, tags: string[], url: string}

local base_url = 'https://3051j7te1j.execute-api.us-east-1.amazonaws.com'

local M = {}

local function parse_querystring(qs)
  return string.gsub(qs, ' ', '%%20')
end

local function build_url(route, querystring_params)
  local url = base_url .. route

  if querystring_params then
    local params = {}
    for key, value in pairs(querystring_params) do
      table.insert(params, key .. '=' .. parse_querystring(value))
    end
    url = url .. '?' .. table.concat(params, '&')
  end

  return url
end

---@param query string
---@return Plugin[] | nil
M.search = function(query)
  local res = curl.get({
    url = build_url('/search', {
      q = query,
      -- testDelay = 1000,
    }),
  })

  if res.status == 200 then
    local json = vim.fn.json_decode(res.body)
    if not json then
      error 'error decoding json'
    end

    return json.results
  end

  error('api returned non 200 status: ' .. res.status)
end

M.search_job = function(query, handler)
  local url = build_url('/search', {
    q = query,
    testDelay = 1000,
  })

  Job:new({
    command = 'curl',
    args = { url },
    on_exit = function(response, exit_code)
      local data = response:result()
      -- local res = vim.fn.json_decode(data)
      vim.schedule(function()
        local json = vim.fn.json_decode(data[1])
        json = json or { results = {} }
        handler(json.results)
      end)
    end
  }):start()
end

M.fake_search = function(_, handler)
  local json = [[{
  "results": [
      {
        "name": "ThePrimeagen/harpoon",
        "url": "https://github.com/ThePrimeagen/harpoon",
        "description": "A per project, auto updating and editable marks utility for fast file navigation.",
        "tags": [
          "marks"
        ],
        "score": 0.000748,
        "stars": 0
      },
      {
        "name": "haringsrob/nvim_context_vt",
        "url": "https://github.com/haringsrob/nvim_context_vt",
        "description": "Shows virtual text of the current context.",
        "tags": [
          "editing support"
        ],
        "score": 0.015625,
        "stars": 0
      },
      {
        "name": "mhartington/oceanic-next",
        "url": "https://github.com/mhartington/oceanic-next",
        "description": "Oceanic Next theme.",
        "tags": [
          "colorscheme",
          "tree-sitter supported colorscheme"
        ],
        "score": 0.017576,
        "stars": 0
      },
      {
        "name": "mhartington/formatter.nvim",
        "url": "https://github.com/mhartington/formatter.nvim",
        "description": "A format runner written in Lua.",
        "tags": [
          "formatting"
        ],
        "score": 0.017576,
        "stars": 0
      },
      {
        "name": "kkharji/sqlite.lua",
        "url": "https://github.com/kkharji/sqlite.lua",
        "description": "SQLite/LuaJIT binding for Lua and Neovim.",
        "tags": [
          "neovim lua development"
        ],
        "score": 0.019683,
        "stars": 0
      },
      {
        "name": "m4xshen/hardtime.nvim",
        "url": "https://github.com/m4xshen/hardtime.nvim",
        "description": "Helping you establish good command workflow and habit.",
        "tags": [
          "workflow"
        ],
        "score": 0.021999,
        "stars": 0
      },
      {
        "name": "saifulapm/chartoggle.nvim",
        "url": "https://github.com/saifulapm/chartoggle.nvim",
        "description": "Toggle any character at end of line.",
        "tags": [
          "utility"
        ],
        "score": 0.022002,
        "stars": 0
      },
      {
        "name": "ojroques/nvim-hardline",
        "url": "https://github.com/ojroques/nvim-hardline",
        "description": "A statusline / bufferline. It is inspired by [vim-airline](https://github.com/vim-airline/vim-airline) but aims to be as light and simple as possible.",
        "tags": [
          "bars and lines",
          "statusline"
        ],
        "score": 0.039765,
        "stars": 0
      },
      {
        "name": "catppuccin/nvim",
        "url": "https://github.com/catppuccin/nvim",
        "description": "Warm mid-tone dark theme to show off your vibrant self! with support for native LSP, Tree-sitter, and more 🍨!",
        "tags": [
          "colorscheme",
          "tree-sitter supported colorscheme"
        ],
        "score": 0.090999,
        "stars": 0
      },
      {
        "name": "darksinge/plink.nvim",
        "url": "https://github.com/darksinge/plink.nvim",
        "description": "Plugin finder",
        "tags": [
          "plugin"
        ],
        "score": 0.125,
        "stars": 11
      },
      {
        "name": "hrsh7th/nvim-cmp",
        "url": "https://github.com/hrsh7th/nvim-cmp",
        "description": "A completion plugin written in Lua. New version of nvim-compe.",
        "tags": [
          "completion"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "marko-cerovac/material.nvim",
        "url": "https://github.com/marko-cerovac/material.nvim",
        "description": "Material.nvim is a highly configurable colorscheme written in Lua and based on the material palette.",
        "tags": [
          "colorscheme",
          "tree-sitter supported colorscheme"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "darksinge/neodash.nvim",
        "url": "https://github.com/darksinge/neodash.nvim",
        "description": "A utility library providing 'lodash' like functions for Lua",
        "tags": [
          "utility"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "hkupty/iron.nvim",
        "url": "https://github.com/hkupty/iron.nvim",
        "description": "Interactive REPLs of over 30 languages embedded.",
        "tags": [
          "code runner"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "MarcHamamji/runner.nvim",
        "url": "https://github.com/MarcHamamji/runner.nvim",
        "description": "A customizable Lua code runner.",
        "tags": [
          "code runner"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "aaronhallaert/advanced-git-search.nvim",
        "url": "https://github.com/aaronhallaert/advanced-git-search.nvim",
        "description": "Search your git history by commit content, message and author with Telescope.",
        "tags": [
          "git"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "karb94/neoscroll.nvim",
        "url": "https://github.com/karb94/neoscroll.nvim",
        "description": "Smooth scrolling.",
        "tags": [
          "scrolling"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "cappyzawa/trim.nvim",
        "url": "https://github.com/cappyzawa/trim.nvim",
        "description": "This plugin trims trailing whitespace and lines.",
        "tags": [
          "formatting"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "Darazaki/indent-o-matic",
        "url": "https://github.com/Darazaki/indent-o-matic",
        "description": "Dumb automatic fast indentation detection written in Lua.",
        "tags": [
          "formatting",
          "indent"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "hkupty/nvimux",
        "url": "https://github.com/hkupty/nvimux",
        "description": "Neovim as tmux replacement.",
        "tags": [
          "split and window",
          "tmux"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "artart222/CodeArt",
        "url": "https://github.com/artart222/CodeArt",
        "description": "A fast general-purpose IDE written entirely in Lua with an installer for Linux/Windows/macOS and built in `:CodeArtUpdate` command for updating it.",
        "tags": [
          "preconfigured configuration"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "hackorum/VapourNvim",
        "url": "https://github.com/hackorum/VapourNvim",
        "description": "A Neovim config for THE ULTIMATE Vim IDE-like experience.",
        "tags": [
          "preconfigured configuration"
        ],
        "score": 0.125,
        "stars": 0
      },
      {
        "name": "ellisonleao/glow.nvim",
        "url": "https://github.com/ellisonleao/glow.nvim",
        "description": "Markdown preview using glow.",
        "tags": [
          "markdown and latex"
        ],
        "score": 0.335178,
        "stars": 0
      },
      {
        "name": "jbyuki/carrot.nvim",
        "url": "https://github.com/jbyuki/carrot.nvim",
        "description": "Markdown evaluator Lua code blocks.",
        "tags": [
          "markdown and latex"
        ],
        "score": 0.360732,
        "stars": 0
      },
      {
        "name": "kdheepak/panvimdoc",
        "url": "https://github.com/kdheepak/panvimdoc",
        "description": "A pandoc to vimdoc GitHub action.",
        "tags": [
          "markdown and latex"
        ],
        "score": 0.380772,
        "stars": 0
      },
      {
        "name": "davidgranstrom/nvim-markdown-preview",
        "url": "https://github.com/davidgranstrom/nvim-markdown-preview",
        "description": "Markdown preview in the browser using pandoc and live-server through Neovim's job-control API.",
        "tags": [
          "markdown and latex"
        ],
        "score": 0.456599,
        "stars": 0
      },
      {
        "name": "bluz71/vim-moonfly-colors",
        "url": "https://github.com/bluz71/vim-moonfly-colors",
        "description": "A dark charcoal colorscheme with modern Neovim support including Tree-sitter.",
        "tags": [
          "colorscheme",
          "tree-sitter supported colorscheme"
        ],
        "score": 0.49625,
        "stars": 0
      },
      {
        "name": "cbochs/grapple.nvim",
        "url": "https://github.com/cbochs/grapple.nvim",
        "description": "Provides tagging, cursor tracking, and immediate navigation to important project files.",
        "tags": [
          "marks"
        ],
        "score": 0.5,
        "stars": 0
      },
      {
        "name": "chentoast/marks.nvim",
        "url": "https://github.com/chentoast/marks.nvim",
        "description": "A better user experience for viewing and interacting with Vim marks.",
        "tags": [
          "marks"
        ],
        "score": 0.5,
        "stars": 0
      },
      {
        "name": "ofirgall/open.nvim",
        "url": "https://github.com/ofirgall/open.nvim",
        "description": "Open the current word with custom openers, GitHub shorthand for example.",
        "tags": [
          "marks"
        ],
        "score": 0.5,
        "stars": 0
      },
      {
        "name": "LeonHeidelbach/trailblazer.nvim",
        "url": "https://github.com/LeonHeidelbach/trailblazer.nvim",
        "description": "TrailBlazer introduces a stack based mark system that enables a completely new dynamic and super fast workflow using project wide marks.",
        "tags": [
          "marks"
        ],
        "score": 0.5,
        "stars": 0
      },
      {
        "name": "tomasky/bookmarks.nvim",
        "url": "https://github.com/tomasky/bookmarks.nvim",
        "description": "Bookmarks with global file storage, written in Lua.",
        "tags": [
          "marks"
        ],
        "score": 0.5,
        "stars": 0
      },
      {
        "name": "metalelf0/jellybeans-nvim",
        "url": "https://github.com/metalelf0/jellybeans-nvim",
        "description": "A port of jellybeans colorscheme.",
        "tags": [
          "lua colorscheme"
        ],
        "score": 0.53812,
        "stars": 0
      },
      {
        "name": "ruifm/gitlinker.nvim",
        "url": "https://github.com/ruifm/gitlinker.nvim",
        "description": "Generate shareable file permalinks for several git hosts. Inspired by tpope/vim-fugitive's :GBrowse.",
        "tags": [
          "git"
        ],
        "score": 0.545094,
        "stars": 0
      },
      {
        "name": "Chaitanyabsrip/present.nvim",
        "url": "https://github.com/Chaitanyabsprip/present.nvim",
        "description": "A Presentation plugin written in Lua.",
        "tags": [
          "media"
        ],
        "score": 0.568015,
        "stars": 0
      },
      {
        "name": "kylechui/nvim-surround",
        "url": "https://github.com/kylechui/nvim-surround",
        "description": "A plugin for adding/changing/deleting surrounding delimiter pairs.",
        "tags": [
          "syntax"
        ],
        "score": 0.592136,
        "stars": 0
      },
      {
        "name": "brenoprata10/nvim-highlight-colors",
        "url": "https://github.com/brenoprata10/nvim-highlight-colors",
        "description": "A plugin to highlight colors with Neovim.",
        "tags": [
          "color"
        ],
        "score": 0.592136,
        "stars": 0
      },
      {
        "name": "lalitmee/cobalt2.nvim",
        "url": "https://github.com/lalitmee/cobalt2.nvim",
        "description": "A port of cobalt2 colorscheme using colorbuddy.",
        "tags": [
          "lua colorscheme"
        ],
        "score": 0.592136,
        "stars": 0
      },
      {
        "name": "gelguy/wilder.nvim",
        "url": "https://github.com/gelguy/wilder.nvim",
        "description": "A plugin for fuzzy command line autocompletion.",
        "tags": [
          "command line"
        ],
        "score": 0.592136,
        "stars": 0
      },
      {
        "name": "svrana/neosolarized.nvim",
        "url": "https://github.com/svrana/neosolarized.nvim",
        "description": "Dark solarized colorscheme using colorbuddy for easy customization.",
        "tags": [
          "colorscheme",
          "tree-sitter supported colorscheme"
        ],
        "score": 0.612168,
        "stars": 0
      },
      {
        "name": "yamatsum/nvim-cursorline",
        "url": "https://github.com/yamatsum/nvim-cursorline",
        "description": "A plugin that highlights cursor words and lines.",
        "tags": [
          "cursorline"
        ],
        "score": 0.612168,
        "stars": 0
      },
      {
        "name": "akinsho/git-conflict.nvim",
        "url": "https://github.com/akinsho/git-conflict.nvim",
        "description": "A plugin to visualise and resolve merge conflicts.",
        "tags": [
          "git"
        ],
        "score": 0.612168,
        "stars": 0
      },
      {
        "name": "antonk52/bad-practices.nvim",
        "url": "https://github.com/antonk52/bad-practices.nvim",
        "description": "Helping you give up bad practices in Vim.",
        "tags": [
          "workflow"
        ],
        "score": 0.612168,
        "stars": 0
      },
      {
        "name": "xiyaowong/nvim-cursorword",
        "url": "https://github.com/xiyaowong/nvim-cursorword",
        "description": "Part of nvim-cursorline. Highlight the word under the cursor.",
        "tags": [
          "cursorline"
        ],
        "score": 0.630252,
        "stars": 0
      },
      {
        "name": "kevinhwang91/nvim-hlslens",
        "url": "https://github.com/kevinhwang91/nvim-hlslens",
        "description": "Helps you better glance searched information, seamlessly jump matched instances.",
        "tags": [
          "search"
        ],
        "score": 0.645281,
        "stars": 0
      },
      {
        "name": "AckslD/messages.nvim",
        "url": "https://github.com/AckslD/messages.nvim",
        "description": "Capture and show any messages in a customisable (floating) buffer.",
        "tags": [
          "utility"
        ],
        "score": 0.645281,
        "stars": 0
      },
      {
        "name": "m00qek/plugin-template.nvim",
        "url": "https://github.com/m00qek/plugin-template.nvim",
        "description": "A plugin template that setups test infrastructure and GitHub Actions.",
        "tags": [
          "boilerplate"
        ],
        "score": 0.645281,
        "stars": 0
      },
      {
        "name": "Dotfyle",
        "url": "https://dotfyle.com",
        "description": "Dotfyle is a site for sharing and discovering Neovim configs and plugins.",
        "tags": [
          "resource"
        ],
        "score": 0.654271,
        "stars": 0
      },
      {
        "name": "DNLHC/glance.nvim",
        "url": "https://github.com/DNLHC/glance.nvim",
        "description": "A pretty window for previewing, navigating and editing your LSP locations.",
        "tags": [
          "lsp",
          "(requires neovim 0.5)"
        ],
        "score": 0.657927,
        "stars": 0
      },
      {
        "name": "savq/melange-nvim",
        "url": "https://github.com/savq/melange-nvim",
        "description": "Warm colorscheme written in Lua with support for various terminal emulators.",
        "tags": [
          "colorscheme",
          "tree-sitter supported colorscheme"
        ],
        "score": 0.657927,
        "stars": 0
      }
    ],
    "total": 50
  }]]
  local res = vim.fn.json_decode(json) or {}
  handler(res.results)
end


return M
