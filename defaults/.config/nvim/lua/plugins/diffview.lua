return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewFileHistory" },
	opts = {
		diff_binaries = false, -- Show diffs for binaries
		use_icons = false, -- Requires nvim-web-devicons
		enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
		signs = { fold_closed = "", fold_open = "" },
		merge_tool = {
			-- Config for conflicted files in diff views during a merge or rebase.
			layout = "diff3_mixed",
			disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
		},
		file_panel = {
			win_config = {
				position = "left", -- One of 'left', 'right', 'top', 'bottom'
				width = 25, -- Only applies when position is 'left' or 'right'
				height = 10, -- Only applies when position is 'top' or 'bottom'
			},
		},
		file_history_panel = {
			win_config = {
				position = "bottom",
				width = 35,
				height = 16,
			},
			log_options = {
				single_file = {
					max_count = 512,
					follow = true,
				},
				multi_file = {
					max_count = 128,
				},
			},
		},
		key_bindings = {
			disable_defaults = true, -- Disable the default key bindings
			-- The `view` bindings are active in the diff buffers, only when the current
			-- tabpage is a Diffview.
			view = {
				["<tab>"] = require("diffview.actions").select_next_entry, -- Open the diff for the next file
				["<s-tab>"] = require("diffview.actions").select_prev_entry, -- Open the diff for the previous file
				["gf"] = require("diffview.actions").goto_file, -- Open the file in a new split in the previous tabpage
				["<C-w><C-f>"] = require("diffview.actions").goto_file_split, -- Open the file in a new split
				["<C-w>gf"] = require("diffview.actions").goto_file_tab, -- Open the file in a new tabpage
				["<leader>e"] = require("diffview.actions").focus_files, -- Bring focus to the file panel
				["<leader>b"] = require("diffview.actions").toggle_files, -- Toggle the file panel.
				["g<C-x>"] = require("diffview.actions").cycle_layout, -- Cycle through available layouts.
				["[x"] = require("diffview.actions").prev_conflict, -- In the merge_tool: jump to the previous conflict
				["]x"] = require("diffview.actions").next_conflict, -- In the merge_tool: jump to the next conflict
				["<leader>co"] = require("diffview.actions").conflict_choose("ours"), -- Choose the OURS version of a conflict
				["<leader>ct"] = require("diffview.actions").conflict_choose("theirs"), -- Choose the THEIRS version of a conflict
				["<leader>cb"] = require("diffview.actions").conflict_choose("base"), -- Choose the BASE version of a conflict
				["<leader>ca"] = require("diffview.actions").conflict_choose("all"), -- Choose all the versions of a conflict
				["dx"] = require("diffview.actions").conflict_choose("none"), -- Delete the conflict region
			},
			file_panel = {
				["j"] = require("diffview.actions").next_entry, -- Bring the cursor to the next file entry
				["<down>"] = require("diffview.actions").next_entry,
				["k"] = require("diffview.actions").prev_entry, -- Bring the cursor to the previous file entry.
				["<up>"] = require("diffview.actions").prev_entry,
				["<cr>"] = require("diffview.actions").select_entry, -- Open the diff for the selected entry.
				["o"] = require("diffview.actions").select_entry,
				["<2-LeftMouse>"] = require("diffview.actions").select_entry,
				["-"] = require("diffview.actions").toggle_stage_entry, -- Stage / unstage the selected entry.
				["S"] = require("diffview.actions").stage_all, -- Stage all entries.
				["U"] = require("diffview.actions").unstage_all, -- Unstage all entries.
				["X"] = require("diffview.actions").restore_entry, -- Restore entry to the state on the left side.
				["L"] = require("diffview.actions").open_commit_log, -- Open the commit log panel.
				["<c-u>"] = require("diffview.actions").scroll_view(-0.25), -- Scroll the view up
				["<c-d>"] = require("diffview.actions").scroll_view(0.25), -- Scroll the view down
				["<tab>"] = require("diffview.actions").select_next_entry,
				["<s-tab>"] = require("diffview.actions").select_prev_entry,
				["gf"] = require("diffview.actions").goto_file,
				["<C-w><C-f>"] = require("diffview.actions").goto_file_split,
				["<C-w>gf"] = require("diffview.actions").goto_file_tab,
				["i"] = require("diffview.actions").listing_style, -- Toggle between 'list' and 'tree' views
				["f"] = require("diffview.actions").toggle_flatten_dirs, -- Flatten empty subdirectories in tree listing style.
				["R"] = require("diffview.actions").refresh_files, -- Update stats and entries in the file list.
				["<leader>e"] = require("diffview.actions").focus_files,
				["<leader>b"] = require("diffview.actions").toggle_files,
				["g<C-x>"] = require("diffview.actions").cycle_layout,
				["[x"] = require("diffview.actions").prev_conflict,
				["]x"] = require("diffview.actions").next_conflict,
			},
			file_history_panel = {
				["g!"] = require("diffview.actions").options, -- Open the option panel
				["<C-A-d>"] = require("diffview.actions").open_in_diffview, -- Open the entry under the cursor in a diffview
				["y"] = require("diffview.actions").copy_hash, -- Copy the commit hash of the entry under the cursor
				["L"] = require("diffview.actions").open_commit_log,
				["zR"] = require("diffview.actions").open_all_folds,
				["zM"] = require("diffview.actions").close_all_folds,
				["j"] = require("diffview.actions").next_entry,
				["<down>"] = require("diffview.actions").next_entry,
				["k"] = require("diffview.actions").prev_entry,
				["<up>"] = require("diffview.actions").prev_entry,
				["<cr>"] = require("diffview.actions").select_entry,
				["o"] = require("diffview.actions").select_entry,
				["<2-LeftMouse>"] = require("diffview.actions").select_entry,
				["<c-b>"] = require("diffview.actions").scroll_view(-0.25),
				["<c-f>"] = require("diffview.actions").scroll_view(0.25),
				["<tab>"] = require("diffview.actions").select_next_entry,
				["<s-tab>"] = require("diffview.actions").select_prev_entry,
				["gf"] = require("diffview.actions").goto_file,
				["<C-w><C-f>"] = require("diffview.actions").goto_file_split,
				["<C-w>gf"] = require("diffview.actions").goto_file_tab,
				["<leader>e"] = require("diffview.actions").focus_files,
				["<leader>b"] = require("diffview.actions").toggle_files,
				["g<C-x>"] = require("diffview.actions").cycle_layout,
			},
			option_panel = {
				["<tab>"] = require("diffview.actions").select_entry,
				["q"] = require("diffview.actions").close,
			},
		},
	},
}
