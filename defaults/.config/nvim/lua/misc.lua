local log = require("utils.log")
local fmt = string.format
local utl = require("utils.utils")
local line = require("config.plugins.lualine")
local map = require("config.mappings")
local vks = vim.keymap.set
local api = vim.api

function M.setup_comment_frame()
  require("nvim-comment-frame").setup({

    -- if true, <leader>cf keymap will be disabled
    disable_default_keymap = true,

    -- adds custom keymap
    -- keymap = '<leader>cc',
    -- multiline_keymap = '<leader>C',

    -- start the comment with this string
    start_str = "//",

    -- end the comment line with this string
    end_str = "//",

    -- fill the comment frame border with this character
    fill_char = "-",

    -- width of the comment frame
    frame_width = 70,

    -- wrap the line after 'n' characters
    line_wrap_len = 50,

    -- automatically indent the comment frame based on the line
    auto_indent = true,

    -- add comment above the current line
    add_comment_above = true,

    -- configurations for individual language goes here
    languages = {},
  })

  local p = [[<leader>om]]
  local o = { silent = true, desc = "add_multiline_comment" }
  vks("n", p, require("nvim-comment-frame").add_multiline_comment, o)
end

function M.setup_bookmarks()
  vim.g.bookmark_no_default_key_mappings = 1
  vim.g.bookmark_manage_per_buffer = 0
  vim.g.bookmark_save_per_working_dir = 0
  vim.g.bookmark_dir = vim.fn.stdpath("data") .. "/bookmarks"
  vim.g.bookmark_auto_save = 0
  vim.g.bookmark_auto_save_file = vim.g.bookmark_dir .. "/bookmarks"
  vim.g.bookmark_highlight_lines = 1

  local opts = { silent = true }
  local leader = {}
  local prefix = [[<leader>B]]
  leader = {
    t = { "<Plug>BookmarkToggle", "BookmarkToggle" },
    i = { "<Plug>BookmarkAnnotate", "BookmarkAnnotate" },
    a = { "<Plug>BookmarkShowAll", "BookmarkShowAll" },
    n = { "<Plug>BookmarkNext", "BookmarkNext" },
    p = { "<Plug>BookmarkPrev", "BookmarkPrev" },
    c = { "<Plug>BookmarkClear", "BookmarkClear" },
    x = { "<Plug>BookmarkClearAll", "BookmarkClearAll" },
    k = { "<Plug>BookmarkMoveUp", "BookmarkMoveUp" },
    j = { "<Plug>BookmarkMoveDown", "BookmarkMoveDown" },
    o = { "<Plug>BookmarkLoad", "BookmarkLoad" },
    s = { "<Plug>BookmarkSave", "BookmarkSave" },
  }
  map.keymaps_set(leader, "n", opts, prefix)
end

function M.config_leap()
  require("leap").setup({
    case_insensitive = true,
    speacial_keys = {
      repeat_search = "'",
      next_match = "'",
      prev_match = ",",
      next_group = "",
      prev_group = "",
      eol = "",
    },
  })
  vks("n", "s", [[<Plug>(leap-forward)]])
  vks("n", "t", [[<Plug>(leap-forward)]])
end

local function obsession_status()
  return vim.fn["ObsessionStatus"]("S:" .. vim.fn.fnamemodify(vim.v.this_session, ":t:r"), "$")
end

function M.setup_papercolor()
  log.info("[papercolor]: Setting up...")
  vim.g.PaperColor_Theme_Options = {
    ["theme"] = {
      ["default"] = {
        ["transparent_background"] = 0,
        ["allow_bold"] = 1,
        ["allow_italic"] = 1,
      },
    },
  }
end

M.toggleterm = {}
M.toggleterm.ranger = {}
M.toggleterm.keys = "<plug>file_browser"

function M.setup_toggleterm()
  local maps = {}
  maps.mappings = {
    ["<plug>terminal_toggle"] = { "<cmd>ToggleTerm<cr>", "terminal_toggle_toggleterm" },
    ["<plug>terminal_open_horizontal"] = {
      "<cmd>ToggleTerm direction=horizontal<cr>",
      "terminal_open_horizontal_toggleterm",
    },
    ["<plug>terminal_open_vertical"] = {
      "<cmd>ToggleTerm direction=vertical<cr>",
      "terminal_open_vertical_toggleterm",
    },
  }
  map:keymaps_sets(maps)
end

function M.config_toggleterm()
  require("toggleterm").setup({
    direction = "float",
    close_on_exit = false,
    float_opts = {
      border = "curved",
    },
    highlights = {
      -- highlights which map to a highlight group name and a table of it's values
      -- NOTE: this is only a subset of values,
      -- any group placed here will be set for the terminal window split
      Normal = {
        guibg = "White",
      },
      NormalFloat = {
        link = 'Normal'
      },
    },
    -- Set this variable below to false for above to have effect
    shade_terminals = false,
  })
  if vim.fn.executable("ranger") <= 0 then
    return
  end

  local Terminal      = require('toggleterm.terminal').Terminal
  M.toggleterm.ranger = Terminal:new({
    cmd = "ranger",
    close_on_exit = true,
    clear_env = false,
    direction = "float",
    float_opts = {
      border = "single",
    },
    -- function to run on opening the terminal
    on_open = function(term)
      vim.cmd.startinsert()
      vim.keymap.set({ 'n', 'i' }, 'q', vim.cmd.hide, { buffer = true })
    end,
  })
  local r             = function()
    if M.toggleterm.ranger == nil then
      vim.notify("ranger is not executable", vim.log.levels.error, {})
      return
    end
    M.toggleterm.ranger:toggle()
  end
  -- vim.keymap.set('n', '<plug>file_browser', r, { desc = 'file-browser-toggleterm' })
  vim.api.nvim_create_user_command('ToggleTermRanger', r, {})
end

function M.setup_neoterm()
  vim.g.neoterm_automap_keys = ""
  vim.g.neoterm_term_per_tab = 1
  vim.g.neoterm_use_relative_path = 1
  vim.g.neoterm_default_mod = ""
  vim.g.neoterm_autoinsert = 0
  -- " Potential substitue
  -- " https://github.com/Shougo/deol.nvim/blob/master/doc/deol.txt
  -- " there is also vimshell
end

function M.config_neoterm()
  local opts = { silent = true }
  local mappings = {
    ["<plug>terminal_new"] = { "<cmd>Tnew<cr>", "term_new" },
    ["<plug>terminal_send_file"] = { "<cmd>TREPLSendFile<cr>", "term_send_file" },
    ["<plug>terminal_send"] = { "<Plug>(neoterm-repl-send)", "term_send_line" },
    ["<plug>terminal_send_line"] = {
      "<Plug>(neoterm-repl-send-line)",
      "term_send_line",
    },
    ["<plug>terminal_toggle"] = {
      function()
        utl.exec_float_term("Ttoggle")
      end,
      "terminal",
    },
  }
  map.keymaps_set(mappings, "n", opts)
end

function M.setup_pomodoro()
  vim.g.pomodoro_use_devicons = 0
  if vim.fn.executable("dunst") > 0 then
    vim.g.pomodoro_notification_cmd = "notify-send 'Pomodoro' 'Session ended' && "
        .. "mpv ~/.config/dotfiles/notification_sounds/cool_notification1.mp3 "
        .. "2>/dev/null&"
  elseif vim.fn.executable("powershell") > 0 and vim.g.dotfiles ~= nil then
    vim.g.pomodoro_notification_cmd = "powershell " .. vim.g.dotfiles .. "/scripts/win/win_vim_notification.ps1"
  end
  vim.g.pomodoro_log_file = vim.fn.stdpath("data") .. "/pomodoro_log"
end

function M.config_pomodoro()
  log.info("ins_left(): pomodoro")
  line:ins_left({
    function()
      return vim.fn["pomo#status_bar"]()
    end,
    color = { fg = line.colors.orange, gui = "bold" },
    left_padding = 0,
  })
end

function M.setup_luadev()
  local luadev = require("lua-dev").setup({
    library = {
      vimruntime = false, -- runtime path
      -- full signature, docs and completion of vim.api, vim.treesitter,
      -- vim.lsp and others
      types = false,
      -- List of plugins you want autocompletion for
      plugins = false,
    },
    -- pass any additional options that will be merged in the final lsp config
    lspconfig = {
      cmd = { "lua-language-server" },
      on_attach = require("config.lsp").on_lsp_attach,
    },
  })

  require("lspconfig").sumneko_lua.setup(luadev)
end

function M.setup_neogit()
  require("neogit").setup({})
  -- open commit popup
  -- neogit.open({ "commit" })
  local opts = { silent = true, desc = "neogit_open" }
  vks("n", "<leader>vo", require("neogit").open, opts)
end

M.git_messenger = {}
M.git_messenger.cmd = "GitMessenger"
M.git_messenger.keys = "<leader>vm"
M.git_messenger.setup = function()
  vim.g.git_messenger_always_into_popup = true
  vim.g.git_messenger_floating_win_opts = { border = 'single' }
end
M.git_messenger.config = function()
  local opts = { silent = true, desc = "git_messenger" }
  vks("n", "<leader>vm", "<cmd>GitMessenger<cr>", opts)
end

function M.config_copilot()
  local status_ok, copilot = pcall(require, "copilot")
  if not status_ok then
    return
  end

  copilot.setup({
    cmp = {
      enabled = true,
      method = "getPanelCompletions",
    },
    panel = { -- no config options yet
      enabled = true,
    },
    ft_disable = { "markdown" },
    -- plugin_manager_path = vim.fn.stdpath "data" .. "/site/pack/packer",
    -- server_opts_overrides = {},
  })
end

function M.setup_iswap()
  local opts = { silent = true, desc = "iswap_arguments" }
  vks("n", "<localleader>s", require("iswap").iswap, opts)
end

function M.config_iswap()
  require("iswap").setup({
    -- The keys that will be used as a selection, in order
    -- ('asdfghjklqwertyuiopzxcvbnm' by default)
    keys = "qwertyuiop",
    -- Grey out the rest of the text when making a selection
    -- (enabled by default)
    grey = "enabled",
    -- Highlight group for the sniping value (asdf etc.)
    -- default 'Search'
    hl_snipe = "ErrorMsg",
    -- Highlight group for the visual selection of terms
    -- default 'Visual'
    hl_selection = "WarningMsg",
    -- Highlight group for the greyed background
    -- default 'Comment'
    hl_grey = "LineNr",
  })
end

function M.setup_obsession()
  vim.g.obsession_no_bufenter = 1
  log.info("ins_right(): obsession")
  line:ins_right({
    obsession_status,
    color = { fg = line.colors.blue, gui = "bold" },
    right_padding = 0,
  })
end

function M.config_neotest()
  local neotest_py_adapter = {
    adapters = {
      require("neotest-python")({
        -- Extra arguments for nvim-dap configuration
        dap = { justMyCode = false },
        -- Command line arguments for runner
        -- Can also be a function to return dynamic values
        args = { "--log-level", "DEBUG" },
        -- Runner to use. Will use pytest if available by default.
        -- Can be a function to return dynamic value.
        runner = "pytest",

        -- Returns if a given file path is a test file.
        -- NB: This function is called a lot so don't perform any heavy tasks within it.
        -- is_test_file = function(file_path)
        -- end,
      }),
    },
  }

  require("neotest").setup({
    adapters = {
      require("neotest-python")(neotest_py_adapter),
      require("neotest-plenary"),
    },
  })
  local maps = { prefix = "<leader>st" }
  maps.mappings = {
    f = {
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      "neotest_run_current_file",
    },
    r = {
      function()
        require("neotest").run.run()
      end,
      "neotest_run_nearest",
    },
  }
end

function M.setup_img_paste()
  vim.cmd([=[
    function! g:OrgmodePasteImage(relpath)
      execute "normal! i#+CAPTION: H"
      let ipos = getcurpos()
      execute "normal! aere"
      execute "normal! o[[./" . a:relpath . "]]"
      call setpos('.', ipos)
      execute "normal! ve\<C-g>"
    endfunction
    ]=])
  local id = api.nvim_create_augroup("ImagePastePlugin", { clear = true })
  local opts = { silent = true, desc = "image_paste", buffer = 0 }
  local md = function()
    vim.g.PasteImageFunction = "g:MarkdownPasteImage"
    vim.fn["mdip#MarkdownClipboardImage"]()
  end
  local tex = function()
    vim.g.PasteImageFunction = "g:LatexPasteImage"
    vim.fn["mdip#MarkdownClipboardImage"]()
  end
  local org = function()
    vim.g.PasteImageFunction = "g:OrgmodePasteImage"
    vim.fn["mdip#MarkdownClipboardImage"]()
  end
  api.nvim_create_autocmd("FileType", {
    callback = function()
      vks("n", "<localleader>i", org, opts)
    end,
    pattern = "org",
    desc = "OrgModePasteImageFunction",
    group = id,
  })
  api.nvim_create_autocmd("FileType", {
    callback = function()
      vks("n", "<localleader>i", md, opts)
    end,
    pattern = "markdown",
    desc = "MarkdownPasteImageFunction",
    group = id,
  })
  api.nvim_create_autocmd("FileType", {
    callback = function()
      vks("n", "<localleader>i", tex, opts)
    end,
    pattern = "tex",
    desc = "LatexPasteImageFunction",
    group = id,
  })
end

function M.setup_grip()
  vim.g.grip_pdfgrep = {
    executable = "pdfgrep",
    args = {
      [[$*]],
      "--ignore-case",
      "--page-number",
      "--recursive",
      "--context",
      "1",
    },
    grepformat = vim.opt.grepformat:get(),
  }
  local rg_to_vim_filetypes = {
    vim = "vimscript",
    python = "py",
    markdown = "md",
  }
  vim.g.grip_rg = {
    executable = utl.rg.bin,
    args = utl.rg.switches.common,
    ["filetype_support"] = 1,
    ["filetype_map"] = rg_to_vim_filetypes,
    ["filetype_option"] = "--type",
  }

  vim.g.grip_rg_list = {
    name = "list_files",
    executable = utl.rg.bin,
    search_argument = 0,
    prompt = 0,
    grepformat = "%f",
    args = utl.rg.switches.common,
  }

  vim.g.grip_tools = { vim.g.grip_rg, vim.g.grip_pdfgrep, vim.g.grip_rg_list }

  if vim.g.wiki_path == nil then
    return
  end

  vim.g.grip_wiki = {
    name = "wiki",
    prompt = 1,
    executable = utl.rg.bin,
    args = {
      utl.rg.switches.common,
      [[$*]],
      vim.g.wiki_path,
    },
  }

  table.insert(vim.g.grip_tools, vim.g.grip_wiki)
end

function M.config_indent_blankline()
  local config = {
    char_highlight_list = { "Comment" },
    char_list = { "¦", "┆", "┊" },
    show_first_indent_level = false,
    show_current_context = true,
    buftype_exclude = utl.buftype.blacklist,
    filetype_exclude = vim.tbl_flatten({ utl.filetype.blacklist, "markdown", "org", "mail" }),
  }
  require("indent_blankline").setup(config)
end

function M.config_surround()
  require("nvim-surround").setup()
end

function M.config_auto_session()
  local s = utl.fs.path.sep
  local opts = {
    log_level = "info",
    auto_session_enable_last_session = false,
    auto_session_root_dir = vim.fn.stdpath("data") .. s .. "sessions" .. s,
    auto_session_enabled = true,
    auto_session_create_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = false,
    auto_session_suppress_dirs = nil,
    auto_session_use_git_branch = true,
    -- the configs below are lua only
    bypass_session_save_file_types = nil,
  }

  require("auto-session").setup(opts)
end

function M.config_session_lens()
  require("session-lens").setup({
    path_display = { "shorten" },
    -- theme_conf = { border = false },
    previewer = false,
  })
  require("telescope").load_extension("session-lens")
  local o = { silent = true, desc = "sessions" }
  log.info("[sessions]: mappings")
  vks("n", "<leader>fs", "<cmd>SearchSession<cr>", o)
  line:ins_left({
    require("auto-session-library").current_session_name,
    color = { gui = "bold" },
    -- left_padding = 0,
  })
end

M.dial_nvim = {
  nkeys = {
    opts = { noremap = true, silent = true, expr = true },
    mappings = {
      ["<c-a>"] = {
        function()
          require("dial.map").inc_normal()
        end,
        "inc_under_cursor",
      },
      ["<s-x>"] = {
        function()
          require("dial.map").dec_normal()
        end,
        "inc_under_cursor",
      },
    },
  },
  vkeys = {
    mode = "x",
    opts = { noremap = true, silent = true, expr = true },
    mappings = {
      ["<c-a>"] = {
        function()
          return require("dial.map").inc_visual() .. "gv"
        end,
        "inc_v_under_cursor",
      },
      ["<s-x>"] = {
        function()
          return require("dial.map").dec_visual() .. "gv"
        end,
        "dec_v_under_cursor",
      },
      ["g<c-a>"] = {
        function()
          return require("dial.map").inc_gvisual() .. "gv"
        end,
        "inc_gv_under_cursor",
      },
      ["g<s-x>"] = {
        function()
          return require("dial.map").dec_gvisual() .. "gv"
        end,
        "dec_gv_under_cursor",
      },
    },
  },
}
M.dial_nvim.setup = function()
  -- map:keymaps_sets(M.dial_nvim.nkeys)
  -- map:keymaps_sets(M.dial_nvim.vkeys)
end

M.dial_nvim.config = function()
  vim.api.nvim_set_keymap("n", "<C-a>", require("dial.map").inc_normal(), { noremap = true })
  vim.api.nvim_set_keymap("n", "<s-x>", require("dial.map").dec_normal(), { noremap = true })
  vim.api.nvim_set_keymap("v", "<C-a>", require("dial.map").inc_visual(), { noremap = true })
  vim.api.nvim_set_keymap("v", "<s-x>", require("dial.map").dec_visual(), { noremap = true })
  vim.api.nvim_set_keymap("v", "g<C-a>", require("dial.map").inc_gvisual(), { noremap = true })
  vim.api.nvim_set_keymap("v", "g<s-x>", require("dial.map").dec_gvisual(), { noremap = true })

  local augend = require("dial.augend")
  require("dial.config").augends:register_group({
    -- default augends used when no group name is specified
    default = {
      augend.integer.alias.decimal,
      augend.integer.alias.hex,
      augend.integer.alias.octal,
      augend.integer.alias.binary,
      augend.date.alias["%Y/%m/%d"],
      augend.date.alias["%Y-%m-%d"],
      augend.date.alias["%m/%d"],
      augend.date.alias["%H:%M"],
      augend.constant.alias.ja_weekday_full,
      augend.constant.alias.bool,
      augend.semver.alias.semver,
    },
  })
end

M.clangd_extensions = {}
M.clangd_extensions.setup = function()
  local cmp = require("cmp")
  cmp.setup.sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.recently_used,
      require("clangd_extensions.cmp_scores"),
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
      require("clangd_extensions").setup {
        server = require("config.lsp").clangd_settings,
      }
end

M.context = {}
M.context.config = function()
  require 'treesitter-context'.setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
      -- For all filetypes
      -- Note that setting an entry here replaces all other patterns for this entry.
      -- By setting the 'default' entry below, you can control which nodes you want to
      -- appear in the context window.
      default = {
        'class',
        'function',
        'method',
        'for',
        'while',
        'if',
        'switch',
        'case',
        'interface',
        'struct',
        'enum',
      },
      -- Patterns for specific filetypes
      -- If a pattern is missing, *open a PR* so everyone can benefit.
      tex = {
        'chapter',
        'section',
        'subsection',
        'subsubsection',
      },
      haskell = {
        'adt'
      },
      rust = {
        'impl_item',

      },
      terraform = {
        'block',
        'object_elem',
        'attribute',
      },
      scala = {
        'object_definition',
      },
      vhdl = {
        'process_statement',
        'architecture_body',
        'entity_declaration',
      },
      markdown = {
        'section',
      },
      elixir = {
        'anonymous_function',
        'arguments',
        'block',
        'do_block',
        'list',
        'map',
        'tuple',
        'quoted_content',
      },
      json = {
        'pair',
      },
      typescript = {
        'export_statement',
      },
      yaml = {
        'block_mapping_pair',
      },
    },
    exact_patterns = {
      -- Example for a specific filetype with Lua patterns
      -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
      -- exactly match "impl_item" only)
      -- rust = true,
    },

    -- [!] The options below are exposed but shouldn't require your attention,
    --     you can safely ignore them.

    zindex = 20, -- The Z-index of the context window
    mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    separator = nil,
  }
end

M.noice = {}
M.noice.config = function()
  local noice = require("noice")
  require("telescope").load_extension("noice")
  noice.setup({
    routes = {
      {
        view = "notify",
        filter = { event = "msg_showmode" },
      },
    },
    views = {
      cmdline_popup = {
        position = {
          row = 5,
          col = "50%",
        },
        size = {
          width = 60,
          height = "auto",
        },
      },
      popupmenu = {
        relative = "editor",
        position = {
          row = 8,
          col = "50%",
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
    },
  })
end

M.toggletasks = {}
M.toggletasks.config = function()
  require('telescope').load_extension('toggletasks')
  require('toggletasks').setup {
    debug = false,
    silent = false, -- don't show "info" messages
    short_paths = true, -- display relative paths when possible
    -- Paths (without extension) to task configuration files (relative to scanned directory)
    -- All supported extensions will be tested, e.g. '.toggletasks.json', '.toggletasks.yaml'
    search_paths = {
      'toggletasks',
      '.toggletasks',
      '.nvim/toggletasks',
    },
    -- Directories to consider when searching for available tasks for current window
    scan = {
      global_cwd = true, -- vim.fn.getcwd(-1, -1)
      tab_cwd = true, -- vim.fn.getcwd(-1, tab)
      win_cwd = true, -- vim.fn.getcwd(win)
      lsp_root = true, -- root_dir for first LSP available for the buffer
      dirs = { vim.fn.stdpath('config') }, -- explicit list of directories to search or function(win): dirs
      rtp = false, -- scan directories in &runtimepath
      rtp_ftplugin = false, -- scan in &rtp by filetype, e.g. ftplugin/c/toggletasks.json
    },
    tasks = {}, -- list of global tasks or function(win): tasks
    -- this is basically the "Config format" defined using Lua tables
    -- Language server priorities when selecting lsp_root (default is 0)
    lsp_priorities = {
      ['null-ls'] = -10,
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
          select_float = '<C-f>',
          spawn_smart = '<C-a>', -- all if no entries selected, else use multi-select
          spawn_all = '<M-a>', -- all visible entries
          spawn_selected = nil, -- entries selected via multi-select (default <tab>)
        },
      },
      -- Replaces default select_* actions to open task terminal (and change toggleterm
      -- direction for select horiz/vert/tab)
      select = {
        mappings = {
          select_float = '<C-f>',
          open_smart = '<C-a>',
          open_all = '<M-a>',
          open_selected = nil,
          kill_smart = '<C-q>',
          kill_all = '<M-q>',
          kill_selected = nil,
          respawn_smart = '<C-s>',
          respawn_all = '<M-s>',
          respawn_selected = nil,
        },
      },
    },
  }
end

return M
