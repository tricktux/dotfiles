local utl = require('utils.utils')

local M = {}

function M.set_lsp_mappings(bufnr)
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('telescope.lua: which-key module not available')
    return
  end

  local wk = require("which-key")
  local ts = require("telescope.builtin")
  local opts = {prefix = '<localleader>lt', buffer = bufnr}
  local mappings = {
    name = 'telescope',
    c = {ts.lsp_code_actions, 'code_actions'},
    r = {ts.lsp_references, 'references'},
    d = {ts.lsp_definitions, 'definitions'},
    i = {ts.lsp_implementations, 'implementations'},
    s = {ts.lsp_document_symbols, 'document_symbols'},
    a = {ts.lsp_code_actions, 'code_actions'},
    w = {ts.lsp_workspace_symbols, 'workspace_symbols'}
  }
  wk.register(mappings, opts)
end

local function set_mappings()
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('telescope.lua: which-key module not available')
    return
  end

  local wk = require("which-key")
  local ts = require("telescope.builtin")
  local leader = {}
  local leader_p = [[<leader>]]

  wk.register {"<plug>mru_browser", require('telescope.builtin').oldfiles}

  local git = {
    name = 'git',
    f = {ts.git_files, 'files'},
    C = {ts.git_commits, 'commits'},
    c = {ts.git_bcommits, 'commits_current_buffer'},
    b = {ts.git_branches, 'branches'},
    s = {ts.git_status, 'status'},
    S = {ts.git_stash, 'stash'}
  }
  leader['?'] = {ts.live_grep, 'live_grep'}
  leader[':'] = {ts.commands, 'commands'}
  leader.f = {
    name = 'fuzzers',
    g = git,
    b = {ts.buffers, 'buffers'},
    f = {ts.find_files, 'files'},
    o = {ts.vim_options, 'vim_options'},
    O = {ts.colorscheme, 'colorscheme'},
    L = {ts.current_buffer_fuzzy_find, 'lines_current_buffer'},
    t = {ts.current_buffer_tags, 'tags_curr_buffer'},
    T = {ts.tags, 'tags_all_buffers'},
    s = {ts.tagstack, 'tags_stack'},
    r = {ts.treesitter, 'treesitter'},
    [';'] = {ts.command_history, 'command_history'},
    ['/'] = {ts.search_history, 'search_history'},
    F = {ts.oldfiles, 'oldfiles'},
    h = {ts.help_tags, 'helptags'},
    y = {ts.filetypes, 'filetypes'},
    a = {ts.autocommands, 'autocommands'},
    m = {ts.keymaps, 'keymaps'},
    M = {ts.man_pages, 'man_pages'},
    c = {ts.commands, 'commands'},
    q = {ts.quickfix, 'quickfix'},
    l = {ts.loclist, 'locationlist'},
    d = {ts.reloader, 'reload_lua_modules'}
  }
  wk.register(leader, {prefix = leader_p})
end

function M.setup()
  if not utl.is_mod_available('telescope') then
    vim.api.nvim_err_writeln('telescope module not available')
    return
  end

  set_mappings()
  local actions = require('telescope.actions')

  local config = {
    defaults = {
      -- Picker Configuration
      -- border = {},
      -- borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
      -- preview_cutoff = (utl.has_unix() and 120 or 9999),
      -- selection_strategy = "reset",

      -- Can choose EITHER one of these: horizontal, vertical, center
      -- layout_strategy = "horizontal",
      -- horizontal_config = {
      -- get_preview_width = function(columns, _)
      -- return math.floor(columns * 0.5)
      -- end,
      -- },

      -- get_window_options = function(...) end,
      -- To move to bottom, use strategy descending
      pickers = {
        git_files = {recurse_submodules = true},
        find_files = {hidden = true},
        buffers = {
          show_all_buffers = true,
          sort_lastused = true,
          theme = "dropdown",
          previewer = true,
          mappings = {
            i = {["<c-d>"] = actions.delete_buffer},
            n = {["<c-d>"] = actions.delete_buffer}
          }
        }
      },
      sorting_strategy = "ascending",
      layout_strategy = "flex",
      winblend = 5,
      layout_config = {
        prompt_position = "top",
        horizontal = {preview_width = 0.6},
        vertical = {preview_height = 0.5}
      },

      mappings = {
        i = {
          ["<c-j>"] = actions.move_selection_next,
          ["<c-k>"] = actions.move_selection_previous,
          ["<esc>"] = actions.close,
          ["<c-c>"] = actions.close,
          ["<c-q>"] = actions.close,
          ["<CR>"] = actions.file_edit,
          ["<c-m>"] = actions.file_edit,
          ["<C-s>"] = actions.file_split,
          ["<C-e>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          ["<C-v>"] = actions.file_vsplit,
          ["<C-t>"] = actions.file_tab
        },

        n = {
          ["<esc>"] = actions.close,
          ["<c-c>"] = actions.close,
          ["q"] = actions.close,
          ["<CR>"] = actions.file_edit,
          ["<c-m>"] = actions.file_edit
        }
      }
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case" -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      }
    }
  }
  require('telescope').setup(config)
  -- To get fzf loaded and working with telescope, you need to call
  -- load_extension, somewhere after setup function:
  require('telescope').load_extension('fzf')
end

return M
