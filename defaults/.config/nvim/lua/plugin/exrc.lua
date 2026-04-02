local M = {}

local loaded = {}

local function source_nvim_lua(dir)
  if loaded[dir] then
    return
  end

  local path = dir .. '/.nvim.lua'

  if vim.fn.filereadable(path) == 0 then
    return
  end

  local content = vim.secure.read(path)
  if content == nil then
    -- User denied trust or file is untrusted
    return
  end

  local chunk, err = load(content, '@' .. path)
  if not chunk then
    vim.notify(
      '[exrc] Compile error in ' .. path .. ': ' .. err,
      vim.log.levels.ERROR
    )
    return
  end

  local ok, run_err = pcall(chunk)
  if not ok then
    vim.notify(
      '[exrc] Runtime error in ' .. path .. ': ' .. run_err,
      vim.log.levels.ERROR
    )
    return
  end

  loaded[dir] = true
end

function M.setup()
  local group = vim.api.nvim_create_augroup('Exrc', { clear = true })

  vim.api.nvim_create_autocmd('DirChanged', {
    group = group,
    callback = function()
      source_nvim_lua(vim.fn.getcwd())
    end,
  })

  -- Also run on startup for the initial working directory
  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    once = true,
    callback = function()
      source_nvim_lua(vim.fn.getcwd())
    end,
  })
end

return M
