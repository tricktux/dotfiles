local fs = require('utils.utils').fs
local w = require('plugin.wiki')
local utl = require('utils.utils')
local log = require('utils.log')

local M = {}

M.opts = {
  legacy_commands = false,
  workspaces = {},
  footer = { enabled = false },
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
        if last_date and last_date ~= '' then
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
        if last_date and last_date ~= '' then
          return vim.fs.joinpath('dailies', last_date .. '.md')
        else
          return ''
        end
      end,

      -- Link to the last project daily note (updated for nested projects)
      last_project_daily = function(ctx)
        local obsidian_utils = require('plugin.obsidian')

        local project_path = obsidian_utils.get_project_name_from_context(ctx)
        if not project_path or project_path == '' then
          return ''
        end

        local project_dir =
            vim.fs.joinpath(Obsidian.dir.filename, 'projects', project_path)
        local last_date = obsidian_utils.find_last_daily_note(project_dir)
        if last_date and last_date ~= '' then
          return vim.fs.joinpath('projects', project_path, last_date .. '.md')
        else
          return ''
        end
      end,

      -- Link to the project main note (updated for nested projects with verbose naming)
      project_main = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local project_path = obsidian_utils.get_project_name_from_context(ctx)
        if not project_path or project_path == '' then
          return ''
        end

        -- Use verbose naming for nested projects (e.g., "parent/child" -> "parent-child.md")
        local verbose_filename = project_path:gsub('/', '-') .. '.md'
        return vim.fs.joinpath('projects', project_path, verbose_filename)
      end,

      -- Link to parent project (useful for nested project templates)
      parent_project = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local project_path = obsidian_utils.get_project_name_from_context(ctx)
        if not project_path or project_path == '' then
          return ''
        end

        -- Extract parent path (e.g., "parent/child/grandchild" -> "parent/child")
        local parent_path = project_path:match('(.+)/[^/]+$')
        if parent_path then
          local verbose_filename = parent_path:gsub('/', '-') .. '.md'
          return vim.fs.joinpath('projects', parent_path, verbose_filename)
        else
          return '' -- No parent (top-level project)
        end
      end,

      -- Get all sibling projects (useful for project navigation)
      sibling_projects = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local project_path = obsidian_utils.get_project_name_from_context(ctx)
        if not project_path or project_path == '' then
          return ''
        end

        -- Use cross-platform path operations
        local parent_path = project_path:match('(.+)/[^/]+$')
        if not parent_path then
          return ''
        end

        local parent_dir =
            vim.fs.joinpath(Obsidian.dir.filename, 'projects', parent_path)
        local siblings = {}

        -- Check if directory exists before iterating
        if vim.fn.isdirectory(parent_dir) == 0 then
          return ''
        end

        for name, type in vim.fs.dir(parent_dir) do
          if type == 'directory' then
            local sibling_path = parent_path .. '/' .. name -- Keep internal representation as /
            local verbose_filename = sibling_path:gsub('/', '-') .. '.md'
            local sibling_file =
                vim.fs.joinpath(parent_dir, name, verbose_filename)

            if utl.isfile(sibling_file) then
              -- Use vim.fs.joinpath for cross-platform link generation
              local link_path =
                  vim.fs.joinpath('projects', sibling_path, verbose_filename)
              local sibling_link = '- [' .. name .. '](' .. link_path .. ')'
              table.insert(siblings, sibling_link)
            end
          end
        end

        if #siblings > 0 then
          return '\n  ' .. table.concat(siblings, '\n  ')
        else
          return ''
        end
      end,

      -- Get project hierarchy breadcrumbs
      project_breadcrumbs = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local project_path = obsidian_utils.get_project_name_from_context(ctx)
        if not project_path or project_path == '' then
          return ''
        end

        local parts = vim.split(project_path, '/')
        local breadcrumbs = {}
        local current_path = ''

        for i, part in ipairs(parts) do
          if i == 1 then
            current_path = part
          else
            current_path = vim.fs.joinpath(current_path, part)
          end

          local verbose_filename = current_path:gsub('/', '-') .. '.md'
          local link = '['
              .. part
              .. ']('
              .. vim.fs.joinpath('projects', current_path, verbose_filename)
              .. ')'
          table.insert(breadcrumbs, link)
        end

        return table.concat(breadcrumbs, ' → ')
      end,

      -- Get child projects (useful for parent project templates)
      child_projects = function(ctx)
        local obsidian_utils = require('plugin.obsidian')
        local project_path = obsidian_utils.get_project_name_from_context(ctx)
        if not project_path or project_path == '' then
          return ''
        end

        local project_dir =
            vim.fs.joinpath(Obsidian.dir.filename, 'projects', project_path)
        local children = {}

        -- Find all subdirectories that contain project files
        for name, type in vim.fs.dir(project_dir) do
          if type == 'directory' then
            local child_path = vim.fs.joinpath(project_path, name)
            local verbose_filename = child_path:gsub('/', '-') .. '.md'
            local child_file =
                vim.fs.joinpath(project_dir, name, verbose_filename)

            if utl.isfile(child_file) then
              local child_link = '- ['
                  .. name
                  .. ']('
                  .. vim.fs.joinpath('projects', child_path, verbose_filename)
                  .. ')'
              table.insert(children, child_link)
            end
          end
        end

        if #children > 0 then
          return '\n  ' .. table.concat(children, '\n  ')
        else
          return ''
        end
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
      { '<leader>wb', '<cmd>Obsidian backlinks<cr>', desc = 'obsidian_backlinks' },
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
