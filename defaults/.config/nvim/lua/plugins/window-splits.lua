local ignore_filetypes = { 'neo-tree' }
local ignore_buftypes = { 'nofile', 'prompt', 'popup' }

local focus = {
  'beauwilliams/focus.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>tw',
      '<cmd>FocusToggle<cr>',
      desc = 'focus_mode_toggle_mappings',
    },
    {
      '<a-h>',
      function()
        require('focus').split_nicely('h')
      end,
      desc = 'window_switch_left',
    },
    {
      '<a-j>',
      function()
        require('focus').split_nicely('j')
      end,
      desc = 'window_switch_down',
    },
    {
      '<a-k>',
      function()
        require('focus').split_nicely('k')
      end,
      desc = 'window_switch_up',
    },
    {
      '<a-l>',
      function()
        require('focus').split_nicely('l')
      end,
      desc = 'window_switch_right',
    },
  },
  init = function()
    local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })
    vim.api.nvim_create_autocmd('WinEnter', {
      group = augroup,
      callback = function(_)
        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
          vim.b.focus_disable = true
        end
      end,
      desc = 'Disable focus autoresize for BufType',
    })
    vim.api.nvim_create_autocmd('FileType', {
      group = augroup,
      callback = function(_)
        if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
          vim.b.focus_disable = true
        end
      end,
      desc = 'Disable focus autoresize for FileType',
    })
  end,
  opts = {
    autoresize = {
      enable = true, -- Enable or disable auto-resizing of splits
      width = 0, -- Force width for the focused window
      height = 0, -- Force height for the focused window
      minwidth = 0, -- Force minimum width for the unfocused window
      minheight = 0, -- Force minimum height for the unfocused window
      height_quickfix = 10, -- Set the height of quickfix panel
    },
    ui = {
      number = false, -- Display line numbers in the focussed window only
      relativenumber = false, -- Display relative line numbers in the focussed window only
      hybridnumber = false, -- Display hybrid line numbers in the focussed window only
      absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

      cursorline = false, -- Display a cursorline in the focussed window only
      cursorcolumn = false, -- Display cursorcolumn in the focussed window only
      colorcolumn = {
        enable = false, -- Display colorcolumn in the foccused window only
        list = '+1', -- Set the comma-saperated list for the colorcolumn
      },
      signcolumn = true, -- Display signcolumn in the focussed window only
      winhighlight = false, -- Auto highlighting for focussed/unfocussed windows
    },
  },
}

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
      filetype = { --	      |windows.autowidth.filetype|
        help = 0.5,
      },
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
