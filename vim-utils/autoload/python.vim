" File:python.vim
" Description: All functions that use python within vim are going to be here
" Author:Reinaldo Molina <rmolin88@gmail.com>
" Version:1.0.0
" Last Modified: Mar 14 2017 20:09

" Called from utils#UpdateCscope. This parent function checks if cscope and ctags is available
function! python#UpdateCtags() abort
if !has('python3')
    echomsg string("Why U NOT has python???")
    return
endif
python3 << EOF
import os
import vim

delete_files = [ 'cscope.out', 'cscope.po.out', 'cscope.in.out', '.tags' ]
file_ext_tuple = ('.c', '.cpp', '.java', '.cc', '.h', '.hpp')
ctags_cmd = 'ctags -R -L cscope.files -f .tags --sort=no --c-kinds=+l --c++-kinds=+l --fields=+iaSl --extra=+q'

vim.command('silent! cs kill -1')

# Silently delete files
for files in delete_files:
    try:
        os.remove(files)
    except:
        pass

# Populate list of source files
list_files = open('cscope.files', 'w+')
for root, dirs, files in os.walk(os.getcwd()):
	for file in files:
		if file.endswith(file_ext_tuple):
			list_files.write(os.path.join(root, file) + "\n")

# Silently try to create cscope files
try:
	os.system('cscope -b -q -i cscope.files')
except:
	pass

# Check that cscope was created if so. Silently create tags
if os.path.isfile('cscope.out'):
	try:
		os.system(ctags_cmd)
	except:
		pass

# Add new database
vim.command('cs add cscope.out')
EOF
endfunction
