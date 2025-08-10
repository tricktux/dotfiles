local w = require('plugin.wiki')

return {
  {
    'Exafunction/windsurf.nvim',
    enabled = w.path.work ~= nil,
    keys = {
      { '<leader>aj', '<cmd>Codeium Toggle<cr>', desc = 'codeium_toggle' },
      { '<leader>ac', '<cmd>Codeium Chat<cr>', desc = 'codeium_chat' },
      { '<leader>aa', '<cmd>Codeium Auth<cr>', desc = 'codeium_auth' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    config = function()
      require('codeium').setup {
        enterprise_mode = true,
        enable_chat = true,
        api = {
          host = 'windsurf.fedstart.com',
        },
      }
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    enabled = w.path.work == nil,
    event = 'VeryLazy',
    config = function()
      -- c-l clears the buffer everytime
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'codecompanion',
        callback = function()
          vim.keymap.set(
            { 'n' },
            '<c-l>',
            'zz',
            { buffer = true, noremap = true, silent = true }
          )
        end,
      })
      vim.keymap.set(
        { 'n', 'v' },
        '<leader>aa',
        '<cmd>CodeCompanionActions<cr>',
        { noremap = true, silent = true, desc = 'code-companion-actions' }
      )
      vim.keymap.set(
        'n',
        '<leader>ac',
        '<cmd>CodeCompanionChat Toggle<cr>',
        { noremap = true, silent = true, desc = 'code-companion-chat' }
      )
      vim.keymap.set(
        'v',
        '<leader>ac',
        '<cmd>CodeCompanionChat Toggle<cr>',
        { noremap = true, silent = true, desc = 'code-companion-chat-add' }
      )

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanionChat]])
      require('codecompanion').setup({
        adapters = {
          lmstudio = function()
            return require('codecompanion.adapters').extend(
              'openai_compatible',
              {
                env = {
                  url = 'http://192.168.1.96:11435', -- default ollama endpoint
                },
                parameters = {
                  model = 'gpt-oss:20b', -- or whichever model you chose
                },
              }
            )
          end,
          anthropic = function()
            return require('codecompanion.adapters').extend('anthropic', {
              env = {
                api_key = os.getenv('ANTHROPIC_API_KEY'),
              },
            })
          end,
          openai = function()
            return require('codecompanion.adapters').extend('openai', {
              env = {
                api_key = os.getenv('OPENAI_API_KEY'),
              },
            })
          end,
        },
        display = {
          chat = {
            intro_message = 'Welcome to CodeCompanion! Press ? for options',
            show_header_separator = false, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
            separator = '-', -- The separator between the different messages in the chat buffer
            show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
            show_settings = true, -- Show LLM settings at the top of the chat buffer?
            show_token_count = true, -- Show the token count for each response?
            start_in_insert_mode = false, -- Open the chat buffer in insert mode?
            window = {
              layout = 'buffer', -- float|vertical|horizontal|buffer
            },
          },
        },
        strategies = {
          inline = {
            keymaps = {
              accept_change = {
                modes = { n = '<leader>ay' },
                description = 'Accept the suggested change',
              },
              reject_change = {
                modes = { n = '<leader>ar' },
                description = 'Reject the suggested change',
              },
            },
          },
          chat = {
            adapter = 'anthropic',
            keymaps = {
              send = {
                modes = { n = '<C-g>', i = '<C-g>' },
              },
              close = {
                modes = { n = '<nop>', i = '<nop>' },
              },
              -- Add further custom keymaps here
            },
          },
          inline = {
            adapter = 'anthropic',
          },
        },
      })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
}
