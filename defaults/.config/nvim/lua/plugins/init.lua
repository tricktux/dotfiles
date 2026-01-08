local utl = require('utils.utils')
local map = require('mappings')

local c = {}
c.flavour = {
  daytime = 'latte',
  night = 'mocha',
  transition = 'frappe',
}
c.change_flavour = function(period)
  -- Use colorscheme command so that ColorScheme autocmd executes
  vim.cmd.colorscheme('catppuccin-' .. c.flavour[period])
end

local function setup_flux()
  local period = vim.fn['flux#Check']()
  if (period == 'none' or period == nil) then period = 'daytime' end
  c.change_flavour(period)
end

local p = {
  {
    'catppuccin/nvim',
    -- NOTE: These keymaps need to match those in neoflux
    keys = {
      {
        '<leader>tcd',
        function()
          c.change_flavour('daytime')
        end,
        mode = { 'n' },
        desc = 'toggle_colors_day',
      },
      {
        '<leader>tcn',
        function()
          c.change_flavour('night')
        end,
        mode = { 'n' },
        desc = 'toggle_colors_night',
      },
      {
        '<leader>tct',
        function()
          c.change_flavour('transition')
        end,
        mode = { 'n' },
        desc = 'toggle_colors_transition',
      },
    },
    init = function()
      setup_flux()
    end,
    name = 'catppuccin',
    cmd = {
      'CatppuccinCompile',
      'CatppuccinStatus',
      'Catppuccin',
      'CatppuccinClean',
    },
    opts = {
      compile = {
        enabled = true,
        -- .. [[/site/plugin/catppuccin]]
        path = vim.fs.joinpath(vim.fn.stdpath('data'), [[catppuccin]]),
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
        filetypes = vim
          .iter({ utl.filetype.blacklist, 'markdown', 'org', 'mail', 'dashboard' })
          :flatten(math.huge)
          :totable(),
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
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
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
      {
        '<c-c>',
        '<Plug>CapsLockToggle',
        mode = 'i',
        desc = 'caps_lock_toggle',
      },
    },
  },
  {
    'andrewferrier/debugprint.nvim',
    keys = {
      { 'g?', mode = 'n' },
      { 'g?', mode = 'x' },
    },
    opts = {
      keymaps = {
        insert = {},
      },
      print_tag = '',
      filetypes = {
        ['c'] = {
          left_var = 'printf("',
        },
      },
    },
    version = '*', -- Remove if you DON'T want to use the stable version
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      preview = {
        auto_preview = false,
      },
    },
  },
  {
    'lunarVim/bigfile.nvim',
    opts = {},
  },
  {
    'dhananjaylatkar/cscope_maps.nvim',
    cmd = 'Cs',
    opts = {
      -- maps related defaults
      disable_maps = true, -- "true" disables default keymaps
      skip_input_prompt = false, -- "true" doesn't ask for input
      ski_picker_for_single_result = true,
    },
  },
  {
    'hat0uma/csvview.nvim',
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { '#', '//' } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { 'if', mode = { 'o', 'x' } },
        textobject_field_outer = { 'af', mode = { 'o', 'x' } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
        jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
        jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
        jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
      },
    },
    cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    keys = {
      { map.vcs.prefix .. 'n', '<cmd>Neogit<cr>', mode = 'n' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim', -- required

      -- Only one of these is needed.
      'nvim-telescope/telescope.nvim', -- optional
    },
    config = true,
  },
  {
    'b3nj5m1n/kommentary',
    enabled = vim.fn.has('nvim-0.10') <= 0,
    keys = {
      {
        '<plug>comment_line',
        '<plug>kommentary_line_default',
        desc = 'kommentary_line_default',
      },
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
  },
  {
    'folke/zen-mode.nvim',
    keys = {
      {
        '<leader>tf',
        '<cmd>ZenMode<cr>',
        desc = 'focus-mode-zen-mode-toggle',
      },
    },
    cmd = { 'ZenMode' },
    opts = {
      window = {
        backdrop = 1, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        width = 100, -- width of the Zen window
        height = 1, -- height of the Zen window
      },
    },
  },
}

return p
