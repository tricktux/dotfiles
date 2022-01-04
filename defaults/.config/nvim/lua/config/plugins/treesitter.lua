local utl = require('utils/utils')

local M = {}

function M.setup()
  -- Mon Apr 05 2021 17:36:
  -- performance of treesitter in large files is very low.
  -- Keep as little modules enabled as possible.
  -- Also no status line
  -- No extra modules. Looking at you rainbow
  if not utl.is_mod_available('nvim-treesitter') then
    api.nvim_err_writeln('nvim-treesitter module not available')
    return
  end

  require('nvim-treesitter.install').compilers = { "clang" }
  -- local ts = require'nvim-treesitter'
  local tsconf = require 'nvim-treesitter.configs'

  local config = {
    -- This line will install all of them
    -- one of "all", "language", or a list of languages
    ensure_installed = {
      "c", "cpp", "python", "lua", "java", "bash", "c_sharp", "rust", "json",
      "toml", "bash", "cmake", "dockerfile", "json5", "latex", "r", "yaml",
      "vim", "markdown", "json", "make", "nix", "html", "llvm", "comment"
    },
    highlight = {
      enable = true, -- false will disable the whole extension
      additional_vim_regex_highlighting = {'markdown'}
    },
    indent = {enable = false},
    textsubjects = {
      enable = true,
      keymaps = {
        ['.'] = 'textsubjects-smart',
        [';'] = 'textsubjects-big',
      }
    },
    -- textobjects = {enable = true}
  }

  -- if utl.is_mod_available('rainbow') then config["rainbow"] = {enable = true} end
  tsconf.setup(config)

  -- vim.cmd(
    -- "autocmd FileType c,cpp,python,lua,java,bash,rust,json,toml,cs setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()")
  -- if exists('g:lightline')
    -- let g:lightline.active.right[2] += [ 'sessions' ]
    -- let g:lightline.component_function['sessions'] =
    -- \ string(function('s:obsession_status'))
      -- endif
      -- Set highlights for PaperColor
      -- local hl = {
        -- 'highlight TSPunctDelimiter guifg=#00ad7f',
        -- 'highlight TSPunctSpecial guifg=#004e3d',
        -- 'highlight TSTagDelimiter guifg=#004257',
        -- 'highlight TSConstBuiltin guifg=#00d7af',
        -- 'highlight TSConstructor gui=Bold guifg=#8700d7',
        -- 'highlight TSVariableBuiltin guifg=#005faf',
        -- 'highlight TSStringRegex guifg=#afd700',
        -- 'highlight TSLiteral guifg=#00bcd4',
        -- 'highlight TSMethod gui=italic guifg=#d75f87',
        -- 'highlight TSField guifg=#afd7d7',
        -- 'highlight TSProperty guifg=#ffaf87',
        -- 'highlight TSParameterReference guifg=#005685',
        -- 'highlight TSAttribute guifg=#185d95',
        -- 'highlight TSTag guifg=#305b7e',
        -- 'highlight TSKeywordFunction guifg=#40596d',
        -- 'highlight TSKeywordOperator guifg=#1ac9ff',
        -- 'highlight TSTypeBuiltin guifg=#5f00ff',
        -- 'highlight TSNamespace guifg=#b71f1f',
      -- }

      -- for _, high in ipairs(hl) do
        -- vim.cmd(high)
      -- end
end

return M
