local M = {}

function M:config()
  local ls = require "luasnip"
  local types = require "luasnip.util.types"

  ls.config.set_config {
    -- This tells LuaSnip to remember to keep around the last snippet.
    -- You can jump back into it even if you move outside of the selection
    history = true,

    -- This one is cool cause if you have dynamic snippets, it updates as you type!
    updateevents = "TextChanged,TextChangedI",

    -- Autosnippets:
    enable_autosnippets = true,

    -- Crazy highlights!!
    -- ext_opts = nil,
    ext_opts = {
      [types.choiceNode] = {active = {virt_text = {{"●", "GruvboxOrange"}}}},
      [types.insertNode] = {active = {virt_text = {{"●", "GruvboxBlue"}}}}
    }
  }

  ls.filetype_extend("all", {"_"})
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()
  -- Load snippets from my-snippets folder
  -- If path is not specified, luasnip will look for the `snippets` directory
  -- in rtp (for custom-snippet probably
  -- -- `~/.config/nvim/snippets`).
  require("luasnip.loaders.from_snipmate").load({
    path = {vim.g.std_config_path .. [[/snippets/]]}
  })

  local wk = require("which-key")
  local mappings = {
    -- <c-k> is my expansion key
    -- this will expand the current item or jump to the next item within the snippet.
    ["<c-k>"] = {
      function() if ls.expand_or_jumpable() then ls.expand_or_jump() end end,
      "expand_snippet"
    },
    -- <c-j> is my jump backwards key.
    -- this always moves to the previous item within the snippet
    ["<c-j>"] = {
      function() if ls.jumpable(-1) then ls.jump(-1) end end, "in_snippet_prev"
    },
    -- <c-l> is selecting within a list of options.
    -- This is useful for choice nodes (introduced in the forthcoming episode 2)
    ["<c-l>"] = {
      function() if ls.choice_active() then ls.change_choice(1) end end,
      "in_snippet_select"
    }
  }
  wk.register(mappings, {mode = "i"})
  wk.register(mappings, {mode = "s"})
  --[[ vim.keymap.set({ "i", "s" }, "<c-k>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, { silent = true }) ]]
  --[[ vim.keymap.set({ "i", "s" }, "<c-j>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, { silent = true })

  vim.keymap.set("i", "<c-l>", function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end) ]]

  -- shorcut to source my luasnips file again, which will reload my snippets
  -- vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<CR>")
end

return M
