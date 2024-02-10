local utl = require("utils.utils")
local fs = require("utils.filesystem")

local oil_get_entry = function()
  local o = require("oil")
  local d = fs.is_path(o.get_current_dir())
  if d == nil then
    vim.api.nvim_err_writeln("No oil directory found")
    return nil
  end
  local e = o.get_entry_on_line(0, vim.fn.line("."))
  if e == nil then
    vim.api.nvim_err_writeln("No oil file found")
    return nil
  end
  local f = fs.is_path(vim.fs.joinpath(d, e.name))
  if f == nil then
    vim.api.nvim_err_writeln("File: '" .. f .. "' not found")
    return nil
  end

  return f
end

local oil_yank_entry = function()
  local e = oil_get_entry()
  if e == nil then
    return
  end

  vim.fn.setreg('"', e)
  vim.fn.setreg('+', e)
  vim.fn.setreg('*', e)
  vim.notify("Yanked to clipboard: " .. e)
end

local oil_start_entry = function()
  local e = oil_get_entry()
  if e == nil then
    return
  end

	utl.term.open_uri(e)
end

local nvim_open_win_override = function(conf)
	local lines = utl.get_visible_lines(0)
	local s = lines.start_line
	local e = lines.end_line
	conf.height = math.floor((e - s) * 0.8)
  conf.width = math.floor(vim.o.columns * 0.6)
	conf.row = math.floor((e - s) * 0.1)
end

return {
	"stevearc/oil.nvim",
  event = "VeryLazy",
	keys = {
		{
			"<plug>file_oil_browser",
			function()
				require("oil").open()
			end,
			desc = "file-tree-neotree",
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function(args)
				vim.keymap.set("n", "q", "<cmd>normal! ZZ<cr>", { buffer = args.buf })
				vim.keymap.set("n", "s", oil_start_entry, { buffer = args.buf })
        vim.keymap.set("n", "Y", oil_yank_entry, { buffer = args.buf })
			end,
		})
	end,
	opts = {
		default_file_explorer = true,
		win_options = {
			wrap = false,
			signcolumn = "no",
			cursorcolumn = false,
			foldcolumn = "0",
			spell = false,
			list = false,
			conceallevel = 3,
			concealcursor = "n",
			number = false,
			relativenumber = true,
			numberwidth = 1,
			cursorline = true,
		},
		columns = {
			"size",
			"mtime",
			"icon",
			-- "permissions",
		},
		-- Configuration for the floating window in oil.open_float
		float = {
			-- Padding around the floating window
			padding = 0,
			max_width = 80,
			max_height = 60,
			border = "rounded",
			win_options = {
				winblend = 0,
			},
			override = nvim_open_win_override,
		},
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-s>"] = "actions.select_vsplit",
			["<C-v>"] = "actions.select_vsplit",
			["<C-h>"] = "actions.select_split",
			["<C-t>"] = "actions.select_tab",
			["<C-p>"] = "actions.preview",
			["<C-c>"] = "actions.close",
			["q"] = "actions.close",
			["<C-l>"] = "actions.refresh",
			["-"] = "actions.parent",
			["<bs>"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = "actions.tcd",
			["g."] = "actions.toggle_hidden",
		},
		view_options = {
			-- Show files and directories that start with "."
			show_hidden = true,
			-- This function defines what is considered a "hidden" file
			is_hidden_file = function(name, bufnr)
				return vim.startswith(name, ".")
			end,
			-- This function defines what will never be shown, even when `show_hidden` is set
			is_always_hidden = function(name, bufnr)
				return false
			end,
		},
	},
}
