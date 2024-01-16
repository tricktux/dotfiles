local M = {}

function M:setup()
  vim.opt.hidden = true
  vim.opt.timeout = true
  vim.opt.timeoutlen = 100
  -- Tab management
  -- No tabs in the code. Tabs are expanded to spaces
  vim.opt.expandtab = true
  vim.opt.shiftround = true
  vim.opt.softtabstop = -8 -- Use value of shiftwidth
  vim.opt.shiftwidth = 4 -- Always set this two values to the same
  vim.opt.tabstop = 4
  ----------------------------
  -- Title
  vim.opt.title = true
  vim.opt.titlelen = 90 -- Percent of columns
  ----------------------------
  vim.opt.updatetime = 100
  vim.opt.display:append("uhex")
  vim.opt.sessionoptions = { "buffers", "tabpages" }
  vim.opt.foldlevel = 99  -- Do not fold code at startup
  vim.opt.foldmethod = "syntax"
  vim.opt.mouse = ""
  vim.opt.background = "light" -- This forces lualine to use the right theme
  vim.opt.laststatus = 3
  vim.opt.cmdheight = 1
  vim.opt.spell = true
  vim.opt.spelllang = "en_us"
  vim.opt.inccommand = "split"
  vim.opt.wrapscan = false
  vim.opt.showtabline = 1
  vim.opt.shada = {
    [['1024]],
    -- Do not restore buffer list, leave that for sessions
    -- [[%]],
    "s10000",
    -- Removable media below, avoid storing marks on these drivers
    "r/tmp", -- Unix
    "rE:", -- Windows
    "rF:"
  }
  vim.opt.signcolumn = "yes:1"
  vim.opt.number = false
  vim.opt.relativenumber = true
  vim.opt.numberwidth = 1
  -- Supress messages
  -- a - Usefull abbreviations
  -- c - Do no show match 1 of 2
  -- o and O no enter when openning files
  -- s - Do not show search hit bottom
  -- t - Truncate message if is too long
  vim.opt.shortmess = "aoOcst"
  if vim.fn.has("unix") <= 0 then
    vim.opt.shell = "powershell"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
  -- https://www.reddit.com/r/neovim/comments/zg44mm/comment/izfdbtw/?utm_source=reddit&utm_medium=web2x&context=3
  vim.opt.virtualedit = "block"

  -- diagnostics
  vim.diagnostic.config {
    virtual_text = false,
    underline = true,
    signs = true,
    update_in_insert = false,
    float = { source = "if_many" },
  }

  -- Coming from lazyvim
  vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
  vim.opt.autowrite = true -- Enable auto write
  vim.opt.completeopt = "menu,menuone,noselect"
  vim.opt.formatoptions = "jcroqlnt" -- tcqj
  vim.opt.ignorecase = true -- Ignore case
  vim.opt.pumheight = 10 -- Maximum number of entries in a popup
  vim.opt.scrolloff = 4 -- Lines of context
  vim.opt.sidescrolloff = 8 -- Columns of context
  vim.opt.smartindent = true -- Insert indents automatically
  vim.opt.termguicolors = true -- True color support
  vim.opt.wildmode = "longest:full,full" -- Command-line completion mode

  if vim.fn.has("nvim-0.9.0") >= 1 then
    vim.opt.splitkeep = "cursor"
    vim.opt.shortmess:append { C = true }
  end

  -- Fix markdown indentation settings
  vim.g.markdown_recommended_style = 0
end

return M
