" fork: TODO-list stuff

syn region itemTodo       start="^.*\[ ] "  end="$" keepend contains=itemCause
syn region itemInProgress start="^.*\[o] "  end="$" keepend contains=itemCause
syn region itemBlocked    start="^.*\[x] "  end="$" keepend contains=itemCause
syn region itemComplete   start="^.*\[+] "  end="$" keepend contains=itemCause
syn region itemWontDo     start="^.*\[-] "  end="$" keepend contains=itemCause
syn region itemCause      start=" > "     end="$"
syn region itemShell      start=" \$ "    end="$"

highlight def link itemTodo       htmlTagName
highlight def link itemInProgress Type
highlight def link itemBlocked    htmlH1
highlight def link itemCause      htmlLink
highlight def link itemComplete   Label
highlight def link itemWontDo     Delimiter
highlight def link itemShell String
