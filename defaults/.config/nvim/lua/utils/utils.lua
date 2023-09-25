local log = require("utils.log")
local fs = require("utils.filesystem")
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
M.browser.open_file_async = function(file)
  if vim.loop.fs_stat(file) == nil then
    vim.api.nvim_err_writeln("file: '" .. file .. "' does not exists")
    return
  end
  local cmd = { M.browser.path, file }
  vim.system(cmd, { detach = true })
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

M.table = {}
M.table.string_to_table = function(string)
  vim.validate({ string = { string, "s" } })
  local t = {}
  for str in string.gmatch(string, "%S+") do
    table.insert(t, str)
  end
  return t
end

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
M.term.kitty_get_number_of_windows_in_current_tab = function()
  local json = vim.json
  local output = vim.system({ "kitty", "@", "ls" }, { text = true }):wait()
  if output == nil then
    return 0
  end
  if output.code ~= 0 then
    return 0
  end
  local data = json.decode(output.stdout)

  for _, tab in ipairs(data[1].tabs) do
    if tab.is_focused == true then
      return #tab.windows
    end
  end
  return 0
end

M.term.exec = function(cmd)
  if type(cmd) == "string" then
    cmd = M.table.string_to_table(cmd)
  end
  vim.validate({ cmd = { cmd, "t" } })
  log.info(fmt("term.exec.cmd = %s", vim.inspect(cmd)))
  if os.getenv("KITTY_WINDOW_ID") ~= nil and M.term.kitty_get_number_of_windows_in_current_tab() > 1 then
    local f = { "/usr/bin/kitty", "@", "send-text", "--match", "recent:1" }
    for _, c in ipairs(cmd) do
      table.insert(f, c)
    end
    table.insert(f, "\x0d")
    log.info(fmt("term.exec.kitty = %s", vim.inspect(f)))
    vim.system(f, { detach = true })
    return
  end

  if os.getenv("TMUX") ~= nil then
    -- \! = ! which means target (-t) last active tmux pane (!)
    local f = { [[/usr/bin/tmux]], "send", "-t", "!" }
    for _, c in ipairs(cmd) do
      table.insert(f, c)
    end
    table.insert(f, "Enter")
    log.info(fmt("term.exec.tmux = %s", vim.inspect(f)))
    vim.system(f, { detach = true })
    return
  end

  local fcmd = ":!" .. table.concat(cmd, " ")
  log.info(fmt("term.exec.cmd = %s", cmd))
  vim.cmd(fcmd)
end

M.term.open_uri = function(uri)
  vim.validate({ uri = { uri, "s", false } })

  local start = M.has_unix and "xdg-open" or "start"
  local cmd = {start, uri}
  vim.system(cmd, { detach = true })
end

function M.get_visible_lines(winid)
  local cursor_pos = vim.api.nvim_win_get_cursor(winid)
  local cursor_line = cursor_pos[1]
  local win_height = vim.api.nvim_win_get_height(winid)
  local start_line = math.max(cursor_line - math.floor(win_height / 2), 1)
  local end_line = start_line + win_height - 1
  local buf = vim.api.nvim_win_get_buf(winid)
  local visible_lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line - 1, false)
  return { start_line = start_line, end_line = end_line, visible_lines = visible_lines }
end

M.links = {}
M.links.sources = {
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

M.links.find_source = function(line)
  vim.validate({ line = { line, "s", false } })

  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  if M.links.sources[ft] == nil then
    -- vim.api.nvim_err_writeln("No sources for filetype: " .. ft)
    return nil
  end

  -- vim.print("Filetype: " .. ft)
  for _, pattern in pairs(M.links.sources[ft]) do
    -- vim.print("Pattern: " .. pattern)
    local match = string.match(line, pattern)
    if match then
      return match
    end
  end

  -- vim.print("No image pattern matched")
  return nil
end

M.links.open_uri_in_line = function(line)
  vim.validate({ line = { line, "s", false } })
  -- vim.print("Line: " .. line)
  local source = M.links.find_source(line)
  local u = source or line
  local file = fs.is_path(u)
  if file then
    M.term.open_uri(file)
    return
  end

  M.term.open_uri(u)
end

return M
