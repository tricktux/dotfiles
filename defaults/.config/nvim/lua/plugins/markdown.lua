local fs = require('utils.utils').fs
local w = require('plugin.wiki')
local utl = require('utils.utils')
local log = require('utils.log')

local M = {}

M.opts = {
  legacy_commands = false,
  workspaces = {},
  templates = {
    folder = 'templates',
    date_format = '%Y-%m-%d',
    time_format = '%H:%M',
    -- A map for custom variables, the key should be the variable and the value a function
    substitutions = {
      -- Link to the last daily note (for daily.md template)
      last_daily = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local dailies_path = vim.fs.joinpath(Obsidian.dir.filename, 'dailies')
        local last_date = obsidian_utils.find_last_daily_note(dailies_path)
        if last_date then
          return vim.fs.joinpath('dailies', last_date .. '.md')
        else
          return ''
        end
      end,

      todays_daily = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local dailies_path = vim.fs.joinpath(Obsidian.dir.filename, 'dailies')
        local last_date =
            obsidian_utils.find_last_daily_note(dailies_path, true)
        if last_date then
          return vim.fs.joinpath('dailies', last_date .. '.md')
        else
          return ''
        end
      end,

      -- Link to the last project daily note (for project-daily.md template)
      last_project_daily = function(ctx)
        local obsidian_utils = require('plugin.obsidian')

        local project_name = obsidian_utils.get_project_name_from_context(ctx)
        if not project_name then
          return ''
        end

        local project_path =
            vim.fs.joinpath(Obsidian.dir.filename, 'projects', project_name)
        local last_date = obsidian_utils.find_last_daily_note(project_path)
        if last_date then
          return vim.fs.joinpath('projects', project_name, last_date .. '.md')
        else
          return ''
        end
      end,

      -- Link to the project main note (for project-daily.md template)
      project_main = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local project_name = obsidian_utils.get_project_name_from_context(ctx)
        return vim.fs.joinpath('projects', project_name, project_name .. '.md')
      end,
    },
  },
  daily_notes = {
    folder = 'dailies',
    template = 'daily.md',
    -- weekly
    date_format = '%Y-%m-%d',
    alias_format = '%B, %Y %d',
  },
  ui = { enable = false },
}

return {
  {
    'HakonHarnes/img-clip.nvim',
    ft = { 'markdown', 'org', 'quarto', 'tex' },
    cmd = { 'PasteImage' },
    -- event = "BufEnter",
    opts = {
      default = {
        relative_to_current_file = true, -- make dir_path relative to current file rather than the cwd
        relative_template_path = false,  -- make file path in the template relative to current file rather than the cwd
        dir_path = 'assets',
      },
      quarto = {
        template = '![$CURSOR]($FILE_PATH)',
      },
    },
    keys = {
      {
        '<localleader>i',
        '<cmd>PasteImage<cr>',
        desc = 'Paste clipboard image',
      },
    },
  },
  {
    'obsidian-nvim/obsidian.nvim',
    enabled = w.path.personal ~= nil or w.path.work ~= nil,
    ft = { 'markdown', 'org', 'quarto', 'tex' },
    cmd = { 'Obsidian' },
    keys = {
      { '<leader>wj', '<cmd>Obsidian today<cr>', desc = 'obsidian_daily' },
      {
        '<leader>wh',
        '<cmd>Obsidian today -1<cr>',
        desc = 'obsidian_yesterday',
      },
      {
        '<leader>wl',
        '<cmd>Obsidian today +1<cr>',
        desc = 'obsidian_tomorrow',
      },
      {
        '<leader>wk',
        '<cmd>Obsidian quick_switch carry.md<cr>',
        desc = 'obsidian_todo_carry',
      },
      { '<leader>wa', '<cmd>Obsidian new<cr>',   desc = 'obsidian_new' },
      {
        '<leader>ww',
        '<cmd>Obsidian workspace<cr>',
        desc = 'obsidian_list_workspace',
      },
      { '<leader>ws', '<cmd>Obsidian search<cr>', desc = 'obsidian_search' },
      { '<leader>wo', '<cmd>Obsidian open<cr>',   desc = 'obsidian_open' },
      {
        '<leader>wf',
        function()
          fs.path.fuzzer(Obsidian.dir.filename)
        end,
        desc = 'obsidian_fuzzy',
      },
      {
        '<leader>wt',
        '<cmd>Obsidian tags<cr>',
        desc = 'obsidian_tags',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          vim.opt_local.conceallevel = 1
        end,
        pattern = { 'markdown', 'mkd' },
        desc = 'Set conceallevel for obsidian',
      })
      if w.path.work ~= nil then
        table.insert(M.opts.workspaces, { name = 'work', path = w.path.work })
      end
      if w.path.personal ~= nil then
        table.insert(
          M.opts.workspaces,
          { name = 'personal', path = w.path.personal }
        )
      end
      -- vim.print(vim.inspect(M.opts.workspaces))
      require('obsidian').setup(M.opts)
      require('plugin.obsidian').setup()
    end,
  },
}
