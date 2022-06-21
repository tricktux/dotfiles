local log = require("utils.log")
local utl = require("utils.utils")
local line = require("config.plugins.lualine")
local vks = vim.keymap.set
local api = vim.api

local M = {}

function M.config_neoscrooll()
	-- enable performance_mode for cpp on unix
	local perf = vim.fn.has("unix") > 0 and false or true
	require("neoscroll").setup({
		-- All these keys will be mapped to their corresponding default scrolling animation
		mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
		hide_cursor = true, -- Hide cursor while scrolling
		stop_eof = true, -- Stop at <EOF> when scrolling downwards
		use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
		respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
		cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
		easing_function = nil, -- Default easing function
		pre_hook = nil, -- Function to run before the scrolling animation starts
		post_hook = nil, -- Function to run after the scrolling animation ends
		performance_mode = perf, -- Disable "Performance Mode" on all buffers.
	})
end

function M.config_notify()
	local has_telescope, telescope = pcall(require, "telescope")
	local has_which_key, whichkey = pcall(require, "which-key")

	if has_telescope and has_which_key then
		telescope.load_extension("notify")
		whichkey.register({ ["<leader>fn"] = { telescope.extensions.notify.notify, "notify" } })
	else
		log.error("[notify]: no telescope and no mappings set")
	end

	vim.notify = require("notify")
	vim.notify.setup({
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
		timeout = 5000,

		-- Max number of columns for messages
		max_width = nil,
		-- Max number of lines for a message
		max_height = nil,

		-- For stages that change opacity this is treated as the highlight behind the window
		-- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
		background_colour = "Normal",

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
	})
end

function M.config_alpha()
	local alpha = require("alpha")
	local startify = require("alpha.themes.startify")
	startify.section.header.val = {
		[[                                   __                ]],
		[[      ___     ___    ___   __  __ /\_\    ___ ___    ]],
		[[     / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
		[[    /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
		[[    \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
		[[     \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
	}
	startify.section.top_buttons.val = {
		startify.button("e", "New file", ":ene <BAR> startinsert <CR>"),
	}
	-- disable MRU
	startify.section.mru.val = { { type = "padding", val = 0 } }
	-- disable MRU cwd
	startify.section.mru_cwd.val = { { type = "padding", val = 0 } }
	-- disable nvim_web_devicons
	startify.nvim_web_devicons.enabled = false
	-- startify.nvim_web_devicons.highlight = false
	-- startify.nvim_web_devicons.highlight = 'Keyword'
	--
	startify.section.bottom_buttons.val = {
		startify.button("q", "Quit NVIM", ":qa<CR>"),
	}
	startify.section.footer = {
		{ type = "text", val = "footer" },
	}
	-- ignore filetypes in MRU

	startify.mru_opts.ignore = function(path, ext)
		return (string.find(path, "COMMIT_EDITMSG")) or (vim.tbl_contains(default_mru_ignore, ext))
	end
	alpha.setup(startify.config)
end

function M.config_neomake()
	log.info("ins_right(): neomake")
	line:ins_right({
		function()
			return vim.fn["linting#neomake_native_status_line"]()
		end,
		color = { fg = line.colors.yellow, gui = "bold" },
		right_padding = 0,
	})
	vim.fn["neomake#configure#automake"]("nw", 750)
end

function M.config_neogen()
	local ls_ok, _ = pcall(require, "luasnip")
	local ng = require("neogen")

	local config = {
		enabled = true,
		languages = {
			csharp = {
				template = {
					annotation_convention = "xmldoc",
				},
			},
		},
	}

	if ls_ok then
		config.snippet_engine = "luasnip"
	end

	ng.setup(config)

	local opts = { silent = true }
	local mappings = {
		f = {
			function()
				ng.generate({ type = "func" })
			end,
			"function",
		},
		c = {
			function()
				ng.generate({ type = "class" })
			end,
			"class",
		},
		i = {
			function()
				ng.generate({ type = "file" })
			end,
			"file",
		},
		t = {
			function()
				ng.generate({ type = "type" })
			end,
			"type",
		},
	}
	local prefix = "<leader>og"
	opts.desc = "generate_neogen"
	vks("n", prefix, ng.generate, opts)
	prefix = "<leader>oG"
	for k, v in pairs(mappings) do
		if v[1] ~= nil then
			opts.desc = v[2]
			vks("n", prefix .. k, v[1], opts)
		end
	end
end

function M.config_kitty_navigator()
	require("which-key").register({
		["<a-h>"] = { "<cmd>KittyNavigateLeft<cr>", "kitty_left" },
		["<a-j>"] = { "<cmd>KittyNavigateDown<cr>", "kitty_down" },
		["<a-k>"] = { "<cmd>KittyNavigateUp<cr>", "kitty_up" },
		["<a-l>"] = { "<cmd>KittyNavigateRight<cr>", "kitty_right" },
	})
	log.info("setup of kitty navigator complete")
end

function M.setup_diffview()
	-- Lua
	local cb = require("diffview.config").diffview_callback

	require("diffview").setup({
		diff_binaries = false, -- Show diffs for binaries
		use_icons = false, -- Requires nvim-web-devicons
		enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
		signs = { fold_closed = "", fold_open = "" },
		file_panel = {
			position = "left", -- One of 'left', 'right', 'top', 'bottom'
			width = 35, -- Only applies when position is 'left' or 'right'
			height = 10, -- Only applies when position is 'top' or 'bottom'
		},
		file_history_panel = {
			position = "bottom",
			width = 35,
			height = 16,
			log_options = {
				max_count = 256, -- Limit the number of commits
				follow = true, -- Follow renames (only for single file)
				all = true, -- Include all refs under 'refs/' including HEAD
				merges = false, -- List only merge commits
				no_merges = false, -- List no merge commits
				reverse = false, -- List commits in reverse order
			},
		},
		key_bindings = {
			disable_defaults = true, -- Disable the default key bindings
			-- The `view` bindings are active in the diff buffers, only when the current
			-- tabpage is a Diffview.
			view = {
				["<leader>dj"] = cb("select_next_entry"), -- Open the diff for the next file
				["<leader>dk"] = cb("select_prev_entry"), -- Open the diff for the previous file
				["gf"] = cb("goto_file"), -- Open the file in a new split in previous tabpage
				["<C-w><C-f>"] = cb("goto_file_split"), -- Open the file in a new split
				["<C-w>gf"] = cb("goto_file_tab"), -- Open the file in a new tabpage
				["<leader>dp"] = cb("focus_files"), -- Bring focus to the files panel
				["<leader>dt"] = cb("toggle_files"), -- Toggle the files panel.
			},
			file_panel = {
				["j"] = cb("next_entry"), -- Bring the cursor to the next file entry
				["<down>"] = cb("next_entry"),
				["k"] = cb("prev_entry"), -- Bring the cursor to the previous file entry.
				["<up>"] = cb("prev_entry"),
				["<cr>"] = cb("select_entry"), -- Open the diff for the selected entry.
				["o"] = cb("select_entry"),
				["<2-LeftMouse>"] = cb("select_entry"),
				["<leader>ds"] = cb("toggle_stage_entry"), -- Stage / unstage the selected entry.
				["<leader>da"] = cb("stage_all"), -- Stage all entries.
				["<leader>du"] = cb("unstage_all"), -- Unstage all entries.
				["<leader>dU"] = cb("restore_entry"), -- Restore entry to the state on the left side.
				["<leader>dr"] = cb("refresh_files"), -- Update stats and entries in the file list.
				["<leader>dj"] = cb("select_next_entry"), -- Open the diff for the next file
				["<leader>dk"] = cb("select_prev_entry"), -- Open the diff for the previous file
				["gf"] = cb("goto_file"),
				["<C-w><C-f>"] = cb("goto_file_split"),
				["<C-w>gf"] = cb("goto_file_tab"),
				["<leader>dp"] = cb("focus_files"), -- Bring focus to the files panel
				["<leader>dt"] = cb("toggle_files"), -- Toggle the files panel.
			},
			file_history_panel = {
				["<leader>do"] = cb("options"), -- Open the option panel
				["<leader>dd"] = cb("open_in_diffview"), -- Open the entry under the cursor in a diffview
				["zR"] = cb("open_all_folds"),
				["<c-n>"] = cb("open_all_folds"),
				["zM"] = cb("close_all_folds"),
				["<c-c>"] = cb("close_all_folds"),
				["j"] = cb("next_entry"),
				["<down>"] = cb("next_entry"),
				["k"] = cb("prev_entry"),
				["<up>"] = cb("prev_entry"),
				["<cr>"] = cb("select_entry"),
				["o"] = cb("select_entry"),
				["<2-LeftMouse>"] = cb("select_entry"),
				["<leader>dj"] = cb("select_next_entry"), -- Open the diff for the next file
				["<leader>dk"] = cb("select_prev_entry"), -- Open the diff for the previous file
				["gf"] = cb("goto_file"),
				["<C-w><C-f>"] = cb("goto_file_split"),
				["<C-w>gf"] = cb("goto_file_tab"),
				["<leader>dp"] = cb("focus_files"), -- Bring focus to the files panel
				["<leader>dt"] = cb("toggle_files"), -- Toggle the files panel.
			},
			option_panel = {
				["<leader>ds"] = cb("select"),
				["<tab>"] = cb("select"),
				["q"] = cb("close"),
			},
		},
	})
end

function M.setup_lens()
	-- Resizing not always work
	-- Specially when openning a few windows, like 5 or 6
	vim.g["lens#disabled_filetypes"] = { "nerdtree", "fzf", "NvimTree" }
	vim.g["lens#width_resize_max"] = 120
	vim.g["lens#height_resize_max"] = 60
end

function M.setup_zen_mode()
	require("zen-mode").setup({
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
	})

	require("which-key").register({
		["<plug>focus_toggle"] = { "<cmd>ZenMode<cr>", "zen_mode_focus_toggle" },
	})
end

local function gps_get_location()
	local ret = require("nvim-gps").get_location()
	if ret == "error" then
		return ""
	end

	return ret
end

function M.setup_gpsnvim()
	local gps = require("nvim-gps")
	gps.setup({
		icons = {
			["class-name"] = "", -- Classes and class-like objects
			["function-name"] = "", -- Functions
			["method-name"] = "", -- Methods (functions inside class-like objects)
			["container-name"] = "", -- Containers (example: lua tables)
			["tag-name"] = "", -- Tags (example: html tags)
		},
		depth = 4,
		separator = " > ",
	})

	if vim.fn.has("nvim-0.8") <= 0 then
		log.info("ins_left(): nvim-gps")
		line:ins_left({
			gps_get_location,
			condition = gps.is_available,
		})
	end
end

function M.config_focus()
	-- Initially mappings are enabled
	local focus = require("focus")
	focus.setup({
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
	})

	local mappings = {
		["<leader>tw"] = { "<cmd>FocusToggle<cr>", "focus_mode_toggle_mappings" },
		["<a-h>"] = {
			function()
				focus.split_command("h")
			end,
			"window_switch_left",
		},
		["<a-j>"] = {
			function()
				focus.split_command("j")
			end,
			"window_switch_down",
		},
		["<a-k>"] = {
			function()
				focus.split_command("k")
			end,
			"window_switch_up",
		},
		["<a-l>"] = {
			function()
				focus.split_command("l")
			end,
			"window_switch_right",
		},
	}
	require("which-key").register(mappings)
	log.info("setup of focus complete")
end

function M.setup_sneak()
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
end

function M.config_kommentary()
	local config = require("kommentary.config")
	config.configure_language("wings_syntax", {
		single_line_comment_string = "//",
		prefer_single_line_comments = true,
	})
	config.configure_language("dosini", {
		single_line_comment_string = ";",
		prefer_single_line_comments = true,
	})

	--[[ The default mapping for line-wise operation; will toggle the range from
  commented to not-commented and vice-versa, will use a single-line comment. ]]
	vim.api.nvim_set_keymap("n", "-", "<Plug>kommentary_line_default", {})
	--[[ The default mapping for visual selections; will toggle the range from
  commented to not-commented and vice-versa, will use multi-line comments when
  the range is longer than 1 line, otherwise it will use a single-line comment. ]]
	vim.api.nvim_set_keymap("x", "-", "<Plug>kommentary_visual_default<C-c>", {})
	--[[ The default mapping for motions; will toggle the range from commented to
  not-commented and vice-versa, will use multi-line comments when the range
  is longer than 1 line, otherwise it will use a single-line comment. ]]
	vim.api.nvim_set_keymap("n", "0", "<Plug>kommentary_motion_default", {})

	--[[--
  Creates mappings for in/decreasing comment level.
  ]]
	--[[ vim.api.nvim_set_keymap("n", "<leader>oic", "<Plug>kommentary_line_increase", {})
  vim.api.nvim_set_keymap("n", "<leader>oi", "<Plug>kommentary_motion_increase", {})
  vim.api.nvim_set_keymap("x", "<leader>oi", "<Plug>kommentary_visual_increase", {})
  vim.api.nvim_set_keymap("n", "<leader>odc", "<Plug>kommentary_line_decrease", {})
  vim.api.nvim_set_keymap("n", "<leader>od", "<Plug>kommentary_motion_decrease", {})
  vim.api.nvim_set_keymap("x", "<leader>od", "<Plug>kommentary_visual_decrease", {}) ]]
end

function M.setup_comment_frame()
	require("nvim-comment-frame").setup({

		-- if true, <leader>cf keymap will be disabled
		disable_default_keymap = true,

		-- adds custom keymap
		-- keymap = '<leader>cc',
		-- multiline_keymap = '<leader>C',

		-- start the comment with this string
		start_str = "//",

		-- end the comment line with this string
		end_str = "//",

		-- fill the comment frame border with this character
		fill_char = "-",

		-- width of the comment frame
		frame_width = 70,

		-- wrap the line after 'n' characters
		line_wrap_len = 50,

		-- automatically indent the comment frame based on the line
		auto_indent = true,

		-- add comment above the current line
		add_comment_above = true,

		-- configurations for individual language goes here
		languages = {},
	})

	local p = [[<leader>om]]
  local o = { silent = true, desc = "add_multiline_comment" }
  vks('n', p, require("nvim-comment-frame").add_multiline_comment, o)
end

function M.config_starlite()
	local opts = { silent = true, desc = "goto_next_abs_word_under_cursor" }
	local sl = require("starlite")
	vks("n", "*", sl.star, opts)
	opts.desc = "goto_next_word_under_cursor"
	vks("n", "g*", sl.g_star, opts)
	opts.desc = "goto_prev_abs_word_under_cursor"
	vks("n", "#", sl.hash, opts)
	opts.desc = "goto_prev_word_under_cursor"
	vks("n", "g#", sl.g_hash, opts)
end

function M.setup_bookmarks()
	vim.g.bookmark_no_default_key_mappings = 1
	vim.g.bookmark_manage_per_buffer = 0
	vim.g.bookmark_save_per_working_dir = 0
	vim.g.bookmark_dir = vim.fn.stdpath("data") .. "/bookmarks"
	vim.g.bookmark_auto_save = 0
	vim.g.bookmark_auto_save_file = vim.g.bookmark_dir .. "/bookmarks"
	vim.g.bookmark_highlight_lines = 1
end

function M.config_bookmarks()
  local opts = { silent = true }
	local leader = {}
	local prefix = [[<leader>B]]
	leader = {
		t = { "<Plug>BookmarkToggle", "BookmarkToggle" },
		i = { "<Plug>BookmarkAnnotate", "BookmarkAnnotate" },
		a = { "<Plug>BookmarkShowAll", "BookmarkShowAll" },
		n = { "<Plug>BookmarkNext", "BookmarkNext" },
		p = { "<Plug>BookmarkPrev", "BookmarkPrev" },
		c = { "<Plug>BookmarkClear", "BookmarkClear" },
		x = { "<Plug>BookmarkClearAll", "BookmarkClearAll" },
		k = { "<Plug>BookmarkMoveUp", "BookmarkMoveUp" },
		j = { "<Plug>BookmarkMoveDown", "BookmarkMoveDown" },
		o = { "<Plug>BookmarkLoad", "BookmarkLoad" },
		s = { "<Plug>BookmarkSave", "BookmarkSave" },
	}
  for k, v in pairs(leader) do
    if v[1] ~= nil then
      opts.desc = v[2]
      vks("n", prefix .. k, v[1], opts)
    end
  end
end

function M.setup_bdelete()
	local bd = require("close_buffers")
	bd.setup({
		filetype_ignore = {}, -- Filetype to ignore when running deletions
		file_glob_ignore = {}, -- File name glob pattern to ignore when running deletions (e.g. '*.md')
		file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
		preserve_window_layout = { "this", "nameless" }, -- Types of deletion that should preserve the window layout
		next_buffer_cmd = nil, -- Custom function to retrieve the next buffer when preserving window layout
	})

	local wk = require("which-key")
	local leader = {}
	local leader_p = [[<leader>]]
	leader.b = {
		name = "buffers",
		d = {
			function()
				bd.delete({ type = "this" })
			end,
			"buffer_delete_current",
		},
		l = {
			function()
				bd.delete({ type = "all", force = true })
			end,
			"buffer_delete_all",
		},
		n = {
			function()
				bd.delete({ type = "nameless" })
			end,
			"buffer_delete_nameless",
		},
		g = {
			function()
				bd.delete({ glob = vim.fn.input("Please enter glob (ex. *.lua): ") })
			end,
			"buffer_delete_glob",
		},
	}
	wk.register(leader, { prefix = leader_p })
end

function M.config_leap()
	require("leap").setup({
		case_insensitive = true,
		speacial_keys = {
			repeat_search = "'",
			next_match = "'",
			prev_match = ",",
			next_group = "",
			prev_group = "",
			eol = "",
		},
	})
	vks("n", "s", [[<Plug>(leap-forward)]])
	vks("n", "t", [[<Plug>(leap-forward)]])
end

local function obsession_status()
	return vim.fn["ObsessionStatus"]("S:" .. vim.fn.fnamemodify(vim.v.this_session, ":t:r"), "$")
end

function M.setup_papercolor()
	log.info("[papercolor]: Setting up...")
	vim.g.flux_day_colorscheme = "PaperColor"
	vim.g.flux_night_colorscheme = "PaperColor"
	vim.g.flux_day_statusline_colorscheme = "PaperColor_light"
	vim.g.flux_night_statusline_colorscheme = "PaperColor_dark"
	if vim.fn.has("unix") > 0 and vim.fn.executable("luajit") > 0 then
		vim.g.flux_enabled = 0
		vim.fn["flux#Manual"]()
	else
		local id = api.nvim_create_augroup("FluxLike", { clear = true })
		api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
			callback = function()
				vim.fn["flux#Flux"]()
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
	vim.g.PaperColor_Theme_Options = {
		["theme"] = {
			["default"] = {
				["transparent_background"] = 0,
				["allow_bold"] = 1,
				["allow_italic"] = 1,
			},
		},
	}
end

function M.setup_neoterm()
	vim.g.neoterm_automap_keys = ""
	vim.g.neoterm_term_per_tab = 1
	vim.g.neoterm_use_relative_path = 1
	vim.g.neoterm_default_mod = ""
	vim.g.neoterm_autoinsert = 0
	-- " Potential substitue
	-- " https://github.com/Shougo/deol.nvim/blob/master/doc/deol.txt
	-- " there is also vimshell
end

function M.config_neoterm()
	require("which-key").register({
		["<plug>terminal_new"] = { "<cmd>Tnew<cr>", "term_new" },
		["<plug>terminal_send_file"] = { "<cmd>TREPLSendFile<cr>", "term_send_file" },
		["<plug>terminal_send"] = { "<Plug>(neoterm-repl-send)", "term_send_line" },
		["<plug>terminal_send_line"] = {
			"<Plug>(neoterm-repl-send-line)",
			"term_send_line",
		},
	})
	local opts = { silent = true, desc = "terminal" }
	vks("n", "<plug>terminal_toggle", function()
		utl.exec_float_term("Ttoggle")
	end, opts)
end

function M.setup_pomodoro()
	vim.g.pomodoro_use_devicons = 0
	if vim.fn.executable("dunst") > 0 then
		vim.g.pomodoro_notification_cmd = "notify-send 'Pomodoro' 'Session ended' && "
			.. "mpv ~/.config/dotfiles/notification_sounds/cool_notification1.mp3 "
			.. "2>/dev/null&"
	elseif vim.fn.executable("powershell") > 0 then
		local notif = os.getenv("APPDATA") .. "/dotfiles/scripts/win/win_vim_notification.ps1"
		if vim.fn.filereadable(notif) then
			vim.g.pomodoro_notification_cmd = notif
		end
	end
	vim.g.pomodoro_log_file = vim.fn.stdpath("data") .. "/pomodoro_log"

	log.info("ins_left(): pomodoro")
	line:ins_left({
		function()
			return vim.fn["pomo#status_bar"]()
		end,
		color = { fg = line.colors.orange, gui = "bold" },
		left_padding = 0,
	})
end

function M.setup_luadev()
	local luadev = require("lua-dev").setup({
		library = {
			vimruntime = true, -- runtime path
			-- full signature, docs and completion of vim.api, vim.treesitter,
			-- vim.lsp and others
			types = true,
			-- List of plugins you want autocompletion for
			plugins = true,
		},
		-- pass any additional options that will be merged in the final lsp config
		lspconfig = {
			cmd = { "lua-language-server" },
			on_attach = require("config.lsp").on_lsp_attach,
		},
	})

	local lspconfig = require("lspconfig")
	lspconfig.sumneko_lua.setup(luadev)
end

function M.setup_neogit()
	require("neogit").setup({})
	-- open commit popup
	-- neogit.open({ "commit" })
	require("which-key").register({
		["<leader>vo"] = { require("neogit").open, "neogit_open" },
	})
end

function M.config_git_messenger()
	require("which-key").register({
		["<leader>vm"] = { "<cmd>GitMessenger<cr>", "git_messenger" },
	})
end

function M.config_iswap()
	require("iswap").setup({
		-- The keys that will be used as a selection, in order
		-- ('asdfghjklqwertyuiopzxcvbnm' by default)
		keys = "qwertyuiop",
		-- Grey out the rest of the text when making a selection
		-- (enabled by default)
		grey = "enabled",
		-- Highlight group for the sniping value (asdf etc.)
		-- default 'Search'
		hl_snipe = "ErrorMsg",
		-- Highlight group for the visual selection of terms
		-- default 'Visual'
		hl_selection = "WarningMsg",
		-- Highlight group for the greyed background
		-- default 'Comment'
		hl_grey = "LineNr",
	})
	local opts = { silent = true, desc = "iswap_arguments" }
	vks("n", "<localleader>s", require("iswap").iswap, opts)
end

function M.setup_obsession()
	vim.g.obsession_no_bufenter = 1
	log.info("ins_right(): obsession")
	line:ins_right({
		obsession_status,
		color = { fg = line.colors.blue, gui = "bold" },
		right_padding = 0,
	})
end

return M
