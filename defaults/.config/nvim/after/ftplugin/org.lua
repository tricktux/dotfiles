---@module org after ftplugin
---@author Reinaldo Molina

if vim.b.did_org_ftplugin then
	return
end

vim.b.did_org_ftplugin = 1

vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.spell = true

vim.b.AutoPairs = {
	["="] = "=",
	["("] = ")",
	['"'] = '"',
	["["] = "]",
	["<"] = ">",
}

if vim.fn.exists("*mdip#MarkdownClipboardImage") > 0 then
	local opts = { silent = true, buffer = true, desc = "insert_clipboard_image" }
	vim.keymap.set("n", "<localleader>i", function()
		return vim.fn["mdip#MarkdownClipboardImage"]()
	end, opts)
end

-- Make sure treesitter is not overriding foldexpr/indent in Org buffers
vim.b.did_fold_settings = 1
vim.b.did_indent_settings = 1
