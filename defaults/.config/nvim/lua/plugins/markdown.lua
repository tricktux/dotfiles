local fs = require('utils.utils').fs
local w = require('plugin.wiki')

local M = {}

M.opts = {
  workspaces = {},
  mappings = {},
  templates = {
    folder = 'templates',
    date_format = '%Y-%m-%d',
    time_format = '%H:%M',
    -- A map for custom variables, the key should be the variable and the value a function
    substitutions = {},
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
    'bngarren/checkmate.nvim',
    ft = 'markdown', -- Lazy loads for Markdown files matching patterns in 'files'
    opts = {
      files = { '*' },
      -- checkmate.Config
      todo_markers = {
        unchecked = "[ ]",
        checked = "[x]",
      },
    },
  },
  {
    'obsidian-nvim/obsidian.nvim',
    enabled = w.path.personal ~= nil or w.path.work ~= nil,
    ft = { 'markdown', 'org', 'quarto', 'tex' },
    cmd = { 'ObsidianToday' },
    keys = {
      { '<leader>wj', '<cmd>ObsidianToday<cr>',     desc = 'obsidian_daily' },
      { '<leader>wh', '<cmd>ObsidianYesterday<cr>', desc = 'obsidian_daily' },
      { '<leader>wl', '<cmd>ObsidianTomorrow<cr>',  desc = 'obsidian_daily' },
      {
        '<leader>wk',
        '<cmd>ObsidianQuickSwitch carry.md<cr>',
        desc = 'obsidian_todo_carry',
      },
      { '<leader>wa', '<cmd>ObsidianNew<cr>',    desc = 'obsidian_new' },
      {
        '<leader>ww',
        '<cmd>ObsidianWorkspace<cr>',
        desc = 'obsidian_list_workspace',
      },
      { '<leader>ws', '<cmd>ObsidianSearch<cr>', desc = 'obsidian_search' },
      { '<leader>wo', '<cmd>ObsidianOpen<cr>',   desc = 'obsidian_open' },
      {
        '<leader>wf',
        function()
          local c = require('obsidian').get_client()
          fs.path.fuzzer(c:vault_root().filename)
        end,
        desc = 'obsidian_fuzzy',
      },
      {
        '<leader>wt',
        function()
          local c = require('obsidian').get_client()
          -- TODO: set arguments
          print(vim.inspect(c:list_tags()))
        end,
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
