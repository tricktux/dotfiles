" File:cpp_highlight.vim
" Description: Choose one of the many forms of c++ highlight that there are for 
" (neo)vim
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:0.0.0
" Last Modified: Aug 21 2017 10:29
" Created: Aug 21 2017 10:29


function! cpp_highlight#Set(type) abort
	call s:set_vim_syntax_options()
	if empty(a:type)
		call s:regular_highlight()
	elseif a:type ==# 'chromatica'
		call s:set_chromatica()
	elseif a:type ==# 'easytags'
		call s:set_easytags()
	elseif a:type ==# 'neotags'
		call s:set_neotags()
	elseif a:type ==# 'color_coded'
		call s:set_color_coded()
	elseif a:type ==# 'clighter8'
		call s:set_clighter8()
	elseif a:type ==# 'tag-highlight' && has('nvim')
		call s:set_c_highlight()
	elseif a:type ==# 'semantic'
		call s:set_semantic_highlight()
	else
		echomsg 'Not a recognized highlight type: ' . a:type .
				\ '. Using only regular highlight'
		call s:regular_highlight()
	endif
endfunction

function! cpp_highlight#SetNeotagsHighlight() abort
	" C
	call highlight#Set('cTypeTag',                { 'fg': g:brown })
	call highlight#Set('cPreProcTag',             { 'fg': g:cyan })
	call highlight#Set('cFunctionTag',            { 'fg': g:darkred })
	call highlight#Set('cMemberTag',              { 'link': 'cMember' })
	call highlight#Set('cEnumTag',                { 'link': 'cEnum' })

	" Cpp
	call highlight#Set('cppTypeTag',              { 'fg': g:brown })
	call highlight#Set('cppPreProcTag',           { 'fg': g:cyan })
	call highlight#Set('cppFunctionTag',          { 'fg': g:darkred })
	call highlight#Set('cppMemberTag',            { 'link': 'cppMember' })
	call highlight#Set('cppEnumTag',              { 'link': 'cppEnum' })
	" Vim
	call highlight#Set('vimAutoGroupTag',					{ 'fg': g:brown })
	call highlight#Set('vimCommandTag',						{ 'fg': g:cyan })
	call highlight#Set('vimFuncNameTag',					{ 'fg': g:darkred })
	call highlight#Set('vimVariableTag',          { 'link': 'cppEnum' })
	call highlight#Set('vimScriptFuncNameTag',    { 'link': 'cppMember' })

	" Python
	call highlight#Set('pythonClassTag',          { 'fg': g:brown })
	call highlight#Set('pythonFunctionTag',       { 'fg': g:darkred })
	call highlight#Set('pythonMethodTag',         { 'link': 'cMember' })

	" Java
	call highlight#Set('javaClassTag',						{ 'fg': g:brown })
	call highlight#Set('javaMethodTag',						{ 'fg': g:darkred })
	call highlight#Set('javaInterfaceTag',        { 'link': 'cMember' })
endfunction

function! s:set_clighter8_highlight() abort
	hi default link clighter8Decl Identifier
	hi default link clighter8Ref Type
	hi default link clighter8Prepro PreProc
	hi default link clighter8Stat Keyword

	hi default link clighter8StructDecl Identifier
	hi default link clighter8UnionDecl Identifier
	hi default link clighter8ClassDecl Identifier
	hi default link clighter8EnumDecl Identifier
	hi default link clighter8FieldDecl Identifier
	hi default link clighter8EnumConstantDecl Constant
	hi default link clighter8FunctionDecl Identifier
	hi default link clighter8VarDecl Identifier
	hi default link clighter8ParmDecl Identifier
	hi default link clighter8TypedefDecl Identifier
	hi default link clighter8CxxMethod Identifier
	hi default link clighter8Namespace Identifier
	hi default link clighter8Constructor Identifier
	hi default link clighter8Destructor Identifier
	hi default link clighter8TemplateTypeParameter Identifier
	hi default link clighter8TemplateNoneTypeParameter Identifier
	hi default link clighter8FunctionTemplate Identifier
	hi default link clighter8ClassTemplate Identifier
	hi default link clighter8TypeRef Type
	hi default link clighter8TemplateRef Type
	hi default link clighter8NamespaceRef Type
	hi default link clighter8MemberRef Type
	hi default link clighter8DeclRefExpr Type
	hi default link clighter8MemberRefExpr Type
	hi default link clighter8MacroInstantiation Constant
	hi default link clighter8InclusionDirective cIncluded
endfunction

function! s:set_vim_syntax_options() abort
	" Vim cpp syntax highlight
	let g:cpp_class_scope_highlight = 1
	let g:cpp_member_variable_highlight = 1
	let g:cpp_class_decl_highlight = 1
	let g:cpp_concepts_highlight = 1

	let g:cpp_experimental_simple_template_highlight = 1
endfunction

function! s:regular_highlight() abort
  Plug 'justinmk/vim-syntax-extra', { 'for' : [ 'c' , 'cpp' ] }
	Plug 'octol/vim-cpp-enhanced-highlight', { 'for' : [ 'c' , 'cpp' ] }
  Plug 'vim-jp/cpp-vim', { 'for' : [ 'c' , 'cpp' ] }
endfunction

function! s:set_neotags() abort
	if !has('python3')
		echomsg 'Neotags requires python3'
		return
	endif

	if !has('nvim')
		echomsg 'Neotags requires neovim'
		return
	endif

	" Depends on pip3 install --user psutil
	Plug 'c0r73x/neotags.nvim',  { 'build' : 'make' }
	set regexpengine=1 " This speed up the engine alot but still not enough
	" let g:neotags_verbose = 1
	let g:neotags_find_tool = executable('fd') ?
				\ 'fd --type file --hidden --no-ignore --follow --exclude ".{sync,git,svn}" 2> /dev/null'
				\ : ''
	let g:neotags_run_ctags = 0
	" let g:neotags_directory = g:std_data_path . '/ctags/neotags'
	" let g:neotags#cpp#order = 'cgstuedfpm'
	let g:neotags#cpp#order = 'ced'
	" let g:neotags#c#order = 'cgstuedfpm'
	let g:neotags#c#order = 'ced'
	" let g:neotags_events_highlight = [
	" \   'BufEnter'
	" \ ]
	let g:neotags_ft_conv = {
				\ 'C': 'c',
				\ 'C++': 'cpp',
				\ 'C#': 'cs',
				\ 'JavaScript': 'flow',
				\ 'Vim': 'vim',
				\ 'Python': 'python',
				\ }

	let g:neotags_ignore = [
				\ 'text',
				\ 'nofile',
				\ 'mail',
				\ 'qf',
				\ 'neoterm',
				\ ]
	" let g:neotags_bin = '~/.vim_tags/bin/neotags'

endfunction

function! s:set_easytags() abort
	if has('nvim') || !has('python3')
		echomsg 'Vim-Easytags compatible with vim and python3 only'
		return
	endif

	" Too slow for not async abilities
	" Plug 'xolox/vim-easytags', { 'on' : 'HighlightTags' }
	Plug 'xolox/vim-easytags'
	Plug 'xolox/vim-misc' " dependency of vim-easytags
	Plug 'xolox/vim-shell' " dependency of vim-easytags
	set regexpengine=1 " This speed up the engine alot but still not enough
	let g:easytags_file = stdpath('cache') . '/easytags_tags'
	let g:easytags_syntax_keyword = 'always'
	let g:easytags_auto_update = 0
	" let g:easytags_cmd = 'ctags'
	" let g:easytags_on_cursorhold = 1
	" let g:easytags_updatetime_min = 4000
	" let g:easytags_auto_update = 1
	" " let g:easytags_auto_highlight = 1
	" let g:easytags_dynamic_files = 1
	" let g:easytags_by_filetype = '~/.cache/easy-tags-filetype'
	" " let g:easytags_events = ['BufReadPost' , 'BufWritePost']
	" let g:easytags_events = ['BufReadPost']
	" " let g:easytags_include_members = 1
	" let g:easytags_async = 1
	" let g:easytags_python_enabled = 1
endfunction

function! s:set_clighter8() abort
	if has('nvim') || !has('python3') " || !has('unix')
		echomsg 'Clighter8 compatible with vim and python3 and unix only'
		return
	endif

	Plug 'bbchung/clighter8'
	let g:clighter8_syntax_groups = ['clighter8NamespaceRef',
																\ 'clighter8FunctionDecl']
	let g:clighter8_libclang_path = 'C:\Program Files\LLVM\bin\libclang.dll'
	" let g:clighter8_global_compile_args = ['-I/usr/local/include']
	let g:clighter8_logfile = stdpath('cache') . '/clighter8.log'
	call s:set_clighter8_highlight()
endfunction

function! s:set_chromatica() abort
	if !has('nvim') || !has('python3')
		echomsg 'Chromatica compatible with nvim and python3 in unix'
		return
	endif

	Plug 'arakashic/chromatica.nvim', { 'do' : ':UpdateRemotePlugins',
				\ 'for' : [ 'cpp', 'c' ] }
	let g:chromatica#enable_at_startup = 1
	let g:chromatica#libclang_path = '/usr/lib/libclang.so'
	let g:chromatica#responsive_mode = 1
	" let g:chromatica#debug_log = 1
	let g:chromatica#debug_profiling = 1
	let l:inc = finddir('bits', '/usr/include/c++/**2')
	if (!empty(l:inc))
		let l:inc = '-I' . l:inc[:-5]
		let g:chromatica#compile_args = [ l:inc ]
	endif

endfunction

function! s:set_color_coded() abort
	if !has('unix') || has('nvim')
		echomsg 'Color_coded only works on unix and vim'
		return
	endif

	Plug 'jeaye/color_coded', { 'do':
				\ 'cmake . && make && make install && make clean && make clean_clang' }

	" Color_Coded
	" call highlight#Set('Variable',								{ 'link' : 'cTypeTag' })
	" call highlight#Set('Namespace',								{ 'fg' : g:cyan })
	" call highlight#Set('EnumConstant',						{ 'link' : 'cEnum' })
	" call highlight#Set('Member',			 						{ 'link' : 'cMember' })
	let l:grey_blue = '#8a9597'
	let l:light_grey_blue = '#a0a8b0'
	let l:dark_grey_blue = '#34383c'
	let l:mid_grey_blue = '#64686c'
	let l:beige = '#ceb67f'
	let l:light_orange = '#ebc471'
	let l:yellow = '#e3d796'
	let l:violet = '#a982c8'
	let l:magenta = '#a933ac'
	let l:green = '#e0a96f'
	let l:lightgreen = '#c2c98f'
	let l:red = '#d08356'
	let l:cyan = '#74dad9'
	let l:darkgrey = '#1a1a1a'
	let l:grey = '#303030'
	let l:lightgrey = '#605958'
	let l:white = '#fffedc'
	let l:orange = '#d08356'
	exe 'hi Member guifg='.l:cyan .' guibg='.l:darkgrey .' gui=italic'
	exe 'hi Variable guifg='.l:light_grey_blue .' guibg='.l:darkgrey .' gui=none'
	exe 'hi Namespace guifg='.l:red .' guibg='.l:darkgrey .' gui=none'
	exe 'hi EnumConstant guifg='.l:lightgreen .' guibg='.l:darkgrey .' gui=none'
endfunction

function! s:set_neo_neotags() abort
	" let g:neotags_enabled = 1
	" let g:neotags_bin = ''
	" call s:set_neotags()
endfunction

function! s:set_c_highlight() abort
	Plug 'roflcopter4/tag-highlight.nvim', { 'do' : 'cmake . && make' }
endfunction

function! s:set_semantic_highlight() abort
	Plug 'jaxbot/semantic-highlight.vim'
endfunction
