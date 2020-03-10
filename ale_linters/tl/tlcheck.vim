" Author: Patrick Desaulniers https://github.com/pdesaulniers
" Description: TL linter based on `tl check`

call ale#Set('tl_tlcheck_executable', 'tl')
call ale#Set('tl_tlcheck_options', '')

function! ale_linters#tl#tlcheck#GetCommand(buffer) abort
    return '%e' . ale#Pad(ale#Var(a:buffer, 'tl_tlcheck_options'))
    \   . ' check %s'
endfunction

function! ale_linters#tl#tlcheck#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " artal.tl:159:17: shadowing definition of loop variable 'i' on line 106
    " artal.tl:182:7: unused loop variable 'i'
    let l:pattern = '^.*:\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        if !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
        \   && l:match[3] is# 'W'
        \   && index(range(611, 614), str2nr(l:match[4])) >= 0
            continue
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('tl', {
\   'name': 'tlcheck',
\   'executable': {b -> ale#Var(b, 'tl_tlcheck_executable')},
\   'command': function('ale_linters#tl#tlcheck#GetCommand'),
\   'callback': 'ale_linters#tl#tlcheck#Handle',
\   'output_stream': 'both'
\})
