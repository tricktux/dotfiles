local utl = require("utils.utils")

local vks = vim.keymap.set
local map = require("mappings")
local vf = vim.fn
local fmt = string.format
local log = require("utils.log")

local M = {}
M.leader_key = "j"

local function grep_cword()
  local ts = require("telescope.builtin")
  local wd = vim.fn.getcwd()
  local s = vim.fn.expand("<cword>")
  ts.grep_string({
    prompt_title = "Grep for '" .. s .. "' in '" .. wd .. "'...",
  })
end

local function live_grep()
  local ts = require("telescope.builtin")
  ts.live_grep({
    prompt_title = "Live grep in '" .. vim.fn.getcwd() .. "'...",
  })
end

local live_grep_opts = {
  cwd = wd,
  glob_pattern = nil,
  type_filter = nil,
}

local live_grep_opts_input = {
  cwd = {
    opts = {
      prompt = "Change search directory: ",
      default = vf.getcwd(),
      completion = "dir",
    },
    on_confirm = function(input)
      if input == nil then
        return
      end

      local plok, pl = pcall(require, "plenary.path")
      if not plok then
        if vim.fn.isdir(vf.getcwd() .. input) == 1 then
          live_grep_opts.cwd = vf.getcwd() .. input
        end
        return
      end
      local p = pl:new(input)
      if not p:exists() then
        vim.notify("Invalid input path: '" .. p:absolute() .. "'", vim.log.levels.WARN)
        return
      end
      live_grep_opts.cwd = p:absolute()
    end,
  },
  glob_pattern = {
    opts = {
      prompt = "Change glob pattern 'i.e: !*.toml':",
    },
    on_confirm = function(input)
      if input == nil then
        return
      end

      live_grep_opts.glob_pattern = input
    end,
  },
  type_filter = {
    opts = {
      prompt = "Change type filter: ",
      default = vim.opt.filetype:get(),
    },
    on_confirm = function(input)
      if input == nil then
        return
      end

      live_grep_opts.type_filter = utl.rg.vim_to_rg_map[input] or input
    end,
  },
}

local function grep_cfilter_cword()
  local ts = require("telescope.builtin")
  local f = vim.opt.filetype:get()
  local fx = utl.rg.vim_to_rg_map[f] or f
  local s = vim.fn.expand("<cword>")
  local c = vf.getcwd()
  local p = fmt("Grep for '%s' with filter '%s' in '%s'", s, fx, c)
  local a = function(opts)
    return "--type=" .. fx
  end
  local o = {
    prompt_title = p,
    cwd = c,
    additional_args = a,
  }
  ts.grep_string(o)
end

local function grep_cglob_cword()
  local ts = require("telescope.builtin")
  local g = [[*.]] .. vim.fn.expand("%:e")
  local s = vim.fn.expand("<cword>")
  local c = vf.getcwd()
  local p = fmt("Grep for '%s' with glob '%s' in '%s'", s, g, c)
  local a = function(opts)
    return "--glob=" .. g
  end
  local o = {
    prompt_title = p,
    cwd = c,
    additional_args = a,
  }
  ts.grep_string(o)
end

local function live_grep_cfile_type_filter()
  local ts = require("telescope.builtin")
  local f = vim.opt.filetype:get()
  local fx = utl.rg.vim_to_rg_map[f] or f
  local c = vf.getcwd()
  local p = fmt("Live grep in '%s' for filter '%s'", c, fx)
  local o = {
    prompt_title = p,
    cwd = c,
    type_filter = fx,
  }
  -- print(vim.inspect(o))
  ts.live_grep(o)
end

local function live_grep_cfile_glob_pattern()
  local ts = require("telescope.builtin")
  local g = [[*.]] .. vim.fn.expand("%:e")
  local c = vf.getcwd()
  local p = fmt("Live grep in '%s' for glob '%s'", c, g)
  local o = {
    prompt_title = p,
    cwd = c,
    glob_pattern = g,
  }
  -- print(vim.inspect(o))
  ts.live_grep(o)
end

local function custom_live_grep()
  local ts = require("telescope.builtin")
  local wd = vim.fn.getcwd()
  local opts_names = { "cwd", "glob_pattern", "type_filter" }
  local live_grep_opts = {
    cwd = wd,
    glob_pattern = nil,
    type_filter = nil,
  }
  local function make_choice()
    local choice = nil
    vim.ui.select(opts_names, {
      prompt = "Would you like to modify an option?:",
      format_item = function(item)
        return "'" .. item .. "' = " .. (live_grep_opts[item] or "nil")
      end,
    }, function(selected)
      choice = selected
    end)

    return choice
  end

  local ret = ""
  while ret ~= nil do
    ret = make_choice()
    if ret == nil then
      break
    end
    vim.ui.input(live_grep_opts[ret].opts, live_grep_opts[ret].on_confirm)
  end

  live_grep_opts.prompt_title = "Live grep in '" .. live_grep_opts.cwd .. "'..."
  ts.live_grep(live_grep_opts)
end

function M:config_project()
  require("project_nvim").setup({
    -- Manual mode doesn't automatically change your root directory, so you have
    -- the option to manually do so using `:ProjectRoot` command.
    manual_mode = false,

    -- Methods of detecting the root directory. **"lsp"** uses the native neovim
    -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
    -- order matters: if one is not detected, the other is used as fallback. You
    -- can also delete or rearangne the detection methods.
    detection_methods = { "lsp", "pattern" },

    -- All the patterns used to detect root dir, when **"pattern"** is in
    -- detection_methods
    patterns = {
      ".git",
      ".svn",
      ".vs",
      "*.sln",
      "Makefile",
      "_darcs",
      ".hg",
      "notes.org",
      ".bzr",
      "package.json",
      "[Cc]argo.toml",
      "wiki",
    },

    -- Table of lsp clients to ignore by name
    -- eg: { "efm", ... }
    ignore_lsp = { "null-ls" },

    -- Don't calculate root dir on specific directories
    -- Ex: { "~/.cargo/*", ... }
    exclude_dirs = {},

    -- Show hidden files in telescope
    show_hidden = true,

    -- When set to false, you will get a message when project.nvim changes your
    -- directory.
    silent_chdir = true,

    -- What scope to change the directory, valid options are
    -- * global (default)
    -- * tab
    -- * win
    scope_chdir = "win",

    -- Path where project.nvim will store the project history for use in
    -- telescope
    datapath = vim.fn.stdpath("data"),
  })

  local ts = require("telescope")
  ts.load_extension("projects")

  local opts = { silent = true, desc = "projects" }
  vim.keymap.set("n", "<leader>" .. M.leader_key .. "p", ts.extensions.projects.projects, opts)
end

function M.set_lsp_mappings(bufnr)
  local opts = { buffer = true, silent = true }
  local prefix = "<localleader>lt"
  local ts = require("telescope.builtin")
  local mappings = {
    r = { ts.lsp_references, "tele_references" },
    d = { ts.lsp_definitions, "tele_definitions" },
    i = { ts.lsp_implementations, "tele_implementations" },
    s = { ts.lsp_document_symbols, "tele_document_symbols" },
    w = { ts.lsp_workspace_symbols, "tele_workspace_symbols" },
  }

  map.keymaps_set(mappings, "n", opts, prefix)

  -- Override default mappings with telescope lsp intelligent analogous
  prefix = "<localleader>"
  mappings = {
    D = {
      function()
        vim.cmd([[vsplit]])
        ts.lsp_definitions()
      end,
      "tele_lsp_definition_split",
    },
    d = { ts.lsp_definitions, "tele_lsp_definition" },
    r = { ts.lsp_references, "tele_lsp_references" },
  }

  map.keymaps_set(mappings, "n", opts, prefix)
end

local cust_path_display = function(opts, path)
  if utl.has_win then
    path = path:gsub("/", "\\")
  end -- normalize paths
  local tail = require("telescope.utils").path_tail(path)
  return string.format("%-35s %s", tail, path)
end

local cust_layout_config = { height = 0.5, width = 0.6 }

local cust_buff_opts = function()
  return {
    show_all_buffers = true,
    only_cwd = false,
    sort_mru = true,
    sort_lastused = true,
    previewer = false,
    path_display = cust_path_display,
    layout_config = cust_layout_config,
  }
end

local cust_files_opts = {
  previewer = false,
  layout_config = cust_layout_config,
  path_display = cust_path_display,
}

M.toggletasks = {}
M.toggletasks.config = function()
  require("telescope").load_extension("toggletasks")
  require("toggletasks").setup({
    debug = false,
    silent = false,   -- don't show "info" messages
    short_paths = true, -- display relative paths when possible
    -- Paths (without extension) to task configuration files (relative to scanned directory)
    -- All supported extensions will be tested, e.g. '.toggletasks.json', '.toggletasks.yaml'
    search_paths = {
      "toggletasks",
      ".toggletasks",
      ".nvim/toggletasks",
    },
    -- Directories to consider when searching for available tasks for current window
    scan = {
      global_cwd = true,                -- vim.fn.getcwd(-1, -1)
      tab_cwd = true,                   -- vim.fn.getcwd(-1, tab)
      win_cwd = true,                   -- vim.fn.getcwd(win)
      lsp_root = true,                  -- root_dir for first LSP available for the buffer
      dirs = { vim.fn.stdpath("config") }, -- explicit list of directories to search or function(win): dirs
      rtp = false,                      -- scan directories in &runtimepath
      rtp_ftplugin = false,             -- scan in &rtp by filetype, e.g. ftplugin/c/toggletasks.json
    },
    tasks = {},                         -- list of global tasks or function(win): tasks
    -- this is basically the "Config format" defined using Lua tables
    -- Language server priorities when selecting lsp_root (default is 0)
    lsp_priorities = {
      ["null-ls"] = -10,
    },
    -- Defaults used when opening task's terminal (see Terminal:new() in toggleterm/terminal.lua)
    toggleterm = {
      close_on_exit = false,
      hidden = true,
    },
    -- Configuration of telescope pickers
    telescope = {
      spawn = {
        open_single = true, -- auto-open terminal window when spawning a single task
        show_running = false, -- include already running tasks in picker candidates
        -- Replaces default select_* actions to spawn task (and change toggleterm
        -- direction for select horiz/vert/tab)
        mappings = {
          select_float = "<C-f>",
          spawn_smart = "<C-a>", -- all if no entries selected, else use multi-select
          spawn_all = "<M-a>", -- all visible entries
          spawn_selected = nil, -- entries selected via multi-select (default <tab>)
        },
      },
      -- Replaces default select_* actions to open task terminal (and change toggleterm
      -- direction for select horiz/vert/tab)
      select = {
        mappings = {
          select_float = "<C-f>",
          open_smart = "<C-a>",
          open_all = "<M-a>",
          open_selected = nil,
          kill_smart = "<C-q>",
          kill_all = "<M-q>",
          kill_selected = nil,
          respawn_smart = "<C-s>",
          respawn_all = "<M-s>",
          respawn_selected = nil,
        },
      },
    },
  })
end

function M.find_files_sanitize(path)
  vim.validate({ path = { path, "s" } })
  local Path = require("plenary.path")

  local ppath = Path:new(path)
  if not ppath:is_dir() then
    vim.notify("telescope.lua: path not found: " .. ppath:absolute(), vim.log.levels.ERROR)
    return
  end
  local opts = cust_files_opts
  local spath = ppath:absolute()
  opts["prompt_title"] = 'Files in "' .. spath .. '"...'
  opts["cwd"] = spath
  opts["find_command"] = utl.fd.file_cmd
  return opts
end

function M.find_files_yank(_prompt_bufnr)
  local actions = require("telescope.actions")
  local p = require("telescope.actions.state").get_selected_entry().path
  -- put the selected entry in the clipboard register
  vim.fn.setreg("p", p)
  vim.fn.setreg("*", p)
  vim.fn.setreg("+", p)
  -- close search window
  actions.close(_prompt_bufnr)
  print("Path copied to clipboard: " .. p)
  -- Telescope runs async, in case you want to do something with special
  -- with this filename subscribe to this autocommand, value is in
  -- register p
  vim.cmd.doautocmd("User TelescopeFindFilesYankPost")
end

function M.file_fuzzer_yank(path)
  local opts = M.find_files_sanitize(path)

  opts["attach_mappings"] = function(_, map)
    map("i", "<cr>", M.find_files_yank)
    -- needs to return true if you want to map default_mappings and
    -- false if not
    return true
  end
  require("telescope.builtin").find_files(opts)
end

function M.file_fuzzer(path)
  local opts = M.find_files_sanitize(path)

  opts["attach_mappings"] = function(_, map)
    map("i", "<c-y>", M.find_files_yank)
    -- needs to return true if you want to map default_mappings and
    -- false if not
    return true
  end
  require("telescope.builtin").find_files(opts)
end

function M:set_mappings()
  local ts = require("telescope.builtin")
  local leader = {}
  local opts = { silent = true, desc = "telescope_fuzzy_command_search" }
  vks("c", "<c-v>", "<Plug>(TelescopeFuzzyCommandSearch)", opts)
  opts.desc = "telescope_command_history"
  vks("n", "<leader>;", ts.command_history, opts)
  opts.desc = "telescope"
  vks("n", "<leader>J", "<cmd>Telescope<cr>", opts)

  opts.desc = "buffer_browser"
  vks("n", "<plug>buffer_browser", function()
    ts.buffers(cust_buff_opts())
  end, opts)
  local git = {}
  git.prefix = "<leader>" .. M.leader_key .. "g"
  git.mappings = {
    f = { ts.git_files, "files" },
    C = { ts.git_commits, "commits" },
    c = { ts.git_bcommits, "commits_current_buffer" },
    r = { ts.git_bcommits_range, "commits_current_buffer_range" },
    b = { ts.git_branches, "branches" },
    s = { ts.git_status, "status" },
    S = { ts.git_stash, "stash" },
  }

  map:keymaps_sets(git)
  git.prefix = map.vcs.prefix .. "t"
  map:keymaps_sets(git)

  -- TODO: These should all probably <plug> type
  local search = { prefix = "<leader>" }
  search.mappings = {
    [">"] = { grep_cword, "grep_cword_all_files" },
    [","] = { grep_cfilter_cword, "grep_cfilter_cword" },
    ["."] = { ts.resume, "resume" },
    ["<"] = { grep_cglob_cword, "grep_cglob_cword" },
    ["sca"] = { grep_cword, "grep_cword_all_files" },
    ["saa"] = { live_grep, "live_grep_all_words_all_files" },
    ["sr"] = { ts.resume, "ts.resume" },
    ["su"] = { custom_live_grep, "custom_live_grep" },
    ["sag"] = { live_grep_cfile_glob_pattern, "live_grep_cfile_glob_pattern" },
    ["saf"] = { live_grep_cfile_type_filter, "live_grep_cfile_type_filter" },
    ["scf"] = { grep_cfilter_cword, "grep_cword_filter" },
    ["scg"] = { grep_cglob_cword, "grep_cword_cglob" },
  }

  map:keymaps_sets(search)

  leader.prefix = "<leader>" .. M.leader_key
  leader.mappings = {
    b = { ts.buffers, "buffers" },
    f = { ts.oldfiles, "oldfiles" },
    o = { ts.vim_options, "vim_options" },
    O = { ts.colorscheme, "colorscheme" },
    l = { ts.current_buffer_fuzzy_find, "lines_current_buffer" },
    T = { ts.tags, "tags_all_buffers" },
    r = { ts.registers, "registers" },
    R = { ts.treesitter, "treesitter" },
    e = { ts.resume, "resume_picker" },
    [";"] = { ts.command_history, "command_history" },
    ["/"] = { ts.search_history, "search_history" },
    F = { ts.find_files, "files" }, -- Use c-p
    h = { ts.help_tags, "helptags" },
    y = { ts.filetypes, "filetypes" },
    a = { ts.autocommands, "autocommands" },
    m = { ts.keymaps, "keymaps" },
    M = { ts.man_pages, "man_pages" },
    c = { ts.commands, "commands" },
    q = { ts.quickfix, "quickfix" },
    u = { ts.loclist, "locationlist" },
    d = { ts.reloader, "reload_lua_modules" },
  }

  map:keymaps_sets(leader)
end

function M:setup()
  local ts = require("telescope")
  local actions = require("telescope.actions")
  local actions_generate = require("telescope.actions.generate")
  local actions_layout = require("telescope.actions.layout")

  local config = {
    defaults = {
      vimgrep_arguments = utl.rg.grep_cmd,
      pickers = {
        git_files = { recurse_submodules = true },
        find_files = { hidden = true },
      },
      sorting_strategy = "ascending",
      layout_strategy = "flex",
      winblend = 5,
      layout_config = {
        prompt_position = "top",
        horizontal = { preview_width = 0.5 },
        vertical = { preview_height = 0.5 },
      },
      preview = {
        hide_on_startup = false,
      },
      mappings = {
        i = {
          ["<C-n>"] = actions.cycle_history_next,
          ["<C-p>"] = actions.cycle_history_prev,
          ["<c-j>"] = actions.move_selection_next,
          ["<c-k>"] = actions.move_selection_previous,
          ["<esc>"] = actions.close,
          ["<c-c>"] = actions.close,
          ["<c-b>"] = actions.delete_buffer,
          ["<c-q>"] = function(bufnr)
            actions.smart_send_to_qflist(bufnr)
            actions.open_qflist(bufnr)
          end,
          -- Mapping enter breaks other modes, such as commands, select, etc...
          -- ["<CR>"] = actions.file_edit,
          -- ["<c-m>"] = actions.file_edit,
          ["<C-s>"] = actions.file_split,
          ["<C-u>"] = actions.results_scrolling_up,
          ["<C-d>"] = actions.results_scrolling_down,
          ["<C-v>"] = actions.file_vsplit,
          ["<C-t>"] = actions.file_tab,
          ["<C-e>"] = actions_layout.toggle_preview,
          ["?"] = actions_generate.which_key({
            name_width = 20,    -- typically leads to smaller floats
            max_height = 0.5,   -- increase potential maximum height
            seperator = " > ",  -- change sep between mode, keybind, and name
            close_with_action = true, -- do not close float on action
          }),
        },
        n = {
          ["<c-c>"] = actions.close,
          ["q"] = actions.close,
          -- ["<CR>"] = actions.file_edit,
          -- ["<c-m>"] = actions.file_edit,
          ["?"] = actions_generate.which_key({
            name_width = 30,    -- typically leads to smaller floats
            max_height = 0.5,   -- increase potential maximum height
            seperator = " > ",  -- change sep between mode, keybind, and name
            close_with_action = true, -- do not close float on action
          }),
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,               -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case",   -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      frecency = {
        -- db_root = "home/my_username/path/to/db_root",
        show_scores = true,
        show_unindexed = true,
        ignore_patterns = { "*.git/*", "*/tmp/*" },
        disable_devicons = true,
        workspaces = {
          ["conf"] = "$USER/.config",
          -- ["data"] = "$USER/.local/share",
          ["project"] = "$USER/Documents",
          ["wiki"] = "$USER/Documents/wiki",
        },
      },
    },
  }

  ts.setup(config)
  self:set_mappings()
  log.info("[telescope]: called set_mappings")
end

return {
  {
    "nvim-lua/telescope.nvim",
    event = "VeryLazy",
    config = function()
      M:setup()
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" }
    },
  },
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      M:config_project()
    end,
    dependencies = {
      { "nvim-lua/telescope.nvim" }
    },
  },
  {
    "jedrzejboczar/toggletasks.nvim",
    keys = {
      {
        "<leader>" .. M.leader_key .. "k",
        [[<cmd>Telescope toggletasks select<cr>]],
        desc = "toggletasks"
      }
    },
    config = function()
      M.toggletasks.config()
    end,
    dependencies = {
      { "nvim-lua/telescope.nvim" }
    },
  },
  {
    "ThePrimeagen/git-worktree.nvim",
    keys = {
      {
        "<leader>vws",
        function()
          require("telescope").extensions.git_worktree.git_worktrees()
        end,
        desc = "git-worktree-switch",
      },
    },
    dependencies = {
      "nvim-lua/telescope.nvim",
    },
    config = function()
      require("git-worktree").setup()
      require("telescope").load_extension("git_worktree")
    end,
  },
  {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    -- Author's Note: If default keymappings fail to register (possible config issue in my local setup),
    -- verify lazy loading functionality. On failure, disable lazy load and report issue
    -- lazy = false,
    config = function()
      require("textcase").setup({})
      require("telescope").load_extension("textcase")
    end,
    keys = {
      { "<leader>rc", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "v" }, desc = "change_case" },
    },
  },
  -- Hooks for other plugins, will trigger warnings in Lazy.nvim
  set_lsp_mappings = M.set_lsp_mappings,
  file_fuzzer = M.file_fuzzer,
  file_fuzzer_yank = M.file_fuzzer_yank,
}
