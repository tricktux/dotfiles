if vim.fn.has('win32') > 0 then
  return {}
end

if vim.g.advanced_plugins == 0 then
  return {}
end

local M = {
  {
    'kelly-lin/ranger.nvim',
    keys = {
      {
        '<plug>file_ranger_nvim',
        function()
          require('ranger-nvim').open(true)
        end,
        desc = 'file_ranger_nvim',
      },
    },
    opts = {
      replace_netrw = false,
      ui = {
        border = 'single',
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
      },
    },
  },
  { 'jamessan/vim-gnupg', event = 'VeryLazy' },
  { 'mboughaba/i3config.vim', ft = 'i3config' },
  {
    'untitled-ai/jupyter_ascending.vim',
    ft = 'python',
    init = function()
      vim.g.jupyter_ascending_default_mappings = false
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
        pattern = '*.sync.py',
        callback = function()
          if vim.b.has_jupyter_plugin == true then
            return
          end
          vim.b.has_jupyter_plugin = true
          local opts = { silent = true, buffer = true, desc = 'jupyter_execute' }
          vim.keymap.set('n', '<localleader>j', '<Plug>JupyterExecute', opts)
          opts.desc = 'jupyter_execute_all'
          vim.keymap.set('n', '<localleader>k', '<Plug>JupyterExecuteAll', opts)
        end,
      })
    end,
  },
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    config = function()
      require('kitty-scrollback').setup()
    end,
  },
}

return M
