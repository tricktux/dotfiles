local w = require('plugin.wiki')
local opt = require('options')

local hsavedir = w.path.personal ~= nil
    and vim.fs.joinpath(w.path.personal, 'ai/ai-history/codecommpanion.nvim')
  or vim.fs.joinpath(vim.fn.stdpath('data'), '/codecompanion-history')

local prompts_dir = w.path.personal ~= nil
    and vim.fs.joinpath(w.path.personal, 'ai/prompts')
  or nil

--- Read a prompt file from the prompts directory.
--- Returns nil if prompts_dir is not set or file doesn't exist.
---@param filename string
---@return string|nil
local function read_prompt(filename)
  if not prompts_dir then
    return nil
  end
  local path = vim.fs.joinpath(prompts_dir, filename)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines then
    return nil
  end
  return table.concat(lines, '\n')
end

local prompt_library = {
  ['Software Developer'] = {
    interaction = 'chat',
    description = 'Expert software developer and helpful coding assistant',
    opts = {
      alias = 'dev',
    },
    prompts = {
      {
        role = 'system',
        content = function()
          return read_prompt('dev.md')
            or [[
You are an expert software developer and helpful coding assistant.
Primary languages: Zig, Rust, C, C++, Python, and Lua.
Be concise and precise. Show only the relevant changed parts of any code.
Ask clarifying questions when helpful.
          ]]
        end,
      },
    },
  },
  ['General Assistant'] = {
    interaction = 'chat',
    description = 'Helpful, thoughtful, and knowledgeable assistant for any topic',
    opts = {
      alias = 'general',
    },
    prompts = {
      {
        role = 'system',
        content = function()
          return read_prompt('general.md')
            or [[
You are a helpful, thoughtful, and knowledgeable assistant.
Be warm, empathetic, and thorough. Ask clarifying questions when helpful.
          ]]
        end,
      },
    },
  },
  ['Anki Flashcard Creator'] = {
    interaction = 'chat',
    description = 'Creates focused Anki flashcards for software engineers',
    opts = {
      alias = 'anki',
    },
    prompts = {
      {
        role = 'system',
        content = function()
          return read_prompt('anki.md')
            or [[
You are an expert at creating Anki flashcards for software engineers.
Follow Piotr Wozniak's "Twenty Rules of Formulating Knowledge" strictly.
Keep answers SHORT. Output format: Q: <question> / A: <short answer>.
          ]]
        end,
      },
    },
  },
}

local h = {
  enabled = true,
  opts = {
    -- Keymap to open history from chat buffer (default: gh)
    keymap = 'gh',
    -- Keymap to save the current chat manually (when auto_save is disabled)
    save_chat_keymap = 'gS',
    -- Save all chats by default (disable to save only manually using 'sc')
    auto_save = true,
    -- Number of days after which chats are automatically deleted (0 to disable)
    expiration_days = 0,
    -- Picker interface (auto resolved to a valid picker)
    picker = 'telescope', --- ("telescope", "snacks", "fzf-lua", or "default")
    ---Optional filter function to control which chats are shown when browsing
    chat_filter = nil, -- function(chat_data) return boolean end
    -- Customize picker keymaps (optional)
    picker_keymaps = {
      rename = { n = 'r', i = '<M-r>' },
      delete = { n = 'd', i = '<M-d>' },
      duplicate = { n = '<C-y>', i = '<C-y>' },
    },
    ---Automatically generate titles for new chats
    auto_generate_title = true,
    title_generation_opts = {
      ---Adapter for generating titles (defaults to current chat adapter)
      adapter = nil, -- "copilot"
      ---Model for generating titles (defaults to current chat model)
      model = nil, -- "gpt-4o"
      ---Number of user prompts after which to refresh the title (0 to disable)
      refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
      ---Maximum number of times to refresh the title (default: 3)
      max_refreshes = 3,
      format_title = function(original_title)
        -- this can be a custom function that applies some custom
        -- formatting to the title.
        return original_title
      end,
    },
    ---On exiting and entering neovim, loads the last chat on opening chat
    continue_last_chat = false,
    ---When chat is cleared with `gx` delete the chat from history
    delete_on_clearing_chat = false,
    ---Directory path to save the chats
    dir_to_save = hsavedir,
    ---Enable detailed logging for history extension
    enable_logging = false,

    -- Summary system
    summary = {
      -- Keymap to generate summary for current chat (default: "gcs")
      create_summary_keymap = 'gcs',
      -- Keymap to browse summaries (default: "gbs")
      browse_summaries_keymap = 'gbs',

      generation_opts = {
        adapter = nil, -- defaults to current chat adapter
        model = nil, -- defaults to current chat model
        context_size = 90000, -- max tokens that the model supports
        include_references = true, -- include slash command content
        include_tool_outputs = true, -- include tool execution results
        system_prompt = nil, -- custom system prompt (string or function)
        format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
      },
    },

    -- Memory system (requires VectorCode CLI)
    memory = {
      -- Automatically index summaries when they are generated
      auto_create_memories_on_summary_generation = false,
      -- Path to the VectorCode executable
      vectorcode_exe = 'vectorcode',
      -- Tool configuration
      tool_opts = {
        -- Default number of memories to retrieve
        default_num = 10,
      },
      -- Enable notifications for indexing progress
      notify = true,
      -- Index all existing memories on startup
      -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
      index_on_startup = false,
    },
  },
}

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
          opt.set_text_settings()
          vim.keymap.set(
            { 'n' },
            '<c-l>',
            'zz',
            { buffer = true, noremap = true, silent = true }
          )
          -- Set path to recent screenshots for easy `/images` integration
          if vim.fn.has('unix') > 0 then
            vim.fn.mkdir('/tmp/screenshots', 'p')
            vim.cmd.cd('/tmp/screenshots')
          end
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
        extensions = {
          history = h,
        },
        prompt_library = prompt_library,
        adapters = {
          http = {
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
            xai = function()
              return require('codecompanion.adapters').extend('xai', {
                env = {
                  api_key = 'XAI_API_KEY',
                },
                schema = {
                  model = {
                    default = 'grok-4',
                  },
                },
              })
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
        },
      })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'ravitemer/codecompanion-history.nvim',
    },
  },
}
