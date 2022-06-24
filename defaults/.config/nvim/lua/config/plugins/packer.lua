-- File:           plugin.lua
-- Description:    Used to configure different plugins
-- Author:		    Reinaldo Molina
-- Email:          me at molinamail dot com
-- Created:        Tue Sep 08 2020 22:20
-- Last Modified:  Tue Sep 08 2020 22:20
local utl = require("utils.utils")

local M = {}
M.__path = vim.fn.stdpath("data") .. [[/site/pack/packer/start/packer.nvim]]
M.__repo = [[https://github.com/wbthomason/packer.nvim]]

function M:__update()
  local p = require("packer")
  local snapshot_time = os.date("%y%m%d_%H%M%S")
  vim.notify("PackerSnapshot '" .. snapshot_time .. "' started..", vim.log.levels.INFO)
  p.snapshot(snapshot_time)
  vim.notify("PackerSync started..", vim.log.levels.INFO)
  p.sync()
end

function M:config()
  local p = require("packer")
  local opts = { silent = true, desc = "packer_compile" }

  vim.keymap.set("n", "<leader>Pc", p.compile, opts)
  opts.desc = "packer_update"
  vim.keymap.set("n", "<leader>Pu", p.update, opts)
  opts.desc = "packer_my_update"
  vim.keymap.set("n", "<leader>PU", self.__update, opts)
  opts.desc = "update_remote_plugins"
  vim.keymap.set("n", "<leader>Pr", "<cmd>UpdateRemotePlugins<cr>", opts)
  opts.desc = "packer_install"
  vim.keymap.set("n", "<leader>Pi", p.install, opts)
  opts.desc = "packer_sync"
  vim.keymap.set("n", "<leader>Ps", p.sync, opts)
  opts.desc = "packer_status"
  vim.keymap.set("n", "<leader>Pa", p.status, opts)
  opts.desc = "packer_clean"
  vim.keymap.set("n", "<leader>Pl", p.clean, opts)

  vim.api.nvim_create_autocmd("User", {
    pattern = "PackerCompileDone",
    callback = function()
      vim.notify("PackerCompile done...", vim.log.levels.INFO)
    end,
  })
end

function M:download()
  if vim.fn.isdirectory(self.__path) ~= 0 then
    -- Already exists
    return
  end

  if vim.fn.executable("git") == 0 then
    vim.notify("Packer: git is not in your path. Cannot download packer.nvim", vim.log.levels.ERROR)
    return
  end

  local git_cmd = "git clone " .. self.__repo .. " --depth 1 " .. self.__path
  vim.notify("Packer: downloading packer.nvim...", vim.log.levels.INFO)
  vim.fn.system(git_cmd)
  vim.cmd("packadd packer.nvim")
end

-- Thu May 13 2021 22:42: After much debuggin, found out that config property
-- is not working as intended because of issues in packer.nvim. See:
-- https://github.com/wbthomason/packer.nvim/issues/351
-- TL;DR: no outside of local scope function calling for config
function M:__setup()
  local packer = nil
  if packer == nil then
    local jobs = utl.has_unix() and nil or 5
    packer = require("packer")
    packer.init({
      max_jobs = jobs,
      snapshot_path = vim.fn.stdpath("data") .. [[/packer_snapshots]],
      log = "trace",
    })
  end

  local use = packer.use
  packer.reset()

  use({
    "wbthomason/packer.nvim",
    config = function()
      require("config.plugins.packer"):config()
    end,
  })

  use({
    "folke/which-key.nvim",
    config = function()
      require("config.plugins.whichkey"):setup()
    end,
  })

  use({
    "nvim-lua/telescope.nvim",
    requires = {
      { "nvim-lua/popup.nvim" },
      { "nvim-lua/plenary.nvim" },
      { "ahmedkhalf/project.nvim" },
      { "nvim-telescope/telescope-ui-select.nvim" },
    },
    config = function()
      require("config.plugins.telescope"):setup()
    end,
  })

  -- Post-install/update hook with neovim command
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    requires = { "p00f/nvim-ts-rainbow", "RRethy/nvim-treesitter-textsubjects" },
    config = function()
      require("config.plugins.treesitter"):setup()
    end,
  })

  use({
    "hrsh7th/nvim-cmp",
    after = "LuaSnip",
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "ray-x/cmp-treesitter",
      "quangnguyen30192/cmp-nvim-tags",
      "onsails/lspkind-nvim",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("config.plugins.nvim-cmp"):setup()
    end,
  })

  use({
    "RishabhRD/nvim-cheat.sh",
    requires = "RishabhRD/popfix",
    cmd = "Cheat",
  })

  use({
    "neovim/nvim-lspconfig",
    tag = vim.fn.has("nvim-0.8") and "*" or "v0.1.3*", -- Compatible with 0.7.0
    requires = { { "ray-x/lsp_signature.nvim" }, { "j-hui/fidget.nvim" } },
    config = function()
      require("config.lsp").setup()
    end,
  })

  use({
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("config.plugins.gitsigns").setup()
    end,
  })

  use({
    "kdheepak/lazygit.nvim",
    setup = function()
      vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
      vim.g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" } -- customize lazygit popup window corner characters
      vim.g.lazygit_use_neovim_remote = 0
    end,
  })

  use({
    "kyazdani42/nvim-tree.lua",
    config = function()
      require("config.plugins.tree_explorer").nvimtree_config()
    end,
  })

  use({
    "kosayoda/nvim-lightbulb",
    config = function()
      vim.cmd([[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])
      require("nvim-lightbulb").update_lightbulb({})
    end,
  })

  use({
    "lukas-reineke/indent-blankline.nvim",
    setup = function()
      vim.g.indent_blankline_filetype = {
        "vim",
        "lua",
        "c",
        "python",
        "cpp",
        "java",
        "cs",
        "sh",
        "ps1",
        "dosbatch",
      }
      vim.g.indent_blankline_char_highlight_list = { "Comment" }
      vim.g.indent_blankline_char_list = { "¦", "┆", "┊" }
      vim.g.indent_blankline_show_first_indent_level = false
    end,
  })

  use({
    "rhysd/git-messenger.vim",
    cmd = "GitMessenger",
    setup = function()
      vim.g.git_messenger_always_into_popup = true
    end,
    config = function()
      require("config.plugins.misc").config_git_messenger()
    end,
  })

  if utl.has_unix() then
    use({
      "zbirenbaum/copilot.lua",
      requires = {
        { "zbirenbaum/copilot-cmp", module = "copilot_cmp" },
        --[[ {
          "github/copilot.vim",
          setup = function()
            -- extract with tar -xJvf
            vim.g.copilot_node_command = "/home/reinaldo/.local/lib/nodejs/node-v16.15.1-linux-x64/bin/node"
          end,
        }, ]]
      },
      event = { "VimEnter" },
      config = function()
        require("config.plugins.misc").config_copilot()
        vim.defer_fn(function()
          require("copilot").setup()
        end, 100)
      end,
    })

    use({
      "iamcco/markdown-preview.nvim",
      setup = function()
        vim.g.mkdp_auto_close = 0
      end,
      run = "cd app && npm install",
      ft = "markdown",
    })

    -- Extra syntax
    use({ "PotatoesMaster/i3-vim-syntax" })

    use({
      "ThePrimeagen/git-worktree.nvim",
      after = { "telescope.nvim" },
      requires = { { "nvim-lua/telescope.nvim" } },
      config = function()
        require("config.plugins.git_worktree").setup()
      end,
    })

    use({
      "knubie/vim-kitty-navigator",
      after = "focus.nvim",
      run = "cp ./*.py ~/.config/kitty/",
      setup = function()
        vim.g.kitty_navigator_no_mappings = 1
      end,
      config = function()
        require("config.plugins.misc"):config_kitty_navigator()
      end,
    })

    use({
      "untitled-ai/jupyter_ascending.vim",
      setup = function()
        vim.g.jupyter_ascending_default_mappings = false
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
          pattern = "*.sync.py",
          callback = function()
            if vim.b.has_jupyter_plugin == true then
              return
            end
            vim.b.has_jupyter_plugin = true
            local opts = { silent = true, buffer = true, desc = "jupyter_execute" }
            vim.keymap.set("n", "<localleader>j", "<Plug>JupyterExecute", opts)
            opts.desc = "jupyter_execute_all"
            vim.keymap.set("n", "<localleader>k", "<Plug>JupyterExecuteAll", opts)
          end,
        })
      end,
    })
    -- Depends on github cli
    use({
      "folke/lua-dev.nvim",
      cond = function()
        return vim.fn.executable("lua-language-server") > 0
      end,
      config = function()
        require("config.plugins.misc").setup_luadev()
      end,
    })

    use({
      "pwntester/octo.nvim",
      requires = {
        { "nvim-lua/popup.nvim" },
        { "nvim-lua/plenary.nvim" },
        { "nvim-lua/telescope.nvim" },
      },
      config = function()
        require("telescope").load_extension("octo")
      end,
      cond = function()
        return vim.fn.executable("gh") > 0
      end,
    })

    use({ "lambdalisue/suda.vim" })

    use({ "chr4/nginx.vim" })

    use({
      "rcarriga/nvim-dap-ui",
      requires = {
        { "mfussenegger/nvim-dap" },
        { "mfussenegger/nvim-dap-python" },
        { "theHamsta/nvim-dap-virtual-text" },
      },
      config = function()
        require("config.plugins.dap"):setup()
      end,
    })
  end

  use({
    "mizlan/iswap.nvim",
    after = { "nvim-treesitter" },
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("config.plugins.misc").config_iswap()
    end,
  })

  use({
    "kristijanhusak/orgmode.nvim",
    after = { "nvim-treesitter", "LuaSnip" },
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("config.plugins.orgmode"):setup()
    end,
  })

  use({
    "juneedahamed/svnj.vim",
    cmd = { "SVNStatus", "SVNCommit" },
    setup = function()
      vim.g.svnj_allow_leader_mappings = 0
      vim.g.svnj_cache_dir = vim.fn.stdpath("cache")
      vim.g.svnj_browse_cache_all = 1
      vim.g.svnj_custom_statusbar_ops_hide = 0
      vim.g.svnj_browse_cache_max_cnt = 50
      vim.g.svnj_custom_fuzzy_match_hl = "Directory"
      vim.g.svnj_custom_menu_color = "Question"
      vim.g.svnj_fuzzy_search = 1
    end,
  })

  use({
    "PProvost/vim-ps1",
    ft = "ps1",
    cond = function()
      return require("utils.utils").has_win()
    end,
  })

  use({ "matze/vim-ini-fold", ft = "dosini" })

  use({
    "chrisbra/csv.vim",
    ft = "csv",
    setup = function()
      vim.g.no_csv_maps = 1
      vim.g.csv_strict_columns = 1
    end,
  })

  use({ "aklt/plantuml-syntax", ft = "plantuml" })
  use({ "MTDL9/vim-log-highlighting", ft = "log" })
  use({ "neomutt/neomutt.vim", ft = "muttrc" })
  use({ "fladson/vim-kitty" })

  use({
    "chaoren/vim-wordmotion",
    setup = function()
      vim.g.wordmotion_mappings = {
        w = "L",
        b = "H",
        e = "",
        W = "",
        B = "",
        E = "",
        ["ge"] = "",
        ["aw"] = "",
        ["iw"] = "",
        ["<C-R><C-W>"] = "",
      }
    end,
  })

  use({
    "mhinz/vim-startify",
    setup = function()
      vim.g.startify_session_dir = vim.fn.stdpath("data") .. "/sessions/"

      vim.g.startify_lists = {
        { ["type"] = "sessions", ["header"] = { "   Sessions" } },
        { ["type"] = "files", ["header"] = { "   MRU" } },
      }
      vim.g.startify_change_to_dir = 0
      vim.g.startify_session_sort = 1
      vim.g.startify_session_number = 10
    end,
  })

  use({
    "NLKNguyen/papercolor-theme",
    setup = function()
      require("config.plugins.misc"):setup_papercolor()
    end,
    config = function()
      require("utils.log").info("[papercolor]: Configuring...")
      vim.cmd([[colorscheme PaperColor]])
    end,
  })

  use({
    "jiangmiao/auto-pairs",
    setup = function()
      -- Really annoying option
      vim.g.AutoPairsFlyMode = 0
      vim.g.AutoPairsShortcutToggle = ""
      vim.g.AutoPairsShortcutFastWrap = ""
      vim.g.AutoPairsShortcutJump = ""
      vim.g.AutoPairsShortcutBackInsert = ""
    end,
  })

  use("tpope/vim-repeat")
  use("tpope/vim-surround")
  use({
    "tpope/vim-obsession",
    setup = function()
      require("config.plugins.misc"):setup_obsession()
    end,
  })

  use({
    "tricktux/pomodoro.vim",
    setup = function()
      require("config.plugins.misc"):setup_pomodoro()
    end,
  })

  use({
    "kassio/neoterm",
    setup = function()
      require("config.plugins.misc"):setup_neoterm()
    end,
    config = function()
      require("config.plugins.misc"):config_neoterm()
    end,
  })

  use({ "ferrine/md-img-paste.vim", ft = { "markdown", "org" } })

  use({
    "gcmt/taboo.vim",
    config = function()
      vim.cmd([[nnoremap <leader>tr :TabooRename ]])
    end,
  })

  use({
    "ironhouzi/starlite-nvim",
    config = function()
      require("config.plugins.misc"):config_starlite()
    end,
  })

  use({
    "justinmk/vim-sneak",
    setup = function()
      require("config.plugins.misc"):setup_sneak()
    end,
  })

  use({
    "kazhala/close-buffers.nvim",
    config = function()
      require("config.plugins.misc"):setup_bdelete()
    end,
  })

  use({
    "MattesGroeger/vim-bookmarks",
    setup = function()
      require("config.plugins.misc"):setup_bookmarks()
    end,
    config = function()
      require("config.plugins.misc"):config_bookmarks()
    end,
  })

  use({ "aquach/vim-http-client", cmd = "HTTPClientDoRequest" })

  use({
    "jsfaint/gen_tags.vim", -- Not being suppoprted anymore
    setup = function()
      vim.g["gen_tags#cache_dir"] = vim.fn.stdpath("cache") .. "/ctags/"
      vim.g["gen_tags#use_cache_dir"] = 1
      vim.g["loaded_gentags#gtags"] = 1 -- Disable gtags
      vim.g["gen_tags#gtags_default_map"] = 0
      vim.g["gen_tags#statusline"] = 0

      vim.g["gen_tags#ctags_auto_gen"] = 1
      vim.g["gen_tags#ctags_prune"] = 1
      vim.g["gen_tags#ctags_opts"] = "--sort=no --append"
    end,
  })

  use({
    "jamessan/vim-gnupg",
    cond = function()
      return vim.fn.executable("gpg") > 0
    end,
  })

  use({
    "s1n7ax/nvim-comment-frame",
    after = { "nvim-treesitter" },
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("config.plugins.misc"):setup_comment_frame()
    end,
  })

  use({
    "b3nj5m1n/kommentary",
    setup = function()
      vim.g.kommentary_create_default_mappings = false
    end,
    config = function()
      require("config.plugins.misc"):config_kommentary()
    end,
  })

  use({
    "beauwilliams/focus.nvim",
    config = function()
      require("config.plugins.misc"):config_focus()
    end,
  })

  use({
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("config.plugins.misc"):setup_zen_mode()
    end,
  })

  use({ "weilbith/nvim-code-action-menu", cmd = "CodeActionMenu" })

  use({
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    config = function()
      require("config.plugins.misc"):setup_diffview()
    end,
  })

  use({
    "SmiteshP/nvim-gps",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("config.plugins.misc"):setup_gpsnvim()
    end,
  })

  use({
    "nicwest/vim-camelsnek",
    setup = function()
      local opts = {
        silent = true,
        desc = "to_snake_case",
      }
      vim.keymap.set({ "n", "v" }, "<localleader>cs", "<cmd>Snek<cr>", opts)
      opts.desc = "to_camel_case"
      vim.keymap.set({ "n", "v" }, "<localleader>cc", "<cmd>Camel<cr>", opts)
      opts.desc = "to_camel_back_case"
      vim.keymap.set({ "n", "v" }, "<localleader>cb", "<cmd>CamelB<cr>", opts)
      opts.desc = "to_kebak_case"
      vim.keymap.set({ "n", "v" }, "<localleader>ck", "<cmd>Kebak<cr>", opts)
    end,
  })

  use({
    "rcarriga/nvim-notify",
    after = { "telescope.nvim" },
    config = function()
      require("config.plugins.misc"):config_notify()
    end,
  })

  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("config.plugins.null-ls"):setup()
    end,
  })

  use({
    "L3MON4D3/LuaSnip",
    requires = { "rafamadriz/friendly-snippets", "honza/vim-snippets" },
    config = function()
      require("config.plugins.luasnip"):config()
    end,
  })

  use({
    "danymat/neogen",
    after = { "LuaSnip" },
    config = function()
      require("config.plugins.misc"):config_neogen()
    end,
    requires = "nvim-treesitter/nvim-treesitter",
    -- Uncomment next line if you want to follow only stable versions
    tag = "*",
  })

  use({
    "tpope/vim-capslock",
    setup = function()
      vim.keymap.set("i", [[<c-l>]], "<Plug>CapsLockToggle", { silent = true, desc = "caps_lock_toggle" })
    end,
  })

  use({
    "dhruvasagar/vim-table-mode",
    cmd = "TableModeToggle",
    setup = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_align_char = ":"
      vim.g.table_mode_disable_mappings = 1
      vim.keymap.set(
        "n",
        [[<leader>ta]],
        [[<cmd>TableModeToggle<cr>]],
        { silent = true, desc = "table_mode_toggle" }
      )
    end,
  })

  use({
    "glts/vim-radical",
    requires = "glts/vim-magnum",
    setup = function()
      vim.g.radical_no_mappings = 1
      vim.keymap.set({ "n", "x" }, "<leader>nr", "<Plug>RadicalView", {
        silent = true,
        desc = "radical_view",
      })
    end,
  })

  use({
    -- Folder name to give
    "https://gitlab.com/yorickpeterse/nvim-pqf",
    as = "nvim-pqf",
    config = function()
      require("pqf").setup({
        signs = {
          error = "E",
          warning = "W",
          info = "I",
          hint = "H",
        },
      })
    end,
  })

  use({
    "nvim-lualine/lualine.nvim",
    -- List of plugins that update the lualine elements
    -- Add plugis here that use the ins_{left,right} functions
    after = {
      "nvim-gps",
      "pomodoro.vim",
      "vim-obsession",
      "gitsigns.nvim",
      "papercolor-theme",
    },
    -- setup = function() require('config.plugins.lualine'):setup() end,
    config = function()
      require("config.plugins.lualine"):config()
    end,
  })
end

function M:__setup_local_grip_plugin()
  vim.g.grip_pdfgrep = {
    executable = "pdfgrep",
    args = {
      [[$*]],
      "--ignore-case",
      "--page-number",
      "--recursive",
      "--context",
      "1",
    },
    grepformat = vim.opt.grepformat:get(),
  }
  local rg_to_vim_filetypes = {
    vim = "vimscript",
    python = "py",
    markdown = "md",
  }
  vim.g.grip_rg = {
    executable = "rg",
    args = {
      "--vimgrep",
      "--smart-case",
      "--follow",
      "--fixed-strings",
      "--hidden",
      "--no-ignore-vcs",
      utl.rg_ignore_file,
    },
    ["filetype_support"] = 1,
    ["filetype_map"] = rg_to_vim_filetypes,
    ["filetype_option"] = "--type",
  }

  vim.g.grip_rg_list = {
    name = "list_files",
    executable = "fd",
    search_argument = 0,
    prompt = 0,
    grepformat = "%f",
    args = { "--follow", "--fixed-strings", "--hidden", utl.rg_ignore_file },
  }

  vim.g.grip_tools = { vim.g.grip_rg, vim.g.grip_pdfgrep, vim.g.grip_rg_list }

  if vim.g.wiki_path == nil then
    return
  end

  vim.g.grip_wiki = {
    name = "wiki",
    prompt = 1,
    executable = "rg",
    args = {
      "--vimgrep",
      "--smart-case",
      "--follow",
      "--fixed-strings",
      "--hidden",
      utl.rg_ignore_file,
      [[$*]],
      vim.g.wiki_path,
    },
  }

  table.insert(vim.g.grip_tools, vim.g.wiki)
end

function M:setup()
  self:__setup_local_grip_plugin()
  self:download()
  self:__setup()
end

return M
