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
	vim.validate({ line = { line, "s" }, sources = { sources, "t" } })

	local plok, pl = pcall(require, "plenary.path")
	if not plok then
		vim.api.nvim_err_writeln("Failed to load plenary.path")
		return
	end

	local check_file = function(path)
		return path:exists() and path:is_file()
	end

	local ft = vim.api.nvim_buf_get_option(0, "filetype")
	if M.sources[ft] == nil then
		vim.api.nvim_err_writeln("No sources for filetype: " .. ft)
		return nil
	end

  -- vim.print("Filetype: " .. ft)
	for _, pattern in pairs(M.sources[ft]) do
    -- vim.print("Pattern: " .. pattern)
		local match = string.match(line, pattern)
    if match then
      local path = pl:new(match)
      if check_file(path) then
        vim.print("File: '" .. path:absolute() .. "' found")
        return path:absolute()
      end
      -- Make another attempt by constructing a full path
      local new_path = pl:new(vim.fn.expand("%:p:h"), match)
      if check_file(new_path) then
        vim.print("File: '" .. new_path:absolute() .. "' found")
        return new_path:absolute()
      end
      vim.api.nvim_err_writeln("Match found, but file does not exists: '" .. match .. "'")
      return nil
    end
	end

  -- vim.print("No image pattern matched")
	return nil
end

M.open_source_in_line = function(line)
	vim.validate({ line = { line, "s", false } })
  -- vim.print("Line: " .. line)
	local source = M.find_source(line, M.sources)
	-- vim.print("Source: " .. source and nil "" )
	if source ~= nil then
		utl.term.open_file(source)
		return
	end

	local plok, pl = pcall(require, "plenary.path")
	if not plok then
		vim.api.nvim_err_writeln("Failed to load plenary.path")
		return
	end
	source = pl:new(line):absolute()
	-- vim.print("Source not found, using: " .. vim.inspect(source))
	utl.term.open_file(source)
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
