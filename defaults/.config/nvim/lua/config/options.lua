local M = {}

M.eval = function()
	if vim.api.nvim_eval_statusline("%f", {})["str"] == "[No Name]" then
		return ""
	end

	local gps_ok, gps = pcall(require, "nvim-gps")
	local ret = vim.fn.expand("%:t")
	local g = nil
	if gps_ok and gps.is_available() then
		g = gps.get_location()
		if g == "" then g = nil end
	end
	return g ~= nil and ret .. " > " .. g or ret
end

function M:setup()
  -- Tab management
  -- No tabs in the code. Tabs are expanded to spaces
  vim.opt.expandtab = true
  vim.opt.shiftround = true
  vim.opt.softtabstop = -8   -- Use value of shiftwidth
  vim.opt.shiftwidth = 4  -- Always set this two values to the same
  vim.opt.tabstop=4
  ----------------------------

  vim.opt.pumblend = 30
  vim.api.nvim_set_hl(0, "PmenuSel", {blend = 0})
  -- Mon Aug 24 2020 14:55: For CursorHold to trigger more often 
  vim.opt.updatetime=100
  vim.opt.display:append("uhex")
  vim.opt.sessionoptions = {"buffers","tabpages","options","winsize"}
  vim.opt.foldmethod = "syntax"
  vim.opt.mouse = ""
  vim.opt.background = "light"  -- This forces lualine to use the right theme
  vim.opt.laststatus = 3
  if vim.fn.has("nvim-0.8") > 0 then
    vim.opt.winbar = "%{v:lua.require'config.options'.eval()}"
    -- https://github.com/neovim/neovim/pull/19185
    -- vim.opt.cmdheight = 0
  end
end

return M
