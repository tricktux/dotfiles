local utl = require('utils.utils')

local M = {}

function M:setup()
  if not utl.is_mod_available('orgmode') then
    vim.api.nvim_err_writeln("orgmode.nvim module not found")
    return
  end

  require('orgmode').setup {
    org_agenda_files = {vim.g.wiki_path .. [[/*]]},
    org_priority_lowest = 'D',
    org_todo_keywords = {
      'TODO', 'WAITING', 'BLOCKED', '|', 'DONE', 'WONT_DO', 'CANCELED'
    },
    org_default_notes_file = vim.g.wiki_path .. [[/notes.org]],
    mappings = {
      global = {org_agenda = '<leader>ma', org_capture = '<leader>mc'},
      org = {
        org_refile = '<localleader>r',
        org_increase_date = '<localleader>A',
        org_decrease_date = '<localleader>X',
        org_change_date = '<localleader>d',
        org_set_tags_command = '<localleader>t',
        org_toggle_archive_tag = '<localleader>a',
        org_todo = '<localleader>j',
        org_todo_prev = '<localleader>k',
        org_move_subtree_down = '<localleader>J',
        org_move_subtree_up = '<localleader>K',
        org_do_promote = '<localleader>h',
        org_do_demote = '<localleader>l',
        org_demote_subtree = '<localleader>L',
        org_promote_subtree = '<localleader>H',
        org_meta_return = '<localleader><cr>',
        org_open_at_point = '<localleader>f',
        org_toggle_checkbox = '<localleader>d',
      },
      capture = {
        org_capture_finalize = 'q',
        org_capture_refile = 'R',
        org_capture_kill = 'Q'
      },
      agenda = {
        org_agenda_later = '<localleader>l',
        org_agenda_earlier = '<localleader>e',
        org_agenda_goto_today = '<localleader>t',
        org_agenda_week_view = '<localleader>w',
        org_agenda_month_view = '<localleader>m',
        org_agenda_year_view = '<localleader>y',
        org_agenda_goto = '<localleader>f',
      }
    }
  }
end

return M
