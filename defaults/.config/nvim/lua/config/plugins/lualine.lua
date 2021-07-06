-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
-- Link: https://gist.github.com/hoob3rt/b200435a765ca18f09f83580a606b878
local utl = require('utils/utils')
local api = vim.api

local M = {}

-- Color table for highlights
M.__colors = {
  bg = '#202328',
  fg = '#bbc2cf',
  yellow = '#ECBE7B',
  cyan = '#008080',
  darkblue = '#081633',
  green = '#98be65',
  orange = '#FF8800',
  violet = '#a9a1e1',
  magenta = '#c678dd',
  blue = '#51afef',
  red = '#ec5f67'
}

M.__conditions = {
  buffer_not_empty = function() return vim.fn.empty(vim.fn.expand('%:t')) ~= 1 end,
  hide_in_width = function() return vim.fn.winwidth(0) > 80 end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end
}

-- Config
M.__config = {
  options = {
    -- Disable sections and component separators
    component_separators = "",
    section_separators = "",
    icons_enabled = false,
    theme = {
      -- We are going to use lualine_c an lualine_x as left and
      -- right section. Both are highlighted by c theme .  So we
      -- are just setting default looks o statusline
      normal = {c = {fg = M.__colors.fg, bg = M.__colors.bg}},
      inactive = {c = {fg = M.__colors.fg, bg = M.__colors.bg}}
    }
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {}
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_v = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {{'filename', path = 2}},
    lualine_x = {'location'}
  },
  extensions = {'fzf', 'nvim-tree', 'quickfix', 'fugitive'}
}

-- Inserts a component in lualine_c at left section
function M:ins_left(component)
  table.insert(self.__config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x ot right section
function M:ins_right(component)
  table.insert(self.__config.sections.lualine_x, component)
end

function M:config()
  self:ins_left{
    function() return '▊' end,
    color = {fg = self.__colors.blue}, -- Sets highlighting of component
    left_padding = 0 -- We don't need space before this
  }

  self:ins_left{
    -- mode component
    function()
      -- auto change color according to neovims mode
      local mode_color = {
        n = self.__colors.red,
        i = self.__colors.green,
        v = self.__colors.blue,
        [''] = self.__colors.blue,
        V = self.__colors.blue,
        c = self.__colors.magenta,
        no = self.__colors.red,
        s = self.__colors.orange,
        S = self.__colors.orange,
        [''] = self.__colors.orange,
        ic = self.__colors.yellow,
        R = self.__colors.violet,
        Rv = self.__colors.violet,
        cv = self.__colors.red,
        ce = self.__colors.red,
        r = self.__colors.cyan,
        rm = self.__colors.cyan,
        ['r?'] = self.__colors.cyan,
        ['!'] = self.__colors.red,
        t = self.__colors.red
      }
      vim.api.nvim_command(
          'hi! LualineMode guifg=' .. mode_color[vim.fn.mode()] .. " guibg=" ..
              self.__colors.bg)
      return ''
    end,
    color = "LualineMode",
    left_padding = 0
  }

  self:ins_left{
    'filename',
    file_status = true,
    condition = self.__conditions.buffer_not_empty,
    color = {fg = self.__colors.magenta, gui = 'bold'}
  }

  self:ins_left{
    'branch',
    icons_enabled = true,
    icon = 'git:',
    condition = self.__conditions.check_git_workspace,
    color = {fg = self.__colors.violet, gui = 'bold'}
  }

  self:ins_left{
    'diff',
    -- Is it me or the symbol for modified us really weird
    symbols = {added = '+', modified = '~', removed = '-'},
    color_added = self.__colors.green,
    color_modified = self.__colors.orange,
    color_removed = self.__colors.red,
    condition = self.__conditions.hide_in_width
  }

  -- Insert mid section. You can make any number of sections in neovim :)
  -- for lualine it's any number greater then 2
  -- self:ins_left{function() return '%=' end}

  self:ins_right{
    'diagnostics',
    sources = {'nvim_lsp'},
    symbols = {error = 'e:', warn = 'w:', info = 'i:', hint = 'h:'},
    color_error = self.__colors.red,
    color_warn = self.__colors.yellow,
    color_info = self.__colors.cyan,
    color_hint = self.__colors.blue
  }

  self:ins_right{
    -- Lsp server name .
    function()
      local msg = 'No Active Lsp'
      local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
      local clients = vim.lsp.get_active_clients()
      if next(clients) == nil then return msg end
      for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
          return client.name
        end
      end
      return msg
    end,
    icons_enabled = true,
    icon = 'lsp:',
    color = {fg = '#ffffff', gui = 'bold'},
    condition = function() return #vim.lsp.buf_get_clients() > 0 end
  }

  -- Add components to right sections
  -- self:ins_right{
  -- 'o:encoding', -- option component same as &encoding in viml
  -- upper = true, -- I'm not sure why it's upper case either ;)
  -- condition = self.__conditions.hide_in_width,
  -- color = {fg = self.__colors.green, gui = 'bold'}
  -- }

  -- self:ins_right{
  -- 'fileformat',
  -- upper = true,
  -- icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
  -- color = {fg = self.__colors.green, gui = 'bold'}
  -- }

  self:ins_right{'location'}

  self:ins_right{'progress', color = {fg = self.__colors.fg, gui = 'bold'}}

  self:ins_right{
    -- filesize component
    function()
      local function format_file_size(file)
        local size = vim.fn.getfsize(file)
        if size <= 0 then return '' end
        local sufixes = {'b', 'k', 'm', 'g'}
        local i = 1
        while size > 1024 do
          size = size / 1024
          i = i + 1
        end
        return string.format('%.1f%s', size, sufixes[i])
      end
      local file = vim.fn.expand('%:p')
      if string.len(file) == 0 then return '' end
      return format_file_size(file)
    end,
    condition = self.__conditions.buffer_not_empty
  }

  self:ins_right{
    function() return '▊' end,
    color = {fg = self.__colors.blue},
    right_padding = 0
  }

end

function M:setup()
  if not utl.is_mod_available('lualine') then
    api.nvim_err_writeln("lualine was set, but module not found")
    return
  end
  require('lualine').setup(self.__config)
end

return M
