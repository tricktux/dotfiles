-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
-- Link: https://gist.github.com/hoob3rt/b200435a765ca18f09f83580a606b878
local utl = require('utils/utils')
local api = vim.api

local M = {}

-- Color table for highlights
M.colors = {
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
      normal = {c = {fg = M.colors.fg, bg = M.colors.bg}},
      inactive = {c = {fg = M.colors.fg, bg = M.colors.bg}}
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

-- Inserts a component in lualine_x at left section
function M:ins_right(component)
  table.insert(self.__config.sections.lualine_x, 1, component)
end

-- Inserts a component in lualine_x at right section
function M:__ins_right(component)
  table.insert(self.__config.sections.lualine_x, component)
end

function M:config()
  self:ins_left{
    function() return '▊' end,
    color = {fg = self.colors.blue}, -- Sets highlighting of component
    left_padding = 0 -- We don't need space before this
  }

  self:ins_left{
    -- mode component
    function()
      -- auto change color according to neovims mode
      local mode_color = {
        n = self.colors.red,
        i = self.colors.green,
        v = self.colors.blue,
        [''] = self.colors.blue,
        V = self.colors.blue,
        c = self.colors.magenta,
        no = self.colors.red,
        s = self.colors.orange,
        S = self.colors.orange,
        [''] = self.colors.orange,
        ic = self.colors.yellow,
        R = self.colors.violet,
        Rv = self.colors.violet,
        cv = self.colors.red,
        ce = self.colors.red,
        r = self.colors.cyan,
        rm = self.colors.cyan,
        ['r?'] = self.colors.cyan,
        ['!'] = self.colors.red,
        t = self.colors.red
      }
      local mode = vim.fn.mode()
      vim.api.nvim_command('hi! LualineMode guifg=' .. mode_color[mode] ..
                               " guibg=" .. self.colors.bg)
      return mode
    end,
    color = "LualineMode",
    left_padding = 0
  }

  self:ins_left{
    'filename',
    file_status = true,
    condition = self.__conditions.buffer_not_empty,
    color = {fg = self.colors.magenta, gui = 'bold'}
  }

  self:__ins_right{'location', right_padding = 0}

  self:__ins_right{'progress', color = {fg = self.colors.fg, gui = 'bold'}}

  self:__ins_right{
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
    condition = self.__conditions.buffer_not_empty,
    left_padding = 0,
    right_padding = 0
  }

  self:__ins_right{

    function() return '▊' end,
    color = {fg = self.colors.blue},
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
