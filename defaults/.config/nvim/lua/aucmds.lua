local log = require("utils.log")
local api = vim.api

local M = {}

local function set_text_settings()
  vim.opt_local.wrap = true
  vim.opt_local.spell = true
	vim.opt.conceallevel = 0
	vim.opt.textwidth = 0
	vim.opt.foldenable = true
	vim.opt.complete:append("kspell")
	vim.opt.tabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.comments:append({ b = "-" })
end

M.setup = function()
	local id = api.nvim_create_augroup("highlight_yank", { clear = true })
	api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank({ timeout = 250 })
		end,
		desc = "Highlight text on Yank",
		group = id,
	})

	id = api.nvim_create_augroup("Cursor", { clear = true })
	api.nvim_create_autocmd("CursorHold", {
		command = [[silent! update | checktime]],
		pattern = "*",
		desc = "Avoid manual save, autoread",
		group = id,
	})

	-- resize splits if window got resized
	id = api.nvim_create_augroup("resize_splits", { clear = true })
	vim.api.nvim_create_autocmd({ "VimResized" }, {
		group = id,
		callback = function()
			vim.cmd("tabdo wincmd =")
		end,
	})

	id = api.nvim_create_augroup("Terminal", { clear = true })
	api.nvim_create_autocmd("TermOpen", {
		callback = function()
			log.info("terminal autocmd called")
			vim.opt.number = false
			vim.opt.bufhidden = "hide"
			vim.keymap.set("n", [[q]], [[ZZ]], { silent = true, buffer = true })
			vim.keymap.set("n", [[<M-`>]], [[ZZ]], { silent = true, buffer = true })
			local color = vim.opt.background:get() == "dark" and "Black" or "White"
			vim.cmd("highlight Terminal guibg=" .. color)
			vim.opt.winhighlight = "NormalFloat:Terminal"
		end,
		pattern = "*",
		desc = "Better settings for terminal",
		group = id,
	})

	id = api.nvim_create_augroup("FiletypesLua", { clear = true })
	api.nvim_create_autocmd("FileType", {
		callback = function()
			vim.keymap.set("n", [[<s-j>]], [[:b#<cr>]], { silent = true, buffer = true, desc = "Remap next buffer" })
			vim.keymap.set("n", [[<C-j>]], [[)]], { silent = true, buffer = true, desc = "Next section" })
			vim.keymap.set("n", [[<C-k>]], [[(]], { silent = true, buffer = true, desc = "Prev section" })
		end,
		pattern = "fugitive",
		desc = "Better mappings for fugitive filetypes",
		group = id,
	})

	api.nvim_create_autocmd("FileType", {
		callback = function()
			vim.opt.suffixesadd = { ".scp", ".cmd", ".bat" }
			log.info("wings_syntax autocmd called")
		end,
		pattern = "wings_syntax",
		desc = "Better go to files for wings filetypes",
		group = id,
	})
	api.nvim_create_autocmd("FileType", {
		callback = function()
			log.info("markdown autocmd called")
			set_text_settings()
		end,
		pattern = { "markdown", "mkd" },
		desc = "Better settings for markdown",
		group = id,
	})
	api.nvim_create_autocmd("FileType", {
		callback = function()
			log.info("tex autocmd called")
			set_text_settings()
			vim.opt.formatoptions:remove("tc")
		end,
		pattern = "tex",
		desc = "Better settings for tex",
		group = id,
	})
	-- close some filetypes with <q>
	vim.api.nvim_create_autocmd("FileType", {
		group = id,
		pattern = {
			"qf",
			"help",
			"man",
			"notify",
			"lspinfo",
			"spectre_panel",
			"startuptime",
			"tsplayground",
			"PlenaryTestPopup",
		},
		callback = function(event)
			vim.bo[event.buf].buflisted = false
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
		end,
	})
	api.nvim_create_autocmd("FileType", {
		callback = function()
			log.info("mail autocmd called")
			vim.opt.textwidth = 72
		end,
		pattern = "mail",
		desc = "Better settings for mail",
		group = id,
	})
	api.nvim_create_autocmd("FileType", {
		callback = function()
			log.info("c autocmd called")
			local tab = vim.fn.has("unix") > 0 and 2 or 4
			vim.opt.tabstop = tab
			vim.opt.shiftwidth = tab
		end,
		pattern = { "c", "cpp" },
		desc = "Better settings for c",
		group = id,
	})

	id = api.nvim_create_augroup("Buf", { clear = true })
	vim.api.nvim_create_autocmd("BufReadPost", {
		group = id,
		desc = "Restore cursor on file open",
		pattern = "*",
		callback = function()
			local mark = vim.api.nvim_buf_get_mark(0, '"')
			local lcount = vim.api.nvim_buf_line_count(0)
			if mark[1] > 0 and mark[1] <= lcount then
				pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
			vim.api.nvim_feedkeys("zz", "n", true)
		end,
	})

	if vim.fn.has("nvim-0.9") <= 0 then
		id = api.nvim_create_augroup("Omni", { clear = true })
		vim.api.nvim_create_autocmd("TextChangedI", {
			group = id,
			desc = "Temp fix for omnifunc",
			pattern = "*",
			callback = function()
				vim.opt.omnifunc = ""
			end,
		})
	end
end

return M