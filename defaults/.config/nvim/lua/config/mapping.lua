local log = require('utils/log')
local utils = require('utils/utils')

local M = {}

M._modes = {'n', 'v', 'x', 's', 'o', '!', 'i', 'l', 'c', 't'}

function M:_validate_mode(mode)
    log.trace("vali mode = ", mode)
    vim.validate {mode = {mode, 'string'}}
    for _,m in pairs(self._modes) do if m == mode then return true end end
    return false
end

function M:_noremap(lhs, rhs, opts, mode)
    log.trace("mode = ", mode)
    vim.validate {lhs = {lhs, 'string'}}
    vim.validate {opts = {opts, 'table'}}
    vim.validate {mode = {mode, function(a) return self._validate_mode(a) end, 'vim mapping mode'}}
    -- Always set mode to n
    -- Always add noremap to opts
    -- Do not modify orignal options
    log.trace("opts = ", opts)
    local copts = {}
    if not vim.tbl_isempty(opts) then copts = vim.deepcopy(opts) end
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

-- Programatically setup all mode .. noremap functions. Such as {n,i,c}noremap
function M:set()
  for _, mode in ipairs(M._modes) do
      -- See help: map!
      if mode == '!' then
          M['mapi'] = function(lhs, rhs, opts)
              M:_noremap(lhs, rhs, opts, mode)
          end
      else
          M[mode .. 'noremap'] = function(lhs, rhs, opts)
              M:_noremap(lhs, rhs, opts, mode)
          end
      end
  end
  log.debug("mapping = ", M)
end

return M
