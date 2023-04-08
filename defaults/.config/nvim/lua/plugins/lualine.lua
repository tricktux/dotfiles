-- statusline
-- Pretty awful: https://github.com/nvim-lualine/lualine.nvim/issues/921
vim.api.nvim_create_autocmd("CursorHold", {
	pattern = "*",
	callback = function()
		vim.opt.showtabline = 1
    -- print("showtabline = " .. vim.opt.showtabline.get())
	end,
})

vim.keymap.set("n", "<leader>tr",
  function()
    vim.ui.input("Enter Tab name: ", function(text)
      vim.cmd([[LualineRenameTab ]] .. text)
    end)
  end, { silent = true })

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	opts = function(plugin)
		local icons = require("utils.utils").icons

		local function fg(name)
			return function()
				---@type {foreground?:number}?
				local hl = vim.api.nvim_get_hl_by_name(name, true)
				return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
			end
		end

		return {
			options = {
				theme = "auto",
				globalstatus = true,
				disabled_filetypes = { statusline = { "dashboard", "lazy", "alpha" } },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
				lualine_c = {
					{
						"diagnostics",
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
					},
					{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
					{ "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
					{
						function()
							return require("nvim-navic").get_location()
						end,
						cond = function()
							return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
						end,
					},
				},
				lualine_x = {
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
						color = fg("Special"),
					},
					{
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
					},
				},
				lualine_y = {
					{ "progress", separator = "", padding = { left = 1, right = 0 } },
					{ "location", padding = { left = 0, right = 1 } },
				},
				lualine_z = {
					function()
						return " " .. os.date("%R")
					end,
				},
			},
			extensions = { "neo-tree" },
			tabline = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {"filename"},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "tabs" },
			},
			winbar = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_winbar = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		}
	end,
}
