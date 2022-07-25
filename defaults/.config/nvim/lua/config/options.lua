local M = {}

function M:setup()
	-- Tab management
	-- No tabs in the code. Tabs are expanded to spaces
	vim.opt.expandtab = true
	vim.opt.shiftround = true
	vim.opt.softtabstop = -8 -- Use value of shiftwidth
	vim.opt.shiftwidth = 4 -- Always set this two values to the same
	vim.opt.tabstop = 4
	----------------------------
  -- Title
  vim.opt.title = true
  vim.opt.titlelen = 90  -- Percent of columns
  ----------------------------

	vim.opt.pumblend = 30
	vim.api.nvim_set_hl(0, "PmenuSel", { blend = 0 })
	-- Mon Aug 24 2020 14:55: For CursorHold to trigger more often
	vim.opt.updatetime = 100
	vim.opt.display:append("uhex")
	vim.opt.sessionoptions = { "buffers", "tabpages" }
	vim.opt.foldmethod = "syntax"
	vim.opt.mouse = ""
	vim.opt.background = "light" -- This forces lualine to use the right theme
	vim.opt.laststatus = 3
end

return M
