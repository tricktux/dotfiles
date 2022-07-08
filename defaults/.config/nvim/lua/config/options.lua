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
  vim.opt.background = 'light'  -- This forces lualine to use the right theme
  vim.opt.laststatus = 3
  if vim.fn.has("nvim-0.8") > 0 then
    vim.opt.winbar = "%{v:lua.require'config.options'.eval()}"
    -- https://github.com/neovim/neovim/pull/19185
    -- vim.opt.cmdheight = 0
  end
end

return M
