return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  config = function()
    local opts = {
      diff_binaries = false, -- Show diffs for binaries
      use_icons = false, -- Requires nvim-web-devicons
      enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
      signs = { fold_closed = '', fold_open = '' },
      merge_tool = {
        -- Config for conflicted files in diff views during a merge or rebase.
        layout = 'diff3_mixed',
        disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
      },
      file_panel = {
        win_config = {
          position = 'left', -- One of 'left', 'right', 'top', 'bottom'
          width = 25, -- Only applies when position is 'left' or 'right'
          height = 10, -- Only applies when position is 'top' or 'bottom'
        },
      },
      file_history_panel = {
        win_config = {
          position = 'bottom',
          width = 35,
          height = 16,
        },
        log_options = {
          single_file = {
            max_count = 512,
            follow = true,
          },
          multi_file = {
            max_count = 128,
          },
        },
      },
    }

    require('diffview').setup(opts)
  end,
}
