local log = require("utils.log")
local Path = require("plenary.path")
local luv = vim.loop
local api = vim.api

local M = {}

-- List of useful vim helper functions
-- >vim.tbl_*
--  >vim.tbl_count
-- >vim.validate
-- >vim.deepcopy

function M.set_new(t)
	vim.validate({ t = { t, "t" } })

	local set = {}
	for _, l in ipairs(t) do
		set[l] = true
	end
	return set
end

function M.set_tostring(set)
	vim.validate({ set = { set, "t" } })

	local s = ""
	local sep = ""
	for e in pairs(set) do
		s = s .. sep .. e
		sep = ", "
	end
	return s
end

-- @brief Recurses through a directory in search for a file
-- @param dir Directory to recurse
-- @param file File looking for. Could use wildcards. Will be used by glob()
-- @param ignore Regex with files that will be ignored. Will be used by
-- readdirs(). See help for that function on what can be passed to reduce list
-- of files. Example: [[v:val !~ '^\.\|\~$']]
-- @return Table with all file matches with full path if found. Nil
-- otherwise
function M.find_file(dir, file, ignore)
	vim.validate({ dir = { dir, "s" } })
	vim.validate({ file = { file, "s" } })
	vim.validate({ ignore = { ignore, "s" } })

	if vim.fn.isdirectory(dir) == 0 then
		return nil
	end

	-- Check if the file is in dir
	log.trace("dir = " .. vim.inspect(dir))
	local files = vim.fn.glob(dir .. [[\]] .. file, true, false)
	log.trace("files = " .. vim.inspect(files))
	if files ~= nil and files ~= "" then
		return files
	end

	-- Do not go into backup or dot files
	local dirs = vim.fn.readdir(dir, ignore)
	log.trace("dirs = " .. vim.inspect(dirs))
	for _, d in ipairs(dirs) do
		if vim.fn.isdirectory(dir) == 1 then
			files = _find_file_recurse(dir .. [[\]] .. d, file, ignore)
			if files ~= nil and files ~= "" then
				return files
			end
		end
	end

	return nil
end

function M.is_mod_available(name)
	if package.loaded[name] then
		return true
	end
	for _, searcher in ipairs(package.searchers or package.loaders) do
		local loader = searcher(name)
		if type(loader) == "function" then
			package.preload[name] = loader
			return true
		end
	end
	return false
end

function M.has_unix()
	return package.config:sub(1, 1) == [[/]]
end

function M.has_win()
	return package.config:sub(1, 1) == [[\]]
end

-- TODO:remove plenary dependency
local win_file = Path:new(os.getenv("LOCALAPPDATA")):joinpath([[ignore-file]])
local win_ignore_file = [[--ignore-file=]] .. win_file:absolute()
-- TODO: For now env var ignore file is not working
local nix_ignore_file = [[--ignore-file=]] .. os.getenv("HOME") .. [[/.config/ignore-file]]
M.rg_ignore_file = M.has_win() and win_ignore_file or nix_ignore_file

function M.isdir(path)
	vim.validate({ path = { path, "s" } })
	local stat = luv.fs_stat(path)
	if stat == nil then
		return false
	end
	if stat.type == "directory" then
		return true
	end
	return false
end

function M.isfile(path)
	vim.validate({ path = { path, "s" } })
	local stat = luv.fs_stat(path)
	if stat == nil then
		return false
	end
	if stat.type == "file" then
		return true
	end
	return false
end

function M.file_fuzzer(path)
	vim.validate({ path = { path, "s" } })

	local epath = vim.fn.expand(path)
	if isdir(epath) == nil then
		api.nvim_err_writeln("Path provided is not valid: " .. epath)
		return
	end

	if is_mod_available("telescope") then
		require("telescope.builtin").find_files({
			-- Optional
			cwd = path,
			find_command = { "rg", "-i", "--hidden", "--files", "-g", "!.{git,svn}" },
		})
		return
	end

	log.trace("file_fuzzer: path = ", epath)
	if vim.fn.exists(":Files") > 0 then
		vim.cmd("Files " .. epath)
		return
	end

	-- Raw handling of file selection
	-- Save cwd
	local dir = vim.fn.getcwd()
	-- CD to new location
	vim.cmd("lcd " .. epath)
	-- Select file
	local file = vim.fn.input("e " .. epath, "", "file")
	-- Sanitize file
	if file == nil then
		return
	end
	if isfile(file) == nil then
		vim.cmd([[echoerr "Selected file does not exists" ]] .. file)
		vim.cmd("lcd " .. dir)
		return
	end
	vim.cmd("e " .. file)
	vim.cmd("lcd " .. dir)
end

function M.table_removekey(table, key)
	vim.validate({ table = { table, "t" } })
	vim.validate({ key = { key, "s" } })

	local element = table[key]
	if element == nil then
		return nil
	end
	table[key] = nil
	return element
end

-- Creates a floating buffer occuping width and height precentage of the screen
-- Example width = 0.8, height = 0.8
-- Returns buffer, and window handle
function M.open_win_centered(width, height)
	vim.validate({ width = { width, "n" } })
	vim.validate({ height = { height, "n" } })
	local buf = api.nvim_create_buf(false, true)

	local mheight = math.floor((vim.o.lines - 2) * height)
	local row = math.floor((vim.o.lines - mheight) / 2)
	local mwidth = math.floor(vim.o.columns * width)
	local col = math.floor((vim.o.columns - mwidth) / 2)

	local opts = {
		relative = "editor",
		row = row,
		col = col,
		width = mwidth,
		height = mheight,
		style = "minimal",
		border = "rounded",
	}

	log.trace("row = ", row, "col = ", col, "width = ", mwidth, "height = ", mheight)
	return buf, api.nvim_open_win(buf, true, opts)
end

-- @brief Execute program in floating terminal
-- @param cmd vim command, if terminal command is desired append term
-- @param closeterm close window when command is done?
-- @param startinsert start insert mode in terminal
function M.exec_float_term(cmd, startinsert)
	vim.validate({ cmd = { cmd, "s" } })
	-- Last true makes them optional arguments
	vim.validate({ startinsert = { startinsert, "b", true } })

	M.open_win_centered(0.8, 0.8)
	vim.cmd(cmd)
	if startinsert then
		vim.cmd("startinsert")
	end
end

-- Execute cmd and return all of its output
function M.io_popen_read(cmd)
	vim.validate({ cmd = { cmd, "s" } })
	local file = assert(io.popen(cmd))
	local output = file:read("*all")
	file:close()
	-- Strip all spaces from output
	return output:gsub("%s+", "")
end

function M.get_visual_selection()
	-- Why is this not a built-in Vim script function?!
	local sline = vim.fn.getpos("'<")
	local line_start = sline[2]
	local column_start = sline[3]
	local eline = vim.fn.getpos("'>")
	local line_end = eline[2]
	local column_end = eline[3]
	local lines = vim.fn.getline(line_start, line_end)
	if lines == nil then
		return ""
	end
	local selection = vim.opt.selection:get() == "inclusive" and 1 or 2
	lines[1] = lines[1]:sub(column_start - 1)
	lines[#lines] = lines[#lines]:sub(1, column_end - selection)
	local ret = table.concat(lines, "\n")
	-- print("ret = " .. ret)
	return ret
end

function M.execute_in_shell(cmd)
	local fmt = string.format
	local fn = vim.fn
	vim.validate({ cmd = { cmd, "s" } })
	local fcmd = ""
	-- cmd = fn.shellescape(cmd)
	if fn.exists("$KITTY_WINDOW_ID") > 0 then
		fcmd = [[/usr/bin/kitty @ send-text --match recent:1 ]] .. cmd .. [[\\x0d]]
		log.info(fmt("repl.cpp.cmd = %s", cmd))
		fn.system(fcmd)
		return
	end

	if fn.exists("$TMUX") > 0 then
		-- \! = ! which means target (-t) last active tmux pane (!)
		fcmd = [[/usr/bin/tmux send -t ! ]] .. cmd .. " Enter"
		log.info(fmt("repl.cpp.cmd = %s", cmd))
		fn.system(fcmd)
		return
	end

	--[[ if fn.exists(':T') > 0 then
    fcmd =  'T ' .. cmd
    log.info(fmt("repl.cpp.cmd = %s", cmd))
    vim.cmd(fcmd)
    return
  end ]]

	fcmd = "vsplit term://" .. cmd
	log.info(fmt("repl.cpp.cmd = %s", cmd))
	vim.cmd(fcmd)
	vim.notify("[cpp.repl]: no compiler available", vim.log.levels.ERROR)
end

return M
