" Vim indent file
" Language: Teal

" Adapted from https://github.com/tbastos/vim-lua and the default lua file

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
let s:begin_block_open_patt = '^\s*\%(if\>\|for\>\|while\>\|repeat\>\|else\>\|elseif\>\|do\>\|then\>\)'
let s:end_block_open_patt = '\({\|(\|enum\>\)\s*$'
let s:block_close_patt = '^\s*\%(end\>\|else\>\|elseif\>\|until\>\|}\|)\)'

let s:function_patt = '\<function\>'
let s:record_patt = '\<record\>'
let s:ignore_patt = 'tealString'
	\ . '\|tealLongString' 
	\ . '\|tealComment' 
	\ . '\|tealLongComment' 
	\ . '\|tealBasicType'
	\ . '\|tealFunctionType'
	\ . '\|tealFunctionTypeArgs'
	\ . '\|tealParenTypes'
	\ . '\|tealTableType'
	\ . '\|tealGenericType'
	\ . '\|tealTypeAnnotation'
	\ . '\|tealVarName'

let s:bin_op = "[<>=~^&|*/\%+-.:]"
let s:starts_with_bin_op = "^[\t ]*" . s:bin_op 
let s:ends_with_bin_op = s:bin_op . "[\t ]*$"
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

" strip comments
function s:GetLineContent(line_number)
	" remove trailing -- ...
	let content = getline(a:line_number)
	return substitute(content, '--.*$', '', '')
endfunction

function s:MatchPatt(line_num, line_content, patt, prev_match)
	if a:prev_match != -1
		return a:prev_match
	endif
	let match_index = match(a:line_content, a:patt)
	if match_index != -1 &&
		\ synIDattr(synID(a:line_num, match_index+1, 1), "name") =~# s:ignore_patt
		let match_index = -1
	endif
	return match_index
endfunction
" }}}
" {{{ The Indent function
function GetTealIndent()
	if s:IsInCommentOrString(v:lnum, 1)
		return indent(v:lnum - 1)
	endif
	let prev_line_num = s:PrevLineOfCode(v:lnum - 1)
	if prev_line_num == 0
		return 0
	endif

	let prev_line = s:GetLineContent(prev_line_num)

	let i = 0
	let match_index = s:MatchPatt(prev_line_num, prev_line, s:begin_block_open_patt, -1)
	let match_index = s:MatchPatt(prev_line_num, prev_line, s:end_block_open_patt, match_index)
	let match_index = s:MatchPatt(prev_line_num, prev_line, s:function_patt, match_index)
	let match_index = s:MatchPatt(prev_line_num, prev_line, s:record_patt, match_index)

	" If the previous line opens a block (and doesnt close it), outdent
	if match_index != -1 && prev_line !~# '\<end\>\|\<until\>'
		let i += 1
	endif

	" If the current line closes a block, indent
	let curr_line = s:GetLineContent(v:lnum)
	" let match_index = match(curr_line, s:block_close_patt)
	let match_index = s:MatchPatt(v:lnum, curr_line, s:block_close_patt, -1)
	if match_index != -1
		let i -= 1
	endif

	" if line starts with bin op and previous line doesnt, indent
	let current_starts_with_bin_op = 0
	let prev_starts_with_bin_op = 0
	" let match_index = match(curr_line, s:starts_with_bin_op)
	let match_index = s:MatchPatt(v:lnum, curr_line, s:starts_with_bin_op, -1)
	if match_index != -1
		let current_starts_with_bin_op = 1
	endif
	" let match_index = match(prev_line, s:starts_with_bin_op)
	let match_index = s:MatchPatt(prev_line_num, prev_line, s:starts_with_bin_op, -1)
	if match_index != -1
		let prev_starts_with_bin_op = 1
	endif

	if current_starts_with_bin_op 
		if !prev_starts_with_bin_op
			let i += 1
		endif
	else
		if prev_starts_with_bin_op
			let i -= 1
		endif
	endif

	return indent(prev_line_num) + (shiftwidth() * i)
endfunction
" }}}
