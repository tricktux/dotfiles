-- File:           plugin.lua
-- Description:    Used to configure different plugins
-- Author:		    Reinaldo Molina
-- Email:          me at molinamail dot com
-- Created:        Tue Sep 08 2020 22:20
-- Last Modified:  Tue Sep 08 2020 22:20
local utl = require("utils.utils")
local log = require("utils.log")
local map = require("config.mappings")
local vks = vim.keymap.set

local M = {}
local data_folder = vim.fn.stdpath("data")
M.path = {}
M.__package_name = "plugins" -- folder under which plugins are located
M.path.plugins = data_folder .. [[/site/pack/]] .. M.__package_name
M.path.__this = M.path.plugins .. [[/start/packer.nvim]]
M.path.__snaphots = data_folder .. [[/packer_snapshots]]
M.path.__compile = data_folder .. [[/site/plugin/packer_compiled.lua]]
M.__repo = [[https://github.com/wbthomason/packer.nvim]]

function M:__update()
  local snapshot_time = os.date("%y%m%d_%H%M%S")
  vim.notify("PackerSnapshot '" .. snapshot_time .. "' started..", vim.log.levels.INFO)
  local c = [[PackerSnapshot ]] .. snapshot_time
  vim.cmd(c)
	local p = require("packer")
	vim.notify("PackerSync started..", vim.log.levels.INFO)
	p.sync()
end

M.maps = { prefix = "<leader>P" }
M.maps.mappings = {
  c = {"<cmd>PackerCompile<cr>", "packer_compile"},
  u = {"<cmd>PackerUpdate<cr>", "packer_update"},
  U = {function() M.__update() end, "packer_snapshot_update"},
  r = {"<cmd>UpdateRemotePlugins<cr>", "update_remote_plugins"},
  i = {"<cmd>PackerInstall<cr>", "packer_install"},
  s = {"<cmd>PackerSync<cr>", "packer_sync"},
  a = {"<cmd>PackerStatus<cr>", "packer_status"},
  l = {"<cmd>PackerClean<cr>", "packer_clean"},
}

function M:setup()
  map:keymaps_sets(self.maps)

	vim.api.nvim_create_autocmd("User", {
		pattern = "PackerCompileDone",
		callback = function()
			vim.notify("PackerCompile done...", vim.log.levels.INFO)
		end,
	})
  local o = { desc = "packer_snapshot_sync" }
  vim.api.nvim_create_user_command("PackerUPDATE", self.__update, o)
end

function M:download()
	if vim.fn.isdirectory(self.path.__this) ~= 0 then
		-- Already exists
		return
	end

	if vim.fn.executable("git") == 0 then
		print("Packer: git is not in your path. Cannot download packer.nvim")
		return
	end

	local git_cmd = "git clone " .. self.__repo .. " --depth 1 " .. self.path.__this
	print("Packer: downloading packer.nvim...")
	vim.fn.system(git_cmd)
	vim.cmd("packadd packer.nvim")
end

M.__config = {
	max_jobs = utl.has_unix and nil or 5,
	snapshot_path = M.path.__snaphots,
	plugin_package = M.__package_name,
	log = "trace",
	compile_path = M.path.__compile,
}

-- Thu May 13 2021 22:42: After much debuggin, found out that config property
-- is not working as intended because of issues in packer.nvim. See:
-- https://github.com/wbthomason/packer.nvim/issues/351
-- TL;DR: no outside of local scope function calling for config
M.__plugins = {}
M.__plugins.common = {
	{
		"wbthomason/packer.nvim",
    cmd = {
      "PackerSnapshot",
      "PackerSnapshotRollback",
      "PackerSnapshotDelete",
      "PackerInstall",
      "PackerUpdate",
      "PackerSync",
      "PackerClean",
      "PackerCompile",
      "PackerStatus",
      "PackerProfile",
      "PackerLoad",
    },
		setup = function()
			require("config.plugins.packer"):setup()
		end,
    config = function()
      require("config.plugins.packer"):config()
    end,
	},
	{
		"folke/which-key.nvim",
    event = "CursorHold",
		config = function()
			require("config.plugins.whichkey"):setup()
		end,
	},
  { "nvim-lua/plenary.nvim", module = "plenary" },
  -- Telescope
	{
		"nvim-lua/telescope.nvim",
    -- Lazyload once we enter
    event = "CursorHold",
		config = function()
			require("config.plugins.telescope"):setup()
		end,
	},
  {
    "ahmedkhalf/project.nvim",
    after = "telescope.nvim",
    config = function() 
      require("config.plugins.telescope"):config_project() 
    end,
  },
  -- Treesitter loading
	{
		"nvim-treesitter/nvim-treesitter",
    event = "CursorHold",
		config = function()
			require("config.plugins.treesitter"):setup()
		end,
	},
  {"p00f/nvim-ts-rainbow", after = "nvim-treesitter"},
  {"RRethy/nvim-treesitter-textsubjects", after = "nvim-treesitter"},
  {
    "mizlan/iswap.nvim",
    after = "nvim-treesitter",
    config = function()
      require("config.plugins.misc").config_iswap()
    end,
  },
  {
    "s1n7ax/nvim-comment-frame",
    after = "nvim-treesitter",
    config = function()
      require("config.plugins.misc"):setup_comment_frame()
    end,
  },
  {
    "SmiteshP/nvim-gps",
    after = "nvim-treesitter",
    config = function()
      require("config.plugins.misc"):setup_gpsnvim()
    end,
  },
  ------------------------
  -- This is the order to load completion
  {
    "rafamadriz/friendly-snippets",
    -- Lazyload on start
    event = "CursorHold",
  },
  {
    "L3MON4D3/LuaSnip",
    after = "friendly-snippets",
    config = function()
      require("config.plugins.luasnip"):config()
    end,
  },
	{
		"hrsh7th/nvim-cmp",
    after = "LuaSnip",
		config = function()
			require("config.plugins.nvim-cmp"):setup()
		end,
	},
  { "hrsh7th/cmp-buffer", after = "nvim-cmp"},
  { "hrsh7th/cmp-nvim-lua", after = "nvim-cmp"},
  { "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp"},
  { "hrsh7th/cmp-path", after = "nvim-cmp"},
  { "hrsh7th/cmp-calc", after = "nvim-cmp"},
  { "ray-x/cmp-treesitter", after = "nvim-cmp" },
  { "onsails/lspkind-nvim", after = "nvim-cmp" },
  { "saadparwaiz1/cmp_luasnip", after = "nvim-cmp"},
  { "hrsh7th/cmp-omni", after = "nvim-cmp" },
  -- lspconfig after nvim-cmp
  {
    "neovim/nvim-lspconfig",
    after = "cmp-nvim-lsp",
    tag = vim.fn.has("nvim-0.8") > 0 and "*" or "v0.1.3*", -- Compatible with 0.7.0
    config = function()
      require("config.lsp"):config()
    end,
  },
  {"ray-x/lsp_signature.nvim", after = "nvim-lspconfig"},
  {
    "j-hui/fidget.nvim",
    after = "nvim-lspconfig",
    config = function()
      require("config.lsp"):config_fidget()
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    after = "nvim-lspconfig",
    config = function()
      require("config.plugins.null-ls"):setup()
    end,
  },
  { "weilbith/nvim-code-action-menu", after = "nvim-lspconfig" },
  ------------------
	{
		"lewis6991/gitsigns.nvim",
    event = "CursorHold",
		config = function()
			require("config.plugins.gitsigns").setup()
		end,
	},
	{
		"kdheepak/lazygit.nvim",
    cmd = "Lazygit",
		setup = function()
			vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
			vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
			vim.g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" } -- customize lazygit popup window corner characters
			vim.g.lazygit_use_neovim_remote = 0
		end,
	},
	{
		"kyazdani42/nvim-tree.lua",
    keys = "<plug>file_browser",
		config = function()
			require("config.plugins.tree_explorer").nvimtree_config()
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
    event = "CursorHold",
		config = function()
			require("config.plugins.misc").config_indent_blankline()
		end,
	},
	{
		"rhysd/git-messenger.vim",
		cmd = "GitMessenger",
		setup = function()
			vim.g.git_messenger_always_into_popup = true
		end,
		config = function()
			require("config.plugins.misc").config_git_messenger()
		end,
	},
	{
		"kristijanhusak/orgmode.nvim",
		requires = "nvim-treesitter/nvim-treesitter",
    ft = "org",
		config = function()
			require("config.plugins.orgmode"):setup()
		end,
	},
	{
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
	},
	{
		"PProvost/vim-ps1",
		ft = "ps1",
	},
	{ "matze/vim-ini-fold", ft = "dosini" },
	{
		"chrisbra/csv.vim",
		ft = "csv",
		setup = function()
			vim.g.no_csv_maps = 1
			vim.g.csv_strict_columns = 1
		end,
	},
	{ "aklt/plantuml-syntax", ft = "plantuml" },
	{ "MTDL9/vim-log-highlighting", ft = "log" },
	{
		"chaoren/vim-wordmotion",
    event = "CursorHold",
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
	},
	{
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
	},
	{
		"jiangmiao/auto-pairs",
    event = "CursorHold",
		setup = function()
			-- Really annoying option
			vim.g.AutoPairsFlyMode = 0
			vim.g.AutoPairsShortcutToggle = ""
			vim.g.AutoPairsShortcutFastWrap = ""
			vim.g.AutoPairsShortcutJump = ""
			vim.g.AutoPairsShortcutBackInsert = ""
		end,
	},
	{ 
    "tpope/vim-repeat",
    event = "CursorHold",
  },
	{
		"kylechui/nvim-surround",
    event = "CursorHold",
		config = function()
			require("config.plugins.misc"):config_surround()
		end,
	},
	{
		"rmagatti/auto-session",
		requires = {
			{
        "rmagatti/session-lens",
        after = "telescope.nvim",
        config = function()
          require("config.plugins.misc"):config_session_lens()
        end,
      },
			{ "nvim-lua/telescope.nvim" },
		},
		config = function()
			require("config.plugins.misc"):config_auto_session()
		end,
	},
	{
		"tricktux/pomodoro.vim",
    cmd = "Pomodoro",
		setup = function()
			require("config.plugins.misc"):setup_pomodoro()
		end,
	},
	{
		"akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
		config = function()
			require("config.plugins.misc"):config_toggleterm()
		end,
	},
	{
		"ferrine/md-img-paste.vim",
		ft = { "markdown", "org" },
		setup = function()
			require("config.plugins.misc"):setup_img_paste()
		end,
	},
	{
		"gcmt/taboo.vim",
    cmd = "TabooRename",
		config = function()
			local opts = { silent = true, desc = "TabooRename" }
			vim.keymap.set("n", "<leader>tr", "<cmd>TabooRename<cr>", opts)
		end,
	},
	{
		"ironhouzi/starlite-nvim",
    event = "CursorHold",
		config = function()
			require("config.plugins.misc"):config_starlite()
		end,
	},
	{
		"justinmk/vim-sneak",
    event = "CursorHold",
		setup = function()
			require("config.plugins.misc"):setup_sneak()
      -- Silly I know, but needs to be here
      require("config.plugins.misc"):config_sneak()
		end,
    config = function()
      require("config.plugins.misc"):config_sneak()
    end,
	},
	{
		"kazhala/close-buffers.nvim",
    event = "CursorHold",
		config = function()
			require("config.plugins.misc"):setup_bdelete()
		end,
	},
	{
		"MattesGroeger/vim-bookmarks",
    cmd = {"BookmarkToggle", "BookmarkAnnotate", "BookmarkShowAll"},
		setup = function()
			require("config.plugins.misc"):setup_bookmarks()
		end,
	},
	{ "aquach/vim-http-client", cmd = "HTTPClientDoRequest" },
	{
		"b3nj5m1n/kommentary",
    keys = {
      {"n", "-", "kommentary_line_default"},
      {"x", "-", "kommentary_visual_default"},
      {"n", "0", "kommentary_motion_default"},
    },
		setup = function()
			vim.g.kommentary_create_default_mappings = false
		end,
		config = function()
			require("config.plugins.misc"):config_kommentary()
		end,
	},
	{
		"beauwilliams/focus.nvim",
    event = "CursorHold",
		config = function()
			require("config.plugins.misc"):config_focus()
		end,
	},
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		config = function()
			require("config.plugins.misc"):setup_zen_mode()
		end,
	},
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		config = function()
			require("config.plugins.misc"):setup_diffview()
		end,
	},
	{
		"nicwest/vim-camelsnek",
    keys = {
      {"n", "<localleader>cs", "snek"},
      {"v", "<localleader>cs", "snek"},
      {"n", "<localleader>cc", "camel"},
      {"v", "<localleader>cc", "camel"},
      {"n", "<localleader>cb", "camelb"},
      {"v", "<localleader>cb", "camelb"},
      {"n", "<localleader>ck", "kebak"},
      {"v", "<localleader>ck", "kebak"},
    },
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
	},
	{
		"rcarriga/nvim-notify",
		after = { "telescope.nvim" },
		config = function()
			require("config.plugins.misc"):config_notify()
		end,
	},
	{
		"danymat/neogen",
    keys = {
      {"n", "<leader>og", "generate_neogen"},
      {"n", "<leader>oGf", "generate_neogen_function"},
      {"n", "<leader>oGc", "generate_neogen_class"},
      {"n", "<leader>oGf", "generate_neogen_file"},
      {"n", "<leader>oGt", "generate_neogen_type"},
    },
		config = function()
			require("config.plugins.misc"):config_neogen()
		end,
		requires = "nvim-treesitter/nvim-treesitter",
		-- Comment next line if you don't want to follow only stable versions
		tag = "*",
	},
	{
		"tpope/vim-capslock",
    keys = {
      {"i", "<c-l>", "caps_lock_toggle"},
    },
		setup = function()
			vim.keymap.set("i", [[<c-l>]], "<Plug>CapsLockToggle", { silent = true, desc = "caps_lock_toggle" })
		end,
	},
	{
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
	},
	{
		"glts/vim-radical",
    keys = {
      {"x", "<leader>nr", "radical_view"},
      {"n", "<leader>nr", "radical_view"},
    },
		setup = function()
			vim.g.radical_no_mappings = 1
			vim.keymap.set({ "n", "x" }, "<leader>nr", "<Plug>RadicalView", {
				silent = true,
				desc = "radical_view",
			})
		end,
	},
  { "glts/vim-magnum", after = "vim-radical" },
	{
		-- Folder name to give
		"https://gitlab.com/yorickpeterse/nvim-pqf",
		as = "nvim-pqf",
    event = "QuickFixCmdPre",
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
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("config.plugins.lualine"):config()
		end,
	},
  -- These go together
	{
		"nvim-neotest/neotest",
    ft = "python",
    keys = {
      {"n", "<leader>stf", "neotest_run_current_file"},
      {"n", "<leader>str", "neotest_run_nearest"},
    },
		config = function()
			require("config.plugins.misc"):config_neotest()
		end,
	},
  {"antoinemadec/FixCursorHold.nvim", after = "neotest"},
  {"nvim-neotest/neotest-python", after = "neotest"},
  {"nvim-neotest/neotest-plenary", after = "neotest"},
  ------
	{
		"catppuccin/nvim",
		as = "catppuccin",
		config = function()
			require("config.plugins.misc"):config_catpuccin()
		end,
		run = "CatppuccinCompile",
	},
	{
		"norcalli/nvim-colorizer.lua",
		cmd = "ColorizerToggle",
		setup = function()
			local o = { silent = true, desc = "toggle_highlight" }
			vim.keymap.set("n", "<leader>tch", "<cmd>ColorizerToggle<cr>", o)
		end,
		config = function()
			require 'colorizer'.setup {
        '!*'; -- Dont highlight any files
      }
		end,
	},
  {"lewis6991/impatient.nvim"},
}
M.__plugins.deps = {}
M.__plugins.deps.has = {
	["nvim-0.8"] = {
		{
			"smjonas/inc-rename.nvim",
      cmd = "IncRename",
			config = function()
				require("inc_rename").setup()
			end,
		},
	},
	["unix"] = {
    {
      "RishabhRD/nvim-cheat.sh",
      requires = "RishabhRD/popfix",
      cmd = "Cheat",
    },
    {
      "jamessan/vim-gnupg",
      cond = function()
        return vim.fn.executable("gpg") > 0
      end,
    },
		{
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
		},
		{
			"iamcco/markdown-preview.nvim",
			setup = function()
				vim.g.mkdp_auto_close = 0
			end,
			run = "cd app && npm install",
			ft = "markdown",
		},
		{ "PotatoesMaster/i3-vim-syntax" },
		{
			"ThePrimeagen/git-worktree.nvim",
			requires = { { "nvim-lua/telescope.nvim" } },
      keys = {
        {"n", "<leader>vwa", "git_worktree_create"}, 
        {"n", "<leader>vwd", "git_worktree_delete"}, 
        {"n", "<leader>vws", "git_worktree_switch"},
      },
			config = function()
				require("config.plugins.git_worktree").setup()
			end,
		},
		{
			"knubie/vim-kitty-navigator",
			after = "focus.nvim",
			run = "cp ./*.py ~/.config/kitty/",
			setup = function()
				vim.g.kitty_navigator_no_mappings = 1
			end,
			config = function()
				require("config.plugins.misc"):config_kitty_navigator()
			end,
		},
		{
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
		},
		{
			"folke/lua-dev.nvim",
			cond = function()
				return vim.fn.executable("lua-language-server") > 0
			end,
			config = function()
				require("config.plugins.misc").setup_luadev()
			end,
		},
		{
			"pwntester/octo.nvim",
			requires = {
				{ "nvim-lua/plenary.nvim" },
				{ "nvim-lua/telescope.nvim" },
			},
			config = function()
				require("telescope").load_extension("octo")
			end,
			cond = function()
				return vim.fn.executable("gh") > 0
			end,
		},
		{ "lambdalisue/suda.vim" },
		{ "chr4/nginx.vim" },
		{
			"rcarriga/nvim-dap",
			requires = {
				{ "mfussenegger/nvim-dap-ui" },
				{ "mfussenegger/nvim-dap-python" },
				{ "theHamsta/nvim-dap-virtual-text" },
			},
      -- Comment next line if you don't want to follow only stable versions
      tag = "*",
			config = function()
				require("config.plugins.dap"):setup()
			end,
		},
		{ "neomutt/neomutt.vim", ft = "muttrc" },
		{ "fladson/vim-kitty" },
	},
}

function M:config()
	self:download()
	local packer = require("packer")
	local plugins = self.__plugins.common
	for key, dep in pairs(self.__plugins.deps.has) do
		if vim.fn.has(key) > 0 then
			for _, plug in pairs(dep) do
				table.insert(plugins, plug)
			end
		end
	end

	log.trace("packer: plugins = ", plugins)
	packer.startup({ plugins, config = self.__config })
end

return M
