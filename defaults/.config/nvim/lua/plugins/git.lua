local map = require('mappings')

return {
  'tpope/vim-fugitive',
  cmd = 'Git',
  keys = {
    {
      map.vcs.prefix .. 'p',
      function()
        local base = vim.fn.input('Base branch: ', 'develop')
        if base ~= '' then
          vim.cmd('Git difftool -y ' .. base .. '..HEAD')
        end
      end,
      desc = 'PR review (diff vs base branch)',
    },
  },
}
