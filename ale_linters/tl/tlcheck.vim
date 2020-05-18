" Description: Teal linter based on `tl check`

" Based on https://github.com/dense-analysis/ale/blob/master/ale_linters/lua/luacheck.vim

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
    let l:pattern = '^\(.*\):\(\d\+\):\(\d\+\): \(.\+\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'filename': l:match[1],
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 0,
        \   'text': l:match[4],
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
