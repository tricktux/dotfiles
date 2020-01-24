" fork: TODO-list stuff

syn match itemTodo       "^.*\[ ]" contains=itemCause
syn match itemInProgress "^.*\[o]" contains=itemCause
syn match itemBlocked    "^.*\[x]" contains=itemCause
syn match itemComplete   "^.*\[+]" contains=itemCause
syn match itemWontDo     "^.*\[-]" contains=itemCause
syn match itemTags "@\w*"
syn region itemCause      start=" > "     end="$"
syn region itemShell      start=" \$ "    end="$"

highlight def link itemTags PreProc
highlight def link itemTodo       Type
highlight def link itemInProgress htmlTagName
highlight def link itemBlocked    Label
highlight def link itemCause      htmlLink
highlight def link itemComplete   htmlH1
highlight def link itemWontDo     Delimiter
highlight def link itemShell String
