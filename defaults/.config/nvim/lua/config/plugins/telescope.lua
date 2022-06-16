local utl = require('utils.utils')
local Path = require('plenary.path')

local M = {}

local function project_bufenter_event()
  local pr_ok, pr = pcall(require, "project_nvim.project")
  if not pr_ok then
    vim.api.nvim_err_writeln("project_nvim not available")
    return
  end
  local root, _ = pr.get_project_root()
  if root == "" or root == nil then
    return
  end
  vim.cmd('lcd '.. root)
end

function M:config_project()
  require("project_nvim").setup {
    -- Manual mode doesn't automatically change your root directory, so you have
    -- the option to manually do so using `:ProjectRoot` command.
    manual_mode = true,

    -- Methods of detecting the root directory. **"lsp"** uses the native neovim
    -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
    -- order matters: if one is not detected, the other is used as fallback. You
    -- can also delete or rearangne the detection methods.
    detection_methods = { "lsp", "pattern" },

    -- All the patterns used to detect root dir, when **"pattern"** is in
    -- detection_methods
    patterns = {
      ".git",
      "_darcs",
      ".hg",
      ".bzr",
      ".svn",
      "Makefile",
      ".vs",
      "*.sln",
      "package.json"
    },

    -- Table of lsp clients to ignore by name
    -- eg: { "efm", ... }
    ignore_lsp = {"null-ls"},

    -- Don't calculate root dir on specific directories
    -- Ex: { "~/.cargo/*", ... }
    exclude_dirs = {},

    -- Show hidden files in telescope
    show_hidden = true,

    -- When set to false, you will get a message when project.nvim changes your
    -- directory.
    silent_chdir = true,

    -- Path where project.nvim will store the project history for use in
    -- telescope
    datapath = vim.fn.stdpath('data'),
  }

  local ts = require("telescope")
  ts.load_extension('projects')

  local opts = {silent = true, desc = 'projects'}
  vim.keymap.set('n', "<leader>fp", ts.extensions.projects.projects, opts)

  vim.api.nvim_create_autocmd("BufEnter", {
    callback = project_bufenter_event,
    pattern = "*",
    desc = "My ProjectRoot",
  })
end

function M.set_lsp_mappings(bufnr)
  local wk = require("which-key")
  local ts = require("telescope.builtin")
  local opts = {prefix = '<localleader>l', buffer = bufnr}
  local mappings = {
    name = 'telescope',
    c = {ts.lsp_code_actions, 'tele_code_actions'},
    R = {ts.lsp_references, 'tele_references'},
    d = {ts.lsp_definitions, 'tele_definitions'},
    i = {ts.lsp_implementations, 'tele_implementations'},
    s = {ts.lsp_document_symbols, 'tele_document_symbols'},
    a = {ts.lsp_code_actions, 'tele_code_actions'},
    W = {ts.lsp_workspace_symbols, 'tele_workspace_symbols'}
  }
  wk.register(mappings, opts)

  -- Override default mappings with telescope lsp intelligent analougous
  opts.prefix = "<localleader>"
  mappings = {
    D = {function()
      vim.cmd[[vsplit]]
      ts.lsp_definitions()
    end, 'tele_lsp_definition_split'},
    d = {ts.lsp_definitions, 'tele_lsp_definition'},
    u = {ts.lsp_references, 'tele_lsp_references'},
    U = {function()
      vim.cmd[[vsplit]]
      ts.lsp_references()
    end, 'tele_lsp_references_split'},
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

local fd_file_cmd = {
  "fd", "--type=file", "--color=never", "--hidden", "--follow", utl.rg_ignore_file
}
local fd_folder_cmd = {
  "fd", "--type=directory", "--color=never", "--hidden", "--follow", utl.rg_ignore_file
}
local rg_file_cmd = {
  "rg", "--color=never", "--hidden", "--files", "--follow", utl.rg_ignore_file,
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
}
local rg_grep_cmd = {
  "--color=never", "--hidden", "--smart-case", "--follow", utl.rg_ignore_file,
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
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

function M:set_mappings()
  local opts = {silent = true, desc = 'telescope_fuzzy_command_search'}
  vim.keymap.set('c', '<c-v>', '<Plug>(TelescopeFuzzyCommandSearch)', opts)

  local wk = require("which-key")
  local ts = require("telescope.builtin")
  local leader = {}
  local leader_p = [[<leader>]]

  wk.register {
    ["Q"] = {function() ts.quickfix{ignore_filename = false} end, "quickfix"},
    ["U"] = {function() ts.loclist{ignore_filename = false} end, "loclist"},
    -- Map <s-;> to commands history
    [':'] = {function() ts.command_history{layout_config = cust_layout_config} end, 'command_history'},
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

  local lua_plugins = Path:new(vim.fn.stdpath('data')):joinpath(
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
  --[[ leader['/'] = {
    function()
      local input = vim.fn.input("Enter regex for telescope.grep_string: ")
      if input == nil or input == "" then
        return
      end
      ts.grep_string {
        search = input,
        use_regex = true,
        additional_args = rg_grep_cmd
      }
    end, 'live_grep'
  } ]]
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
    r = {ts.registers, 'registers'},
    R = {ts.treesitter, 'treesitter'},
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

function M:setup()
  self:set_mappings()
  local actions = require('telescope.actions')
  local actions_generate = require('telescope.actions.generate')
  local actions_layout = require('telescope.actions.layout')

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
      preview = {
        hide_on_startup = true,
      },
      mappings = {
        i = {
          ["<c-j>"] = actions.move_selection_next,
          ["<c-k>"] = actions.move_selection_previous,
          ["<esc>"] = actions.close,
          ["<c-c>"] = actions.close,
          ["<c-q>"] = actions.smart_send_to_qflist,
          -- Mapping enter breaks other modes, such as commands, select, etc...
          -- ["<CR>"] = actions.file_edit,
          -- ["<c-m>"] = actions.file_edit,
          ["<C-s>"] = actions.file_split,
          ["<C-u>"] = actions.results_scrolling_up,
          ["<C-d>"] = actions.results_scrolling_down,
          ["<C-v>"] = actions.file_vsplit,
          ["<C-t>"] = actions.file_tab,
          ["<C-p>"] = actions_layout.toggle_preview,
          ["?"] = actions_generate.which_key {
            name_width = 20, -- typically leads to smaller floats
            max_height = 0.5, -- increase potential maximum height
            seperator = " > ", -- change sep between mode, keybind, and name
            close_with_action = false, -- do not close float on action
          },
        },
        n = {
          ["<esc>"] = actions.close,
          ["<c-c>"] = actions.close,
          ["q"] = actions.close,
          -- ["<CR>"] = actions.file_edit,
          -- ["<c-m>"] = actions.file_edit,
          ["?"] = actions_generate.which_key {
            name_width = 20, -- typically leads to smaller floats
            max_height = 0.5, -- increase potential maximum height
            seperator = " > ", -- change sep between mode, keybind, and name
            close_with_action = true, -- do not close float on action
          },
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

  local ts = require("telescope")
  ts.setup(config)
  self:config_project()
  ts.load_extension("ui-select")
end

return M
