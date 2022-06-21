local utl = require("utils.utils")
local vks = vim.keymap.set

local M = {}

function M.setup()
  -- Workflow is:
  -- mkcdir neovim
  -- git clone <neovim> --bare
  -- git worktree add master <branch>
  -- Then you'll have: neovim/{master,neovim.git,<other_workstrees>}
  local gw = require("git-worktree")
  gw.setup({ update_on_change = true, clearjumps_on_change = true })

  local function get_worktree_name(upstream)
    local wt_name = nil
    wt_name = vim.fn.input("New worktree name?\n")
    if wt_name == nil then
      return
    end

    local upstream_name = nil
    if upstream ~= nil then
      upstream_name = vim.fn.input("Branch?\n", [[upstream/master]])
    end

    return { wt_name, upstream_name }
  end

  local gwa = function()
    gw.create_worktree(get_worktree_name(true))
  end
  local gwd = function()
    gw.delete_worktree(get_worktree_name())
  end
  local gws = function()
    gw.switch_worktree(get_worktree_name())
  end

  local opts = { silent = true }
  local prefix = [[<leader>vw]]
  local mappings = {}
  mappings = {
    a = { gwa, "create" },
    d = { gwd, "delete" },
    s = { gws, "switch" },
  }
  local tl_ok, tl = pcall(require, "telescope")
  if tl_ok then
    tl.load_extension("git_worktree")
    -- To bring up the telescope window listing your workspaces run the following
    opts.desc = "switch"
    vks("n", prefix .. "s", tl.extensions.git_worktree.git_worktrees, opts)
    -- <Enter> - switches to that worktree
    -- <c-d> - deletes that worktree
    -- <c-D> - force deletes that worktree
  end
  utl.keymaps_set(mappings, "n", opts, prefix)
end

return M
