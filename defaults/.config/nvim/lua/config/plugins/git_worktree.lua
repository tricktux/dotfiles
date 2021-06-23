
local M = {}

function M.setup()
  -- Workflow is:
  -- mkcdir neovim
  -- git clone <neovim> --bare
  -- git worktree add master <branch>
  -- Then you'll have: neovim/{master,neovim.git,<other_workstrees>}
  if not utl.is_mod_available('git-worktree') then
    api.nvim_err_writeln('git-worktree module not available')
    return
  end

  if not utl.is_mod_available('which-key') then
    api.nvim_err_writeln('which-key module not available')
    return
  end
  local wk = require("which-key")

  local gw = require('git-worktree')
  gw.setup({update_on_change = true, clearjumps_on_change = true})

  local mapping_prefix = {prefix = [[<leader>v]]}
  local function get_worktree_name(upstream)
    local wt_name = nil
    wt_name = vim.fn.input("New worktree name?\n")
    if wt_name == nil then return end

    local upstream_name = nil
    if upstream ~= nil then
      upstream_name = vim.fn.input("Branch?\n", [[upstream/master]])
    end

    return {wt_name, upstream_name}
  end

  local gwa = function() gw.create_worktree(get_worktree_name(true)) end
  local gwd = function() gw.delete_worktree(get_worktree_name()) end
  local gws = function() gw.switch_worktree(get_worktree_name()) end

  local mapping = {}
  mapping.w = {
    name = 'worktree',
    a = {gwa, 'create'},
    d = {gwd, 'delete'},
    s = {gws, 'switch'},
  }
  if utl.is_mod_available('telescope') then
    local t = require('telescope')
    t.load_extension("git_worktree")
    -- To bring up the telescope window listing your workspaces run the following
    mapping.w.s = {t.extensions.git_worktree.git_worktrees, 'switch'}
    -- <Enter> - switches to that worktree
    -- <c-d> - deletes that worktree
    -- <c-D> - force deletes that worktree
  end
  wk.register(mapping, mapping_prefix)
end

return M
