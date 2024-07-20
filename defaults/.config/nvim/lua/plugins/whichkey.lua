local log = require("utils.log")
local map = require("mappings")

local M = {}

M.__config = {
	preset = "modern",
	plugins = {
		registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		presets = {
			g = false, -- bindings for prefixed with g
		},
	},
	replace = {
		key = {
			function(key)
				return require("which-key.view").format(key)
			end,
			-- { "<Space>", "SPC" },
		},
		desc = {
			{ "<[pP]lug>%(?(.*)%)?", "%1" },
			{ "^%+", "" },
			{ "<[cC]md>", "" },
			{ "<[cC][rR]>", "" },
			{ "<[sS]ilent>", "" },
			{ "^lua%s+", "" },
			{ "^call%s+", "" },
			{ "^:%s*", "" },
		},
	},
	triggers = {
		{ "<auto>", mode = "nixsotc" },
		{ "j", mode = { "i", "v" } },
		{ "k", mode = { "i", "v" } },
	},
}

local leader = {
	{ "<leader>c", group = map.cd.name },
	{ "<leader>d", desc = "duplicate_char" },
	{ "<leader>e", group = map.edit.name },
	{ "<leader>et", desc = map.edit.temporary.name },
	{ "<leader>n", group = "num_representation" },
	{ "<leader>na", desc = "get_ascii_cursor" },
	{ "<leader>nc", desc = "hex_to_ascii" },
	{ "<leader>nh", desc = "ascii_to_hex" },
	{ "<leader>nr", desc = "radical_viewer" },
	{ "<leader>t", group = map.toggle.name },
	{ "<leader>v", group = map.vcs.name },
	{ "<leader>y", group = "misc" },
	{ "<leader>y-", "<cmd>UtilsFontZoomOut<cr>", desc = "font_decrease" },
	{ "<leader>y.", desc = "repeat_last_command" },
	{ "<leader>y2", desc = "2_char_indent" },
	{ "<leader>y4", desc = "4_char_indent" },
	{ "<leader>y8", desc = "8_char_indent" },
	{ "<leader>y=", "<cmd>UtilsFontZoomIn<cr>", desc = "font_increase" },
	{ "<leader>yc", desc = "count_last_search" },
	{ "<leader>ye", group = "sessions" },
	{ "<leader>yee", desc = "load_default" },
	{ "<leader>yel", desc = "load" },
	{ "<leader>yes", desc = "save" },
	{ "<leader>ys", desc = "sync_from_start" },
	{ "<leader>yw", desc = "wings_syntax" },
}
local lleader = {
	{ "<localleader>8", desc = "print_hex" },
	{ "<localleader><", desc = "print_prev_command_output" },
	{ "<localleader>?", desc = "rot13_encode_motion" },
	{ "<localleader>E", "<plug>terminal_send_file", desc = "send_file_terminal" },
	{ "<localleader>c", group = "var_case_change" },
	{ "<localleader>e", "<plug>terminal_send_line", desc = "send_line_terminal" },
	{ "<localleader>f", "<plug>format_code", desc = "format_code" },
	{ "<localleader>j", "<plug>make_file", desc = "make_file" },
	{ "<localleader>k", "<plug>make_project", desc = "make_project" },
	{ "<localleader>q", desc = "format_motion" },
	{ "<localleader>r", "<plug>refactor_code", desc = "refactor_code" },
	{ "<localleader>~", desc = "swap_case_motion" },
}
local rbracket = {
	{ "]#", desc = "goto_next_unmatched_defined_if" },
	{ "])", desc = "goto_next_unmatched_parenthesis" },
	{ "]/", desc = "goto_next_comment" },
	{ "]F", desc = "goto_file_under_cursor_on_right_win" },
	{ "]S", desc = "fix_next_spell_error" },
	{ "]T", desc = "goto_tag_under_cursor_on_right_win" },
	{ "]Z", desc = "scroll_up" },
	{ "]]", desc = "goto_next_function" },
	{ "]c", desc = "next_diff" },
	{ "]d", desc = "delete_next_lines" },
	{ "]g", "<cmd>diffget<cr>", desc = "diffget" },
	{ "]l", desc = "next_location_list_item" },
	{ "]m", desc = "move_line_below" },
	{ "]o", desc = "comment_next_lines" },
	{ "]p", "<cmd>diffput<cr>", desc = "diffput" },
	{ "]q", desc = "next_quickfix_item" },
	{ "]s", desc = "goto_next_spell_error" },
	{ "]t", desc = "goto_tag_under_cursor" },
	{ "]y", desc = "yank_from_next_lines" },
	{ "]z", desc = "scroll_right" },
	{ "]}", desc = "goto_next_unmatched_brace" },
}

local lbracket = {
	{ "[#", desc = "goto_prev_unmatched_defined_if" },
	{ "[(", desc = "goto_prev_unmatched_parenthesis" },
	{ "[/", desc = "goto_prev_comment" },
	{ "[F", desc = "goto_file_under_cursor_on_left_win" },
	{ "[S", desc = "fix_prev_spell_error" },
	{ "[T", desc = "goto_tag_under_cursor_on_left_win" },
	{ "[Z", desc = "scroll_down" },
	{ "[[", desc = "goto_prev_function" },
	{ "[c", desc = "prev_diff" },
	{ "[d", desc = "delete_prev_lines" },
	{ "[f", desc = "go_back_one_file" },
	{ "[g", "<cmd>diffget<cr>", desc = "diffget" },
	{ "[i", desc = "goto_include_under_cursor" },
	{ "[l", desc = "prev_location_list_item" },
	{ "[m", desc = "move_line_up" },
	{ "[o", desc = "comment_prev_lines" },
	{ "[p", "<cmd>diffput<cr>", desc = "diffput" },
	{ "[q", desc = "prev_quickfix_item" },
	{ "[s", desc = "goto_prev_spell_error" },
	{ "[t", desc = "pop_tag_stack" },
	{ "[y", desc = "yank_from_prev_lines" },
	{ "[z", desc = "scroll_left" },
	{ "[{", desc = "goto_prev_unmatched_brace" },
}

function M:setup()
	local wk = require("which-key")
	wk.setup(self.__config)
	wk.add(leader)
	wk.add(lleader)
	wk.add(lbracket)
	wk.add(rbracket)
	log.info("setup of which key complete")
end

return {
	"folke/which-key.nvim",
	keys = {
		{ "<leader>", mode = { "n", "x" } },
		{ "<localleader>", mode = { "n", "x" } },
	},
	config = function()
		M:setup()
	end,
}
