return {
  'sindrets/diffview.nvim',
  keys = {
    {
      '<leader>vc',
      '<cmd>DiffviewFileHistory %<cr>',
      mode = { 'n' },
      desc = 'diffview_file_history',
    },
  },
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  config = function()
    local opts = {
      diff_binaries = false, -- Show diffs for binaries
      use_icons = false, -- Requires nvim-web-devicons
      icons = {
        folder_closed = '',
        folder_open = '',
      },
      signs = { fold_closed = '>', fold_open = '' },
      enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
      merge_tool = {
        -- Config for conflicted files in diff views during a merge or rebase.
        layout = 'diff3_mixed',
        disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
      },
    }

    require('diffview').setup(opts)
  end,
}
