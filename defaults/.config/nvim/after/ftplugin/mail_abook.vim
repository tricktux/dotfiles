" mail FTplugin
"
" Requires vim 6.x.  
" To install place in ~/.vim/after/ftplugin/mail.vim
"
" Author: Brian Medley
" Email:  freesoftware@4321.tv
"
" This file was modified from Cedric Duval's version.
" http://cedricduval.free.fr/download/vimrc/mail

" Only do this when not done yet for this buffer
if exists("b:did_mail_after_ftplugin")
  finish
endif
let b:did_mail_after_ftplugin = 1

if !exists ("mail_alias_program")
    let mail_alias_program="Abook"
endif

" ====================================================================
"                               Globals
" ====================================================================

if !exists ("mail_quote_chars")
    let s:quote_chars = ':!|>'
else
    let s:quote_chars = mail_quote_chars
endif

" This re defines a 'quote'
let s:quote_re = '\(\s\?\w*[' . s:quote_chars . ']\)'
"                   \s\?                             => 0 or one whitespace char 
"                                                       (b/c some ppl put
"                                                       spaces in the quote,
"                                                       and others don't)
"                                                   
"                       \w*                          => maybe word chars (b/c
"                                                       some ppl put initals in
"                                                       the quotes)
"                               the rest             => actual quote chars 
"                 \(                              \) => this is a quote "level"

" This re defines the quoting level at the *beginning* of a line
let s:quote_start = '^' . s:quote_re . s:quote_re . '*'
"                    ^s:quote_re                        => quote at beginning of
"                                                          line
"                                      s:quote_re*      => perhaps followed by
"                                                          more quotes

" For debugging:
" let b:quote_chars = s:quote_chars
" let b:quote_re = s:quote_re
" let b:quote_start = s:quote_start

" ====================================================================
"                               Mappings
" ====================================================================

if !exists("no_plugin_maps") && !exists("no_mail_maps")
    
    "
    " get alias list mappings
    " 
    if !hasmapto('<Plug>MailAliasList', 'n')
        nmap <buffer> <unique> <LocalLeader>al  <Plug>MailAliasList
    endif
    if !hasmapto('<Plug>MailAliasList', 'i')
        imap <buffer> <unique> <LocalLeader>al  <Plug>MailAliasList
    endif
    
    nnoremap <buffer> <unique> <script> <Plug>MailAliasList <SID>AliasList
    inoremap <buffer> <unique> <script> <Plug>MailAliasList <SID>AliasList
    
    " Redraw is there b/c my screen was messed up after abook finished.
    " The 'set paste' is in the function b/c I couldn't figure out how to put it in
    "   the mapping.
    " The 'set nopaste' is in the mapping b/c it didn't work for me in the script.
    nnoremap <buffer> <SID>AliasList A<c-r>=<SID>AliasList{mail_alias_program}()<cr><c-o>:set nopaste<cr><c-o>:redraw!<cr><c-o>:echo b:AliasListMsg<cr><esc>
    inoremap <buffer> <SID>AliasList  <c-r>=<SID>AliasList{mail_alias_program}()<cr><c-o>:set nopaste<cr><c-o>:redraw!<cr><c-o>:echo b:AliasListMsg<cr>

    "
    " get alias query mappings
    "
    if !hasmapto('<Plug>MailAliasQuery', 'n')
        nmap <buffer> <unique> <LocalLeader>aq  <Plug>MailAliasQuery
    endif
    if !hasmapto('<Plug>MailAliasQuery', 'i')
        imap <buffer> <unique> <LocalLeader>aq  <Plug>MailAliasQuery
    endif
    
    nnoremap <buffer> <unique> <script> <Plug>MailAliasQuery <SID>AliasQuery
    inoremap <buffer> <unique> <script> <Plug>MailAliasQuery <SID>AliasQuery
    
    nnoremap <buffer> <SID>AliasQuery      :call <SID>AliasQuery{mail_alias_program}()<cr>:echo b:AliasQueryMsg<cr>
    inoremap <buffer> <SID>AliasQuery <c-o>:call <SID>AliasQuery{mail_alias_program}()<cr><c-o>:echo b:AliasQueryMsg<cr><right>

    " 
    " mail formatting mappings
    "

    " * <F1> to re-format a quotelvl
    " * <F2> to format a line which is too long, and go to the next line
    " * <F3> to merge the previous line with the current one, with a correct
    "        formatting (sometimes useful associated with <F2>)
    " * <F4> to re-format the current paragraph correctly

    if !hasmapto('<Plug>MailFormatQuoteLvl', 'n')
        nmap <buffer> <unique> <F1> <Plug>MailFormatQuoteLvl
    endif
    if !hasmapto('<Plug>MailFormatLine', 'n')
        nmap <buffer> <unique> <F2> <Plug>MailFormatLine
    endif
    if !hasmapto('<Plug>MailFormatMerge', 'n')
        nmap <buffer> <unique> <F3> <Plug>MailFormatMerge
    endif
    if !hasmapto('<Plug>MailFormatParagraph', 'n')
        nmap <buffer> <unique> <F4> <Plug>MailFormatParagraph
    endif

    if !hasmapto('<Plug>MailFormatQuoteLvl', 'i')
        imap <buffer> <unique> <F1> <Plug>MailFormatQuoteLvl
    endif
    if !hasmapto('<Plug>MailFormatLine', 'i')
        imap <buffer> <unique> <F2> <Plug>MailFormatLine
    endif
    if !hasmapto('<Plug>MailFormatMerge', 'i')
        imap <buffer> <unique> <F3> <Plug>MailFormatMerge
    endif
    if !hasmapto('<Plug>MailFormatParagraph', 'i')
        imap <buffer> <unique> <F4> <Plug>MailFormatParagraph
    endif

    nnoremap <buffer> <unique> <script> <Plug>MailFormatQuoteLvl  <SID>FormatQuoteLvl
    nnoremap <buffer> <unique> <script> <Plug>MailFormatLine      <SID>FormatLine
    nnoremap <buffer> <unique> <script> <Plug>MailFormatMerge     <SID>FormatMerge
    nnoremap <buffer> <unique> <script> <Plug>MailFormatParagraph <SID>FormatParagraph
    inoremap <buffer> <unique> <script> <Plug>MailFormatQuoteLvl  <SID>FormatQuoteLvl
    inoremap <buffer> <unique> <script> <Plug>MailFormatLine      <SID>FormatLine
    inoremap <buffer> <unique> <script> <Plug>MailFormatMerge     <SID>FormatMerge
    inoremap <buffer> <unique> <script> <Plug>MailFormatParagraph <SID>FormatParagraph

    nnoremap <buffer> <script> <SID>FormatQuoteLvl  gq<SID>QuoteLvlMotion
    nnoremap <buffer>          <SID>FormatLine      gqqj
    nnoremap <buffer>          <SID>FormatMerge     kgqj
    nnoremap <buffer>          <SID>FormatParagraph gqap
    inoremap <buffer> <script> <SID>FormatQuoteLvl  <ESC>gq<SID>QuoteLvlMotioni
    inoremap <buffer>          <SID>FormatLine      <ESC>gqqji
    inoremap <buffer>          <SID>FormatMerge     <ESC>kgqji
    inoremap <buffer>          <SID>FormatParagraph <ESC>gqapi

    " 
    " sig removal mappings
    "
    if !hasmapto('<Plug>MailEraseQuotedSig', 'n')
        nmap <silent> <buffer> <unique> <LocalLeader>eqs <Plug>MailEraseQuotedSig
    endif
    nnoremap <buffer> <unique> <script> <Plug>MailEraseQuotedSig <SID>EraseQuotedSig
    nnoremap <buffer> <SID>EraseQuotedSig :call<SID>EraseQuotedSig()<CR>

    "
    " Provide a motion operator for commands (so you can delete a quote
    " segment, or format quoted segment)
    "
    if !hasmapto('<Plug>MailQuoteLvlMotion', 'o')
        omap <silent> <buffer> <unique> q <Plug>MailQuoteLvlMotion
    endif
    onoremap <buffer> <unique> <script> <Plug>MailQuoteLvlMotion <SID>QuoteLvlMotion
    onoremap <buffer> <script> <SID>QuoteLvlMotion :execute "normal!" . <SID>QuoteLvlMotion(line("."))<cr>
    
endif

" ====================================================================
"                     Mail Manipulation Functions
" ====================================================================

" --------------------------------------------------------------------
"                          Manipulate Quotes
" --------------------------------------------------------------------

"
" Description: 
" This function will try and remove 'quoted' signatures.
"
" If someone responds with an email that doesn't use '>' as the
" quote character this will try and take care of that:
"   | Yeah, I agree vim is cool.
"   | 
"   | -- 
"   | Some power user
"
" If there is a signature inside a 'multi-quoted' email this will try and get
" rid of it:
"   > | No, I don't agree with you.
"   >
"   > Nonsense.  You are wrong.  Grow up.
"   >
"   > | I can't believe I'm even replying to this.
"   > | -- 
"   > | Some power user
"   >
"   > Yeah, believe it, brother.
" 
if !exists("*s:EraseQuotedSig")
function s:EraseQuotedSig()
    while 0 != search((s:quote_start . '\s*--\s*$'), 'w')
        let motion = s:QuoteLvlMotion(line("."))
        exe "normal! d" . motion
    endwhile
endfunction
endif

"
" Description:
" Replacing empty quoted lines (i.e. "> $") with empty lines
" (convenient to automatically reformat one paragraph)
"
if !exists("*s:DelEmptyQuoted")
function s:DelEmptyQuoted()
    let empty_quote = s:quote_start . '\s*$'

    " goto start of email and jump passed headers
    normal gg
    if 0 == search('^$', 'W')
        return
    endif
    
    while 0 != search (empty_quote, 'W')
        let newline = substitute(getline("."), empty_quote, '', '')
        call setline(line("."), newline)
    endwhile
endfunction
endif

"
" Description:
" This function will output a motion command that operatates over a "quote
" level" segment.  This makes it possible to perform vi commands on quotes.
" E.g:
"   dq  => delete an entire quote section
"   gqq => format an entire quote section
"
if !exists("*s:QuoteLvlMotion")
function s:QuoteLvlMotion(line)
    let quote = matchstr(getline(a:line), s:quote_start)
    " abort command if no quote
    if "" == quote
        return "\<esc>"
    endif
        
    let len = s:LenQuoteLvl(a:line, quote)

    " the 'V' makes the motion linewise
    if 1 == len
        return "V" . line(".") . "G"
    else
        return "V" . (len - 1) . "j"
    endif
endfunction
endif

"
" Description:
" This tries to figure out when the quoting level changes
"
if !exists("s:LenQuoteLvl")
function s:LenQuoteLvl(start, quote)
    let i = a:start + 1
    let len = 1
    let quote = '^' . a:quote
    
    " find end of quote
    while i <= line('$')
        " check if quote level decreased
        if -1 == match(getline(i), quote)
            break
        endif

        " check if quote level increased
        if -1 != match(getline(i), (quote . s:quote_re))
            break
        endif
        
        let i   = i   + 1 
        let len = len + 1
    endwhile

    return len
endfunction
endif

" --------------------------------------------------------------------
"                    Location Manipulator Functions
" --------------------------------------------------------------------

"
" Description:
" Moves the cursor to a 'sensible' position.
" 
if !exists("*s:CursorStart")
function s:CursorStart()
    " put cursor in known position
    silent normal gg
    
    if search('^From: $', 'W')
        silent startinsert!
    elseif search('^To: $', 'W')
        silent startinsert!
    elseif search('^Subject: $', 'W')
        silent startinsert!
        
    " check if we are editing a reply
    elseif search('^On.*wrote:', 'W')
        normal 2j
        
    elseif search('^$', 'W')
        normal j
        silent startinsert!
    endif
endfunction
endif

" ================================================
"               Process Mutt Aliases
" ================================================

" ------------------------------------------------
"                  Get Email List
" ------------------------------------------------

"
" Description:
" This function will launch abook and spit out what the user selected from the
" application (by pressing 'Q').  It's always called from 'insert' mode, so
" the text will be inserted like it was typed.
"
" That's why 'paste' is set and reset.  So that the text that we insert won't
" be 'mangled' by the user's settings.
"
if !exists("*s:AliasListAbook")
function s:AliasListAbook()
    let b:AliasListMsg = ""
    let f = tempname()

    set paste
    silent exe '!abook 2> ' . f
    exe 'let addresses=system("cat ' . f . '")'
    if "" == addresses
        let b:AliasListMsg = "Nothing found to lookup"
        return ""
    endif

    " - parses the output from abook
    let addresses=s:ParseMuttQuery(addresses)
    if "" == addresses
        let b:AliasListMsg = b:ParseMuttQueryErr
        return ""
    endif

    " so that they will be aligned under the 'to' or 'cc' line
    let addresses=substitute(addresses, "\n", ",\n    ", "g")

    return addresses
endfunction
endif

" ------------------------------------------------
"                 Get Email Query
" ------------------------------------------------

"
" Description:
" This function assumes that user has the cursor on an alias to lookup.  Based
" on this it:
" - retrieves the alias(es) from abook
" - parses the output from abook
" - actually replaces the alias with the parsed output
"
if !exists("*s:AliasQueryAbook")
function s:AliasQueryAbook()
    let b:AliasQueryMsg = ""

    " - retrieves the alias(es) from abook
    let lookup=expand("<cword>")
    if "" == lookup
        let b:AliasQueryMsg = "Nothing found to lookup"
        return
    endif

    silent exe 'let output=system("abook --mutt-query ' . lookup . '")'
    if v:shell_error
        let b:AliasQueryMsg = output
        return
    endif

    " - parses the output from abook
    let replacement=s:ParseMuttQuery(output)
    if "" == replacement
        let b:AliasQueryMsg = b:ParseMuttQueryErr
        return
    endif

    " so that they will be aligned under the 'to' or 'cc' line
    let replacement=substitute(replacement, "\n", ",\n    ", "g")

    " - actually replaces the alias with the parsed output
    " paste is set/unset so that the email addresses aren't "mangled" by the
    " user's formating options
    set paste
    exe "normal! ciw" . replacement . "\<Esc>"
    set nopaste
endfunction
endif

" --------------------------------------------------------------------
"                          Utility Functions
" --------------------------------------------------------------------

"
" Description:
" This function will take the output of a "mutt query" (as defined by the mutt
" documenation) and parses it.  
"
" It returns the email addresses formatted as follows:
" - each address is on a line
"
if !exists("*s:ParseMuttQuery")
function s:ParseMuttQuery(aliases)
    " remove first informational line
    let aliases   = substitute (a:aliases, "\n", "", "")
    let expansion = ""

    while 1
        " whip off the name and address
        let line    = matchstr(aliases, ".\\{-}\n")
        let address = matchstr(line, ".\\{-}\t")
        let address = substitute(address, "\t", "", "g")
        if "" == address
            let b:ParseMuttQueryErr = "Unable to parse address from ouput"
            return ""
        endif

        let name = matchstr(line, "\t.*\t")
        let name = substitute(name, "\t", "", "g")
        if "" == name
            let b:ParseMuttQueryErr = "Unable to parse name from ouput"
            return ""
        endif

        " debugging:
        " echo "line: " . line . "|"
        " echo "address: " . address . "|"
        " echo "name: " . name . "|"
        " let a=input("hit enter")

        " make into valid email address
        let needquote = match (name, '"')
        if (-1 == needquote)
            let name = '"' . name    . '" '
        endif
        
        let needquote = match (address, '<')
        if (-1 == needquote)
            let address = '<' . address . '>'
        endif
        
        " add email address to list
        let expansion = expansion . name
        let expansion = expansion . address

        " debugging:
        " echo "address: " . address . "|"
        " echo "name: " . name . "|"
        " let a=input("hit enter")
        
        " process next line (if there is one)
        let aliases = substitute(aliases, ".\\{-}\n", "", "")
        if "" == aliases
            let b:ParseMuttQueryErr = ""
            return expansion
        endif

        let expansion = expansion . "\n"
    endwhile
endfunction
endif

" ====================================================================
"                      Abbreviation Manipulation
" ====================================================================

"
" Description:
" This will generate vi abbreviations from your mutt alias file.
" 
" Note:
" However, remember that the abbreviation will be replaced *everywhere*.  For
" example, if you have the alias 'Mary', then if you try and type "Hi, Mary
" vim is cool", then it won't work.  This is because the 'Mary' will be
" expanded as an alias.
"
if !exists("*s:MakeAliasAbbrev")
function s:MakeAliasAbbrev()
    let aliasfile = tempname()
    silent exe "!sed -e 's/alias/iab/' ~/.mutt/aliases > " . aliasfile
    exe "source " . aliasfile
endfunction
endif


" ====================================================================
"                           Initializations
" ====================================================================

if exists ("mail_erase_quoted_sig")
    call s:EraseQuotedSig()
endif

if exists ("mail_delete_empty_quoted")
    call s:DelEmptyQuoted()
endif

if exists ("mail_generate_abbrev")
    call s:MakeAliasAbbrev()
endif

if exists ("mail_cursor_start")
    call s:CursorStart()
endif
