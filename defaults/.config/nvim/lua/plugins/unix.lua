if vim.fn.has('win32') > 0 then
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
}

local advanced = {
  { 'jamessan/vim-gnupg', event = 'VeryLazy' },
  { 'mboughaba/i3config.vim', ft = 'i3config' },
  { 'lambdalisue/suda.vim', cmd = { 'SudaWrite', 'SudaRead' } },
  { 'chr4/nginx.vim', ft = 'nginx' },
  { 'neomutt/neomutt.vim', ft = 'muttrc' },
  { 'fladson/vim-kitty', ft = 'kitty' },
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
  {
    'michaelb/sniprun',
    cmd = { 'SnipRun' },
    ft = { 'markdown', 'org' },
    build = 'sh ./install.sh',
    opts = {
      --# you can combo different display modes as desired and with the 'Ok' or 'Err' suffix
      --# to filter only sucessful runs (or errored-out runs respectively)
      display = {
        'Classic', --# display results in the command-line  area
        'VirtualTextOk', --# display ok results as virtual text (multiline is shortened)
        -- "VirtualText",             --# display results as virtual text
        -- "TempFloatingWindow",      --# display results in a floating window
        -- "LongTempFloatingWindow",  --# same as above, but only long results. To use with VirtualText[Ok/Err]
        -- "Terminal",                --# display results in a vertical split
        'TerminalWithCode', --# display results and code history in a vertical split
        -- "NvimNotify",              --# display with the nvim-notify plugin
        -- "Api"                      --# return output to a programming interface
      },
    },
  },
}

if vim.g.advanced_plugins > 0 then
  for _, item in ipairs(advanced) do
    table.insert(M, item)
  end
end
return M
