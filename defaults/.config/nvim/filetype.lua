local log = require('utils.log')

--- Attempt to detect if .h file belongs in a cpp codebase or a "c"
---@param path string: File path
---@param bufnr string: Buffer number
---@return string: cpp or c
local function is_cpp(path, bufnr)
  -- search directory of current bufnr file
  -- it will search for .cpp files
  local names = function(name)
    local ext = { 'cpp', 'cc', 'cxx' }
    for _, v in pairs(ext) do
      if string.find(name, '.' .. v) > 0 then
        return true
      end
    end
    return false
  end
  local opts = {
    -- Need to get the path of the current bufnr
    -- path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
    path = vim.fs.dirname(path),
    upward = false,
    limit = 1,
    type = 'file',
  }
  local r = #vim.fs.find(names, opts) > 0 and 'cpp' or 'c'
  vim.api.nvim_echo({ { "r = '" .. r .. "'" } }, true, {})
  return r
end

log.info('Setting lua filetypes...')
vim.filetype.add({
  extension = {
    -- h = is_cpp,
    Vhd = 'vhdl',
    CPP = 'cpp',
    ino = 'arduino',
    pde = 'arduino',
    csv = 'csv',
    bat = 'dosbatch',
    scp = 'wings_syntax',
    set = 'dosini',
    sum = 'dosini',
    ini = 'dosini',
    bin = 'xxd',
    pdf = 'xxd',
    hsr = 'xxd',
  },
})
