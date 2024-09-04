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

M.path.list.work = {
  vim.fs.joinpath(home, 'Documents/work/wiki'),
}

M.path.list.personal = {
  vim.fs.joinpath(home, 'Documents/resilio/rei/wiki'),
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
