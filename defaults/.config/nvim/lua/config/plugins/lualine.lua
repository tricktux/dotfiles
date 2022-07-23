-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
-- Link: https://gist.github.com/hoob3rt/b200435a765ca18f09f83580a606b878
local set = require("utils.utils").Set
local log = require("utils.log")

local M = {}

-- Color table for highlights
M.colors = {
	bg = "#202328",
	fg = "#bbc2cf",
	yellow = "#ECBE7B",
	cyan = "#008080",
	darkblue = "#081633",
	green = "#98be65",
	orange = "#FF8800",
	violet = "#a9a1e1",
	magenta = "#c678dd",
	blue = "#51afef",
	red = "#ec5f67",
}

M.__conditions = {
	buffer_not_empty = function()
		return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
	end,
	hide_in_width = function()
		return vim.fn.winwidth(0) > 80
	end,
	check_git_workspace = function()
		local filepath = vim.fn.expand("%:p:h")
		local gitdir = vim.fn.finddir(".git", filepath .. ";")
		return gitdir and #gitdir > 0 and #gitdir < #filepath
	end,
}

-- Diagnositcs
M.__diagnostics = {
	"diagnostics",

	-- Table of diagnostic sources, available sources are:
	--   'nvim_lsp', 'nvim_diagnostic', 'coc', 'ale', 'vim_lsp'.
	-- or a function that returns a table as such:
	--   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
	sources = { "nvim_lsp" },

	-- Displays diagnostics for the defined severity types
	sections = { "error", "warn", "info", "hint" },
	symbols = { error = "E", warn = "W", info = "I", hint = "H" },
	colored = true, -- Displays diagnostics status in color if set to true.
	update_in_insert = false, -- Update diagnostics in insert mode.
	always_visible = false, -- Show diagnostics even if there are none.
	diagnostics_color = {
		error = { fg = M.colors.red, gui = "bold" },
		warn = { fg = M.colors.orange, gui = "bold" },
		info = { gui = "bold" },
		hint = { fg = M.colors.green, gui = "bold" },
	},
}

-- Config
M.__config = {
	options = {
		-- Disable sections and component separators
		component_separators = "",
		section_separators = "",
		icons_enabled = false,
		globalstatus = vim.fn.has("nvim-0.7") > 0 and true or false,
		theme = "auto",
	},
	sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_b = {},
		lualine_y = {},
		lualine_z = {},
		-- These will be filled later
		lualine_c = {},
		lualine_x = {},
	},
	inactive_sections = {
		-- these are to remove the defaults
		lualine_a = {},
		lualine_v = {},
		lualine_y = {},
		lualine_z = {},
		lualine_c = { { "filename", path = 2 } },
		lualine_x = { "location" },
	},
	extensions = { "fzf", "nvim-tree", "quickfix", "fugitive" },
}

-- Inserts a component in lualine_c at left section
function M:ins_left(component)
	if self.__setup_called ~= true then
		self:setup()
	end
	table.insert(self.__config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at left section
function M:ins_right(component)
	if self.__setup_called ~= true then
		self:setup()
	end
	table.insert(self.__config.sections.lualine_x, 1, component)
end

-- Inserts a component in lualine_x at right section
function M:__ins_right(component)
	table.insert(self.__config.sections.lualine_x, component)
end

function M:__filesize()
	local function format_file_size(file)
		local size = vim.fn.getfsize(file)
		if size <= 0 then
			return ""
		end
		local sufixes = { "b", "k", "m", "g" }
		local i = 1
		while size > 1024 do
			size = size / 1024
			i = i + 1
		end
		return string.format("%.1f%s", size, sufixes[i])
	end

	local file = vim.fn.expand("%:p")
	if string.len(file) == 0 then
		return ""
	end
	return format_file_size(file)
end

function M:__lsp()
	local msg = ""
	local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
	local clients = vim.lsp.get_active_clients()
	if next(clients) == nil then
		return msg
	end
	local clients_set = {}
	local any = false
	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes
		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			any = true
			if client.name == "null-ls" then
				local prov = require("config.plugins.null-ls").list_registered_providers_names(buf_ft)
				table.insert(clients_set, set.tostring(prov))
			else
				table.insert(clients_set, client.name)
			end
		end
	end
	return any and "lsp: [" .. set.tostring(set.new(clients_set)) .. "]" or ""
end

M.__setup_called = false

function M:setup()
	self.__setup_called = true
	log.info("[lualine]: Setting up...")
	self:ins_left({
		function()
			return "▊"
		end,
		color = { fg = self.colors.blue }, -- Sets highlighting of component
		left_padding = 0, -- We don't need space before this
	})

	self:ins_left({
		"mode",
		fmt = function(str)
			return str:sub(1, 1)
		end,
		left_padding = 0,
	})

	self:ins_left({ "filetype", colored = true, icon_only = false })

	self:ins_left({ "fileformat" })

	self:ins_left({ "encoding" })

	if vim.fn.has("nvim-0.8") == 0 then
		self:ins_left({ "windows" })
	end

	self:ins_left({ self.__lsp })

	self:ins_left(self.__diagnostics)

	-- Insert mid section. You can make any number of sections in neovim :)
	self:ins_left({
		function()
			return "%="
		end,
	})

	self:ins_left({
		"filename",
		file_status = true,
		path = 1,
		condition = self.__conditions.buffer_not_empty,
	})

	self:__ins_right({ "location", right_padding = 0 })

	self:__ins_right({ "progress" })

	-- filesize component
	self:__ins_right({
		self.__filesize,
		condition = self.__conditions.buffer_not_empty,
		left_padding = 0,
		right_padding = 0,
	})

	self:__ins_right({
		function()
			return "▊"
		end,
		color = { fg = self.colors.blue },
		right_padding = 0,
	})
end

function M:config()
	log.info("[lualine]: Configuring...")
	require("lualine").setup(self.__config)
end

return M
