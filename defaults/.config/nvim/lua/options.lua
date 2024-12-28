local M = {}

function M:unix()
  if vim.fn.has('unix') <= 0 then
    return
  end

  -- Source: https://www.reddit.com/r/neovim/comments/1e9vllk/neovim_weird_issue_when_copypasting_using_osc_52/
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

  local k = os.getenv('KITTY_WINDOW_ID') ~= nil
  local oscplus = require('vim.ui.clipboard.osc52').paste('+')
  local oscast = require('vim.ui.clipboard.osc52').paste('*')

  vim.g.clipboard = {
    name = 'osc52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = k and oscplus or paste,
      ['*'] = k and oscast or paste,
    },
  }
end

function M:windows()
  if vim.fn.has('win32') <= 0 then
    return
  end
end

function M:setup()
  self:unix()
  self:windows()
  vim.opt.inccommand = 'split'
  vim.opt.shada = {
    [['1024]],
    -- Do not restore buffer list, leave that for sessions
    -- [[%]],
    's10000',
    -- Removable media below, avoid storing marks on these drivers
    'r/tmp', -- Unix
    'rE:', -- Windows
    'rF:',
  }
  vim.opt.signcolumn = 'yes:1'
  -- https://www.reddit.com/r/neovim/comments/zg44mm/comment/izfdbtw/?utm_source=reddit&utm_medium=web2x&context=3
  vim.opt.virtualedit = 'block'

  -- diagnostics
  vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    signs = true,
    update_in_insert = false,
    float = { source = 'if_many' },
  })

  -- Coming from lazyvim
  vim.opt.laststatus = 3

  if vim.fn.has('nvim-0.9.0') >= 1 then
    vim.opt.splitkeep = 'cursor'
    vim.opt.shortmess:append('C')
  end

  -- Fix markdown indentation settings
  vim.g.markdown_recommended_style = 0
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
end

return M
