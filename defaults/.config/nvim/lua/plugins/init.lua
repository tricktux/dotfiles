local log = require('utils.log')
local fmt = string.format
local utl = require('utils.utils')
local fs = require('utils.filesystem')
local vks = vim.keymap.set
local api = vim.api
local home = vim.loop.os_homedir()

-- Lua functions that inserts a text and copies it to the clipboard
local function anki_prompt()
  local p = [[
I want you to act as a professional Anki card creator, able to create Anki cards from the text I provide.
Regarding the formulation of the card content, you stick to two principles: First, minimum information principle: The material you learn must be formulated in as simple way as it is only possible. Simplicity does not have to imply losing information and skipping the difficult part.b Second, optimize wording: The wording of your items must be optimized to make sure that in minimum time the right bulb in your brain lights up. This will reduce error rates, increase specificity, reduce response time, and help your concentration.
The following is a model card-create template for you to study.
Text: The characteristics of the Dead Sea: Salt lake located on the border between Israel and Jordan. Its shoreline is the lowest point on the Earth's surface, averaging 396 m below sea level. It is 74 km long. It is seven times as salty (30% by volume) as the ocean. Its density keeps swimmers afloat. Only simple organisms can live in its saline waters
Create cards based on the above text as follows:
Where is the Dead Sea located?
{{c1::On the border between Israel and Jordan}}
What is the lowest point on the Earth's surface?
{{c1:The Dead Sea shoreline}}
What is the average level on which the Dead Sea is located?
{{c1::400 meters (below sea level)}}
How long is the Dead Sea?
{{c1::70 km}}
How much saltier is the Dead Sea as compared with the oceans? 
{{c1::7 times}}
What is the volume content of salt in the Dead Sea?
{{c1::30%}}
Why can the Dead Sea keep swimmers afloat?
{{c1::due to high salt content}}
Why is the Dead Sea called Dead?
{{c1::because only simple organisms can live in i}}
Why only simple organisms can live in the Dead Sea? 
{{c1::because of high salt conten}}

If there's code just use Markdown's code block syntax. For example:
Text: Here's a simple C++ code implementation of Horner's Rule:
```cpp
double horner(int poly[], int n, int x) {
    double result = poly[0];
    for (int i = 1; i < n; i++)
        result = result * x + poly[i];
    return result;
}
```

Please escape anki's cloze syntax in the answer. Example:
```
This is how to escape cloze deletion: \{{c1::text\}} and std\:\:sort
```

If there are math formulas involved please use katex syntax for equations. For example:

How can a polynomial be rewritten using Horner's rule?
{{c1::[$]P(x) = a_n + x(a_{n-1} + x(a_{n-2} + ... + x( a_1 + x*a_0)... ))[\$]}}

Please focus on comprehensivley capturing the content in cards,
as many cards as is necessary, the more the better, as long as content
is not redundant; while keeping the responses of the cards as brief as possible.

Now please use anki cards as described above to explain the concept of:
]]

  -- Copy text to buffer
  vim.fn.setreg('+', p)
  -- Insert text in buffer
  vim.cmd('normal! p"+')
end

vim.api.nvim_create_user_command('UtilsChatGptAnkiPastePrompt', anki_prompt, {})

local function set_colorscheme(period)
  local flavour = {
    day = 'latte',
    night = 'mocha',
    sunrise = 'frappe',
    sunset = 'macchiato',
  }
  vim.g.catppuccin_flavour = flavour[period]
  log.info(fmt("set_colorscheme: period = '%s'", period))
  log.info(fmt("set_colorscheme: catppuccin_flavour = '%s'", flavour[period]))
  vim.cmd('Catppuccin ' .. flavour[period])
  local colors = require('catppuccin.palettes').get_palette()
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

local function setup_flux()
  local f = require('plugin.flux')
  f:setup({
    callback = set_colorscheme,
  })
  local id = api.nvim_create_augroup('FluxLike', { clear = true })
  api.nvim_create_autocmd('CursorHold', {
    callback = function()
      vim.defer_fn(function()
        f:check()
      end, 0) -- Defered for live reloading
    end,
    pattern = '*',
    desc = 'Flux',
    once = true,
    group = id,
  })
end

local p = {
  {
    'catppuccin/nvim',
    init = function()
      setup_flux()
    end,
    name = 'catppuccin',
    cmd = { 'CatppuccinCompile', 'CatppuccinStatus', 'Catppuccin', 'CatppuccinClean' },
    opts = {
      compile = {
        enabled = true,
        -- .. [[/site/plugin/catppuccin]]
        path = vim.fn.stdpath('data') .. utl.fs.path.sep .. [[catppuccin]],
        suffix = '_compiled',
      },
      integrations = {
        indent_blankline = {
          enabled = true,
          colored_indent_levels = true,
        },
        dap = {
          enabled = vim.fn.has('unix') > 0 and true or false,
          enable_ui = vim.fn.has('unix') > 0 and true or false,
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
        },
        noice = true,
        treesitter_context = true,
        telescope = true,
        which_key = true,
        dashboard = true,
        vim_sneak = true,
        markdown = true,
        ts_rainbow = true,
        notify = true,
        symbols_outline = true,
      },
    },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    keys = {
      {
        '<leader>rr',
        function()
          require('refactoring').select_refactor()
        end,
        mode = { 'n', 'x' },
        desc = 'refactoring',
      },
    },
    opts = {},
  },
  {
    'justinmk/vim-sneak',
    event = 'VeryLazy',
    init = function()
      vim.g['sneak#absolute_dir'] = 1
      vim.g['sneak#label'] = 1
      -- " repeat motion
      -- Using : for next f,t is cumbersome, use ' for that, and ` for marks
      vim.keymap.set('n', ';', '<Plug>Sneak_;')
      vim.keymap.set('n', ',', '<Plug>Sneak_,')

      -- " 1-character enhanced 'f'
      vim.keymap.set('n', 'f', '<Plug>Sneak_f')
      vim.keymap.set('n', 'F', '<Plug>Sneak_F')
      -- " 1-character enhanced 't'
      vim.keymap.set('n', 't', '<Plug>Sneak_t')
      -- " label-mode
      vim.keymap.set('n', 's', '<Plug>SneakLabel_s')
      vim.keymap.set('n', 'S', '<Plug>SneakLabel_S')

      -- TODO: See a way not to have to map these
      -- Wait for: https://github.com/justinmk/vim-sneak/pull/248
      -- vim.g["sneak#disable_mappings"] = 1
      -- " visual-mode
      vim.keymap.set({ 'x', 'o' }, 's', 's')
      vim.keymap.set({ 'x', 'o' }, 'S', 'S')
      vim.keymap.set({ 'x', 'o' }, 'f', 'f')
      vim.keymap.set({ 'x', 'o' }, 'F', 'F')
      vim.keymap.set({ 'x', 'o' }, 't', 't')
      vim.keymap.set({ 'x', 'o' }, 'T', 'T')
    end,
  },
  {
    'ironhouzi/starlite-nvim',
    keys = {
      {
        '*',
        function()
          require('starlite').star()
        end,
        desc = 'goto_next_abs_word_under_cursor',
      },
      {
        'g*',
        function()
          require('starlite').g_star()
        end,
        desc = 'goto_next_word_under_cursor',
      },
      {
        '#',
        function()
          require('starlite').hash()
        end,
        desc = 'goto_prev_abs_word_under_cursor',
      },
      {
        'g#',
        function()
          require('starlite').g_hash()
        end,
        desc = 'goto_prev_word_under_cursor',
      },
    },
  },
  {
    'kazhala/close-buffers.nvim',
    keys = {
      {
        '<leader>bd',
        function()
          require('close_buffers').delete({ type = 'this' })
        end,
        desc = 'buffer_delete_current',
      },
      {
        '<leader>bl',
        function()
          require('close_buffers').delete({ type = 'all', force = true })
        end,
        desc = 'buffer_delete_all',
      },
      {
        '<leader>bn',
        function()
          require('close_buffers').delete({ type = 'nameless' })
        end,
        desc = 'buffer_delete_nameless',
      },
      {
        '<leader>bg',
        function()
          require('close_buffers').delete({
            glob = vim.fn.input('Please enter glob (ex. *.lua): '),
          })
        end,
        desc = 'buffer_delete_glob',
      },
    },
    opts = {
      filetype_ignore = {}, -- Filetype to ignore when running deletions
      file_glob_ignore = {}, -- File name glob pattern to ignore when running deletions (e.g. '*.md')
      file_regex_ignore = {}, -- File name regex pattern to ignore when running deletions (e.g. '.*[.]md')
      preserve_window_layout = { 'this', 'nameless' }, -- Types of deletion that should preserve the window layout
      next_buffer_cmd = nil, -- Custom function to retrieve the next buffer when preserving window layout
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'VeryLazy',
    main = 'ibl',
    opts = {
      debounce = 100,
      indent = { char = { '¦', '┆', '┊' } },
      exclude = {
        filetypes = vim.tbl_flatten({ utl.filetype.blacklist, 'markdown', 'org', 'mail' }),
        buftypes = utl.buftype.blacklist,
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
    },
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = true,
  },
  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    opts = {},
  },
  {
    'monaqa/dial.nvim',
    event = 'VeryLazy',
    config = function()
      vim.api.nvim_set_keymap('n', '<C-a>', require('dial.map').inc_normal(), { noremap = true })
      vim.api.nvim_set_keymap('n', '<s-x>', require('dial.map').dec_normal(), { noremap = true })
      vim.api.nvim_set_keymap('v', '<C-a>', require('dial.map').inc_visual(), { noremap = true })
      vim.api.nvim_set_keymap('v', '<s-x>', require('dial.map').dec_visual(), { noremap = true })
      vim.api.nvim_set_keymap('v', 'g<C-a>', require('dial.map').inc_gvisual(), { noremap = true })
      vim.api.nvim_set_keymap('v', 'g<s-x>', require('dial.map').dec_gvisual(), { noremap = true })
      local augend = require('dial.augend')
      require('dial.config').augends:register_group({
        -- default augends used when no group name is specified
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.integer.alias.octal,
          augend.integer.alias.binary,
          augend.date.alias['%Y/%m/%d'],
          augend.date.alias['%Y-%m-%d'],
          augend.date.alias['%m/%d'],
          augend.date.alias['%H:%M'],
          augend.constant.alias.ja_weekday_full,
          augend.constant.alias.bool,
          augend.semver.alias.semver,
        },
      })
    end,
  },
  {
    'rhysd/git-messenger.vim',
    cmd = { 'GitMessenger' },
    init = function()
      vim.g.git_messenger_always_into_popup = true
      vim.g.git_messenger_floating_win_opts = { border = 'single' }
    end,
  },
  {
    'mhinz/vim-startify',
    lazy = false,
    cond = not vim.g.started_by_firenvim,
    init = function()
      vim.g.startify_session_dir = vim.g.sessions_path

      vim.g.startify_lists = {
        { ['type'] = 'sessions', ['header'] = { '   Sessions' } },
        { ['type'] = 'files', ['header'] = { '   MRU' } },
      }
      vim.g.startify_change_to_dir = 0
      vim.g.startify_session_sort = 1
      vim.g.startify_session_number = 10
    end,
  },
  {
    'tpope/vim-repeat',
    event = 'VeryLazy',
  },
  {
    'jiangmiao/auto-pairs',
    event = 'VeryLazy',
    init = function()
      -- Really annoying option
      vim.g.AutoPairsFlyMode = 0
      vim.g.AutoPairsShortcutToggle = ''
      vim.g.AutoPairsShortcutFastWrap = ''
      vim.g.AutoPairsShortcutJump = ''
      vim.g.AutoPairsShortcutBackInsert = ''
    end,
  },
  {
    'chrisbra/csv.vim',
    ft = 'csv',
    init = function()
      vim.g.no_csv_maps = 1
      vim.g.csv_strict_columns = 1
    end,
  },
  {
    'chaoren/vim-wordmotion',
    event = 'VeryLazy',
    init = function()
      vim.g.wordmotion_mappings = {
        w = 'L',
        b = 'H',
        e = '',
        W = '',
        B = '',
        E = '',
        ['ge'] = '',
        ['aw'] = '',
        ['iw'] = '',
        ['<C-R><C-W>'] = '',
      }
    end,
  },
  {
    'tpope/vim-capslock',
    keys = {
      { '<c-l>', '<Plug>CapsLockToggle', mode = 'i', desc = 'caps_lock_toggle' },
    },
  },
  {
    'glts/vim-radical',
    dependencies = {
      'glts/vim-magnum',
    },
    keys = {
      { '<leader>nr', '<Plug>RadicalView', mode = 'x', desc = 'radical_view' },
      { '<leader>nr', '<Plug>RadicalView', desc = 'radical_view' },
    },
    init = function()
      vim.g.radical_no_mappings = 1
    end,
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf'
  },
  -- better ui from lazyvim
  -- ui components
  { 'MunifTanjim/nui.nvim' },
  {
    'stevearc/dressing.nvim',
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    'tjdevries/stackmap.nvim',
    event = 'VeryLazy',
  },
  {
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    keys = {
      {
        '<leader>ts',
        '<cmd>SymbolsOutline<cr>',
        desc = 'symbols-outline',
      },
    },
    init = function()
      local id = api.nvim_create_augroup('Symbols', { clear = true })
      api.nvim_create_autocmd('FileType', {
        callback = function(args)
          vim.opt_local.spell = false
        end,
        pattern = 'Outline',
        desc = 'SymbolsOutlineSettings',
        group = id,
      })
    end,
    opts = {
      auto_preview = false,
      highlight_hovered_item = false,
      relative_width = false,
      width = 40,
      keymaps = { -- These keymaps can be a string or a table for multiple keys
        close = { '<Esc>', 'q' },
        goto_location = '<Cr>',
        focus_location = 'o',
        hover_symbol = '<C-space>',
        toggle_preview = 'K',
        rename_symbol = 'r',
        code_actions = 'a',
        fold = 'x',
        unfold = 'X',
        fold_all = '<c-z>',
        unfold_all = '<c-x>',
        fold_reset = 'R',
      },
    },
  },
  {
    'lunarVim/bigfile.nvim',
    opts = {},
  },
  {
    "dhananjaylatkar/cscope_maps.nvim",
    event = 'VeryLazy',
    opts = {
      -- maps related defaults
      disable_maps = true, -- "true" disables default keymaps
      skip_input_prompt = false, -- "true" doesn't ask for input
    }
  }
}

if vim.fn.has('nvim-0.10') <= 0 then
  table.insert(p, {
    'b3nj5m1n/kommentary',
    keys = {
      { '<plug>comment_line', '<plug>kommentary_line_default', desc = 'kommentary_line_default' },
      {
        '<bs>',
        '<Plug>kommentary_visual_default<C-c>',
        mode = { 'x', 'v' },
        desc = 'kommentary_line_visual',
      },
    },
    init = function()
      vim.g.kommentary_create_default_mappings = false
    end,
    config = function()
      local config = require('kommentary.config')
      config.configure_language('dosini', {
        single_line_comment_string = ';',
        prefer_single_line_comments = true,
      })
    end,
  })
end

return p
