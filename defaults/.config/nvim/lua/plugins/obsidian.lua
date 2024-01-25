local fs = require("utils.filesystem")
local home = vim.loop.os_homedir()

local M = {}

M.work_wikis = {
  vim.fs.joinpath(home, "Documents/work/wiki"),
}

M.personal_wikis = {
  vim.fs.joinpath(home, "Documents/wiki"),
  vim.fs.joinpath(home, "Documents/Nextcloud/wiki"),
  vim.fs.joinpath(home, "Documents/Drive/wiki"),
  vim.fs.joinpath(home, "External/reinaldo/resilio/wiki"),
  "/mnt/samba/server/resilio/wiki",
  [[D:\Seafile\KnowledgeIsPower\wiki]],
  [[D:\wiki]],
  [[D:\Reinaldo\Documents\src\resilio\wiki]],
}

M.opts = {
  workspaces = {},
  mappings = {},
  daily_notes = {
    folder = "dailies",
  },
}

M.find_workspace = function(wikis, name)
  for _, dir in pairs(wikis) do
    local w = fs.is_path(dir)
    if w then
      table.insert(M.opts.workspaces, { name = name, path = w })
      break
    end
  end
end

return {
  "epwalsh/obsidian.nvim",
  keys = {
    { "<leader>wj", "<cmd>ObsidianToday<cr>",              desc = "obsidian_daily" },
    { "<leader>wa", "<cmd>ObsidianNew<cr>",                desc = "obsidian_new" },
    { "<leader>wp", "<cmd>ObsidianWorkspace personal<cr>", desc = "obsidian_workspace_personal" },
    { "<leader>ww", "<cmd>ObsidianWorkspace work<cr>",     desc = "obsidian_workspace_work" },
    { "<leader>ws", "<cmd>ObsidianSearch<cr>",             desc = "obsidian_workspace_work" },
    { "<leader>wo", "<cmd>ObsidianOpen<cr>",               desc = "obsidian_open" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    M.find_workspace(M.work_wikis, "work")
    M.find_workspace(M.personal_wikis, "personal")
  end,
  opts = M.opts,
}
