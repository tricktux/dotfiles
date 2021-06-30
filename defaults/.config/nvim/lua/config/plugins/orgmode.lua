local utl = require('utils.utils')

local M = {}

function M:setup()
  if not utl.is_mod_available('orgmode') then
    vim.api.nvim_err_writeln("orgmode.nvim module not found")
    return
  end

  require('orgmode').setup {
    org_agenda_files = {vim.g.wiki_path .. [[\*]]},
    org_priority_lowest = 'D',
    org_todo_keywords = {
      'TODO', 'WAITING', 'BLOCKED', '|', 'DONE', 'WONT_DO', 'CANCELED'
    },
    -- org_default_notes_file = '~/Dropbox/org/refile.org',
    mappings = {
      global = {org_agenda = '<leader>ma', org_capture = '<leader>mc'},
      agenda = {
        org_agenda_later = '<localleader>l',
        org_agenda_earlier = '<localleader>e',
        org_agenda_goto_today = '<localleader>t',
        org_agenda_week_view = '<localleader>w',
        org_agenda_month_view = '<localleader>m',
        org_agenda_year_view = '<localleader>y',
        org_agenda_goto = '<localleader>f'
      }
    }
  }
end

return M
