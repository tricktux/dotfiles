local w = require('plugin.wiki')

if vim.g.advanced_plugins == 0 then
  return {}
end

local function setup()
  local id = vim.api.nvim_create_augroup('Orgmode', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    callback = function()
      vim.opt_local.cursorline = true
    end,
    pattern = 'orgagenda',
    desc = 'Set cursor line',
    group = id,
  })
  local org = require('orgmode')
  org.setup_ts_grammar()

  local wb = w.path.personal or w.path.work
  local wo = w.path.org

  org.setup({
    org_agenda_files = { vim.fs.joinpath(wb, [[org/**/*.org]]) },
    org_todo_keywords = {
      'TODO',
      'IN_PROGRESS',
      'WAITING',
      'BLOCKED',
      '|',
      'DONE',
      'WONT_DO',
      'CANCELLED',
    },
    org_highlight_latex_and_related = 'entities',
    -- TODO: fix this
    org_capture_templates = {
      j = {
        description = 'Journal',
        template = '\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?',
        target = vim.fs.joinpath(wb, w.path.journal),
      },
      t = 'TODO',
      tw = {
        description = 'Work Task',
        template = '* TODO %?\n SCHEDULED: %t',
        target = '~/core/org-mode/work.org',
      },
      sw = {
        description = 'Study Task',
        template = '* TODO %?\n SCHEDULED: %t',
        target = '~/core/org-mode/study.org',
      },
    },
    org_default_notes_file = vim.fs.joinpath(wb, wo.main),
    mappings = {
      global = { org_agenda = '<leader>ma', org_capture = '<leader>mc' },
      org = {
        org_refile = '<localleader>r',
        org_timestamp_up = '<localleader>A',
        org_timestamp_down = '<localleader>X',
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
        org_capture_kill = 'Q',
      },
      agenda = {
        org_agenda_later = '<localleader>l',
        org_agenda_earlier = '<localleader>e',
        org_agenda_goto_today = '<localleader>t',
        org_agenda_week_view = '<localleader>w',
        org_agenda_month_view = '<localleader>m',
        org_agenda_year_view = '<localleader>y',
        org_agenda_goto = '<cr>',
        org_agenda_switch_to = '<localleader>f',
      },
    },
  })
end

return {
  'kristijanhusak/orgmode.nvim',
  ft = 'org',
  config = setup,
}
