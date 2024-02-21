local utils = require("utils.utils")
local vcs = {}

-- Based on the current folder determine what's the version control source in
-- use, based on that support some basic commands such as status, commit, etc.
function vcs:new(o) -- constructor for the VCS class
  o = o or {}       -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

function vcs:status()
  -- This should be overwritten by subclass
  print("Status: Not implemented")
end

function vcs:diff()
  -- This should be overwritten by subclass
  print("diff: Not implemented")
end

function vcs:buffer_commits()
  -- This should be overwritten by subclass
  print("buffer_commits: Not implemented")
end

function vcs:blame()
  -- This should be overwritten by subclass
  print("blame: Not implemented")
end

-- Git subclass
local git = vcs:new()
function git:status()
  if vim.fn.executable("lazygit") > 0 then
    local o = { startinsert = true }
    local b = utils.term.float.exec("term lazygit", o)
    return
  end

  print("Git Status: Not implemented")
end

function git:diff()
  if vim.fn.exists(":DiffviewOpen") > 0 then
    vim.cmd("DiffviewOpen")
    return
  end
  print("Git Diff: Not implemented")
end

function git:buffer_commits()
  if vim.fn.executable("lazygit") > 0 then
    -- Get path to current buffer
    local o = { startinsert = true }
    local path = vim.api.nvim_buf_get_name(0)
    utils.term.float.exec('term lazygit -f "' .. path .. '"', o)
    return
  end

  if vim.fn.exists(":DiffviewFileHistory") > 0 then
    vim.cmd("DiffviewFileHistory %")
    return
  end

  print("Git buffer_commits: Not implemented")
end

function git:blame()
  if vim.fn.exists(":GitMessenger") > 0 then
    vim.cmd("GitMessenger")
    return
  end

  print("Git blame: Not implemented")
end

function vcs:factory() -- factory method to instantiate appropriate VCS subclass
  local ret = nil
  local g = vim.fs.find(".git", {
    upward = true,
    stop = vim.uv.os_homedir(),
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
  })
  -- Check if current directory is git repository
  if #g > 0 then
    ret = git
  end

  if ret then
    return ret:new()
  end

  error("Error: Not a Git or SVN repository")
  return nil
end

return vcs
