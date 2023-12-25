if vim.fn.has("win32") > 0 then
  return {}
end

return {
  { "mboughaba/i3config.vim", ft = "i3config" },
  { "lambdalisue/suda.vim", cmd = { "SudaWrite", "SudaRead" } },
  { "chr4/nginx.vim", ft = "nginx" },
  { "neomutt/neomutt.vim", ft = "muttrc" },
  { "fladson/vim-kitty", ft = "kitty" },
  {
    "untitled-ai/jupyter_ascending.vim",
    ft = "python",
    init = function()
      vim.g.jupyter_ascending_default_mappings = false
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = "*.sync.py",
        callback = function()
          if vim.b.has_jupyter_plugin == true then
            return
          end
          vim.b.has_jupyter_plugin = true
          local opts = { silent = true, buffer = true, desc = "jupyter_execute" }
          vim.keymap.set("n", "<localleader>j", "<Plug>JupyterExecute", opts)
          opts.desc = "jupyter_execute_all"
          vim.keymap.set("n", "<localleader>k", "<Plug>JupyterExecuteAll", opts)
        end,
      })
    end,
  },
  {
    "giusgad/pets.nvim",
    opts = {},
    cmd = { "PetsNewCustom", "PetsNew" },
    dependencies = { "MunifTanjim/nui.nvim" },
  },
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    config = function()
      require('kitty-scrollback').setup()
    end,
  },
}
