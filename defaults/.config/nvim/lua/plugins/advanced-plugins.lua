if vim.g.advanced_plugins == 0 then
  return {}
end

return {
  {
    "robitx/gp.nvim",
    keys = {
      {
        '<plug>ai',
        '<cmd>GpChatNew vsplit<cr>',
        desc = 'ai_help',
      },
    },
    config = function()
      local conf = {
        -- For customization, refer to Install > Configuration in the Documentation/Readme
        -- default agent names set during startup, if nil last used agent is used
        default_command_agent = "ChatGPT4o-mini",
        default_chat_agent = "ChatGPT4o-mini",
        -- log_sensitive = true,
      }
      require("gp").setup(conf)
    end,
  },
  {
    'HakonHarnes/img-clip.nvim',
    ft = { 'markdown', 'org', 'quarto', 'tex' },
    cmd = { 'PasteImage' },
    -- event = "BufEnter",
    opts = {
      default = {
        relative_to_current_file = true, -- make dir_path relative to current file rather than the cwd
        relative_template_path = false, -- make file path in the template relative to current file rather than the cwd
        dir_path = 'attachements',
      },
      quarto = {
        template = '![$CURSOR]($FILE_PATH)',
      },
    },
    keys = {
      { '<localleader>i', '<cmd>PasteImage<cr>', desc = 'Paste clipboard image' },
    },
  },
  { 'matze/vim-ini-fold', ft = 'dosini' },
  { 'aklt/plantuml-syntax', ft = 'plantuml' },
  {
    'JellyApple102/easyread.nvim',
    ft = { 'markdown', 'text', 'org', 'quarto' },
    opts = {
      hlValues = {
        ['1'] = 1,
        ['2'] = 1,
        ['3'] = 2,
        ['4'] = 2,
        ['fallback'] = 0.4,
      },
      hlgroupOptions = { link = 'Bold' },
      fileTypes = { 'text', 'markdown', 'org', 'quarto' },
      saccadeInterval = 0,
      saccadeReset = false,
      updateWhileInsert = true,
    },
  },
}
