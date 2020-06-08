" Vim indent file
" Language: Teal
" Options: teal_no_multi_indent

" Adapted from https://github.com/tbastos/vim-lua

" {{{ setup
if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal autoindent
setlocal nosmartindent

setlocal indentexpr=GetTealIndent()
setlocal indentkeys+=0=end,0=until

if exists("*GetTealIndent")
	finish
endif
" }}}
" {{{ Patterns
let s:open_patt = '\C\%(\<\%(function\|record\|enum\|if\|repeat\|do\)\>\|(\|{\)'
let s:middle_patt = '\C\<\%(else\|elseif\)\>'
let s:close_patt = '\C\%(\<\%(end\|until\)\>\|)\|}\)'

let s:anon_func_start = '\S\+\s*[({].*\<function\s*(.*)\s*$'
let s:anon_func_end = '\<end\%(\s*[)}]\)\+'

let s:skip_expr = "synIDattr(synID(line('.'),col('.'),1),'name') =~# 'tealBasicType\\|tealFunctionType\\|tealFunctionTypeArgs\\|tealParenTypes\\|tealTableType\\|tealFunctionArgs\\|tealComment\\|tealString'"
" }}}
" {{{ Helpers
function s:IsInCommentOrString(line_num, column)
	return synIDattr(synID(a:line_num, a:column, 1), 'name') =~# 'tealLongComment\|tealLongString'
		\ && !(getline(a:line_number) =~# '^\s*\%(--\)\?\[=*\[')
endfunction

function s:PrevLineOfCode(line_num)
	let line_num = prevnonblank(a:line_num)
	while s:IsInCommentOrString(line_num, 1)
		let line_num = prevnonblank(line_num - 1)
	endwhile
	return line_num
endfunction

" for teal we should probably strip type annotations
function s:GetLineContent(line_number)
	" strip trailing comments
	return substitute(getline(a:line_number), '\v\m--.*$', '', '')
endfunction
" }}}

function GetTealIndent()
	if s:IsInCommentOrString(v:lnum, 1)
		return -1
	endif
	let prev_line = s:PrevLineOfCode(v:lnum - 1)
	if prev_line == 0
		return 0
	endif
	
	let current_contents = s:GetLineContent(v:lnum)
	let prev_contents = s:GetLineContent(prev_line)
	let cur_pos = getpos(".")

	" count opens
	call cursor(v:lnum, 1)
	let num_prev_opens = searchpair(s:open_patt, s:middle_patt, s:close_patt,
		\ 'mrb', s:skip_expr, prev_line)

	" count closes
	call cursor(prev_line, col([prev_line,'$']))
	let num_closes = searchpair(s:open_patt, s:middle_patt, s:close_patt,
		\ 'mr', s:skip_expr, v:lnum)

	let i = num_prev_opens - num_closes

	" if previous line closed paren, outdent
	" excluding anonymous functions
	call cursor(prev_line - 1, col([prev_line - 1, '$']))
	let num_prev_closed_parens = searchpair('(', '', ')', 'mr',
		\ s:skip_expr, prev_line)
	if num_prev_closed_parens > 0 && prev_contents !~# s:anon_func_end
		let i -= 1
	endif

	" if this line closed a paren, indent
	" excluding anonymous functions
	call cursor(prev_line, col([prev_line, '$']))
	let num_current_closed_parens = searchpair('(', '', ')', 'mr',
		\ s:skip_expr, v:lnum)
	if num_current_closed_parens > 0 && current_contents !~# s:anon_func_end
		let i += 1
	endif

	" special case for ({function()
	if i > 1 && contents_prev =~# s:anon_func_start
		let i = 1
	endif
	" special case for end})
	if i < -1 && contents_cur =~# s:anon_func_end
		let i = -1
	endif

	" restore cursor
	call setpos(".", cur_pos)

	if exists("g:teal_no_multi_indent")
		if i > 1
			let i = 1
		elseif i < -1
			let i = -1
		endif
	endif
	return indent(prev_line) + (shiftwidth() * i)
endfunction
