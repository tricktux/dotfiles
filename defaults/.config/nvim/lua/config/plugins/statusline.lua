local utl = require('utils/utils')
local api = vim.api

local M = {}

function M.lualine_config()
  if not utl.is_mod_available('lualine') then
    api.nvim_err_writeln("lualine was set, but module not found")
    return
  end
  local config = {
    options = {
      theme = 'gruvbox',
      section_separators = {'', ''},
      component_separators = {'', ''},
      icons_enabled = true
    },
    sections = {
      lualine_a = {{'mode', upper = true}},
      lualine_b = {{'branch', icon = ''}},
      lualine_c = {{'filename', file_status = true}},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
    },
    extensions = {'fzf'}
  }
  require('lualine').setup(config)
end

return M
