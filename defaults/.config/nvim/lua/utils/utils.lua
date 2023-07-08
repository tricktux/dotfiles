local log = require("utils.log")
local luv = vim.loop
local api = vim.api
local fmt = string.format
local fn = vim.fn

local M = {}

M.icons = {
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  kinds = {
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = " ",
    Null = "ﳠ ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
  },
}

-- List of useful vim helper functions
-- >vim.tbl_*
--  >vim.tbl_count
-- >vim.validate
-- >vim.deepcopy
M.set = {}
function M.set.new(t)
	vim.validate({ t = { t, "t" } })

	local set = {}
	for _, l in ipairs(t) do
		set[l] = true
	end
	return set
end

function M.set.tostring(set)
	vim.validate({ set = { set, "t" } })

	local s = ""
	local sep = ""
	for e in pairs(set) do
		s = s .. sep .. e
		sep = ", "
	end
	return s
end

-- TODO Fix broken function. Maybe use `plenary`
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
			files = M._find_file_recurse(dir .. [[\]] .. d, file, ignore)
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

M.has_unix = package.config:sub(1, 1) == [[/]]
M.has_win = package.config:sub(1, 1) == [[\]]

local nix_file = vim.loop.os_homedir() .. [[/.config/ignore-file]]
local win_file = (os.getenv("APPDATA") or "nil") .. [[\ignore-file]]
M.ignore_file = [[--ignore-file=]] .. (M.has_win and win_file or nix_file)

M.zeal = {}
M.zeal.path = M.has_unix and "/usr/bin/zeal" or [["C:\\Program Files (x86)\\Zeal\\Zeal.exe"]]
M.zeal.search = function(word)
	vim.validate({ word = { word, "s" } })
	local p = M.zeal.path
	if fn.filereadable(p) <= 0 then
		vim.notify("Zeal '" .. p .. "' is not installed", vim.log.levels.ERROR)
		return
	end
	local z = ""
	if M.has_unix then
		z = p .. " " .. word .. "&"
	else
		z = [[start cmd.exe /k ]] .. p .. " " .. word
	end
	M.term.exec(z)
end

M.browser = {}
M.browser.path = M.has_unix and "/usr/bin/firefox" or "firefox.exe"
M.browser.search = function(word)
	vim.validate({ word = { word, "s" } })
	local b = M.browser.path
	if fn.filereadable(b) <= 0 then
		vim.notify("Browser '" .. b .. "' is not installed", vim.log.levels.ERROR)
		return
	end
	local z = ""
	if M.has_unix then
		z = b .. " " .. word .. "&"
	else
		z = [[start cmd.exe /k ]] .. b .. " " .. word
	end
	M.term.exec(z)
end

M.fd = {}
M.fd.switches = {}
M.fd.bin = M.has_win and "fd" or [[/usr/bin/fd]]
M.fd.switches.common = vim.tbl_flatten({
	"--color=never",
	"--hidden",
	"--follow",
	M.ignore_file,
})
M.fd.switches.file = vim.tbl_flatten({
	M.fd.switches.common,
	"--type=file",
})
M.fd.switches.folder = vim.tbl_flatten({
	M.fd.switches.common,
	"--type=directory",
})
M.fd.folder_cmd = vim.tbl_flatten({
	M.fd.bin,
	M.fd.switches.folder,
})
M.fd.file_cmd = vim.tbl_flatten({
	M.fd.bin,
	M.fd.switches.file,
})
M.rg = {}
M.rg.switches = {}
M.rg.bin = M.has_win and "rg" or [[/usr/bin/rg]]
M.rg.switches.common = vim.tbl_flatten({
	"--vimgrep",
	"--hidden",
	"--smart-case",
	"--follow",
	"--no-ignore-vcs",
	M.ignore_file,
})
M.rg.switches.file = vim.tbl_flatten({
	M.rg.switches.common,
	"--files",
})
M.rg.grep_cmd = vim.tbl_flatten({
	M.rg.bin,
	M.rg.switches.common,
})
M.rg.file_cmd = vim.tbl_flatten({
	M.rg.bin,
	M.rg.switches.file,
})
M.rg.vim_to_rg_map = {
	vim = "vimscript",
	python = "py",
	markdown = "md",
}

M.buftype = {}
M.buftype.whitelist = { "", "acwrite" }
M.buftype.blacklist = { "nofile", "prompt", "terminal", "quickfix" }
M.buftype.blacklist_set = M.set.new(M.buftype.blacklist)
M.filetype = {
	blacklist = {
		"lspinfo",
		"packer",
		"checkhealth",
		"help",
		"man",
		"",
		"NvimTree",
		"startify",
	},
}
M.filetype.blacklist_set = M.set.new(M.filetype.blacklist)

-- Filesystem
M.fs = {}
M.fs.path = {}
M.fs.path.sep = package.config:sub(1, 1)
function M.fs.path.normalize(path)
	vim.validate({ path = { path, "s" } })

	local plok, pl = pcall(require, "plenary.path")
	if not plok then
		vim.notify("plenary is not available", vim.log.levels.ERROR)
		return
	end
	local sep = {
		w = { "/", "\\" },
		u = { "\\", "/" },
	}
	local g = M.has_win and sep.w or sep.u
	local p = string.gsub(path, g[1], g[2])
	return pl:new(p):absolute()
end

function M.fs.path.exists(path)
	vim.validate({ path = { path, "s" } })

	local plok, pl = pcall(require, "plenary.path")
	if not plok then
		vim.notify("plenary is not available", vim.log.levels.ERROR)
		return
	end

	return pl:new(path):exists()
end

M.fs.file = {}

--- Creates path for a new file
---@param path string Base path from where folder/file will be created
function M.fs.file.create(path)
	vim.validate({ path = { path, "s" } })
	local plok, pl = pcall(require, "plenary.path")
	if not plok then
		vim.notify("plenary is not available", vim.log.levels.ERROR)
		return
	end

	local ppath = pl:new(vim.fn.fnameescape(path))
	if not ppath:is_dir() then
		vim.notify("utils.create_file: path not found: " .. ppath:absolute(), vim.log.levels.ERROR)
		return
	end

	local p = string.format("Enter name for new file(%s): ", ppath:absolute())
	local i = nil
	vim.ui.input({ prompt = p, completion = "file" }, function(input)
		i = input
	end)
	if i == nil then
		return
	end

	local f = ppath:joinpath(i)
	local d = f:parent()
	if not d:mkdir({ parents = true, exists_ok = true }) then
		vim.notify("utils.create_file: failed to create parent folder: " .. d:absolute(), vim.log.levels.ERROR)
		return
	end

	vim.cmd("edit " .. f:absolute())
end

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

function M.fs.path.native_fuzzer(path)
	vim.validate({ path = { path, "s" } })

	local epath = vim.fn.expand(path)
	if M.isdir(epath) == nil then
		vim.notify("Path provided is not valid: " .. epath, vim.log.levels.ERROR)
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
	if M.isfile(file) == nil then
		vim.notify("Selected file does not exists" .. file, vim.log.levels.ERROR)
		-- Restore working directory
		vim.cmd("lcd " .. dir)
		return
	end
	vim.cmd("e " .. file)
	vim.cmd("lcd " .. dir)
end

function M.fs.path.fuzzer(path)
	vim.validate({ path = { path, "s" } })

	local tsok, _ = pcall(require, "telescope")
	if tsok then
		local p = M.fs.path.normalize(path)
		if not M.fs.path.exists(p) then
			vim.notify("utils: path not found: " .. p, vim.log.levels.ERROR)
			return
		end
		require("plugins.telescope").file_fuzzer(p)
		return
	end

	if vim.fn.exists(":Files") > 0 then
		vim.cmd("Files " .. epath)
		return
	end

	M.fs.path.native_fuzzer(path)
end

function M.tbl_removekey(table, key)
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

function M.read_file(path)
	vim.validate({ path = { path, "s" } })
	local file = io.open(path)
	if file == nil then
		return ""
	end
	local output = file:read("*all")
	file:close()
	return output
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
	print("get_visual_selection")
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
	-- local selection = vim.opt.selection:get() == "inclusive" and 1 or 2
	-- lines[1] = lines[1]:sub(column_start - 1)
	-- lines[#lines] = lines[#lines]:sub(1, column_end - selection)
	print("ret = " .. vim.inspect(ret))
	return table.concat(lines, "\n")
end

M.term = {}
M.term.exec = function(cmd)
	vim.validate({ cmd = { cmd, "s" } })
	log.info(fmt("term.exec.cmd = %s", cmd))
	local fcmd = ""
	if os.getenv("KITTY_WINDOW_ID") ~= nil then
    -- TODO: detect if there's more than a single window
		local f = { "/usr/bin/kitty", "@", "send-text", "--match", "recent:1", cmd, "\x0d" }
		log.info(fmt("term.exec.fcmd = %s", vim.inspect(f)))
		fn.jobstart(f)
		return
	end

	if os.getenv("TMUX") ~= nil then
		-- \! = ! which means target (-t) last active tmux pane (!)
		fcmd = [[/usr/bin/tmux send -t ! ]] .. cmd .. " Enter"
		log.info(fmt("term.exec.cmd = %s", cmd))
		fn.jobstart(fcmd)
		return
	end

	if fn.exists(":TermExec") > 0 then
		log.info(fmt("term.exec.cmd = %s", cmd))
		require("toggleterm").exec(cmd)
		return
	end

	fcmd = ":!" .. cmd
	log.info(fmt("term.exec.cmd = %s", cmd))
	vim.cmd(fcmd)
end

M.term.firefox_preview_async = function(file)
  if vim.loop.fs_stat(file) == nil then
    vim.api.nvim_err_writeln("file: '" .. file .. "' does not exists")
    return
  end
  local cmd = { "firefox",  file}
  vim.system(cmd, { detach = true })
end

return M
