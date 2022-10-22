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
	vim.opt.updatetime = 100
	vim.opt.display:append("uhex")
	vim.opt.sessionoptions = { "buffers", "tabpages" }
	vim.opt.foldmethod = "syntax"
	vim.opt.mouse = ""
	vim.opt.background = "light" -- This forces lualine to use the right theme
	vim.opt.laststatus = 3
  vim.opt.cmdheight = 1
  vim.opt.spell = true
  vim.opt.spelllang = {"en_us", "es"}
  vim.opt.formatoptions:append('jw')
  vim.opt.inccommand = "split"
  vim.opt.wrapscan = false
  vim.opt.shada = {
    [['1024]],
    -- Do not restore buffer list, leave that for sessions
    -- [[%]],
    "s10000",
    -- Removable media below, avoid storing marks on these drivers
    "r/tmp",  -- Unix
    "rE:",  -- Windows
    "rF:"
  }
  -- Noice.nvim insisting in it to be off
  -- vim.opt.lazyredraw = true
end

return M
