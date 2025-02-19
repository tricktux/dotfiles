local utils = require('utils.utils')
local vcs = {}

-- NOTE: To extend
--   1. local svn = vcs:new()
--   2. Implement all the vcs functions
--   3. Address the factory function

-- Based on the current folder determine what's the version control source in
-- use, based on that support some basic commands such as status, commit, etc.
function vcs:new(o) -- constructor for the VCS class
  o = o or {} -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

function vcs:status()
  -- This should be overwritten by subclass
  print('Status: Not implemented')
end

function vcs:diff()
  -- This should be overwritten by subclass
  print('diff: Not implemented')
end

function vcs:buffer_commits()
  -- This should be overwritten by subclass
  print('buffer_commits: Not implemented')
end

function vcs:blame()
  -- This should be overwritten by subclass
  print('blame: Not implemented')
end

function vcs:branches()
  -- This should be overwritten by subclass
  print('branches: Not implemented')
end

function vcs:reset_hunk()
  -- This should be overwritten by subclass
  print('reset_hunk: Not implemented')
end

function vcs:reset_buffer()
  -- This should be overwritten by subclass
  print('reset_buffer: Not implemented')
end

-- Git subclass
local git = vcs:new()
function git:status()
  if vim.fn.executable('lazygit') > 0 then
    local o = { startinsert = true }
    local b = utils.term.float.exec('term lazygit', o)
    return
  end

  if vim.fn.exists(':Neogit') > 0 then
    vim.cmd('Neogit kind=floating')
    return
  end

  print('Git Status: Not implemented')
end

function git:diff()
  if vim.fn.exists(':DiffviewOpen') > 0 then
    vim.cmd('DiffviewOpen')
    return
  end
  print('Git Diff: Not implemented')
end

function git:buffer_commits()
  if vim.fn.exists(':DiffviewFileHistory') > 0 then
    vim.cmd('DiffviewFileHistory %')
    return
  end

  if vim.fn.executable('lazygit') > 0 then
    -- Get path to current buffer
    local o = { startinsert = true }
    local path = vim.api.nvim_buf_get_name(0)
    utils.term.float.exec('term lazygit -f "' .. path .. '"', o)
    return
  end

  print('Git buffer_commits: Not implemented')
end

function git:branches()
  if vim.fn.exists(':Telescope') > 0 then
    vim.cmd('Telescope git_branches')
    return
  end

  print('Git branches: Not implemented')
end

function git:blame()
  if vim.fn.exists(':GitMessenger') > 0 then
    vim.cmd('GitMessenger')
    return
  end

  print('Git blame: Not implemented')
end

function git:reset_hunk()
  if vim.fn.exists(':Gitsigns') > 0 then
    vim.cmd('Gitsigns reset_hunk')
    return
  end

  print('Git reset_hunk: Not implemented')
end

function git:reset_buffer()
  if vim.fn.exists(':Gitsigns') > 0 then
    vim.cmd('Gitsigns reset_buffer')
    return
  end

  print('Git reset_buffer: Not implemented')
end

function vcs:factory() -- factory method to instantiate appropriate VCS subclass
  local gitdir = ".git"
  local g = vim.fs.find(gitdir, {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  })

  if #g == 0 then
    vim.notify('Error: Not a Git or SVN repository', vim.log.levels.ERROR)
    return nil
  end

  vim.cmd.lcd(vim.fs.dirname(g[1]))

  -- Check if current directory is git repository
  if string.match(g[1], gitdir) ~= nil then
    return git:new()
  end

end

return vcs
