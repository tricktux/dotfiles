-- Add these functions to your git.lua file, replacing the existing fugitive keymap
local map = require('mappings')

return {
  {
    'dlyongemallo/diffview.nvim',
    keys = {
      {
        map.vcs.prefix .. 'p',
        function()
          local base = vim.fn.input('Base branch: ', 'develop')
          if base ~= '' then
            vim.cmd('DiffviewOpen ' .. base .. '...HEAD --imply-local')
          end
        end,
        mode = { 'n' },
        desc = 'diffview: diff against base branch',
      },
      {
        map.vcs.prefix .. 'P',
        function()
          local base = vim.fn.input('Base branch: ', 'develop')
          if base ~= '' then
            vim.cmd('DiffviewFileHistory --range=' .. base .. '...HEAD --right-only --no-merges')
          end
        end,
        mode = { 'n' },
        desc = 'diffview: file history vs base branch',
      },
      {
        '<leader>vc',
        '<cmd>DiffviewFileHistory %<cr>',
        mode = { 'n' },
        desc = 'diffview: file history (current file)',
      },
    },
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    config = function()
      local opts = {
        diff_binaries = false,
        use_icons = false,
        icons = {
          folder_closed = '',
          folder_open = '',
        },
        signs = { fold_closed = '>', fold_open = '' },
        enhanced_diff_hl = true,
        merge_tool = {
          layout = 'diff3_mixed',
          disable_diagnostics = true,
        },
        default_args = {
          DiffviewOpen = { '--imply-local' },
        },
      }

      require('diffview').setup(opts)
    end,
  },
  'tpope/vim-fugitive',
  cmd = 'Git',
}
