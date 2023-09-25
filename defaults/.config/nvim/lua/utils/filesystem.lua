local M = {}
local utl = require("utils.utils")

M.sources = {
	-- First table is find image, second table is extract filename from match
	md = {
		"!%[.-%]%((.-)%)",
		"!%[%[(.-)%]%]",
	},
	org = {
		"%[%[(.-)%]%]",
		"%[%[(.-)%]%[.-%]%]",
		"%[%[file: (.-)%]%[.-%]%]",
	},
}

M.find_source = function(line, sources)
	vim.validate({ line = { line, "s", false }, sources = { sources, "t", false } })

	local ft = vim.api.nvim_buf_get_option(0, "filetype")
	if M.sources[ft] == nil then
		-- vim.api.nvim_err_writeln("No sources for filetype: " .. ft)
		return nil
	end

	-- vim.print("Filetype: " .. ft)
	for _, pattern in pairs(M.sources[ft]) do
		-- vim.print("Pattern: " .. pattern)
		local match = string.match(line, pattern)
		if match then
			return match
		end
	end

	-- vim.print("No image pattern matched")
	return nil
end

-- Path is expected to be plenary:Path
local is_full_path = function(path)
	vim.validate({ path = { path, "t", false } })
	return path:is_absolute() and path:exists()
end

local is_path = function(path)
	vim.validate({ path = { path, "s", false } })
	local p = require("plenary.path")
	local o = p:new(path)
	if is_full_path(o) then
		return o:absolute()
	end
	-- vim.print("its not full path")
	-- Maybe it's relative to the file dir
	local f = p:new(vim.fn.expand("%:p:h"), path)
	if is_full_path(f) then
		return f:absolute()
	end
	-- vim.print("it's not relative to file")
	-- Maybe it's relative to the cwd dir
	local c = p:new(vim.uv.cwd(), path)
	if is_full_path(c) then
		return c:absolute()
	end
	-- vim.print("it's not relative to cwd")
	-- Maybe it has variables
	local e = p:new(o:expand())
	if is_full_path(e) then
		return e:absolute()
	end
	-- vim.print("its not expanded")
	-- We are done
	return nil
end

M.open_source_in_line = function(line)
	vim.validate({ line = { line, "s", false } })
	-- vim.print("Line: " .. line)
	local source = M.find_source(line, M.sources)
	local u = source or line
	local file = is_path(u)
	if file then
		utl.term.open_uri(file)
		return
	end

	utl.term.open_uri(u)
end

M.search_for_first_visible_source = function(sources)
	vim.validate({ sources = { sources, "t" } })

	local lines = utl.get_visible_lines(0)
	for _, line in ipairs(lines.visible_lines) do
		if line ~= nil then
			local source = M.find_source(line, sources)
			if source ~= nil then
				return source
			end
		end
	end

	return nil
end

return M
