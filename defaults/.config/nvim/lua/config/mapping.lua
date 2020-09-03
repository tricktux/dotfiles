local log = require('utils/log')
local utils = require('utils/utils')

local function noremap(lhs, rhs, opts, mode)
  if lhs == nil then
    log.error('Empty lhs variable')
    return
  end
  -- Always set mode to n
  -- Always add noremap to opts
  -- Do not modify orignal options
  log.trace("opts = ", opts)
  if vim.tbl_isempty(opts) then
    copts = {}
  else
    copts = vim.deepcopy(opts)
  end
  copts.noremap = true
  -- Remove and check buffer option from opts
  if utils.table_removekey(copts, 'buffer') == true then
    -- Call buffer version
    log.trace("calling buffer mapping for: ", lhs)
    vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, copts)
    return
  end
  log.trace("calling global mapping for: ", lhs)
  vim.api.nvim_set_keymap(mode, lhs, rhs, copts)
end

local function nnoremap(lhs, rhs, opts)
  if lhs == nil then
    log.error('Empty lhs variable')
    return
  end
  -- Always set mode to n
  -- Always add noremap to opts
  -- Do not modify orignal options
  log.trace("opts = ", opts)
  if vim.tbl_isempty(opts) then
    copts = {}
  else
    copts = vim.deepcopy(opts)
  end
  copts.noremap = true
  -- Remove and check buffer option from opts
  if utils.table_removekey(copts, 'buffer') == true then
    -- Call buffer version
    log.trace("calling buffer mapping for: ", lhs)
    vim.api.nvim_buf_set_keymap(0, 'n', lhs, rhs, copts)
    return
  end
  log.trace("calling global mapping for: ", lhs)
  vim.api.nvim_set_keymap('n', lhs, rhs, copts)
end

return {
  nnoremap = nnoremap
}
