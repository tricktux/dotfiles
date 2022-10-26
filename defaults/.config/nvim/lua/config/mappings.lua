local api = vim.api
local log = require("utils.log")
local fmt = string.format
local vks = vim.keymap.set
local utl = require("utils.utils")
local fs = require("utils.utils").fs
local fn = vim.fn

local M = {}

M.esc = [[;j]]

--- Abstraction over keymaps_set
-- @param keys table expects all the arguments to keymaps_set
function M:keymaps_sets(keys)
	vim.validate({ keys = { keys, "t" } })

	self.keymaps_set(keys.mappings, keys.mode, keys.opts, keys.prefix)
end

--- Abstraction over vim.keymap.set
---@param mappings (table). Example:
--  local mappings = {<lhs> = {<rhs>, <desc>, mode}}
--  The mode above is optional
--  It allows the user to overwrite the mode just for this mapping
--  The function also detects if rhs is a <plug> type mapping and adds remap
--  option for you
---@param mode table or string (optional, default = "n") same as mode in keymap
---@param opts string or function (optional default = {silent = true}) as in keymap.
--              Desc is expected in mappings
---@param prefix (string) To be prefixed to all the indices of mappings
--                Can be nil
function M.keymaps_set(mappings, mode, opts, prefix)
	vim.validate({ mappings = { mappings, "t" } })
	vim.validate({ mode = { mode, { "s", "t" }, true } })
	vim.validate({ opts = { opts, "t", true } })
	vim.validate({ prefix = { prefix, "s", true } })

	for k, v in pairs(mappings) do
		local o = vim.deepcopy(opts or { silent = true })
		o.desc = v[2] or nil
		local m = v[3] or vim.deepcopy(mode or "n")
		local lhs = prefix and prefix .. k or k

		vim.validate({ ["lhs = " .. lhs .. ", rhs = "] = { v[1], { "s", "f" } } })
		local t = type(v[1])
		if t == "string" then -- determine if rhs is a <plug> mapping
			local i, j = string.find(v[1], "^<[Pp]lug>")
			if i == 1 and j == 6 then
				o.remap = true
			end
		end
		log.trace(fmt("mapping: m = '%s', lhs = '%s', rhs = '%s', o = '%s'", vim.inspect(m), lhs, v[1], vim.inspect(o)))
		vks(m, lhs, v[1], o)
	end
end

local function refresh_buffer()
	api.nvim_exec(
		[[
  update
  nohlsearch
  diffupdate
  mode
  edit
  normal! zzze<cr>
  ]],
		false
	)

	local ind_ok, ind = pcall(require, "indent_blankline.commands")
	if ind_ok and ind.refresh ~= nil then
		ind.refresh(false, true)
	end

	local git_ok, git = pcall(require, "gitsigns")
	if git_ok and git.refresh ~= nil then
		git.refresh()
	end
end

local function tmux_move(direction)
	local valid_dir = "phjkl"
	vim.validate({
		direction = {
			direction,
			function(d)
				return (valid_dir):find(d)
			end,
			valid_dir,
		},
	})

	local curr_win = vim.api.nvim_get_current_win()
	fn.execute("wincmd " .. direction)
	local new_win = vim.api.nvim_get_current_win()
	if new_win == curr_win then
		fn.system("tmux select-pane -" .. fn.tr(direction, valid_dir, "lLDUR"))
	end
end

local function terminal_send_line()
	local csel = utl.get_visual_selection()
	if csel == "" or csel == nil then
		return
	end
	utl.term.exec(csel)
end

-- Visual mode mappings
M.visual = {
	mode = "x",
}
-- Select mode mappings
M.selectm = {}
M.selectm.mode = "s"
-- Visual and Select mode mappings
M.viselect = {}
M.viselect.mode = "v"

M.help = {
	prefix = "<leader>h",
}
M.help.mappings = {
	wv = {
		function()
			vim.ui.input({ prompt = "Enter search word for vimhelp: " }, function(input)
				vim.api.nvim_cmd({ cmd = "h", args = { input } }, {})
			end)
		end,
		"help_cword_vimhelp",
	},
	wm = {
		function()
			vim.ui.input({ prompt = "Enter search word for man: " }, function(input)
				vim.api.nvim_cmd({ cmd = "Man", args = { input } }, {})
			end)
		end,
		"help_cword_man",
	},
	wz = {
		function()
			vim.ui.input({ prompt = "Enter search word for zeal: " }, function(input)
				utl.zeal.search(input)
			end)
		end,
		"help_cword_zeal",
	},
	wb = {
		function()
			vim.ui.input({ prompt = "Enter search word for browser: " }, function(input)
				utl.browser.search(input)
			end)
		end,
		"help_cword_browser",
	},
	cv = {
		function()
			vim.api.nvim_cmd({ cmd = "h", args = { fn.expand("<cword>") } }, {})
		end,
		"help_cword_vimhelp",
	},
	cm = {
		function()
			vim.api.nvim_cmd({ cmd = "Man", args = { fn.expand("<cword>") } }, {})
		end,
		"help_cword_man",
	},
	cz = {
		function()
			utl.zeal.search(fn.expand("<cword>"))
		end,
		"help_cword_zeal",
	},
	cb = {
		function()
			utl.browser.search(fn.expand("<cword>"))
		end,
		"help_cword_browser",
	},
}

-- NOTE: Please update the mappings in flux_post_{day,night,sunrise,sunset}
-- if updating these mappings below
M.colors = {}
M.colors.prefix = "<leader>tc"
M.colors.mappings = {
	d = {
		function()
			require("plugin.flux"):set("day")
		end,
		"day",
	},
	n = {
		function()
			require("plugin.flux"):set("night")
		end,
		"night",
	},
	r = {
		function()
			require("plugin.flux"):set("sunrise")
		end,
		"sunrise",
	},
	s = {
		function()
			require("plugin.flux"):set("sunset")
		end,
		"sunset",
	},
}

M.toggle = {
	prefix = "<leader>t",
	virtual = true, -- Used to toggle virtual_text
	diagnostic = true, -- Used to toggle diagnostic
}
M.toggle.mappings = {
	s = {
		function()
			vim.opt_local.spell = not vim.opt_local.spell:get()
			print(fmt("toggle: spell '%s'", (vim.opt_local.spell:get() and "enabled" or "disabled")))
		end,
		"toggle_spell",
	},
	v = {
		function()
			M.toggle.virtual = not M.toggle.virtual
			vim.diagnostic.config({ virtual_text = M.toggle.virtual })
			print(fmt("toggle: virtual_text '%s'", (M.toggle.virtual and "enabled" or "disabled")))
		end,
		"toggle_virtual_text",
	},
	d = {
		function()
			M.toggle.diagnostic = not M.toggle.diagnostic
			if M.toggle.diagnostic then
				vim.diagnostic.disable()
			else
				vim.diagnostic.enable()
			end
			print(fmt("toggle: vim_diagnostic '%s'", (M.toggle.diagnostic and "enabled" or "disabled")))
		end,
		"toggle_vim_diagnostic",
	},
}

M.edit = {}
M.edit.prefix = "<leader>e"
M.edit.edit_temporary_file = function(type)
	local s = utl.fs.path.sep
	local t = os.date("%y%m%d_%H%M%S")
	local f = fmt("%s%stemp_%s", vim.fn.stdpath("cache"), s, t)
	local e = type and "." .. type or ""
	if fn.has("nvim-0.8") > 0 then
		vim.cmd({ cmd = "edit", args = { fmt("%s%s", f, e) } })
		return
	end
	vim.cmd(fmt("edit %s%s", f, e))
end
M.edit.mappings = {
	a = {
		function()
			fs.file.create(vim.fn.getcwd())
		end,
		"add_new_file_folder",
	},
	d = {
		function()
			fs.path.fuzzer(vim.g.dotfiles)
		end,
		"dotfiles",
	},
	h = {
		function()
			fs.path.fuzzer(os.getenv("HOME"))
		end,
		"home",
	},
	c = {
		function()
			fs.path.fuzzer(fn.getcwd())
		end,
		"current_dir",
	},
	p = {
		function()
			local p = require("config.plugins.packer").path.plugins
			fs.path.fuzzer(p)
		end,
		"lua_plugins_path",
	},
	v = {
		function()
			fs.path.fuzzer(os.getenv("VIMRUNTIME"))
		end,
		"vimruntime",
	},
	tm = {
		function()
			M.edit.edit_temporary_file("md")
		end,
		"edit_temporary_markdown",
	},
	tc = {
		function()
			M.edit.edit_temporary_file("cpp")
		end,
		"edit_temporary_cpp",
	},
	tC = {
		function()
			M.edit.edit_temporary_file("c")
		end,
		"edit_temporary_c",
	},
	tr = {
		function()
			M.edit.edit_temporary_file("rs")
		end,
		"edit_temporary_rust",
	},
	tl = {
		function()
			M.edit.edit_temporary_file("lua")
		end,
		"edit_temporary_lua",
	},
	tp = {
		function()
			M.edit.edit_temporary_file("py")
		end,
		"edit_temporary_python",
	},
	tv = {
		function()
			M.edit.edit_temporary_file("vim")
		end,
		"edit_temporary_vim",
	},
	tb = {
		function()
			M.edit.edit_temporary_file(utl.has_unix and "sh" or "bat")
		end,
		"edit_temporary_batch",
	},
	tg = {
		function()
			local o = {
				prompt = "Please enter an extention for the file: ",
				default = "lua",
			}
			local i = function(input)
				M.edit.edit_temporary_file(input)
			end
			vim.ui.input(o, i)
		end,
		"edit_temporary_general",
	},
	P = {
		function()
			vim.api.nvim_exec("edit " .. vim.fn.getreg("+"), true)
		end,
		"edit_file_path_clipboard",
	},
}

M.terminal = {}
M.terminal.mappings = {
	["<localleader>e"] = { "<plug>terminal_send_line", "terminal_send_line" },
	["ge"] = { "<plug>terminal_send_line_visual", "terminal_send_line_visual", "x" },
	["<localleader>v"] = { "<plug>terminal_send_visual", "terminal_send_visual", "x" },
	["<leader>Th"] = { "<plug>terminal_open_horizontal", "terminal_open_horizontal" },
	["<leader>Tv"] = { "<plug>terminal_open_vertical", "terminal_open_vertical" },
	["<a-`>"] = { "<plug>terminal_toggle", "terminal_toggle" },
	["<plug>terminal_toggle"] = {
		function()
			utl.exec_float_term("term")
		end,
		"terminal_toggle",
	},
	["<plug>terminal_send_line"] = {
		function()
			local csel = utl.get_visual_selection()
			if csel == "" or csel == nil then
				return
			end
			utl.term.exec(csel)
		end,
		"terminal_send_line",
		{ "n", "x" },
	},
}

function M:window_movement_setup()
	local opts = { silent = true, desc = "tmux_move_left" }
	if fn.has("unix") > 0 and fn.exists("$TMUX") > 0 then
		vks("n", "<A-h>", function()
			tmux_move("h")
		end, opts)
		opts.desc = "tmux_move_down"
		vks("n", "<A-j>", function()
			tmux_move("j")
		end, opts)
		opts.desc = "tmux_move_up"
		vks("n", "<A-k>", function()
			tmux_move("k")
		end, opts)
		opts.desc = "tmux_move_right"
		vks("n", "<A-l>", function()
			tmux_move("l")
		end, opts)
		opts.desc = "tmux_move_prev"
		vks("n", "<A-p>", function()
			tmux_move("p")
		end, opts)
		return
	end

	opts.desc = "cursor_right_win"
	vks("n", "<A-l>", "<C-w>lzz", opts)
	opts.desc = "cursor_left_win"
	vks("n", "<A-h>", "<C-w>hzz", opts)
	opts.desc = "cursor_up_win"
	vks("n", "<A-k>", "<C-w>kzz", opts)
	opts.desc = "cursor_bot_win"
	vks("n", "<A-j>", "<C-w>jzz", opts)
	opts.desc = "cursor_prev_win"
	vks("n", "<A-p>", "<C-w>pzz", opts)
	-- Window resizing
	opts.desc = "window_size_increase_right"
	vks("n", "<A-S-l>", "<C-w>>", opts)
	opts.desc = "window_size_increase_left"
	vks("n", "<A-S-h>", "<C-w><", opts)
	opts.desc = "window_size_increase_up"
	vks("n", "<A-S-k>", "<C-w>+", opts)
	opts.desc = "window_size_increase_bot"
	vks("n", "<A-S-j>", "<C-w>-", opts)
end

local function misc_mappings()
	vks({ "v", "i" }, M.esc, [[<Esc>zz]])
	local opts = { nowait = true, desc = "start_cmd" }
	-- Awesome hack, typing a command is used way more often than next
	vks("n", ";", ":", opts)

	opts = { silent = true, desc = "visual_end_line" }
	-- Let's make <s-v> consistent as well
	vks("n", "<s-v>", "v$h", opts)
	opts = { silent = true, desc = "visual_line" }
	vks("n", "vv", "<s-v>", opts)
	opts = { silent = true, desc = "visual_increment" }
	vks("v", "gA", "g<c-a>", opts)
	opts.desc = "visual_decrement"
	vks("v", "gX", "g<c-x>", opts)

	vks({ "n", "x", "o" }, "t", "%")

	opts.desc = "refresh_buffer"
	vks("n", "<c-l>", refresh_buffer, opts)

	-- Quickfix/Location list
	opts.desc = "quickfix"
	vks("n", "<s-q>", "<cmd>copen 20<cr>", opts)
	opts.desc = "quickfix"
	vks("n", "<s-u>", "<cmd>lopen 20<cr>", opts)

	opts.desc = "cwd_files"
	vks("n", "<plug>mru_browser", function()
		fs.path.fuzzer(fn.getcwd())
	end, opts)

	vks({ "v", "n" }, "<cr>", [=[o<Esc>zz]=])

	-- Decrease number
	vks({ "n", "x" }, "<s-x>", "<c-x>")
end

M.plug = {}
M.plug.mappings = {
	["<leader>F"] = { "<plug>file_browser", "file_browser" },
	["<leader>tf"] = { "<plug>focus_toggle", "focus_toggle" },
	["<s-k>"] = { "<plug>buffer_browser", "buffer_browser" },
	["<c-p>"] = { "<plug>mru_browser", "mru_browser" },
	["<localleader>f"] = { "<plug>format_code", "format_code", { "x", "n" } },
	["<localleader>r"] = { "<plug>refactor_code", "refactor_code", { "x", "n" } },
	["<c-k>"] = { "<plug>snip_expand", "snip_expand", { "x", "i", "s" } },
	["<leader>G"] = { "<plug>search_internet", "search_internet", { "x", "n" } },
	["<localleader>k"] = { "<plug>make_project", "make_project" },
	["<localleader>j"] = { "<plug>make_file", "make_file" },
	["<leader>cr"] = { "<plug>cd_root", "cd_root" },
}

M.braces = {}
M.braces.mappings = {
	["]f"] = { "gf", "goto_file_under_cursor", { "v", "n" } },
	["]i"] = { "[<c-i>", "goto_include_under_cursor" },
	["[i"] = { "[<c-i>", "goto_include_under_cursor" },
	["]I"] = { "<c-w>i<c-w>L", "goto_include_under_cursor_on_right_win" },
	["[I"] = { "<c-w>i<c-w>H", "goto_include_under_cursor_on_left_win" },
	["]e"] = { "[<c-d>", "goto_define_under_cursor" },
	["[e"] = { "[<c-d>", "goto_define_under_cursor" },
	["]E"] = { "<c-w>d<c-w>L", "goto_define_under_cursor_on_right_win" },
	["[E"] = { "<c-w>d<c-w>H", "goto_define_under_cursor_on_left_win" },
}

M.builtin_terminal = {
	mode = "t",
}
M.builtin_terminal.mappings = {
	["<M-`>"] = { [[<c-\><c-n>ZZ]], "terminal_toggle" },
	[M.esc] = { [[<C-\><C-n>]], "terminal_escape" },
	["<A-h>"] = { [[<C-\><C-n><C-w>h]] },
	["<A-j>"] = { [[<C-\><C-n><C-w>j]] },
	["<A-k>"] = { [[<C-\><C-n><C-w>k]] },
	["<A-l>"] = { [[<C-\><C-n><C-w>l]] },
	["<a-]>"] = { [[<C-\><C-n>gt]] },
	["<a-[>"] = { [[<C-\><C-n>gT]] },
}

local function windows_os_mappings()
	vks({ "x", "n" }, "<a-v>", [=["*p=`]zz]=])
	vks("i", "<a-v>", [=[<c-r>*]=])
	vks("n", "<leader>y", [=["*yy]=])
	vks("v", "<leader>y", [=["*y]=])
	vim.cmd([[silent! vunmap <c-x>]])

	M.builtin_terminal.mappings["<c-a>"] = { "<home>" }
	M.builtin_terminal.mappings["<A-v>"] = { [[<C-\><C-n>"+pi]] }
	M.builtin_terminal.mappings["<C-w>"] = { "<C-bs>" }
	M.builtin_terminal.mappings["<A-b>"] = { "<C-Left>" }
	M.builtin_terminal.mappings["<A-w>"] = { "<C-Right>" }
	M.builtin_terminal.mappings["<C-f>"] = { "<Right>" }
	M.builtin_terminal.mappings["<C-b>"] = { "<Left>" }
	M.builtin_terminal.mappings["<C-p>"] = { "<Up>" }
	M.terminal.mappings["<leader>TV"] = {
		function()
			local cmd = [[cmd.exe /k "C:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\VC\\vcvarsall.bat"]]
			utl.term.exec(cmd)
		end,
		"terminal_open_visual_studio",
	}
	local ms = [[https://docs.microsoft.com/en-us/search/?terms=]]
	M.help.mappings["wm"] = {
		function()
			vim.ui.input({ prompt = "Enter search word for browser: " }, function(input)
				utl.browser.search(ms .. input)
			end)
		end,
		"help_input_microsoft",
	}
	M.help.mappings["cm"] = {
		function()
			utl.browser.search(ms .. fn.expand("<cword>"))
		end,
		"help_cword_microsoft",
	}
end

local function unix_os_mappings()
	vks({ "x", "n" }, "<a-v>", [=["+p=`]zz]=])
	vks({ "v", "n" }, "<leader>y", [=["+yy]=])
end

function M:setup()
	self:keymaps_sets(self.plug)
	if utl.has_win then
		windows_os_mappings()
	else
		unix_os_mappings()
	end
	misc_mappings()
	self:keymaps_sets(self.builtin_terminal)
	self:keymaps_sets(self.braces)
	self:window_movement_setup()
	self:keymaps_sets(self.edit)
	self:keymaps_sets(self.colors)
	self:keymaps_sets(self.terminal)
	self:keymaps_sets(self.toggle)
	self:keymaps_sets(self.help)
end

return M
