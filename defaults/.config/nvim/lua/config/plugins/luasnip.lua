local M = {}

function M.__setup_orgmode_snippets()
  local ls = require("luasnip")
  local c = ls.choice_node
  local s = ls.s
  local fmt = require("luasnip.extras.fmt").fmt
  local i = ls.insert_node
  local t = ls.text_node
  local f = ls.function_node
  local e = require("luasnip.extras")
  local function get_date_time()
    return os.date("%Y-%m-%d %a %H:%M")
  end

  local function get_date()
    return os.date("%Y-%m-%d %a")
  end

  local function schedule()
    return require("orgmode").action("org_mappings.org_schedule")
  end

  local todo_snips = {}
  for k = 1, 3 do
    table.insert(
      todo_snips,
      s(
        string.rep("d", k),
        fmt(
          [[
    {} TODO {}
      {}
      {}
    ]]     ,
          {
            t(string.rep("*", k)),
            i(1, "description"),
            f(function()
              return "DEADLINE: <" .. get_date() .. ">"
            end, {}),
            f(function()
              return "[" .. get_date_time() .. "]"
            end, {}),
          }
        )
      )
    )
    table.insert(
      todo_snips,
      s(
        string.rep("t", k),
        fmt(
          [[
    {} TODO {}
      {}
      {}
    ]]     ,
          {
            t(string.rep("*", k)),
            i(1, "description"),
            f(function()
              return "SCHEDULED: <" .. get_date() .. ">"
            end, {}),
            f(function()
              return "[" .. get_date_time() .. "]"
            end, {}),
          }
        )
      )
    )
  end

  table.insert(
    todo_snips,
    s(
      "tc",
      fmt(
        [[
  {} TODO {}
    {}
    {}
  ]]     ,
        {
          c(1, {
            i(nil, "*"),
            i(nil, "**"),
            i(nil, "***"),
          }),
          i(2, "description"),
          f(function()
            return "SCHEDULED: <" .. get_date() .. ">"
          end, {}),
          f(function()
            return "[" .. get_date_time() .. "]"
          end, {}),
        }
      )
    )
  )

  ls.add_snippets("org", todo_snips)
end

function M:config()
  local ls = require("luasnip")
  local types = require("luasnip.util.types")

  self.__setup_orgmode_snippets()

  ls.config.set_config({
    -- This tells LuaSnip to remember to keep around the last snippet.
    -- You can jump back into it even if you move outside of the selection
    history = true,

    -- This one is cool cause if you have dynamic snippets, it updates as you type!
    updateevents = "TextChanged,TextChangedI",

    -- Autosnippets:
    enable_autosnippets = false,

    -- Crazy highlights!!
    -- ext_opts = nil,
    ext_opts = {
      [types.choiceNode] = { active = { virt_text = { { "● (c-n)", "GruvboxOrange" } } } },
      [types.insertNode] = { active = { virt_text = { { "●", "GruvboxBlue" } } } },
    },
  })

  ls.filetype_extend("all", { "_" })
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()
  -- Load snippets from my-snippets folder
  -- If path is not specified, luasnip will look for the `snippets` directory
  -- in rtp (for custom-snippet probably
  -- -- `~/.config/nvim/snippets`).
  require("luasnip.loaders.from_snipmate").load({
    path = { vim.fn.stdpath("config") .. [[/snippets/]] },
  })

  local opts = { silent = true, desc = "snippet_expand_or_jumpable" }
  vim.keymap.set({ "i", "s" }, "<c-k>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, opts)

  opts.desc = "snippet_jumpable"
  vim.keymap.set({ "i", "s" }, "<c-j>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, opts)

  opts.desc = "snippet_choice_active"
  vim.keymap.set({ "i", "s" }, "<c-n>", function()
    require("luasnip.extras.select_choice")()
  end, opts)
end

return M
