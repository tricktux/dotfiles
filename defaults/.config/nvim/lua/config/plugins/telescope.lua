local utl = require('utils.utils')
local Path = require('plenary.path')

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

local cust_path_display = function(opts, path)
  if utl.has_win() then path = path:gsub("/", "\\") end -- normalize paths
  local tail = require("telescope.utils").path_tail(path)
  return string.format("%-35s %s", tail, path)
end

local cust_layout_config = {height = 0.5, width = 0.6}

local cust_buff_opts = {
  show_all_buffers = true,
  only_cwd = false,
  sort_mru = true,
  sort_lastused = true,
  previewer = false,
  path_display = cust_path_display,
  layout_config = cust_layout_config,
  mappings = {
    i = {["<c-d>"] = require('telescope.actions').delete_buffer},
    n = {["<c-d>"] = require('telescope.actions').delete_buffer}
  }
}

local cust_files_opts = {
  previewer = false,
  layout_config = cust_layout_config,
  path_display = cust_path_display
}

local win_file = Path:new(os.getenv("LOCALAPPDATA")):joinpath([[\ignore-file]])
local win_ignore_file = [[--ignore-file=]] .. win_file:absolute()
-- TODO: For now env var ignore file is not working
local nix_ignore_file = [[--ignore-file=]] .. os.getenv("HOME") ..
                            [[/.config/ignore-file]]
local ignore_file = utl.has_win() and win_ignore_file or nix_ignore_file

local fd_file_cmd = {
  "fd", "--type=file", "--color=never", "--hidden", "--follow", ignore_file
}
local fd_folder_cmd = {
  "fd", "--type=directory", "--color=never", "--hidden", "--follow", ignore_file
}
local rg_file_cmd = {
  "rg", "--color=never", "--hidden", "--files", "--follow", ignore_file
}
local rg_grep_cmd = {
  "--color=never", "--hidden", "--fixed-strings", "--smart-case", "--follow",
  ignore_file
}

local function ff(path)
  vim.validate {path = {path, 's'}}

  if utl.has_win() then path = path:gsub("/", "\\") end -- normalize paths
  local ppath = Path:new(path)
  if not ppath:is_dir() then
    vim.api.nvim_err_writeln('telescope.lua: path not found: ' ..
                                 ppath:absolute())
    return
  end
  local opts = cust_files_opts
  local spath = ppath:absolute()
  opts['prompt_title'] = 'Files in "' .. spath .. '"...'
  opts['cwd'] = spath
  opts['find_command'] = fd_file_cmd
  require("telescope.builtin").find_files(opts)
end

local function set_mappings()
  if not utl.is_mod_available('which-key') then
    vim.api.nvim_err_writeln('telescope.lua: which-key module not available')
    return
  end

  vim.cmd[[cmap <c-v> <Plug>(TelescopeFuzzyCommandSearch)]]

  local wk = require("which-key")
  local ts = require("telescope.builtin")
  local leader = {}
  local leader_p = [[<leader>]]

  wk.register {
    ["<plug>buffer_browser"] = {
      function() ts.buffers(cust_buff_opts) end, "buffers"
    },
    ["<plug>mru_browser"] = {function() ff(vim.fn.getcwd()) end, "oldfiles"}
  }

  local function ff_dotfiles()
    local dotfiles = nil
    if utl.has_unix() then
      dotfiles = Path:new(vim.g.dotfiles)
    else
      dotfiles = Path:new(os.getenv("APPDATA")):joinpath([[dotfiles]])
    end
    return ff(dotfiles:absolute())
  end

  local lua_plugins = Path:new(vim.g.std_data_path):joinpath(
                          [[site/pack/packer]]):absolute()

  leader.e = {
    name = "edit",
    d = {ff_dotfiles, 'dotfiles'},
    h = {function() ff(os.getenv('HOME')) end, 'home'},
    c = {function() ff(vim.fn.getcwd()) end, 'current_dir'},
    p = {function() ff(lua_plugins) end, 'lua_plugins_path'},
    l = {function() ff(vim.g.vim_plugins_path) end, 'vim_plugins_path'},
    v = {function() ff(os.getenv('VIMRUNTIME')) end, 'vimruntime'}
  }

  local git = {
    name = 'git',
    f = {ts.git_files, 'files'},
    C = {ts.git_commits, 'commits'},
    c = {ts.git_bcommits, 'commits_current_buffer'},
    b = {ts.git_branches, 'branches'},
    s = {ts.git_status, 'status'},
    S = {ts.git_stash, 'stash'}
  }
  leader['?'] = {
    function() ts.live_grep {additional_args = rg_grep_cmd} end, 'live_grep'
  }
  leader[';'] = {function() ts.commands{layout_config = cust_layout_config} end, 'commands'}
  leader[':'] = {function() ts.command_history{layout_config = cust_layout_config} end, 'command_history'}
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
      pickers = {
        git_files = {recurse_submodules = true},
        find_files = {hidden = true}
      },
      sorting_strategy = "ascending",
      layout_strategy = "flex",
      winblend = 5,
      layout_config = {
        prompt_position = "top",
        horizontal = {preview_width = 0.5},
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
      },
      frecency = {
        -- db_root = "home/my_username/path/to/db_root",
        show_scores = true,
        show_unindexed = true,
        ignore_patterns = {"*.git/*", "*/tmp/*"},
        disable_devicons = true,
        workspaces = {
          ["conf"] = "$USER/.config",
          -- ["data"] = "$USER/.local/share",
          ["project"] = "$USER/Documents",
          ["wiki"] = "$USER/Documents/wiki"
        }
      }
    }
  }
  require('telescope').setup(config)
  -- To get fzf loaded and working with telescope, you need to call
  -- load_extension, somewhere after setup function:
  -- require('telescope').load_extension('fzf')
end

return M
