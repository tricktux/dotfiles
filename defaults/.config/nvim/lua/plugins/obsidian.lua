local fs = require("utils.utils").fs
local w = require("plugin.wiki")

local M = {}

M.opts = {
  workspaces = {},
  mappings = {},
  daily_notes = {
    folder = "monthlies",
    -- weekly
    date_format = "%Y-%m",
    alias_format = "%B, %Y",
  },
}

return {
  "epwalsh/obsidian.nvim",
  keys = {
    { "<leader>wj", "<cmd>ObsidianToday<cr>",              desc = "obsidian_daily" },
    { "<leader>wa", "<cmd>ObsidianNew<cr>",                desc = "obsidian_new" },
    { "<leader>wp", "<cmd>ObsidianWorkspace personal<cr>", desc = "obsidian_workspace_personal" },
    { "<leader>ww", "<cmd>ObsidianWorkspace work<cr>",     desc = "obsidian_workspace_work" },
    { "<leader>ws", "<cmd>ObsidianSearch<cr>",             desc = "obsidian_workspace_work" },
    { "<leader>wo", "<cmd>ObsidianOpen<cr>",               desc = "obsidian_open" },
    {
      "<leader>wf",
      function()
        local c = require("obsidian").get_client()
        fs.path.fuzzer(c:vault_root().filename)
      end,
      desc = "obsidian_fuzzy",
    },
    {
      "<leader>wt",
      function()
        local c = require("obsidian").get_client()
        -- TODO: set arguments
        c:find_tags()
      end,
      desc = "obsidian_tags",
    }
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    if w.path.work ~= nil then table.insert(M.opts.workspaces, { name = "work", path = w.path.work }) end
    if w.path.personal ~= nil then table.insert(M.opts.workspaces, { name = "personal", path = w.path.personal }) end
    -- vim.print(vim.inspect(M.opts.workspaces))
    require("obsidian").setup(M.opts)
  end,
  -- opts = M.opts,
}