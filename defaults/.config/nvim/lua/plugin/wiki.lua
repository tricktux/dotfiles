local utl = require('utils.utils')
local fs = require('utils.utils').fs
local log = require('utils.log')
local map = require('mappings')
local luv = vim.loop
local home = luv.os_homedir()

local M = {}

M.path = {
  list = {},
  default = vim.fs.joinpath(home, 'Documents/wiki'),
  work = nil,
  personal = nil,
  org = {
    main = [[/org/notes.org]],
    random = [[/org/random.org]],
  },
}

local report = {}

local curr_year = os.date('%Y')
local curr_week = os.date('%U')
report.base_folder = string.format([[%s\hpd]], M.path.base)
report.name_preffix = 'WeeklyReport_ReinaldoMolina_'
report.current =
  string.format([[%s\%s\%s%s.md]], report.base_folder, curr_year, report.name_preffix, curr_week)

function report:__find_most_recent()
  -- Find latest report, search from the current year and week backwards
  local week = curr_week -- initally start with the curr_week
  for i = curr_year, 2016, -1 do
    local search_folder = self.base_folder .. '\\' .. i
    log.info(string.format('folder = %q, week = %q', search_folder, week))
    if not utl.isdir(search_folder) then
      log.warn('Folder does not exists: ', search_folder)
      break
    end
    for j = week, 1, -1 do
      -- Create file name
      local potential = search_folder
        .. '\\'
        .. self.name_preffix
        .. string.format('%02d', j)
        .. '.md'
      log.info('Searching file: ' .. potential)
      if utl.isfile(potential) then
        log.info('Found potential report file: ' .. potential)
        return potential
      end
    end
    -- If we did not find the report in the curr_year folder.
    -- Start searching from week 52
    week = 52
  end
  return nil
end

function report:edit_weekly_report()
  if M.path.base == nil then
    local msg = 'Wiki path not set'
    vim.cmd(string.format([[echohl ErrorMsg | echo '%q' | echohl None]], msg))
    return
  end

  -- Return right away if weekly was already created
  if utl.isfile(self.current) then
    vim.cmd('edit ' .. self.current)
    return
  end

  -- Ensure a folder for this year exists
  local cfolder = self.base_folder .. '\\' .. curr_year
  log.debug('Report folder: ', cfolder)
  if not utl.isdir(cfolder) then
    local msg = string.format('Creating hpd folder: %q', cfolder)
    vim.cmd(string.format([[echohl WarningMsg | echo '%q' | echohl None]], msg))
    luv.fs_mkdir(cfolder, 777)
  end

  local recent = self:__find_most_recent()
  if recent == nil then
    local msg = string.format('Failed to find any previous reports: %q', self.base_folder)
    vim.cmd(string.format([[echohl ErrorMsg | echo '%q' | echohl None]], msg))
    return
  end

  -- Make a copy of the last report
  luv.fs_copyfile(recent, self.current)
  vim.cmd('edit ' .. self.current)
end

M.path.list.work = {
  vim.fs.joinpath(home, 'Documents/work/wiki'),
}

M.path.list.personal = {
  vim.fs.joinpath(home, 'Documents/resilio/resilio-rei/wiki'),
  vim.fs.joinpath(home, 'Nextcloud/wiki'),
  vim.fs.joinpath(home, 'Documents/Nextcloud/wiki'),
  vim.fs.joinpath(home, 'Documents/Drive/wiki'),
  vim.fs.joinpath(home, 'External/reinaldo/resilio/wiki'),
  vim.fs.joinpath(home, 'Documents/wiki'),
}

M.path.find = function(wikis)
  vim.validate({ wikis = { wikis, 'table', false } })
  for _, dir in pairs(wikis) do
    local w = luv.fs_stat(dir)
    if w and w.type == 'directory' then
      return dir
    end
  end

  return nil
end

M.maps = {}
M.maps.mode = 'n'
M.maps.prefix = '<leader>w'
M.maps.opts = { silent = true }
M.maps.mappings = {
  o = {
    function()
      fs.path.fuzzer(M.path.base)
    end,
    'wiki_open',
  },
  a = {
    function()
      fs.file.create(M.path.base)
    end,
    'wiki_add',
  },
  r = {
    function()
      vim.cmd.edit(vim.fs.joinpath(M.path.base, M.path.random))
    end,
    'wiki_random',
  },
  p = {
    function()
      report:edit_weekly_report()
    end,
    'weekly_report',
  },
  w = {
    function()
      vim.cmd.edit(vim.fs.joinpath(M.path.base, M.path.main))
    end,
    'wiki_notes',
  },
}

function M:setup()
  local w = self.path.find(self.path.list.work)
  if w then
    self.path.work = w
  end
  local p = self.path.find(self.path.list.personal)
  if not p then
    vim.fn.mkdir(self.path.default, 'p')
    p = self.path.default
  end

  vim.g.advanced_plugins = string.gmatch(p, 'resilio|[Nn]extcloud|Drive') ~= nil and 1 or 0
  -- vim.g.advanced_plugins = 1
  self.path.personal = p
end

return M
