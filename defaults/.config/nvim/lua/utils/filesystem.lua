local M = {}
local utl = require("utils.utils")

M.find_source = function(line, sources)
	vim.validate({ line = { line, "s" }, sources = { sources, "t" } })

	local plok, pl = pcall(require, "plenary.path")
	if not plok then
		vim.api.nvim_err_writeln("Failed to load plenary.path")
		return
	end

	local check_file = function(path)
		return path:exists() and path:is_file()
	end

	for _, source in pairs(sources) do
		for _, pattern in pairs(source) do
			local inline_link = string.match(line, pattern[1])
			if inline_link then
				local path = pl:new(string.match(inline_link, pattern[2]))
				-- Check if we have a root path in a cross platform way
				if check_file(path) then
					vim.print("File: '" .. path:absolute() .. "' found")
					return path:absolute()
				end
			end
		end
	end

	return nil
end

M.search_for_first_visible_source = function(sources)
	vim.validate({ sources = { sources, "t" } })

	local lines = utl.get_visible_lines(0)
	for _, line in ipairs(lines.visible_lines) do
		if line ~= nil then
			local source = M.find_source(line, sources)
			if source ~= nil then return source end
		end
	end

  return nil
end

return M
