local fs = require("utils.filesystem")
local home = vim.loop.os_homedir()

local M = {}

M.wikis = {}
M.wikis.default = {
  name = "personal",
  path = vim.fs.joinpath(home, "Documents/wiki"),
}
M.wikis.work = {
  vim.fs.joinpath(home, "Documents/work/wiki"),
}

M.wikis.personal = {
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
    {
      "<leader>wf",
      function()
        vim.print(vim.inspect(M.opts.workspaces))
        local w = M.opts.workspaces[1].path
        fs.path.fuzzer(w)
      end,
      desc = "obsidian_fuzzy",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    M.find_workspace(M.wikis.work, "work")
    M.find_workspace(M.wikis.personal, "personal")
    if vim.tbl_isempty(M.opts.workspaces) then
      M.opts.workspaces = M.wikis.default
    end
  end,
  opts = M.opts,
}
