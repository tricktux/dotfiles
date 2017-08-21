

function syntax#Set() abort
	" SYNTAX_OPTIONS
	" ft-java-syntax
	let java_highlight_java_lang_ids=1
	let java_highlight_functions="indent"
	let java_highlight_debug=1
	let java_space_errors=1
	let java_comment_strings=1
	hi javaParen ctermfg=blue guifg=#0000ff

	" ft-c-syntax
	let c_gnu = 1
	let c_ansi_constants = 1
	let c_ansi_typedefs = 1
	let c_minlines = 500
	" Breaks too often
	" let c_curly_error = 1

	" ft-markdown-syntax
	let g:markdown_fenced_languages= [ 'cpp', 'vim', 'dosini', 'wings_syntax' ]

	" ft-python-syntax
	" This option also highlights erroneous whitespaces
	let python_highlight_all = 1

	" Man
	" let g:no_man_maps = 1
	let g:ft_man_folding_enable = 1

	" Never load netrw
	let g:loaded_netrw       = 1
	let g:loaded_netrwPlugin = 1

	if exists("g:plugins_loaded")
		" Nerdtree (Dont move. They need to be here)
		let NERDTreeShowBookmarks=1  " B key to toggle
		let NERDTreeShowLineNumbers=1
		let NERDTreeShowHidden=1 " i key to toggle
		let NERDTreeQuitOnOpen=1 " AutoClose after openning file
		let NERDTreeBookmarksFile=g:cache_path . '.NERDTreeBookmarks'
		" NerdCommenter
		let NERDSpaceDelims=1  " space around comments
		let NERDUsePlaceHolders=0 " avoid commenter doing weird stuff
		let NERDCommentWholeLinesInVMode=2
		let NERDCreateDefaultMappings=0 " Eliminate default mappings
		let NERDRemoveAltComs=1 " Remove /* comments
		let NERD_c_alt_style=0 " Do not use /* on C nor C++
		let NERD_cpp_alt_style=0
		let NERDMenuMode=0 " no menu
		let g:NERDCustomDelimiters = {
					\ 'vim': { 'left': '"', 'right': '', 'leftAlt': '#', 'rightAlt': ''},
					\ 'markdown': { 'left': '//', 'right': '' },
					\ 'dosini': { 'left': ';', 'leftAlt': '//', 'right': '', 'rightAlt': '', 'leftAlt1': ';', 'rightAlt1': '' },
					\ 'wings_syntax': { 'left': '//', 'right': '' }}
	endif
endfunction

" vim:tw=78:ts=2:sts=2:sw=2:
