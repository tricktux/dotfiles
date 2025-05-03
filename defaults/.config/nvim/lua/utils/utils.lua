local log = require('utils.log')
local fs = require('utils.filesystem')
local luv = vim.uv
local api = vim.api
local fmt = string.format
local fn = vim.fn

local M = {}

M.icons = {
  diagnostics = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
  },
  git = {
    added = ' ',
    modified = ' ',
    removed = ' ',
  },
  kinds = {
    Array = ' ',
    Boolean = ' ',
    Class = ' ',
    Color = ' ',
    Constant = ' ',
    Constructor = ' ',
    Copilot = ' ',
    Enum = ' ',
    EnumMember = ' ',
    Event = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = ' ',
    Interface = ' ',
    Key = ' ',
    Keyword = ' ',
    Method = ' ',
    Module = ' ',
    Namespace = ' ',
    Null = 'ﳠ ',
    Number = ' ',
    Object = ' ',
    Operator = ' ',
    Package = ' ',
    Property = ' ',
    Reference = ' ',
    Snippet = ' ',
    String = ' ',
    Struct = ' ',
    Text = ' ',
    TypeParameter = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = ' ',
  },
}

-- List of useful vim helper functions
-- >vim.tbl_*
--  >vim.tbl_count
-- >vim.validate
-- >vim.deepcopy
M.set = {}
function M.set.new(t)
  vim.validate('t', t, 'table')

  local set = {}
  for _, l in ipairs(t) do
    set[l] = true
  end
  return set
end

function M.set.tostring(set)
  vim.validate('t', t, 'table')

  local s = ''
  local sep = ''
  for e in pairs(set) do
    s = s .. sep .. e
    sep = ', '
  end
  return s
end

function M.is_mod_available(name)
  if package.loaded[name] then
    return true
  end
  for _, searcher in ipairs(package.searchers or package.loaders) do
    local loader = searcher(name)
    if type(loader) == 'function' then
      package.preload[name] = loader
      return true
    end
  end
  return false
end

M.has_unix = package.config:sub(1, 1) == [[/]]
M.has_win = package.config:sub(1, 1) == [[\]]

local nix_file = vim.uv.os_homedir() .. [[/.config/ignore-file]]
local win_file = (os.getenv('APPDATA') or 'nil') .. [[\ignore-file]]
M.ignore_file = [[--ignore-file=]] .. (M.has_win and win_file or nix_file)

M.zeal = {}
M.zeal.path = M.has_unix and '/usr/bin/zeal' or [["C:\\Program Files (x86)\\Zeal\\Zeal.exe"]]
M.zeal.search = function(word)
  vim.validate('word', word, 'string')
  local p = M.zeal.path
  if fn.filereadable(p) <= 0 then
    vim.notify("Zeal '" .. p .. "' is not installed", vim.log.levels.ERROR)
    return
  end
  local z = ''
  if M.has_unix then
    z = p .. ' ' .. word .. '&'
  else
    z = [[start cmd.exe /k ]] .. p .. ' ' .. word
  end
  M.term.exec(z)
end

M.browser = {}
M.browser.path = M.has_unix and '/usr/bin/firefox' or 'firefox.exe'
M.browser.search = function(word)
  vim.validate('word', word, 'string')
  local b = M.browser.path
  if fn.filereadable(b) <= 0 then
    vim.notify("Browser '" .. b .. "' is not installed", vim.log.levels.ERROR)
    return
  end
  local z = ''
  if M.has_unix then
    z = b .. ' ' .. word .. '&'
  else
    z = [[start cmd.exe /k ]] .. b .. ' ' .. word
  end
  M.term.exec(z)
end
M.browser.open_file_async = function(file)
  vim.validate('file', file, 'string')
  if vim.uv.fs_stat(file) == nil then
    vim.api.nvim_err_writeln("file: '" .. file .. "' does not exists")
    return
  end
  local cmd = { M.browser.path, file }
  vim.system(cmd, { detach = true })
end

M.fd = {}
M.fd.switches = {}
M.fd.bin = vim.fn.executable('fd') > 0 and 'fd' or 'fdfind'
M.fd.switches.common = vim
  .iter({
    '--color=never',
    '--hidden',
    '--follow',
    '--full-path',
    M.ignore_file,
  })
  :flatten(math.huge)
  :totable()
M.fd.switches.file = vim
  .iter({
    M.fd.switches.common,
    '--type=file',
  })
  :flatten(math.huge)
  :totable()
M.fd.switches.folder = vim
  .iter({
    M.fd.switches.common,
    '--type=directory',
  })
  :flatten(math.huge)
  :totable()
M.fd.folder_cmd = vim
  .iter({
    M.fd.bin,
    M.fd.switches.folder,
  })
  :flatten(math.huge)
  :totable()
M.fd.file_cmd = vim
  .iter({
    M.fd.bin,
    M.fd.switches.file,
  })
  :flatten(math.huge)
  :totable()
M.rg = {}
M.rg.switches = {}
M.rg.bin = 'rg'
M.rg.switches.common = vim
  .iter({
    '--vimgrep',
    '--hidden',
    '--smart-case',
    '--follow',
    '--no-ignore-vcs',
    M.ignore_file,
  })
  :flatten(math.huge)
  :totable()
M.rg.switches.file = vim
  .iter({
    M.rg.switches.common,
    '--files',
  })
  :flatten(math.huge)
  :totable()
M.rg.grep_cmd = vim
  .iter({
    M.rg.bin,
    M.rg.switches.common,
  })
  :flatten(math.huge)
  :totable()
M.rg.file_cmd = vim
  .iter({
    M.rg.bin,
    M.rg.switches.file,
  })
  :flatten(math.huge)
  :totable()
M.rg.vim_to_rg_map = {
  vim = 'vimscript',
  python = 'py',
  markdown = 'md',
}

M.table = {}
M.table.string_to_table = function(string)
  vim.validate('string', string, 'string')
  local t = {}
  for str in string.gmatch(string, '%S+') do
    table.insert(t, str)
  end
  return t
end

M.buftype = {}
M.buftype.whitelist = { '', 'acwrite' }
M.buftype.blacklist = { 'nofile', 'prompt', 'terminal', 'quickfix' }
M.buftype.blacklist_set = M.set.new(M.buftype.blacklist)
M.filetype = {
  blacklist = {
    'lspinfo',
    'packer',
    'checkhealth',
    'help',
    'man',
    '',
    'NvimTree',
    'startify',
  },
}
M.filetype.blacklist_set = M.set.new(M.filetype.blacklist)

-- Filesystem
M.fs = {}
M.fs.path = {}
M.fs.path.sep = package.config:sub(1, 1)
M.fs.file = {}

--- Creates path for a new file
---@param path string Base path from where folder/file will be created
function M.fs.file.create(path)
  local p = fs.is_path(path)
  if p == nil then
    vim.notify('utils.fs.file.create: path not found: ' .. p, vim.log.levels.ERROR)
    return
  end

  local prompt = string.format('Enter name for new file(%s): ', p)
  local on_complete = function(input)
    if input == nil then
      vim.notify('utils.create_file: no file path provided', vim.log.levels.ERROR)
      return
    end

    local f = vim.fs.joinpath(p, input)
    if not fs.mkfile(f) then
      vim.notify('utils.create_file: failed to create parent folder: ' .. f, vim.log.levels.ERROR)
      return
    end

    vim.cmd.edit(f)
  end

  vim.ui.input({ prompt = prompt, completion = 'file' }, on_complete)
end

function M.isdir(path)
  local p = fs.is_path(path)
  if p == nil then
    return false
  end
  local stat = luv.fs_stat(p)
  if stat == nil then
    return false
  end
  if stat.type == 'directory' then
    return true
  end
  return false
end

function M.isfile(path)
  local p = fs.is_path(path)
  if p == nil then
    return false
  end
  local stat = luv.fs_stat(p)
  if stat == nil then
    return false
  end
  if stat.type == 'file' then
    return true
  end
  return false
end

function M.fs.path.native_fuzzer(path)
  vim.validate('path', path, 'string')

  local epath = vim.fn.expand(path)
  if M.isdir(epath) == nil then
    vim.notify('Path provided is not valid: ' .. epath, vim.log.levels.ERROR)
    return
  end

  -- Raw handling of file selection
  -- Save cwd
  local dir = vim.fn.getcwd()
  -- CD to new location
  vim.cmd('lcd ' .. epath)
  -- Select file
  local file = vim.fn.input('e ' .. epath, '', 'file')
  -- Sanitize file
  if file == nil then
    return
  end
  if M.isfile(file) == nil then
    vim.notify('Selected file does not exists' .. file, vim.log.levels.ERROR)
    -- Restore working directory
    vim.cmd('lcd ' .. dir)
    return
  end
  vim.cmd('e ' .. file)
  vim.cmd('lcd ' .. dir)
end

local function fuzzer_sanitize(path)
  vim.validate('path', path, 'string')

  local p = fs.is_path(path)
  if p == nil then
    vim.notify('utils: path not found: ' .. path, vim.log.levels.ERROR)
    return
  end

  return p
end

--- Use this function to yank selected file instead of opening
function M.fs.path.fuzzer_yank(path)
  local p = fuzzer_sanitize(path)

  require('plugin.telescope').file_fuzzer_yank(p)
end

--- Use this function to select file to  open
function M.fs.path.fuzzer(path)
  local p = fuzzer_sanitize(path)

  local tsok, _ = pcall(require, 'telescope')
  if tsok then
    require('plugin.telescope').file_fuzzer(p)
    return
  end

  if vim.fn.exists(':Files') > 0 then
    vim.cmd('Files ' .. p)
    return
  end

  M.fs.path.native_fuzzer(path)
end

function M.tbl_removekey(table, key)
  vim.validate('table', table, 'table')
  vim.validate('key', key, 'string')

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
  vim.validate('width', width, 'number')
  vim.validate('height', height, 'number')
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
    border = 'rounded',
  }

  log.trace('row = ', row, 'col = ', col, 'width = ', mwidth, 'height = ', mheight)
  return {
    bufnr = buf,
    winnr = api.nvim_open_win(buf, true, opts),
  }
end

function M.read_file(path)
  vim.validate('path', path, 'string')
  local file = io.open(path)
  if file == nil then
    return ''
  end
  local output = file:read('*all')
  file:close()
  return output
end

-- Execute cmd and return all of its output
function M.io_popen_read(cmd)
  vim.validate('cmd', cmd, 'string')
  local file = assert(io.popen(cmd))
  local output = file:read('*all')
  file:close()
  -- Strip all spaces from output
  return output:gsub('%s+', '')
end

function M.get_visual_selection()
  print('get_visual_selection')
  -- Why is this not a built-in Vim script function?!
  local sline = vim.fn.getpos("'<")
  local line_start = sline[2]
  local column_start = sline[3]
  local eline = vim.fn.getpos("'>")
  local line_end = eline[2]
  local column_end = eline[3]
  local lines = vim.fn.getline(line_start, line_end)
  if lines == nil then
    return ''
  end
  -- local selection = vim.opt.selection:get() == "inclusive" and 1 or 2
  -- lines[1] = lines[1]:sub(column_start - 1)
  -- lines[#lines] = lines[#lines]:sub(1, column_end - selection)
  print('ret = ' .. vim.inspect(ret))
  return table.concat(lines, '\n')
end

M.term = {}
M.term.kitty_get_number_of_windows_in_current_tab = function()
  local json = vim.json
  local output = vim.system({ 'kitty', '@', 'ls' }, { text = true }):wait()
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

M.buf = {}
M.buf.is_in_current_tab = function(bufnr)
  local tabpage = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(tabpage)
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
  return nil
end
M.buf.is_valid = function(bufnr)
  vim.validate('bufnr', bufnr, 'number')
  if bufnr == nil then
    return false
  end
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  return vim.api.nvim_buf_is_loaded(bufnr)
end

M.term.float = {}
M.term.float.opts = {
  startinsert = false,
  closeterm = true,
  layout = {
    width = 0.90,
    height = 0.90,
  },
}

function M.term.float.exec(cmd, opts)
  vim.validate('cmd', cmd, 'string')
  -- Last true makes them optional arguments
  vim.validate('startinsert', startinsert, 'table', true)
  -- Merge opts
  local startinsert = opts and opts.startinsert or M.term.float.opts.startinsert
  local closeterm = opts and opts.closeterm or M.term.float.opts.closeterm
  local layout = opts and opts.layout or M.term.float.opts.layout

  local b = M.open_win_centered(layout.width, layout.height)
  vim.cmd(cmd)
  if startinsert then
    vim.cmd('startinsert')
  end
  if closeterm then
    vim.api.nvim_create_autocmd('TermClose', {
      buffer = b.bufnr,
      command = 'bwipeout!',
      once = true,
    })
  end
  return b
end

M.term.last = {
  job_id = nil,
  bufnr = nil,
}
M.term.is_valid = function(job_id, bufnr)
  return M.term.valid_job_id(job_id) and M.buf.is_valid(bufnr)
end
M.term.toggle = function()
  local bufnr = M.term.last.bufnr
  local term_valid = M.term.is_valid(M.term.last.job_id, bufnr)

  if not term_valid then
    vim.cmd.terminal()
    return
  end

  local term_win = M.buf.is_in_current_tab(bufnr)
  if term_win ~= nil then
    vim.api.nvim_set_current_win(term_win)
    return
  end
  vim.cmd.buffer(bufnr)
end
M.term.new_vsplit = function()
  vim.cmd.vsplit()
  vim.cmd.terminal()
end
M.term.valid_job_id = function(id)
  vim.validate('id', id, 'number', true)

  if id == nil then
    return false
  end
  for _, chan in pairs(vim.api.nvim_list_chans()) do
    if chan['mode'] == 'terminal' and chan.id == id then
      return true
    end
  end

  return false
end

M.term.send_cmd = function(cmd)
  vim.validate('cmd', cmd, 'string')
  local id = M.term.last.job_id
  if id ~= nil and M.term.valid_job_id(id) then
    vim.api.nvim_chan_send(M.term.last.job_id, cmd .. '\n')
    return true
  end
  return false
end

M.term.exec = function(cmd)
  local lcmd = {}
  if type(cmd) == 'string' then
    lcmd = M.table.string_to_table(cmd)
  end
  vim.validate('lcmd', lcmd, 'table')
  log.info(fmt('term.exec.cmd = %s', vim.inspect(cmd)))

  if M.term.send_cmd(cmd) then
    return
  end

  if
    os.getenv('KITTY_WINDOW_ID') ~= nil
    and M.term.kitty_get_number_of_windows_in_current_tab() > 1
  then
    local f = { '/usr/bin/kitty', '@', 'send-text', '--match', 'recent:1' }
    for _, c in ipairs(lcmd) do
      table.insert(f, c)
    end
    table.insert(f, '\x0d')
    log.info(fmt('term.exec.kitty = %s', vim.inspect(f)))
    vim.system(f, { detach = true })
    return
  end

  if os.getenv('TMUX') ~= nil then
    -- \! = ! which means target (-t) last active tmux pane (!)
    local f = { [[/usr/bin/tmux]], 'send', '-t', '!' }
    for _, c in ipairs(lcmd) do
      table.insert(f, c)
    end
    table.insert(f, 'Enter')
    log.info(fmt('term.exec.tmux = %s', vim.inspect(f)))
    vim.system(f, { detach = true })
    return
  end

  local ttok, tt = pcall(require, 'toggleterm')
  if ttok then
    local trim_spaces = true
    tt.send_lines_to_terminal('single_line', trim_spaces, { args = vim.v.count })
    return
  end

  log.info(fmt('term.exec.cmd = %s', cmd))
  M.term.new_vsplit()
  M.term.send_cmd(cmd)
end

M.term.open_uri = function(uri)
  -- TODO: remove useless function
  vim.ui.open(uri)
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
    '!%[.-%]%((.-)%)',
    '!%[%[(.-)%]%]',
  },
  org = {
    '%[%[(.-)%]%]',
    '%[%[(.-)%]%[.-%]%]',
    '%[%[file: (.-)%]%[.-%]%]',
  },
}

M.links.find_source = function(line)
  vim.validate('line', line, 'string')

  local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
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
  vim.validate('line', line, 'string')
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

M.setup = function()
  -- Use to set autocommand
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'TermOpen', 'TermEnter' }, {
    pattern = '*',
    callback = function(ev)
      if vim.b.terminal_job_id ~= nil then
        M.term.last.job_id = vim.b.terminal_job_id
        M.term.last.bufnr = ev.buf
      end
    end,
  })
end

return M
