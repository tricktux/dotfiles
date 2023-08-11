local M = {}
local utl = require("utils.utils")

M.sources = {
	-- First table is find image, second table is extract filename from match
	md = {
		{ "!%[.-%]%(.-%)", "%((.+)%)" },
		{ "!%[%[.-%]%]", "!%[%[(.-)%]%]" },
	},
	org = {
		{ "%[%[.-%]%]", "%[%[(.-)%]%]" },
	},
}

M.image_type = "png"
M.holograms = {}

M.find_source = function(line)
	-- vim.validate({ line = { line = "s" } })

	local plok, pl = pcall(require, "plenary.path")
	if not plok then
		vim.api.nvim_err_writeln("Failed to load plenary.path")
		return
	end

	local hlok, fs = pcall(require, "hologram.fs")
	if not hlok then
		vim.api.nvim_err_writeln("Failed to load hologram.fs")
		return
	end

	local _, si, _ = string.find(string.lower(line), M.image_type)
	if not si then
		return nil
	end

	local check_file = function(path)
		return path:exists() and fs.check_sig_PNG(path:absolute())
	end

	for _, source in pairs(M.sources) do
		for _, pattern in pairs(source) do
			local inline_link = string.match(line, pattern[1])
			if inline_link then
				local path = pl:new(string.match(inline_link, pattern[2]))
				-- Check if we have a root path in a cross platform way
				if not check_file(path) then
					vim.api.nvim_err_writeln("Image: " .. path:absolute() .. " does not exist, or is not a png file")
					return
				end
				vim.print("Image: '" .. path:absolute() .. "' found")
				return path:absolute()
			end
		end
	end

	vim.api.nvim_err_writeln("No image pattern matched")
	return nil
end

M.toggle_hologram_images = function()
	local hol_ok, hol = pcall(require, "hologram")
	if not hol_ok then
		vim.api.nvim_err_writeln("hologram not installed")
		return
	end

	local buf = vim.api.nvim_get_current_buf()
	local Image = require("hologram.image")
	local lines = utl.get_visible_lines(0)
	for n, line in ipairs(lines.visible_lines) do
		if line ~= nil then
			local source = M.find_source(line)
			if source ~= nil then
				local image = Image:new(source, {}, false)
				image:display(lines.start_line + n, 0, buf, {})
				table.insert(M.holograms, image)
			end
		end
	end

	if vim.tbl_isempty(M.holograms) then
		return
	end

	-- Setup autocmd to clean up hologram images
	vim.api.nvim_create_autocmd({ "BufWinLeave", "CursorMoved" }, {
		callback = function(au)
			for _, image in pairs(M.holograms) do
				image:delete(buf, { free = true })
			end
			M.holograms = {}
		end,
		buffer = buf,
		once = true,
	})
end

-- TODO: return something good
return {
	"giusgad/hologram.nvim",
	event = "VeryLazy",
	opts = {
		auto_display = false,
	},
	toggle_hologram_images = M.toggle_hologram_images,
}
