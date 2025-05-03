local M = {}

-- Path is expected to be plenary:Path
local is_full_path = function(path)
  vim.validate('path', path, 'table')
  return path:is_absolute() and path:exists()
end

M.file_size = function(path)
  vim.validate('path', path, 'string')
  local plok, p = pcall(require, 'plenary.path')
  if not plok then
    vim.notify('plenary is not available', vim.log.levels.ERROR)
    return
  end
  local npath = vim.fs.normalize(path)
  local o = p:new(npath)
  if not is_full_path(o) then
    return nil
  end
  return o:size()
end

--- Get the size of a file in bytes
--- Uses native
---@param path string: The full path to the file
---@return size in bytes or nil
M.file_size_native = function(path)
  vim.validate('path', path, 'string')
  local size = vim.uv.fs_stat(path)
  if not size then
    return nil
  end

  return size
end

M.mkfile = function(path)
  vim.validate('path', path, 'string')
  local plok, p = pcall(require, 'plenary.path')
  if not plok then
    vim.notify('plenary is not available', vim.log.levels.ERROR)
    return
  end

  local npath = vim.fs.normalize(path)
  local parent = p:new(npath):parent()
  p:new(parent):mkdir({ parents = true, exist_ok = true })
  return p:new(npath):touch()
end

M.mkdir = function(path)
  vim.validate('path', path, 'string')
  local plok, p = pcall(require, 'plenary.path')
  if not plok then
    vim.notify('plenary is not available', vim.log.levels.ERROR)
    return
  end

  return p:new(vim.fs.normalize(path)):mkdir({ parents = true, exist_ok = true })
end

M.is_path = function(path)
  vim.validate('path', path, 'string')
  local plok, p = pcall(require, 'plenary.path')
  if not plok then
    vim.notify('plenary is not available', vim.log.levels.ERROR)
    return
  end

  local npath = vim.fs.normalize(path)
  local o = p:new(npath)
  if is_full_path(o) then
    return o:absolute()
  end
  -- vim.print("its not full path")
  -- Maybe it's relative to the file dir
  local d = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local f = p:new(d, npath)
  if is_full_path(f) then
    return f:absolute()
  end
  -- vim.print("it's not relative to file")
  -- Maybe it's relative to the cwd dir
  local c = p:new(vim.uv.cwd(), npath)
  if is_full_path(c) then
    return c:absolute()
  end
  -- vim.print("it's not relative to cwd")
  -- Maybe it has variables
  local e = p:new(o:expand())
  if is_full_path(e) then
    return e:absolute()
  end
  -- vim.print("its not expanded")
  -- We are done
  return nil
end

return M
