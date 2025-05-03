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
    {
      '<c-w>z',
      '<cmd>WindowsMaximize<cr>',
      desc = 'windows_maximize',
    },
    {
      '<c-w>=',
      '<cmd>WindowsEqualize<cr>',
      desc = 'windows_equalize',
    },
  },
  opts = {
    autowidth = {
      enable = true,
      -- NOTE: change help value if the below one changes
      winwidth = 1.2,
      filetype = {
        help = 1.2,
      },
    },
    ignore = {
      buftype = ignore_buftypes,
      filetype = ignore_filetypes,
    },
    animation = {
      enable = false,
    },
  },
}

return windows
