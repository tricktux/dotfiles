local tl = require('plugin.telescope')
local utl = require('utils.utils')
local vks = vim.keymap.set
local map = require('mappings')
local log = require('utils.log')

local M = {}
M.leader_key = 'j'

-- Add this function before your dashboard config
local function telescope_sessions()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local sessions_path = vim.g.sessions_path
    or vim.fn.stdpath('data') .. '/sessions'

  if vim.fn.isdirectory(sessions_path) == 0 then
    vim.notify(
      'Sessions directory not found: ' .. sessions_path,
      vim.log.levels.WARN
    )
    return
  end

  local session_files = vim.fn.glob(sessions_path .. '/*', false, true)

  if #session_files == 0 then
    vim.notify(
      'No session files found in: ' .. sessions_path,
      vim.log.levels.INFO
    )
    return
  end

  -- Sort by modification time (newest first)
  table.sort(session_files, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)

  -- Create entries with session name and modification time
  local entries = {}
  for _, file in ipairs(session_files) do
    local name = vim.fn.fnamemodify(file, ':t:r')
    local mtime = os.date('%Y-%m-%d %H:%M', vim.fn.getftime(file))
    table.insert(entries, {
      display = name .. ' (' .. mtime .. ')',
      value = file,
      ordinal = name,
    })
  end

  pickers
    .new({}, {
      prompt_title = 'Sessions',
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          return {
            display = entry.display,
            value = entry.value,
            ordinal = entry.ordinal,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            vim.cmd('source ' .. vim.fn.fnameescape(selection.value))
            vim.notify(
              'Loaded session: ' .. vim.fn.fnamemodify(selection.value, ':t:r')
            )
          end
        end)
        return true
      end,
    })
    :find()
end

function M:set_mappings()
  local ts = require('telescope.builtin')
  local leader = {}
  local opts = { silent = true, desc = 'telescope' }
  vks('n', '<leader>J', '<cmd>Telescope<cr>', opts)

  opts.desc = 'buffer_browser'
  vks('n', '<plug>buffer_browser', function()
    ts.buffers(tl.cust_buff_opts())
  end, opts)
  local git = {}
  git.prefix = '<leader>' .. M.leader_key .. 'g'
  git.mappings = {
    f = { ts.git_files, 'files' },
    C = { ts.git_commits, 'commits' },
    c = { ts.git_bcommits, 'commits_current_buffer' },
    r = { ts.git_bcommits_range, 'commits_current_buffer_range' },
    b = { ts.git_branches, 'branches' },
    s = { ts.git_status, 'status' },
    S = { ts.git_stash, 'stash' },
  }

  map:keymaps_sets(git)
  git.prefix = map.vcs.prefix .. 't'
  map:keymaps_sets(git)

  leader.prefix = '<leader>' .. M.leader_key
  leader.mappings = {
    b = { ts.buffers, 'buffers' },
    f = { ts.oldfiles, 'oldfiles' },
    o = { ts.vim_options, 'vim_options' },
    O = { ts.colorscheme, 'colorscheme' },
    l = { ts.current_buffer_fuzzy_find, 'lines_current_buffer' },
    T = { ts.tags, 'tags_all_buffers' },
    r = { ts.registers, 'registers' },
    R = { ts.treesitter, 'treesitter' },
    e = { ts.resume, 'resume_picker' },
    [';'] = { ts.command_history, 'command_history' },
    ['/'] = { ts.search_history, 'search_history' },
    F = { ts.find_files, 'files' }, -- Use c-p
    h = { ts.help_tags, 'helptags' },
    y = { ts.filetypes, 'filetypes' },
    a = { ts.autocommands, 'autocommands' },
    s = { '<cmd>TelescopeSessions<cr>', 'sessions' },
    m = { ts.keymaps, 'keymaps' },
    M = { ts.man_pages, 'man_pages' },
    c = { ts.commands, 'commands' },
    q = { ts.quickfix, 'quickfix' },
    u = { ts.loclist, 'locationlist' },
    d = { ts.reloader, 'reload_lua_modules' },
  }

  vks('n', '<leader>sl', '<cmd>TelescopeSessions<cr>', opts)
  map:keymaps_sets(leader)
end

function M:setup()
  local ts = require('telescope')
  local actions = require('telescope.actions')
  local actions_generate = require('telescope.actions.generate')
  local actions_layout = require('telescope.actions.layout')

  local config = {
    defaults = {
      vimgrep_arguments = utl.rg.grep_cmd,
      pickers = {
        git_files = { recurse_submodules = true },
        find_files = { hidden = true },
      },
      sorting_strategy = 'ascending',
      scroll_strategy = 'limit',
      layout_strategy = 'flex',
      winblend = 5,
      layout_config = {
        prompt_position = 'top',
        horizontal = { preview_width = 0.5 },
        vertical = { preview_height = 0.5 },
      },
      preview = false,
      mappings = {
        i = {
          ['<C-n>'] = actions.cycle_history_next,
          ['<C-p>'] = actions.cycle_history_prev,
          ['<c-j>'] = actions.move_selection_next,
          ['<c-k>'] = actions.move_selection_previous,
          ['<esc>'] = actions.close,
          ['<c-c>'] = actions.close,
          ['<c-b>'] = actions.delete_buffer,
          ['<c-q>'] = function(bufnr)
            actions.smart_send_to_qflist(bufnr)
            actions.open_qflist(bufnr)
          end,
          -- Mapping enter breaks other modes, such as commands, select, etc...
          -- ["<CR>"] = actions.file_edit,
          -- ["<c-m>"] = actions.file_edit,
          ['<C-s>'] = actions.file_split,
          ['<C-u>'] = actions.results_scrolling_up,
          ['<C-d>'] = actions.results_scrolling_down,
          ['<C-h>'] = actions.preview_scrolling_up,
          ['<C-l>'] = actions.preview_scrolling_down,
          ['<C-v>'] = actions.file_vsplit,
          ['<C-t>'] = actions.file_tab,
          ['<C-e>'] = actions_layout.toggle_preview,
          ['?'] = actions_generate.which_key({
            name_width = 20, -- typically leads to smaller floats
            max_height = 0.5, -- increase potential maximum height
            seperator = ' > ', -- change sep between mode, keybind, and name
            close_with_action = true, -- do not close float on action
          }),
        },
        n = {
          ['<c-c>'] = actions.close,
          ['q'] = actions.close,
          -- ["<CR>"] = actions.file_edit,
          -- ["<c-m>"] = actions.file_edit,
          ['?'] = actions_generate.which_key({
            name_width = 30, -- typically leads to smaller floats
            max_height = 0.5, -- increase potential maximum height
            seperator = ' > ', -- change sep between mode, keybind, and name
            close_with_action = true, -- do not close float on action
          }),
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      frecency = {
        -- db_root = "home/my_username/path/to/db_root",
        show_scores = true,
        show_unindexed = true,
        ignore_patterns = { '*.git/*', '*/tmp/*' },
        disable_devicons = vim.g.advanced_plugins > 0 and false or true,
        workspaces = {
          ['conf'] = '$USER/.config',
          -- ["data"] = "$USER/.local/share",
          ['project'] = '$USER/Documents',
          ['wiki'] = '$USER/Documents/wiki',
        },
      },
    },
  }

  ts.setup(config)
  self:set_mappings()
  log.info('[telescope]: called set_mappings')
end

local set_telescope_colors = function()
  local catp_ok, catp = pcall(require, 'catppuccin.palettes')
  if not catp_ok then
    vim.notify('telescope: catp colors not available', vim.log.levels.ERROR)
    return
  end
  local colors = catp.get_palette()
  local TelescopeColor = {
    TelescopeMatching = { fg = colors.flamingo },
    TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

    TelescopePromptPrefix = { bg = colors.surface0 },
    TelescopePromptNormal = { bg = colors.surface0 },
    TelescopeResultsNormal = { bg = colors.mantle },
    TelescopePreviewNormal = { bg = colors.mantle },
    TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
    TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
    TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
    TelescopePromptTitle = { bg = colors.red, fg = colors.mantle },
    TelescopeResultsTitle = { fg = colors.mantle },
    TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
  }

  for hl, col in pairs(TelescopeColor) do
    vim.api.nvim_set_hl(0, hl, col)
  end
end

return {
  {
    'nvim-lua/telescope.nvim',
    event = 'VeryLazy',
    config = function()
      -- Create the user command
      vim.api.nvim_create_user_command(
        'TelescopeSessions',
        telescope_sessions,
        {}
      )

      M:setup()

      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = set_telescope_colors,
        desc = 'Set telescope colors for catppuccin',
      })
      set_telescope_colors()
    end,
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
  },
}
