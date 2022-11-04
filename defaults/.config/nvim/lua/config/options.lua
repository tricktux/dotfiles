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
  vim.opt.spelllang = "en_us"
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
  vim.opt.signcolumn = "yes:1"
  vim.opt.number = false
  vim.opt.relativenumber = true
  vim.opt.numberwidth = 1
  -- Supress messages
  -- a - Usefull abbreviations
  -- c - Do no show match 1 of 2
  -- o and O no enter when openning files
  -- s - Do not show search hit bottom
  -- t - Truncate message if is too long
  vim.opt.shortmess = "aoOcst"
end

return M
