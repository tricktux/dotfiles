local M = {}

local time_fmt = {
  date_time = '%Y-%m-%d %a %H:%M',
  date = '%Y-%m-%d %a',
  day_dtime = '%a %b %d %Y %H:%M',
}
local function get_date_time(fmt)
  return os.date(fmt)
end

function M.__setup_text_snippets()
  local ls = require('luasnip')
  local s = ls.s
  local i = ls.insert_node
  local fmt = require('luasnip.extras.fmt').fmt
  local t = ls.text_node
  local f = ls.function_node

  local text_snippet = {}
  local signature = [[
  {},
  Reinaldo Molina
  ]]
  table.insert(
    text_snippet,
    s(
      's',
      fmt(signature, {
        i(1, 'Regards'),
      })
    )
  )
  table.insert(
    text_snippet,
    s(
      'h',
      fmt([[Hi{},]], {
        i(1, ' Juanito'),
      })
    )
  )
  table.insert(
    text_snippet,
    s(
      'd',
      fmt([[{}]], {
        f(function()
          return get_date_time(time_fmt.day_dtime)
        end),
      })
    )
  )
  ls.add_snippets('text', text_snippet)
  ls.add_snippets('markdown', text_snippet)
end

function M.__setup_orgmode_snippets()
  local ls = require('luasnip')
  local c = ls.choice_node
  local s = ls.s
  local fmt = require('luasnip.extras.fmt').fmt
  local i = ls.insert_node
  local t = ls.text_node
  local f = ls.function_node
  local e = require('luasnip.extras')

  local todo_snips = {}
  for k = 1, 5 do
    table.insert(
      todo_snips,
      s(
        string.rep('d', k),
        fmt(
          [[
    {} TODO {}
      {}
      {}
    ]],
          {
            t(string.rep('*', k)),
            i(1, 'description'),
            f(function()
              return 'DEADLINE: <' .. get_date_time(time_fmt.date) .. '>'
            end, {}),
            f(function()
              return '[' .. get_date_time(time_fmt.date_time) .. ']'
            end, {}),
          }
        )
      )
    )
    table.insert(
      todo_snips,
      s(
        string.rep('t', k),
        fmt(
          [[
    {} TODO {}
      {}
      {}
    ]],
          {
            t(string.rep('*', k)),
            i(1, 'description'),
            f(function()
              return 'SCHEDULED: <' .. get_date_time(time_fmt.date) .. '>'
            end, {}),
            f(function()
              return '[' .. get_date_time(time_fmt.date_time) .. ']'
            end, {}),
          }
        )
      )
    )
  end

  table.insert(
    todo_snips,
    s(
      'tc',
      fmt(
        [[
  {} TODO {}
    {}
    {}
  ]],
        {
          c(1, {
            i(nil, '*'),
            i(nil, '**'),
            i(nil, '***'),
          }),
          i(2, 'description'),
          f(function()
            return 'SCHEDULED: <' .. get_date_time(time_fmt.date) .. '>'
          end, {}),
          f(function()
            return '[' .. get_date_time(time_fmt.date_time) .. ']'
          end, {}),
        }
      )
    )
  )

  ls.add_snippets('org', todo_snips)
end

function M.__setup_cpp_snippets()
  local ls = require('luasnip')
  local s = ls.s
  local fmt = require('luasnip.extras.fmt').fmt
  local fmta = require('luasnip.extras.fmt').fmta
  local l = require('luasnip.extras').lambda
  local rep = require('luasnip.extras').rep
  local i = ls.insert_node
  local t = ls.text_node

  local types = { 'info', 'warn', 'error' }
  local log_snippet = {}
  for _, v in pairs(types) do
    local tp = string.sub(v, 1, 1)
    local str = string.format([[LG.%s("{}"{});]], v)
    table.insert(
      log_snippet,
      s(
        'lg' .. tp,
        fmt(str, {
          i(1, 'description'),
          i(2, ', variables'),
        })
      )
    )
  end
  ls.add_snippets('cpp', log_snippet)
  ls.add_snippets('c', log_snippet)

  local cout = s(
    'cout',
    fmt([[std::cout << "{}\n";]], {
      i(1, 'description'),
    })
  )
  local singleton = s(
    'singleton',
    fmta(
      [[
        class <name>
        {
            <>() {}                    // Constructor? (the {} brackets) are needed here.

            // C++ 03
            // ========
            // Don't forget to declare these two. You want to make sure they
            // are unacceptable otherwise you may accidentally get copies of
            // your singleton appearing.
            <>(<> const&);              // Don't Implement
            void operator=(<> const&);  // Don't implement

        public:
            static <>& GetInstance()
            {
                static <> instance; // Guaranteed to be destroyed.
                                      // Instantiated on first use.
                return instance;
            }
            // C++ 11
            // =======
            // We can use the better technique of deleting the methods
            // we don't want.
            // Note: Scott Meyers mentions in his Effective Modern
            //       C++ book, that deleted functions should generally
            //       be public as it results in better error messages
            //       due to the compilers behavior to check accessibility
            //       before deleted status
            <>(<> const&)          = delete;
            void operator=(<> const&)  = delete;
        };
      ]],
      {
        name = i(1, 'name'),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
        rep(1),
      }
    )
  )
  local clock = s('clock', {
    t([[
        #include <chrono>
        auto start = std::chrono::high_resolution_clock::now();
        // function here
        auto stop = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start);
        std::cout << "Time taken by function: "
            << duration.count() << " microseconds\n";
      ]]),
  })
  ls.add_snippets('cpp', { cout, clock, singleton })
end

function M:config()
  local ls = require('luasnip')
  local types = require('luasnip.util.types')

  self.__setup_orgmode_snippets()
  self.__setup_cpp_snippets()
  self.__setup_text_snippets()

  ls.config.set_config({
    -- This tells LuaSnip to remember to keep around the last snippet.
    -- You can jump back into it even if you move outside of the selection
    keep_roots = true,
    link_roots = true,
    link_children = true,

    -- This one is cool cause if you have dynamic snippets, it updates as you type!
    updateevents = 'TextChanged,TextChangedI',

    -- Autosnippets:
    enable_autosnippets = false,

    -- Crazy highlights!!
    -- ext_opts = nil,
    ext_opts = {
      [types.choiceNode] = { active = { virt_text = { { '● (c-n)', 'GruvboxOrange' } } } },
      [types.insertNode] = { active = { virt_text = { { '●', 'GruvboxBlue' } } } },
    },
  })

  ls.filetype_extend('all', { '_' })
  require('luasnip.loaders.from_vscode').lazy_load()
  require('luasnip.loaders.from_snipmate').lazy_load()
  -- Load snippets from my-snippets folder
  -- If path is not specified, luasnip will look for the `snippets` directory
  -- in rtp (for custom-snippet probably
  -- -- `~/.config/nvim/snippets`).
  require('luasnip.loaders.from_snipmate').lazy_load({
    path = { vim.fn.stdpath('config') .. [[/snippets/]] },
  })

  local opts = { silent = true, desc = 'snippet_expand_or_jumpable' }
  vim.keymap.set({ 'i', 's' }, '<c-k>', function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, opts)

  opts.desc = 'snippet_jumpable'
  vim.keymap.set({ 'i', 's' }, '<c-j>', function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, opts)

  opts.desc = 'snippet_choice_active'
  vim.keymap.set({ 'i', 's' }, '<c-n>', function()
    require('luasnip.extras.select_choice')()
  end, opts)
end

return {
  'L3MON4D3/LuaSnip',
  event = 'InsertEnter',
  dependencies = {
    'rafamadriz/friendly-snippets',
  },
  -- version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  config = function()
    M:config()
  end,
  build = vim.g.advanced_plugins > 0 and 'make install_jsregexp' or '',
}
