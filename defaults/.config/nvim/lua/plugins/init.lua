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
  vim.cmd[[
  hi StatusLine ctermfg=white ctermbg=black guifg=white guibg=black gui=bold
  hi StatusLineNC ctermfg=white ctermbg=black guifg=white guibg=black gui=bold " For inactive statusline if desired
        ]]
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
    'kevinhwang91/nvim-bqf',
    ft = 'qf'
  },
  {
    'lunarVim/bigfile.nvim',
    opts = {},
  },
  {
    "dhananjaylatkar/cscope_maps.nvim",
    cmd = 'Cs',
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
