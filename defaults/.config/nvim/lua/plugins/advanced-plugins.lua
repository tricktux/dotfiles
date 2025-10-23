if vim.g.advanced_plugins == 0 then
  return {}
end

return {
  { 'matze/vim-ini-fold',   ft = 'dosini' },
  { 'aklt/plantuml-syntax', ft = 'plantuml' },
  {
    'johmsalas/text-case.nvim',
    config = function()
      require('textcase').setup({
        default_keymappings_enabled = true,
        prefix = '<leader>rc',
      })
    end,
    cmd = {
      -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
      'Subs',
      'TextCaseStartReplacingCommand',
    },
    -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
    -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
    -- available after the first executing of it or after a keymap of text-case.nvim has been used.
    lazy = false,
  },
}
