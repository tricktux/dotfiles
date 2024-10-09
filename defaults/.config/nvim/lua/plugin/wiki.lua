local luv = vim.uv
local home = luv.os_homedir()

local M = {}

M.path = {
  default = vim.fs.joinpath(home, 'Documents/wiki'),
  work = nil,
  personal = nil,
  org = {
    main = [[/org/notes.org]],
    random = [[/org/random.org]],
  },
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
  local exists = function(folder)
    local stat = luv.fs_stat(folder)
    return stat and stat.type == 'directory' and true or false
  end

  local w = luv.os_getenv("WIKI_WORK")
  if w then
    M.path.work = exists(w) and w or nil
    if not M.path.work then
      print("ERROR: Invalid WIKI_WORK directory: " .. w)
    end
  end
  local p = luv.os_getenv("WIKI_PERSONAL")
  if not p then
    vim.fn.mkdir(self.path.default, 'p')
    p = self.path.default
    return
  end

  M.path.personal = exists(p) and p or nil
  if not M.path.personal then
    print("ERROR: Invalid WIKI_PERSONAL directory: " .. p)
    return
  end
  vim.g.advanced_plugins = 1
end

return M
