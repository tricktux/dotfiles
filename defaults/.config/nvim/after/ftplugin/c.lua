---@module c after ftplugin
---@author Reinaldo Molina
if vim.b.did_cpp_ftplugin then
  return
end

vim.b.did_cpp_ftplugin = 1
local log = require('utils.log')
local utl = require('utils.utils')

vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.tabstop = 2

local opts = {silent = true, buffer = true, desc = 'help_under_cursor'}
if vim.fn.has('unix') > 0 then
  vim.keymap.set(
    'n',
    '<plug>help_under_cursor',
    function()
      vim.fn.execute(":vertical Man " .. vim.fn.expand('<cword>'))
    end,
    opts
  )
end

local function repl()
  local fmt = string.format
  local fn = vim.fn
  local comp = nil
  if fn.executable('clang++') > 0 then
    comp = 'clang++'
  elseif fn.executable('g++') > 0 then
    comp = 'g++'
  else
    vim.notify("[cpp.repl]: no compiler available", vim.log.levels.ERROR)
    return
  end

  local out = fn.tempname()
  local exec_out = fn.has('unix') > 0 and out or out .. '.exe'
  local filename = fn.expand("%")
  local cmd = fn.shellescape(fmt("%s %s -g -O3 -o %s && %s", comp, filename, out, exec_out))
  log.info(fmt("repl.cpp.cmd = %s", cmd))
  utl.execute_in_shell(cmd)
end

opts.desc = 'terminal_send_file'
vim.keymap.set('n', '<plug>terminal_send_file', repl, opts)

--[[ function! s:time_exe_win(...) abort
if !exists(':Dispatch')
  echoerr 'Please install vim-dispatch'
  return
  endif

  let l:cmd = "Dispatch powershell -command \"& {&'Measure-Command' {.\\"

  for s in a:000
    let l:cmd .= s . ' '
    endfor

    let l:cmd .= "}}\""

    exe l:cmd
    endfunction

    function! s:set_compiler_and_friends() abort
    if exists('b:current_compiler')
      return
      endif

      if has('unix')
        call linting#SetNeomakeClangMaker()
        if executable('ninja')
          call linting#SetNeomakeNinjaMaker()
        else
          call linting#SetNeomakeMakeMaker()
          endif
          call autocompletion#AdditionalLspSettings()
          return 1
          endif

          " Commands for windows
          if executable('mingw32-make')
            command! -buffer UtilsCompilerGcc
            \ execute("compiler gcc<bar>:setlocal makeprg=mingw32-make")
            nnoremap <buffer> <localleader>mg :UtilsCompilerGcc<cr>
            endif
            command! -buffer UtilsCompilerBorland call linting#SetNeomakeBorlandMaker()
            command! -buffer UtilsCompilerClangNeomake call linting#SetNeomakeClangMaker()
            nnoremap <buffer> <localleader>mb :UtilsCompilerBorland<cr>
            command! -buffer UtilsCompilerMsbuild2017 lua
            \ require('config.linting').set_neomake_msbuild_compiler('cpp', 'vs2017')
            nnoremap <buffer> <localleader>m5 :UtilsCompilerMsbuild2017<cr>
            command! -buffer UtilsCompilerMsbuild2015 lua
            \ require('config.linting').set_neomake_msbuild_compiler('cpp', 'vs2015')
            nnoremap <buffer> <localleader>m7 :UtilsCompilerMsbuild2017<cr>
            nnoremap <buffer> <localleader>mc :UtilsCompilerClangNeomake<cr>

            " Time runtime of a specific program. Pass as Argument executable with 
            " arguments. Pass as Argument executable with arguments. Example sep_calc.exe 
            " seprc.
            command! -nargs=+ -buffer UtilsTimeExec call s:time_exe_win(<f-args>)
            endfunction
 ]]
