local api = vim.api
local vks = vim.keymap.set
local utl = require("utils.utils")
local fs = require("utils.utils").fs
local vf = vim.fn

local M = {}

--- Abstraction over keymaps_set
-- @param keys table expects all the arguments to keymaps_set
function M:keymaps_sets(keys)
  vim.validate({ keys = { keys, "t" } })

  self.keymaps_set(keys.mappings, keys.mode, keys.opts, keys.prefix)
end

--- Abstraction over vim.keymap.set
---@param mappings (table). Example: 
--  local mappings = {<lhs> = {<rhs>, <desc>}}
---@param mode table, string same as mode in keymap
---@param opts string, function as in keymap.
--              Desc is expected in mappings
---@param prefix (string) To be prefixed to all the indices of mappings
--                Can be nil
function M.keymaps_set(mappings, mode, opts, prefix)
  vim.validate({ mappings = { mappings, "t" } })

  for k, v in pairs(mappings) do
    if v[1] ~= nil then
      opts.desc = v[2]
      vks(mode, prefix ~= nil and prefix .. k or k, v[1], opts)
    end
  end
end

local lua_plugins = vf.stdpath("data") .. [[/site/pack/packer]]

local edit = {}
edit.mode = "n"
edit.prefix = "<leader>e"
edit.opts = { silent = true }
edit.mappings = {
  d = { 
    function()
      fs.path.fuzzer(vim.g.dotfiles)
    end,
    "dotfiles" 
  },
  h = {
    function()
      fs.path.fuzzer(os.getenv("HOME"))
    end,
    "home",
  },
  c = {
    function()
      fs.path.fuzzer(vf.getcwd())
    end,
    "current_dir",
  },
  p = {
    function()
      fs.path.fuzzer(lua_plugins)
    end,
    "lua_plugins_path",
  },
  l = {
    function()
      fs.path.fuzzer(vim.g.vim_plugins_path)
    end,
    "vim_plugins_path",
  },
  v = {
    function()
      fs.path.fuzzer(os.getenv("VIMRUNTIME"))
    end,
    "vimruntime",
  },
}

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

	if vf.exists(":SignifyRefresh") > 0 then
		vim.cmd("SignifyRefresh")
	end

	if utl.is_mod_available("gitsigns") then
		require("gitsigns").refresh()
	end

	if vf.exists(":IndentBlanklineRefresh") > 0 then
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
	vf.execute("wincmd " .. direction)
	local new_win = vim.api.nvim_get_current_win()
	if new_win == curr_win then
		vf.system("tmux select-pane -" .. vf.tr(direction, valid_dir, "lLDUR"))
	end
end

function M.terminal_mappings()
	local opts = { silent = true, desc = "terminal" }
	vks("n", "<plug>terminal_toggle", function()
		utl.exec_float_term("term")
	end, opts)
	opts.desc = "terminal_send_line"
	vks("n", "<plug>terminal_send_line", function()
		local cline = vf.getline(".")
		if cline == "" or cline == nil then
			return
		end
		utl.execute_in_shell(cline)
	end, opts)
	opts.desc = "terminal_send"
	vks("x", "<plug>terminal_send", function()
		local csel = utl.get_visual_selection()
		if csel == "" or csel == nil then
			return
		end
		utl.execute_in_shell(csel)
	end, opts)
end

function M:window_movement_setup()
	local opts = { silent = true, desc = "tmux_move_left" }
	if vf.has("unix") > 0 then
		if vf.exists("$TMUX") > 0 then
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
			-- elseif vim.fn.exists('$KITTY_WINDOW_ID') > 0 then
			return
		end
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
end

function M:setup()
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
	opts.desc = "goto_file_under_cursor"
	vks({ "v", "n" }, "]f", "gf", opts)
	opts.desc = "goto_include_under_cursor"
	vks("n", "]i", "[<c-i>", opts)
	opts.desc = "goto_include_under_cursor"
	vks("n", "[i", "[<c-i>", opts)
	opts.desc = "goto_include_under_cursor_on_right_win"
	vks("n", "]I", "<c-w>i<c-w>L", opts)
	opts.desc = "goto_include_under_cursor_on_left_win"
	vks("n", "[I", "<c-w>i<c-w>H", opts)
	opts.desc = "goto_define_under_cursor"
	vks("n", "]e", "[<c-d>", opts)
	opts.desc = "goto_define_under_cursor"
	vks("n", "[e", "[<c-d>", opts)
	opts.desc = "goto_define_under_cursor_on_right_win"
	vks("n", "]E", "<c-w>d<c-w>L", opts)
	opts.desc = "goto_define_under_cursor_on_left_win"
	vks("n", "[E", "<c-w>d<c-w>H", opts)

	vks({ "n", "x", "o" }, "t", "%")

  self.terminal_mappings()

	self:window_movement_setup()
	-- Window resizing
	opts.desc = "window_size_increase_right"
	vks("n", "<A-S-l>", "<C-w>>", opts)
	opts.desc = "window_size_increase_left"
	vks("n", "<A-S-h>", "<C-w><", opts)
	opts.desc = "window_size_increase_up"
	vks("n", "<A-S-k>", "<C-w>+", opts)
	opts.desc = "window_size_increase_bot"
	vks("n", "<A-S-j>", "<C-w>-", opts)

	opts.desc = "refresh_buffer"
	vks("n", "<c-l>", refresh_buffer, opts)

  -- Flux colors
  local f = require("plugin.flux")
  opts.desc = "toggle_colors_day"
  vks("n", "<leader>td", function() f:set('day') end, opts)
  opts.desc = "toggle_colors_night"
  vks("n", "<leader>tn", function() f:set('night') end, opts)
  opts.desc = "toggle_colors_sunset"
  vks("n", "<leader>tS", function() f:set('sunset') end, opts)
  opts.desc = "toggle_colors_sunrise"
  vks("n", "<leader>tR", function() f:set('sunrise') end, opts)

  -- Quickfix/Location list
  opts.desc = "quickfix"
  vks("n", "<s-q>", "<cmd>copen 20<cr>", opts)
  opts.desc = "quickfix"
  vks("n", "<s-u>", "<cmd>lopen 20<cr>", opts)

  opts.desc = "cwd_files"
  vks("n", "<c-p>", function() fs.path.fuzzer(vf.getcwd()) end, opts)

  self:keymaps_sets(edit)
end

return M
