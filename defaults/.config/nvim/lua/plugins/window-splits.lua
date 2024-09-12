local ignore_filetypes = { 'neo-tree' }
local ignore_buftypes = { 'nofile', 'prompt', 'popup' }

local windows = {
  'anuvyklack/windows.nvim',
  event = 'VeryLazy',
  dependencies = 'anuvyklack/middleclass',
  keys = {
    {
      '<leader>tw',
      '<cmd>WindowsToggleAutowidth<cr>',
      desc = 'windows_split_mode_toggle_mappings',
    },
  },
  opts = {
    autowidth = { --		       |windows.autowidth|
      enable = true,
      winwidth = 0.6, --		        |windows.winwidth|
    },
    ignore = { --			  |windows.ignore|
      buftype = ignore_buftypes,
      filetype = ignore_filetypes,
    },
    animation = {
      enable = false,
    },
  },
}

return windows
