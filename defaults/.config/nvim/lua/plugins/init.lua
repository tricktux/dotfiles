local log = require("utils.log")
local fmt = string.format
local utl = require("utils.utils")
local map = require("mappings")
local vks = vim.keymap.set
local api = vim.api

local function set_colorscheme(period)
	local flavour = {
		day = "latte",
		night = "mocha",
		sunrise = "frappe",
		sunset = "macchiato",
	}
	vim.g.catppuccin_flavour = flavour[period]
	log.info(fmt("set_colorscheme: period = '%s'", period))
	log.info(fmt("set_colorscheme: catppuccin_flavour = '%s'", flavour[period]))
	vim.cmd("Catppuccin " .. flavour[period])
	local colors = require("catppuccin.palettes").get_palette()
	local TelescopeColor = {
		TelescopeMatching = { fg = colors.flamingo },
		TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

		TelescopePromptPrefix = { bg = colors.surface0 },
		TelescopePromptNormal = { bg = colors.surface0 },
		TelescopeResultsNormal = { bg = colors.mantle },
		TelescopePreviewNormal = { bg = colors.mantle },
		TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
		TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
		TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
		TelescopePromptTitle = { bg = colors.red, fg = colors.mantle },
		TelescopeResultsTitle = { fg = colors.mantle },
		TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
	}

	for hl, col in pairs(TelescopeColor) do
		vim.api.nvim_set_hl(0, hl, col)
	end
end

local function setup_flux()
	local f = require("plugin.flux")
	f:setup({
		callback = set_colorscheme,
	})
	local id = api.nvim_create_augroup("FluxLike", { clear = true })
	if vim.fn.has("unix") > 0 and vim.fn.executable("luajit") > 0 then
		vim.g.flux_enabled = 0

		api.nvim_create_autocmd("CursorHold", {
			callback = function()
				vim.defer_fn(function()
					f:check()
				end, 0) -- Defered for live reloading
			end,
			pattern = "*",
			desc = "Flux",
			once = true,
			group = id,
		})
		return
	end
	api.nvim_create_autocmd("CursorHold", {
		callback = function()
			vim.defer_fn(function()
				vim.fn["flux#Flux"]()
			end, 0) -- Defered for live reloading
		end,
		pattern = "*",
		desc = "Flux",
		group = id,
	})

	vim.g.flux_enabled = 1
	vim.g.flux_api_lat = 27.972572
	vim.g.flux_api_lon = -82.796745

	vim.g.flux_night_time = 2000
	vim.g.flux_day_time = 700
end

return {
	{
		"catppuccin/nvim",
		init = function()
			setup_flux()
		end,
		name = "catppuccin",
		cmd = { "CatppuccinCompile", "CatppuccinStatus", "Catppuccin", "CatppuccinClean" },
		opts = {
			compile = {
				enabled = true,
				-- .. [[/site/plugin/catppuccin]]
				path = vim.fn.stdpath("data") .. utl.fs.path.sep .. [[catppuccin]],
				suffix = "_compiled",
			},
			integrations = {
				indent_blankline = {
					enabled = true,
					colored_indent_levels = true,
				},
				dap = {
					enabled = vim.fn.has("unix") > 0 and true or false,
					enable_ui = vim.fn.has("unix") > 0 and true or false,
				},
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "underline" },
						hints = { "underline" },
						warnings = { "underline" },
						information = { "underline" },
					},
				},
				noice = true,
				treesitter_context = true,
				telescope = true,
				which_key = true,
				dashboard = true,
				vim_sneak = true,
				markdown = true,
				ts_rainbow = true,
				notify = true,
				symbols_outline = true,
			},
		},
	},
	{
		-- TODO: move it to telescope.nvim
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- Minimum level to show
			level = "info",

			-- Animation style (see below for details)
			stages = "fade_in_slide_out",

			-- Function called when a new window is opened, use for changing win settings/config
			on_open = nil,

			-- Function called when a window is closed
			on_close = nil,

			-- Render function for notifications. See notify-render()
			render = "default",

			-- Default timeout for notifications
			timeout = 500,

			-- Max number of columns for messages
			max_width = nil,
			-- Max number of lines for a message
			max_height = nil,

			-- For stages that change opacity this is treated as the highlight behind the window
			-- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
			background_colour = "#000000",

			-- Minimum width for notification windows
			minimum_width = 50,

			-- Icons for the different levels
			icons = {
				ERROR = "",
				WARN = "",
				INFO = "",
				DEBUG = "",
				TRACE = "✎",
			},
		},
	},
	{
		-- TODO: move it to treesitter.nvim
		"danymat/neogen",
		keys = {
			{
				"<leader>og",
				function()
					require("neogen").generate()
				end,
				desc = "generate_neogen",
			},
			{
				"<leader>oGf",
				function()
					require("neogen").generate({ type = "func" })
				end,
				desc = "generate_neogen_function",
			},
			{
				"<leader>oGc",
				function()
					require("neogen").generate({ type = "class" })
				end,
				desc = "generate_neogen_class",
			},
			{
				"<leader>oGi",
				function()
					require("neogen").generate({ type = "file" })
				end,
				desc = "generate_neogen_file",
			},
			{
				"<leader>oGt",
				function()
					require("neogen").generate({ type = "type" })
				end,
				desc = "generate_neogen_type",
			},
		},
		opts = {
			enabled = true,
			snippet_engine = "luasnip",
			languages = {
				csharp = {
					template = {
						annotation_convention = "xmldoc",
					},
				},
			},
		},
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			window = {
				backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
				-- height and width can be:
				-- * an absolute number of cells when > 1
				-- * a percentage of the width / height of the editor when <= 1
				-- * a function that returns the width or the height
				width = 0.85, -- width of the Zen window
				height = 1, -- height of the Zen window
				-- by default, no options are changed for the Zen window
				-- uncomment any of the options below, or add other vim.wo options you want to apply
				options = {
					signcolumn = "no", -- disable signcolumn
					number = false, -- disable number column
					relativenumber = false, -- disable relative numbers
					-- cursorline = false, -- disable cursorline
					-- cursorcolumn = false, -- disable cursor column
					-- foldcolumn = "0", -- disable fold column
					-- list = false, -- disable whitespace characters
				},
			},
			plugins = {
				-- disable some global vim options (vim.o...)
				-- comment the lines to not apply the options
				options = {
					enabled = true,
					ruler = false, -- disables the ruler text in the cmd line area
					showcmd = false, -- disables the command in the last line of the screen
				},
				twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
				gitsigns = { enabled = false }, -- disables git signs
				tmux = { enabled = false }, -- disables the tmux statusline
				-- this will change the font size on kitty when in zen mode
				-- to make this work, you need to set the following kitty options:
				-- - allow_remote_control socket-only
				-- - listen_on unix:/tmp/kitty
				kitty = {
					enabled = false,
					font = "+4", -- font size increment
				},
			},
			-- callback where you can add custom code when the Zen window opens
			--[[ on_open = function(win)
    end, ]]
			-- callback where you can add custom code when the Zen window closes
			--[[ on_close = function()
    end, ]]
		},
		{
			"beauwilliams/focus.nvim",
			keys = {
				{
					"<leader>tw",
					"<cmd>FocusToggle<cr>",
					desc = "focus_mode_toggle_mappings",
				},
				{
					"<a-h>",
					function()
						require("focus").split_command("h")
					end,
					desc = "window_switch_left",
				},
				{
					"<a-j>",
					function()
						require("focus").split_command("j")
					end,
					desc = "window_switch_down",
				},
				{
					"<a-k>",
					function()
						require("focus").split_command("k")
					end,
					desc = "window_switch_up",
				},
				{
					"<a-l>",
					function()
						require("focus").split_command("l")
					end,
					desc = "window_switch_right",
				},
			},
			opts = {
				-- Displays line numbers in the focussed window only
				-- Not displayed in unfocussed windows
				-- Default: true
				number = false,
				excluded_buftypes = { "nofile", "prompt" },
				relativenumber = false,
				cursorline = false,
				signcolumn = false,
				-- Enable auto highlighting for focussed/unfocussed windows
				-- Default: false
				winhighlight = false,
				-- vim.cmd('hi link UnfocusedWindow CursorLine')
				-- vim.cmd('hi link FocusedWindow VisualNOS')
				-- focus.enable = false
				-- width = 100
				tmux = true,
			},
		},
	},
	{
		"justinmk/vim-sneak",
		event = "VeryLazy",
		init = function()
			vim.g["sneak#absolute_dir"] = 1
			vim.g["sneak#label"] = 1
			-- " repeat motion
			-- Using : for next f,t is cumbersome, use ' for that, and ` for marks
			vim.keymap.set("n", "'", "<Plug>Sneak_;")
			vim.keymap.set("n", ",", "<Plug>Sneak_,")

			-- " 1-character enhanced 'f'
			vim.keymap.set("n", "f", "<Plug>Sneak_f")
			vim.keymap.set("n", "F", "<Plug>Sneak_F")
			-- " 1-character enhanced 't'
			vim.keymap.set("n", "t", "<Plug>Sneak_t")
			-- " label-mode
			vim.keymap.set("n", "s", "<Plug>SneakLabel_s")
			vim.keymap.set("n", "S", "<Plug>SneakLabel_S")

			-- TODO: See a way not to have to map these
			-- Wait for: https://github.com/justinmk/vim-sneak/pull/248
			-- vim.g["sneak#disable_mappings"] = 1
			-- " visual-mode
			vim.keymap.set({ "x", "o" }, "s", "s")
			vim.keymap.set({ "x", "o" }, "S", "S")
			vim.keymap.set({ "x", "o" }, "f", "f")
			vim.keymap.set({ "x", "o" }, "F", "F")
			vim.keymap.set({ "x", "o" }, "t", "t")
			vim.keymap.set({ "x", "o" }, "T", "%")
		end,
	},
	{
		"b3nj5m1n/kommentary",
		keys = {
			{ "-", "<Plug>kommentary_line_default", desc = "kommentary_line_default" },
			{ "-", "<Plug>kommentary_visual_default<C-c>", mode = "x", desc = "kommentary_line_visual" },
			{ "0", "<Plug>kommentary_motion_default", desc = "kommentary_motion_default" },
		},
		init = function()
			vim.g.kommentary_create_default_mappings = false
		end,
		config = function()
			local config = require("kommentary.config")
			config.configure_language("wings_syntax", {
				single_line_comment_string = "//",
				prefer_single_line_comments = true,
			})
			config.configure_language("dosini", {
				single_line_comment_string = ";",
				prefer_single_line_comments = true,
			})
		end,
	},
	{
		"ironhouzi/starlite-nvim",
		keys = {
			{
				"*",
				function()
					require("starlite").star()
				end,
				desc = "goto_next_abs_word_under_cursor",
			},
			{
				"g*",
				function()
					require("starlite").g_star()
				end,
				desc = "goto_next_word_under_cursor",
			},
			{
				"#",
				function()
					require("starlite").hash()
				end,
				desc = "goto_prev_abs_word_under_cursor",
			},
			{
				"g#",
				function()
					require("starlite").g_hash()
				end,
				desc = "goto_prev_word_under_cursor",
			},
		},
	},
	{
		"kazhala/close-buffers.nvim",
		keys = {
			{
				"<leader>bd",
				function()
					require("close_buffers").delete({ type = "this" })
				end,
				desc = "buffer_delete_current",
			},
			{
				"<leader>bl",
				function()
					require("close_buffers").delete({ type = "all", force = true })
				end,
				desc = "buffer_delete_all",
			},
			{
				"<leader>bn",
				function()
					require("close_buffers").delete({ type = "nameless" })
				end,
				desc = "buffer_delete_nameless",
			},
			{
				"<leader>bg",
				function()
					require("close_buffers").delete({ glob = vim.fn.input("Please enter glob (ex. *.lua): ") })
				end,
				desc = "buffer_delete_glob",
			},
		},
		opts = {
			filetype_ignore = {}, -- Filetype to ignore when running deletions
			file_glob_ignore = {}, -- File name glob pattern to ignore when running deletions (e.g. '*.md')
			file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
			preserve_window_layout = { "this", "nameless" }, -- Types of deletion that should preserve the window layout
			next_buffer_cmd = nil, -- Custom function to retrieve the next buffer when preserving window layout
		},
	},
	{
		"akinsho/toggleterm.nvim",
		keys = {
			{ "<plug>terminal_toggle", "<cmd>ToggleTerm<cr>", desc = "terminal_toggle_toggleterm" },
			{
				"<plug>terminal_open_horizontal",
				"<cmd>ToggleTerm direction=horizontal<cr>",
				desc = "terminal_open_horizontal_toggleterm",
			},
			{
				"<plug>terminal_open_vertical",
				"<cmd>ToggleTerm direction=vertical<cr>",
				desc = "terminal_open_vertical_toggleterm",
			},
		},
		config = function()
			require("toggleterm").setup({
				direction = "float",
				close_on_exit = false,
				float_opts = {
					border = "curved",
				},
				highlights = {
					-- highlights which map to a highlight group name and a table of it's values
					-- NOTE: this is only a subset of values,
					-- any group placed here will be set for the terminal window split
					Normal = {
						guibg = "White",
					},
					NormalFloat = {
						link = "Normal",
					},
				},
				-- Set this variable below to false for above to have effect
				shade_terminals = false,
			})
			if vim.fn.executable("ranger") <= 0 then
				return
			end

			local Terminal = require("toggleterm.terminal").Terminal
			_G.ranger = Terminal:new({
				cmd = "ranger",
				close_on_exit = true,
				clear_env = false,
				direction = "float",
				float_opts = {
					border = "single",
				},
				-- function to run on opening the terminal
				on_open = function(term)
					vim.cmd.startinsert()
					vim.keymap.set({ "n", "i" }, "q", vim.cmd.hide, { buffer = true })
				end,
			})
			local r = function()
				if _G.ranger == nil then
					vim.notify("ranger is not executable", vim.log.levels.error, {})
					return
				end
				_G.ranger:toggle()
			end
			-- vim.keymap.set('n', '<plug>file_browser', r, { desc = 'file-browser-toggleterm' })
			vim.api.nvim_create_user_command("ToggleTermRanger", r, {})
		end,
	},
	{
		"ferrine/md-img-paste.vim",
		ft = { "markdown", "org" },
		init = function()
			vim.cmd([=[
        function! g:OrgmodePasteImage(relpath)
          execute "normal! i#+CAPTION: H"
          let ipos = getcurpos()
          execute "normal! aere"
          execute "normal! o[[./" . a:relpath . "]]"
          call setpos('.', ipos)
          execute "normal! ve\<C-g>"
        endfunction
      ]=])
			local id = api.nvim_create_augroup("ImagePastePlugin", { clear = true })
			local opts = { silent = true, desc = "image_paste", buffer = 0 }
			local md = function()
				vim.g.PasteImageFunction = "g:MarkdownPasteImage"
				vim.fn["mdip#MarkdownClipboardImage"]()
			end
			local tex = function()
				vim.g.PasteImageFunction = "g:LatexPasteImage"
				vim.fn["mdip#MarkdownClipboardImage"]()
			end
			local org = function()
				vim.g.PasteImageFunction = "g:OrgmodePasteImage"
				vim.fn["mdip#MarkdownClipboardImage"]()
			end
			api.nvim_create_autocmd("FileType", {
				callback = function()
					vks("n", "<localleader>i", org, opts)
				end,
				pattern = "org",
				desc = "OrgModePasteImageFunction",
				group = id,
			})
			api.nvim_create_autocmd("FileType", {
				callback = function()
					vks("n", "<localleader>i", md, opts)
				end,
				pattern = "markdown",
				desc = "MarkdownPasteImageFunction",
				group = id,
			})
			api.nvim_create_autocmd("FileType", {
				callback = function()
					vks("n", "<localleader>i", tex, opts)
				end,
				pattern = "tex",
				desc = "LatexPasteImageFunction",
				group = id,
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		opts = {
			char_highlight_list = { "Comment" },
			char_list = { "¦", "┆", "┊" },
			show_first_indent_level = false,
			show_current_context = true,
			buftype_exclude = utl.buftype.blacklist,
			filetype_exclude = vim.tbl_flatten({ utl.filetype.blacklist, "markdown", "org", "mail" }),
		},
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = true,
	},
	{
		"rmagatti/auto-session",
		event = "VeryLazy",
		opts = {
			log_level = "info",
			auto_session_enable_last_session = false,
			auto_session_root_dir = vim.fn.stdpath("data") .. utl.fs.path.sep .. "sessions" .. utl.fs.path.sep,
			auto_session_enabled = true,
			auto_session_create_enabled = true,
			auto_save_enabled = true,
			auto_restore_enabled = false,
			auto_session_suppress_dirs = nil,
			auto_session_use_git_branch = true,
			-- the configs below are lua only
			bypass_session_save_file_types = nil,
		},
	},
	{
		"monaqa/dial.nvim",
		event = "VeryLazy",
		config = function()
			vim.api.nvim_set_keymap("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
			vim.api.nvim_set_keymap("n", "<s-x>", require("dial.map").dec_normal(), { noremap = true })
			vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
			vim.api.nvim_set_keymap("v", "<s-x>", require("dial.map").dec_visual(), { noremap = true })
			vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
			vim.api.nvim_set_keymap("v", "g<s-x>", require("dial.map").dec_gvisual(), { noremap = true })
			local augend = require("dial.augend")
			require("dial.config").augends:register_group({
				-- default augends used when no group name is specified
				default = {
					augend.integer.alias.decimal,
					augend.integer.alias.hex,
					augend.integer.alias.octal,
					augend.integer.alias.binary,
					augend.date.alias["%Y/%m/%d"],
					augend.date.alias["%Y-%m-%d"],
					augend.date.alias["%m/%d"],
					augend.date.alias["%H:%M"],
					augend.constant.alias.ja_weekday_full,
					augend.constant.alias.bool,
					augend.semver.alias.semver,
				},
			})
		end,
	},
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitFilter", "LazyGitFilterCurrentFile" },
		init = function()
			vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
			vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
			vim.g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" } -- customize lazygit popup window corner characters
			vim.g.lazygit_use_neovim_remote = 0
		end,
	},
	{
		"rhysd/git-messenger.vim",
		keys = {
			{ "<leader>vm", "<cmd>GitMessenger<cr>", desc = "git_messenger" },
		},
		init = function()
			vim.g.git_messenger_always_into_popup = true
			vim.g.git_messenger_floating_win_opts = { border = "single" }
		end,
	},
	{
		"mhinz/vim-startify",
		lazy = false,
		init = function()
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
		"tpope/vim-repeat",
		event = "VeryLazy",
	},
	{
		"jiangmiao/auto-pairs",
		event = "VeryLazy",
		init = function()
			-- Really annoying option
			vim.g.AutoPairsFlyMode = 0
			vim.g.AutoPairsShortcutToggle = ""
			vim.g.AutoPairsShortcutFastWrap = ""
			vim.g.AutoPairsShortcutJump = ""
			vim.g.AutoPairsShortcutBackInsert = ""
		end,
	},
	{ "aquach/vim-http-client", cmd = "HTTPClientDoRequest" },
	{
		"PProvost/vim-ps1",
		ft = "ps1",
	},
	{ "matze/vim-ini-fold", ft = "dosini" },
	{
		"chrisbra/csv.vim",
		ft = "csv",
		init = function()
			vim.g.no_csv_maps = 1
			vim.g.csv_strict_columns = 1
		end,
	},
	{ "aklt/plantuml-syntax", ft = "plantuml" },
	{ "MTDL9/vim-log-highlighting", ft = "log" },
	{
		"chaoren/vim-wordmotion",
		event = "VeryLazy",
		init = function()
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
		"tpope/vim-capslock",
		keys = {
			{ "<c-l>", "<Plug>CapsLockToggle", mode = "i", desc = "caps_lock_toggle" },
		},
	},
	{
		"glts/vim-radical",
		dependencies = {
			"glts/vim-magnum",
		},
		keys = {
			{ "<leader>nr", "<Plug>RadicalView", mode = "x", desc = "radical_view" },
			{ "<leader>nr", "<Plug>RadicalView", desc = "radical_view" },
		},
		init = function()
			vim.g.radical_no_mappings = 1
		end,
	},
	{
		-- Folder name to give
		"https://gitlab.com/yorickpeterse/nvim-pqf",
		name = "nvim-pqf",
		event = "QuickFixCmdPre",
		opts = {
			signs = {
				error = "E",
				warning = "W",
				info = "I",
				hint = "H",
			},
		},
	},
	-- better ui from lazyvim
	{ "nvim-tree/nvim-web-devicons" },
	-- ui components
	{ "MunifTanjim/nui.nvim" },
	{
		"stevearc/dressing.nvim",
		lazy = true,
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
	},
}