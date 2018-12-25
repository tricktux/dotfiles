" https://github.com/niklasl/vimheap/blob/master/after/syntax/groovy.vim
syn region foldBraces start=/{\s*$/ end=/}\s*$/ transparent fold keepend extend
syn region foldImports start=/\(^\s*\n^import\)\@<= .\+$/ end=+^\s*$+ transparent fold keepend
set foldmethod=syntax

let g:tagbar_type_groovy = {
			\ 'ctagstype' : 'groovy',
			\ 'kinds'     : [
			\ 'p:package',
			\ 'c:class',
			\ 'i:interface',
			\ 'f:function',
			\ 'v:variables',
			\ ]
			\ }
