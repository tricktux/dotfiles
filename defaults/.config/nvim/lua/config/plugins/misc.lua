local utl = require('utils/utils')
local line = require('config.plugins.lualine')
local api = vim.api

local M = {}

local function obsession_status()
  return vim.fn['ObsessionStatus']('S:' .. vim.fn
                                       .fnamemodify(vim.v.this_session, ':t:r'),
                                   '$')
end
function M.setup_obsession()
  vim.g.obsession_no_bufenter = 1
  line:ins_right{
    obsession_status,
    color = {fg = line.__colors.violet, gui = 'bold'}
  }
end

return M
