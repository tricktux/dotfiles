if vim.g.advanced_plugins == 0 then
  return {}
end

return {
  {
    'glacambre/firenvim',

    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn['firenvim#install'](0)
    end,
    init = function()
      if not vim.g.started_by_firenvim then
        return
      end

      local function chat_mappings()
        vim.cmd([[
				" for chat apps. Enter sends the message and deletes the buffer.
				" Shift enter is normal return. Insert mode by default.
				" Note that slack and gitter probably don't respond appropriately to press_keys. Workarounds might directly call javascript functions to send the messages.
				normal! i
				" inoremap <CR> <Esc>:w<CR>:call firenvim#press_keys("<LT>CR>")<CR>ggdGa
				inoremap <CR> <Esc>:w<CR>:call firenvim#press_keys("<LT>CR>")<CR>ggdGa
				inoremap <s-CR> <CR>
				]])
      end

      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*',
        callback = function()
          vim.opt.lines = 20
          local bufname = vim.fn.expand('%:t')
          if string.find(bufname, 'github.com') then
            vim.bo.filetype = 'markdown'
          elseif
            string.find(bufname, 'cocalc.com') or string.find(bufname, 'kaggleusercontent.com')
          then
            vim.bo.filetype = 'python'
          elseif string.find(bufname, 'localhost') then
            vim.bo.filetype = 'python'
          elseif string.find(bufname, 'reddit.com') then
            vim.bo.filetype = 'markdown'
          elseif
            string.find(bufname, 'stackexchange.com') or string.find(bufname, 'stackoverflow.com')
          then
            vim.bo.filetype = 'markdown'
          elseif string.find(bufname, 'slack.com') or string.find(bufname, 'gitter.com') then
            vim.bo.filetype = 'markdown'
          -- chat_mappings()
          elseif string.find(bufname, 'web.whatsapp.com') then
          -- chat_mappings()
          else
            -- markdown by default, since proselint and markdown lint not
            -- working on text
            vim.bo.filetype = 'markdown'
          end
        end,
      })
    end,
  },
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    keys = {
      { '<plug>focus_toggle', '<cmd>ZenMode<cr>', desc = 'zen-mode' },
    },
    opts = {
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = false, -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
        },
        twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = false }, -- disables the tmux statusline
        -- this will change the font size on kitty when in zen mode
        -- to make this work, you need to set the following kitty options:
        -- - allow_remote_control socket-only
        -- - listen_on unix:/tmp/kitty
        kitty = {
          enabled = true,
          font = '+4', -- font size increment
        },
        -- this will change the font size on alacritty when in zen mode
        -- requires  Alacritty Version 0.10.0 or higher
        -- uses `alacritty msg` subcommand to change font size
        alacritty = {
          enabled = false,
          font = '14', -- font size
        },
        -- this will change the font size on wezterm when in zen mode
        -- See alse also the Plugins/Wezterm section in this projects README
        wezterm = {
          enabled = false,
          -- can be either an absolute font size or the number of incremental steps
          font = '+4', -- (10% increase per step)
        },
      },
    },
  },
  {
    "robitx/gp.nvim",
    keys = {
      {
        '<plug>ai',
        '<cmd>GpChatNew vsplit<cr>',
        desc = 'ai_help',
      },
    },
    config = function()
      local conf = {
        -- For customization, refer to Install > Configuration in the Documentation/Readme
        -- default agent names set during startup, if nil last used agent is used
        default_command_agent = "ChatGPT4o-mini",
        default_chat_agent = "ChatGPT4o-mini",
        -- log_sensitive = true,
      }
      require("gp").setup(conf)
    end,
  },
  {
    'jackMort/ChatGPT.nvim',
    cmd = { 'ChatGPTEditWithInstructions', 'ChatGPTActAs', 'ChatGPT' },
    -- keys = {
    --   {
    --     '<plug>ai',
    --     '<cmd>ChatGPT<cr>',
    --     desc = 'ai_help',
    --   },
    -- },
    opts = {
      openai_params = {
        -- gpt-4, gpt-3.5-turbo-16k-0613
        model = 'gpt-4o-mini',
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 16384,
        temperature = 1,
        top_p = 1,
        n = 1,
      },
      popup_layout = {
        default = 'right',
        center = {
          width = '80%',
          height = '80%',
        },
        right = {
          width = '40%',
          width_settings_open = '50%',
        },
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-lua/telescope.nvim',
    },
  },
  {
    'HakonHarnes/img-clip.nvim',
    ft = { 'markdown', 'org', 'quarto', 'tex' },
    cmd = { 'PasteImage' },
    -- event = "BufEnter",
    opts = {
      default = {
        relative_to_current_file = true, -- make dir_path relative to current file rather than the cwd
        relative_template_path = false, -- make file path in the template relative to current file rather than the cwd
        dir_path = 'attachements',
      },
      quarto = {
        template = '![$CURSOR]($FILE_PATH)',
      },
    },
    keys = {
      { '<localleader>i', '<cmd>PasteImage<cr>', desc = 'Paste clipboard image' },
    },
  },
  { 'aquach/vim-http-client', cmd = 'HTTPClientDoRequest' },
  { 'matze/vim-ini-fold', ft = 'dosini' },
  { 'aklt/plantuml-syntax', ft = 'plantuml' },
  { 'MTDL9/vim-log-highlighting', ft = 'log' },
  {
    'tpope/vim-sleuth',
    event = 'VeryLazy',
  },
  {
    'PProvost/vim-ps1',
    ft = 'ps1',
  },
  {
    'JellyApple102/easyread.nvim',
    ft = { 'markdown', 'text', 'org', 'quarto' },
    opts = {
      hlValues = {
        ['1'] = 1,
        ['2'] = 1,
        ['3'] = 2,
        ['4'] = 2,
        ['fallback'] = 0.4,
      },
      hlgroupOptions = { link = 'Bold' },
      fileTypes = { 'text', 'markdown', 'org', 'quarto' },
      saccadeInterval = 0,
      saccadeReset = false,
      updateWhileInsert = true,
    },
  },
}
