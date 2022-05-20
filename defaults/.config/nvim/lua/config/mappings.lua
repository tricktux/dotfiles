local api = vim.api
local utl = require("utils.utils")

local M = {}

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

	if vim.fn.exists(":SignifyRefresh") > 0 then
		vim.cmd("SignifyRefresh")
	end

	if utl.is_mod_available("gitsigns") then
		require("gitsigns").refresh()
	end

	if vim.fn.exists(":IndentBlanklineRefresh") > 0 then
		vim.cmd("IndentBlanklineRefresh")
	end
end

local function tmux_move(direction)
	local valid_dir = "phjkl"
	vim.validate({ direction = {
		direction,
		function(d)
			return (valid_dir):find(d)
		end,
		valid_dir,
	} })

	local curr_win = vim.api.nvim_get_current_win()
	vim.fn.execute("wincmd " .. direction)
	local new_win = vim.api.nvim_get_current_win()
	if new_win == curr_win then
		vim.fn.system("tmux select-pane -" .. vim.fn.tr(direction, valid_dir, "lLDUR"))
	end
end

function M.terminal_mappings()
	local opts = { silent = true, desc = "terminal" }
	vim.keymap.set("n", "<plug>terminal_toggle", function()
		utl.exec_float_term("term")
	end, opts)
	opts.desc = "terminal_send_line"
	vim.keymap.set("n", "<plug>terminal_send_line", function()
		local cline = vim.fn.getline(".")
		if cline == "" or cline == nil then
			return
		end
		utl.execute_in_shell(cline)
	end, opts)
	opts.desc = "terminal_send"
	vim.keymap.set("x", "<plug>terminal_send", function()
		local csel = utl.get_visual_selection()
		if csel == "" or csel == nil then
			return
		end
		utl.execute_in_shell(csel)
	end, opts)
end

function M:window_movement_setup()
	local opts = { silent = true, desc = "tmux_move_left" }
	if vim.fn.has("unix") > 0 then
		if vim.fn.exists("$TMUX") > 0 then
			vim.keymap.set("n", "<A-h>", function()
				tmux_move("h")
			end, opts)
			opts.desc = "tmux_move_down"
			vim.keymap.set("n", "<A-j>", function()
				tmux_move("j")
			end, opts)
			opts.desc = "tmux_move_up"
			vim.keymap.set("n", "<A-k>", function()
				tmux_move("k")
			end, opts)
			opts.desc = "tmux_move_right"
			vim.keymap.set("n", "<A-l>", function()
				tmux_move("l")
			end, opts)
			opts.desc = "tmux_move_prev"
			vim.keymap.set("n", "<A-p>", function()
				tmux_move("p")
			end, opts)
			-- elseif vim.fn.exists('$KITTY_WINDOW_ID') > 0 then
			return
		end
	end

	opts.desc = "cursor_right_win"
	vim.keymap.set("n", "<A-l>", "<C-w>lzz", opts)
	opts.desc = "cursor_left_win"
	vim.keymap.set("n", "<A-h>", "<C-w>hzz", opts)
	opts.desc = "cursor_up_win"
	vim.keymap.set("n", "<A-k>", "<C-w>kzz", opts)
	opts.desc = "cursor_bot_win"
	vim.keymap.set("n", "<A-j>", "<C-w>jzz", opts)
	opts.desc = "cursor_prev_win"
	vim.keymap.set("n", "<A-p>", "<C-w>pzz", opts)
end

function M:setup()
	local opts = { nowait = true, desc = "start_cmd" }
	-- Awesome hack, typing a command is used way more often than next
	vim.keymap.set("n", ";", ":", opts)

	opts = { silent = true, desc = "visual_end_line" }
	-- Let's make <s-v> consistent as well
	vim.keymap.set("n", "<s-v>", "v$h", opts)
	opts = { silent = true, desc = "visual_line" }
	vim.keymap.set("n", "vv", "<s-v>", opts)

	opts = { silent = true, desc = "visual_increment" }
	vim.keymap.set("v", "gA", "g<c-a>", opts)
	opts.desc = "visual_decrement"
	vim.keymap.set("v", "gX", "g<c-x>", opts)
	opts.desc = "goto_file_under_cursor"
	vim.keymap.set({ "v", "n" }, "]f", "gf", opts)
	opts.desc = "goto_include_under_cursor"
	vim.keymap.set("n", "]i", "[<c-i>", opts)
	opts.desc = "goto_include_under_cursor"
	vim.keymap.set("n", "[i", "[<c-i>", opts)
	opts.desc = "goto_include_under_cursor_on_right_win"
	vim.keymap.set("n", "]I", "<c-w>i<c-w>L", opts)
	opts.desc = "goto_include_under_cursor_on_left_win"
	vim.keymap.set("n", "[I", "<c-w>i<c-w>H", opts)
	opts.desc = "goto_define_under_cursor"
	vim.keymap.set("n", "]e", "[<c-d>", opts)
	opts.desc = "goto_define_under_cursor"
	vim.keymap.set("n", "[e", "[<c-d>", opts)
	opts.desc = "goto_define_under_cursor_on_right_win"
	vim.keymap.set("n", "]E", "<c-w>d<c-w>L", opts)
	opts.desc = "goto_define_under_cursor_on_left_win"
	vim.keymap.set("n", "[E", "<c-w>d<c-w>H", opts)

	vim.keymap.set({ "n", "x", "o" }, "t", "%")

  self.terminal_mappings()

	self:window_movement_setup()
	-- Window resizing
	opts.desc = "window_size_increase_right"
	vim.keymap.set("n", "<A-S-l>", "<C-w>>", opts)
	opts.desc = "window_size_increase_left"
	vim.keymap.set("n", "<A-S-h>", "<C-w><", opts)
	opts.desc = "window_size_increase_up"
	vim.keymap.set("n", "<A-S-k>", "<C-w>+", opts)
	opts.desc = "window_size_increase_bot"
	vim.keymap.set("n", "<A-S-j>", "<C-w>-", opts)

	opts.desc = "refresh_buffer"
	vim.keymap.set("n", "<c-l>", refresh_buffer, opts)
end

return M
