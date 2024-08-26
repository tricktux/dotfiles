#!/usr/bin/env bash

src_root=$(cd ..; pwd)
files_ext="*.[ch]"
out_files="cscope.files"

find "$src_root" -type f -name "$files_ext" -print > "$out_files"
cscope -b -q -k
ctags -L "$out_files"

# cscope re-scan: cscope -Rbq; vim: cs reset
# vim: cs add cscope.out
# vim: set tags=tags
# vim: cs f c <c-r><c-w>
# vim: g<c-]> go to definition using ctags
