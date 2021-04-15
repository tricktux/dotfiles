local log = require('utils/log')
local luv = vim.loop
local api = vim.api

-- List of useful vim helper functions
-- >vim.tbl_*
--  >vim.tbl_count
-- >vim.validate
-- >vim.deepcopy

-- Similar to python's pprint. Usage: lua dump({1, 2, 3})
local function dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  log.trace(unpack(objects))
end

-- @brief Recurses through a directory in search for a file
-- @param dir Directory to recurse
-- @param file File looking for. Could use wildcards. Will be used by glob()
-- @param ignore Regex with files that will be ignored. Will be used by 
-- readdirs(). See help for that function on what can be passed to reduce list 
-- of files. Example: [[v:val !~ '^\.\|\~$']]
-- @return Table with all file matches with full path if found. Nil 
-- otherwise
local function _find_file_recurse(dir, file, ignore)
  vim.validate {dir = {dir, 's'}}
  vim.validate {file = {file, 's'}}
  vim.validate {ignore = {ignore, 's'}}

  if vim.fn.isdirectory(dir) == 0 then return nil end

  -- Check if the file is in dir
  log.trace('dir = ' .. vim.inspect(dir))
  local files = vim.fn.glob(dir .. [[\]] .. file, true, false)
  log.trace('files = ' .. vim.inspect(files))
  if files ~= nil and files ~= "" then return files end

  -- Do not go into backup or dot files
  local dirs = vim.fn.readdir(dir, ignore)
  log.trace('dirs = ' .. vim.inspect(dirs))
  for _, d in ipairs(dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      files = _find_file_recurse(dir .. [[\]] .. d, file, ignore)
      if files ~= nil and files ~= "" then return files end
    end
  end

  return nil
end

local function is_mod_available(name)
  if package.loaded[name] then return true end
  for _, searcher in ipairs(package.searchers or package.loaders) do
    local loader = searcher(name)
    if type(loader) == 'function' then
      package.preload[name] = loader
      return true
    end
  end
  return false
end

local function has_unix() return package.config:sub(1, 1) == [[/]] end

local function has_win() return package.config:sub(1, 1) == [[\]] end

local function isdir(path)
  vim.validate {path = {path, 's'}}
  local stat = luv.fs_stat(path)
  if stat == nil then return false end
  if stat.type == "directory" then return true end
  return false
end

local function isfile(path)
  vim.validate {path = {path, 's'}}
  local stat = luv.fs_stat(path)
  if stat == nil then return false end
  if stat.type == "file" then return true end
  return false
end

local function file_fuzzer(path)
  vim.validate {path = {path, 's'}}

  local epath = vim.fn.expand(path)
  if isdir(epath) == nil then
    api.nvim_err_writeln("Path provided is not valid: " .. epath)
    return
  end

  if is_mod_available('telescope') then
    require'telescope.builtin'.find_files {
      -- Optional
      cwd = path,
      find_command = {"rg", "-i", "--hidden", "--files", "-g", "!.{git,svn}"}
    }
    return
  end

  log.trace('file_fuzzer: path = ', epath)
  if vim.fn.exists(':Files') > 0 then
    vim.cmd('Files ' .. epath)
    return
  end

  -- Raw handling of file selection
  -- Save cwd
  local dir = vim.fn.getcwd()
  -- CD to new location
  vim.cmd("lcd " .. epath)
  -- Select file
  local file = vim.fn.input('e ' .. epath, '', 'file')
  -- Sanitize file
  if file == nil then return end
  if isfile(file) == nil then
    vim.cmd([[echoerr "Selected file does not exists" ]] .. file)
    vim.cmd("lcd " .. dir)
    return
  end
  vim.cmd("e " .. file)
  vim.cmd("lcd " .. dir)
end

local function table_removekey(table, key)
  vim.validate {table = {table, 't'}}
  vim.validate {key = {key, 's'}}

  local element = table[key]
  if element == nil then return nil end
  table[key] = nil
  return element
end

-- Creates a floating buffer occuping width and height precentage of the screen
-- Example width = 0.8, height = 0.8
-- Returns buffer, and window handle
local function open_win_centered(width, height)
  vim.validate {width = {width, 'n'}}
  vim.validate {height = {height, 'n'}}
  local buf = api.nvim_create_buf(false, true)

  local mheight = math.floor((vim.o.lines - 2) * height)
  local row = math.floor((vim.o.lines - mheight) / 2)
  local mwidth = math.floor(vim.o.columns * width)
  local col = math.floor((vim.o.columns - mwidth) / 2)

  local opts = {
    relative = 'editor',
    row = row,
    col = col,
    width = mwidth,
    height = mheight,
    style = 'minimal',
    border = 'single'
  }

  log.trace('row = ', row, 'col = ', col, 'width = ', mwidth, 'height = ',
            mheight)
  return buf, api.nvim_open_win(buf, true, opts)
end

-- Execute program in floating terminal
local function exec_float_term(cmd, closeterm, startinsert)
  vim.validate {cmd = {cmd, 's'}}
  vim.validate {startinsert = {startinsert, 'b'}}
  vim.validate {closeterm = {closeterm, 'b'}}

  local buf, win = open_win_centered(0.8, 0.8)
  vim.cmd("term " .. cmd)
  if closeterm then
    vim.cmd("au TermClose <buffer=" .. buf .. [[> quit | bwipeout!]] .. buf)
  end
  if startinsert then vim.cmd("startinsert") end
end

-- Execute cmd and return all of its output
local function io_popen_read(cmd)
  vim.validate {cmd = {cmd, 's'}}
  local file = assert(io.popen(cmd))
  local output = file:read('*all')
  file:close()
  -- Strip all spaces from output
  return output:gsub("%s+", "")
end

-- Attempt to display ranger in a floating window
-- local utl = require('utils.utils')

-- local ranger = {}
-- ranger.out_file = nil
-- ranger.opts = {
-- on_stdout = 'v:lua.ranger.__on_exit'
-- }

-- function ranger:exec()
-- local buf, win = utl.open_win_centered(0.8, 0.8)
-- self.out_file = vim.fn.tempname()
-- local cmd = "ranger --choosefiles " .. self.out_file
-- local job_id = vim.fn.termopen(cmd, self.opts)
-- if job_id <= 0 then
-- error("Failed to execute commands: " .. self.cmd.. ". opts = " .. self.opts)
-- end
-- end

-- function ranger:__on_exit(job_id, data, event)
-- local file = io.open(self.out_file)
-- local output = file:read()
-- file:close()
-- print(output)
-- vim.cmd("edit " .. output)
-- end

-- ranger:exec()

-- Fixing vim.validate

return {
  dump = dump,
  is_mod_available = is_mod_available,
  table_removekey = table_removekey,
  has_unix = has_unix,
  has_win = has_win,
  isdir = isdir,
  isfile = isfile,
  file_fuzzer = file_fuzzer,
  open_win_centered = open_win_centered,
  io_popen_read = io_popen_read,
  exec_float_term = exec_float_term,
  find_file = _find_file_recurse
}
