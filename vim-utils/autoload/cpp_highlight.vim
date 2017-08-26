" File:cpp_highlight.vim
" Description: Choose one of the many forms of c++ highlight that there are for (neo)vim
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:0.0.0
" Last Modified: Aug 21 2017 10:29
" Created: Aug 21 2017 10:29


function! cpp_highlight#SetCppHighlight(type) abort
	if a:type ==# ''
		return
	elseif a:type ==# 'chromatica'
		if !has('nvim') || !has('python3') || !has('unix')
			echomsg 'Chromatica compatible with nvim and python3 in unix'
			return
		endif

		Plug 'arakashic/chromatica.nvim', { 'do' : ':UpdateRemotePlugins' }
			let g:chromatica#enable_at_startup = 1
			let g:chromatica#libclang_path = '/usr/lib/libclang.so'
			let g:chromatica#highlight_feature_level = 1

	elseif a:type ==# 'easytags'
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
		let g:easytags_file = '~/.cache/ctags'
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

	elseif a:type ==# 'neotags'
		if !has('python3')
			echomsg 'Neotags requires python3'
			return
		endif

		if !has('nvim')
			echomsg 'Neotags requires neovim'
			return
		endif

		if system('pip3 list | grep psutil') !~# 'psutil'
			echomsg 'Neotags requires pip3 psutil'
			return
		endif
			
		Plug 'c0r73x/neotags.nvim' " Depends on pip3 install --user psutil
			set regexpengine=1 " This speed up the engine alot but still not enough
			let g:neotags_enabled = 1
			" let g:neotags_file = g:std_data_path . '/ctags/neotags'
			" let g:neotags_verbose = 1
			let g:neotags_run_ctags = 0
			" let g:neotags#cpp#order = 'cgstuedfpm'
			let g:neotags#cpp#order = 'ced'
			" let g:neotags#c#order = 'cgstuedfpm'
			let g:neotags#c#order = 'ced'
			" let g:neotags_events_highlight = [
			" \   'BufEnter'
			" \ ]

		if exists('*highlight#Set')
			call cpp_highlight#SetNeotagsHighlight()
		else
			echomsg 'Neotags highlight not setup'
		endif

	elseif a:type ==# 'color_coded'
		if !has('unix') || has('nvim')
			echomsg 'Color_coded only works on unix and vim'
			return
		endif

		Plug 'jeaye/color_coded', { 'do': 'cmake . && make && make install' }

		" Color_Coded
		" call highlight#Set('Variable',								{ 'link' : 'cTypeTag' })
		" call highlight#Set('Namespace',								{ 'fg' : g:cyan })
		" call highlight#Set('EnumConstant',						{ 'link' : 'cEnum' })
		" call highlight#Set('Member',			 						{ 'link' : 'cMember' })
		let s:grey_blue = '#8a9597'
		let s:light_grey_blue = '#a0a8b0'
		let s:dark_grey_blue = '#34383c'
		let s:mid_grey_blue = '#64686c'
		let s:beige = '#ceb67f'
		let s:light_orange = '#ebc471'
		let s:yellow = '#e3d796'
		let s:violet = '#a982c8'
		let s:magenta = '#a933ac'
		let s:green = '#e0a96f'
		let s:lightgreen = '#c2c98f'
		let s:red = '#d08356'
		let s:cyan = '#74dad9'
		let s:darkgrey = '#1a1a1a'
		let s:grey = '#303030'
		let s:lightgrey = '#605958'
		let s:white = '#fffedc'
		let s:orange = '#d08356'
		exe 'hi Member guifg='.s:cyan .' guibg='.s:darkgrey .' gui=italic'
		exe 'hi Variable guifg='.s:light_grey_blue .' guibg='.s:darkgrey .' gui=none'
		exe 'hi Namespace guifg='.s:red .' guibg='.s:darkgrey .' gui=none'
		exe 'hi EnumConstant guifg='.s:lightgreen .' guibg='.s:darkgrey .' gui=none'

	elseif a:type ==# 'clighter8'
		if has('nvim') || !has('python3') || !has('unix')
			echomsg 'Clighter8 compatible with vim and python3 and unix only'
			return
		endif

		Plug 'bbchung/clighter8'
			let g:clighter8_syntax_groups = ['clighter8NamespaceRef', 'clighter8FunctionDecl']
			let g:clighter8_libclang_path = ''
			let g:clighter8_global_compile_args = ['-I/usr/local/include']
			let g:clighter8_logfile = ''
		call cpp_highlight#SetClight8Highlight()
	else
		echomsg 'Not a recognized highlight type: ' . a:type
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

	" Python
	call highlight#Set('pythonClassTag',          { 'fg': g:brown })
	call highlight#Set('pythonFunctionTag',       { 'fg': g:darkred })
	call highlight#Set('pythonMethodTag',         { 'link': 'cMember' })

	" Java
	call highlight#Set('javaClassTag',						{ 'fg': g:brown })
	call highlight#Set('javaMethodTag',						{ 'fg': g:darkred })
	call highlight#Set('javaInterfaceTag',        { 'link': 'cMember' })
endfunction

function! cpp_highlight#SetClight8Highlight() abort
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
