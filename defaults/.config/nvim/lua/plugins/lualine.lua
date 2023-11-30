vim.keymap.set("n", "<leader>tr", function()
	vim.ui.input("Enter Tab name: ", function(text)
    if text == "" or text == nil then return end
		vim.cmd([[LualineRenameTab ]] .. text)
	end)
end, { silent = true, desc = "tab_rename_lualine" })

local function cwd()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

local function get_lsp_client_name()
  local clients = vim.lsp.get_clients()
  if next(clients) == nil then return "" end -- If no LSP enabled, return nothing.
  local formated_clients = {}
  for _, client in ipairs(clients) do
    table.insert(formated_clients, client.name)
  end
  return table.concat(formated_clients, ', ')
end

local function plugin_updates()
  local u = require("lazy.status").updates()
  if not u or u == nil or u == "" then return false end
  local nums = string.match(u, "(%d+)")
  return nums and tonumber(nums) > 15 or false
end

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
        lualine_b = { { "branch" }, { "diff" } },
				lualine_c = {
          { cwd, padding = { left = 1, right = 1 } },
          { "filename", path = 1, separator = "" },
          { "filetype", icon_only = true, separator = "", padding = { left = 0, right = 0 } },
				},
				lualine_x = {
					{
						require("lazy.status").updates,
            cond =  plugin_updates,
						color = fg("Special"),
					},
				},
				lualine_y = {
					{ "diagnostics", sources = { "nvim_diagnostic" } },
          { get_lsp_client_name },
				},
        lualine_z = {
          { "progress", separator = "", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
			},
			tabline = {
				lualine_a = {
					{ "filetype", icon_only = true },
				},
				lualine_b = {
					{ "tabs", mode = 2, max_length = vim.o.columns },
					{
            -- Pretty awful hack: https://github.com/nvim-lualine/lualine.nvim/issues/921
						function()
							vim.o.showtabline = 1
							return ""
						end,
					},
				},
			},
			winbar = {
				lualine_a = {
					{ "filetype", icon_only = true },
					{ "filename", path = 0 },
				},
				lualine_c = {},
				lualine_x = {
					function()
						return " "
					end,
				},
			},
			inactive_winbar = {
				lualine_a = {
					{ "filetype", icon_only = true },
					{ "filename", path = 0 },
				},
				lualine_x = {
				},
			},
			extensions = { "neo-tree", "quickfix", "toggleterm" },
		}
	end,
}
