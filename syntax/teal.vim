
if exists("b:current_syntax")
	finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match
syn sync fromstart

syn cluster tealBase contains=
	\ tealComment,tealLongComment,
	\ tealConstant,tealNumber,tealString,tealLongString
syn cluster tealExpression contains=
	\ @tealBase,tealParen,tealBuiltin,tealBracket,tealBrace,
	\ tealOperator,tealFunctionBlock,tealFunctionCall,tealError,
	\ tealTableConstructor,tealRecordBlock,tealEnumBlock,tealSelf,
	\ tealVarargs
syn cluster tealStatement contains=
	\ @tealExpression,tealIfThen,tealThenEnd,tealBlock,tealLoop,
	\ tealRepeatBlock,tealWhileDo,tealForDo,
	\ tealGoto,tealLabel,tealBreak,tealReturn,
	\ tealColon,tealLocal,tealGlobal

" {{{ ), ], end, etc error
syntax match tealError "\()\|}\|\]\)"
syntax match tealError "\<\%(end\|else\|elseif\|then\|until\|in\)\>"
" }}}
" {{{ Types
syn match tealTypeComma /,/ contained
	\ nextgroup=@tealType
	\ skipwhite skipempty skipnl
syn match tealUnion /|/ contained
	\ nextgroup=@tealType
	\ skipwhite skipempty skipnl
syn match tealBasicType /\K\k*\(\.\K\k*\)*/ contained
	\ nextgroup=tealGenericType,tealUnion,tealTypeComma
	\ skipwhite skipempty skipnl
syn match tealFunctionType /\<function\>/ contained
	\ nextgroup=tealFunctionGenericType,tealFunctionTypeArgs,tealUnion,tealTypeComma
	\ skipwhite skipempty skipnl
syn region tealGenericType start=/</ end=/>/ transparent contained
	\ nextgroup=tealUnion,tealTypeComma
	\ skipwhite skipempty skipnl
	\ contains=tealGeneric
syn region tealFunctionGenericType 
	\ matchgroup=tealParens
	\ start=/</ end=/>/ transparent contained
	\ nextgroup=tealFunctionTypeArgs
	\ skipwhite skipempty skipnl
	\ contains=tealGeneric
syn match tealGeneric contained /\K\k*/
syn region tealFunctionTypeArgs contained transparent extend
	\ matchgroup=tealParens
	\ start=/(/ end=/)/
	\ contains=@tealType
	\ nextgroup=tealParenTypesAnnotation
	\ skipwhite skipempty skipnl
syn match tealParenTypesAnnotation /:/ contained
	\ nextgroup=@tealType,tealParenTypes
	\ skipwhite skipempty skipnl
syn region tealParenTypes contained transparent extend
	\ matchgroup=tealParens
	\ start=/(/ end=/)/
	\ contains=@tealType
	\ nextgroup=tealUnion
	\ skipwhite skipempty skipnl
syn region tealTableType start=/{/ end=/}/ contained
	\ nextgroup=tealUnion,tealTypeComma
	\ skipwhite skipempty skipnl
	\ contains=@tealType
syn cluster tealType contains=
	\ tealBasicType,
	\ tealFunctionType,
	\ tealFunctionTypeArgs,
	\ tealParenTypesAnnotation,
	\ tealParenTypes,
	\ tealTableType,
	\ tealGenericType
syn match tealTypeAnnotation /:/ contained
	\ nextgroup=@tealType
	\ skipwhite skipempty skipnl

syn cluster tealNewType contains=
	\ tealRecordBlock,tealEnumBlock,tealNominalFuncType
" }}}
" {{{ Function call
syn match tealColon /:/
	\ nextgroup=@tealType,tealFunctionCall
	\ skipwhite skipempty skipnl
syn match tealFunctionCall /\(:\?\)\@=\K\k*\s*\n*\s*\("\|'\|(\|{\|\[=*\[\)\@=/
" }}}
" {{{ Operators
" Symbols
syn match tealOperator "[#<>=~^&|*/%+-]\|\.\."
" Words
syn keyword tealOperator and or not
syn keyword tealOperator is as
	\ nextgroup=@tealType
	\ skipempty skipnl skipwhite
syn match tealVarargs /\.\.\./
" }}}
" {{{ Comments
syn match tealComment "\%^#!.*$"
syn match tealComment /--.*$/ contains=tealTodo,@Spell
syn keyword tealComment contained TODO FIXME XXX
syn region tealLongComment start=/--\[\z(=*\)\[/ end=/\]\z1\]/

" }}}
" {{{ functiontype
syn keyword tealNominalFuncType functiontype
	\ nextgroup=tealFunctionGenericType,tealFunctionTypeArgs
	\ skipempty skipnl skipwhite
" }}}
" {{{ local ... <const>, global ... <const>, break, return, self
syn region tealAttributeBrackets contained transparent
	\ matchgroup=tealParens
	\ start=/</ end=/>/
	\ contains=tealAttribute
	\ nextgroup=tealVarComma,tealTypeAnnotation
	\ skipwhite skipempty skipnl
syn match tealAttribute contained /\K\k*/
syn match tealVarName contained /\K\k*/
	\ nextgroup=tealAttributeBrackets,tealVarComma,tealTypeAnnotation
	\ skipwhite skipempty skipnl
syn match tealVarComma /,/ contained
	\ nextgroup=tealVarName
	\ skipwhite skipempty skipnl
syn keyword tealLocal local
	\ nextgroup=tealFunctionBlock,tealVarName
	\ skipwhite skipempty skipnl
syn keyword tealGlobal global
	\ nextgroup=tealFunctionBlock,tealVarName
	\ skipwhite skipempty skipnl
syn keyword tealBreak break
syn keyword tealReturn return
syn keyword tealSelf self

" }}}
" {{{ Parens
syn region tealParen transparent
	\ matchgroup=tealParens
	\ start=/(/ end=/)/
	\ contains=@tealExpression
syn region tealBracket transparent
	\ matchgroup=tealBrackets
	\ start=/\[/ end=/\]/
	\ contains=@tealExpression
" }}}
" {{{ function ... end
syn region tealFunctionBlock transparent
	\ matchgroup=tealFunction
	\ start=/\<function\>/ end=/\<end\>/
	\ contains=@tealStatement,tealFunctionSignature
syn region tealFunctionSignature contained transparent
	\ start=/\(\<function\>\)\@<=/ end=/)/ keepend
	\ contains=tealFunctionName,tealFunctionGeneric,tealFunctionArgs
syn match tealFunctionName /\K\k*\(\.\K\k*\)*\(:\K\k*\)\?/ contained
	\ nextgroup=tealFunctionGeneric,tealFunctionArgs
	\ skipwhite skipempty skipnl
syn region tealFunctionGeneric contained transparent
	\ start=/</ end=/>/
	\ contains=tealGeneric
	\ nextgroup=tealFunctionArgs
	\ skipwhite skipempty skipnl
syn region tealFunctionArgs contained transparent
	\ matchgroup=tealParens
	\ start=/(/ end=/)/
	\ contains=@tealBase,tealFunctionArgName,
	\ tealFunctionArgTypeAnnotation,@tealType
	\ nextgroup=tealTypeAnnotation
syn match tealFunctionArgName contained /\K\k*/
	\ nextgroup=tealFunctionArgTypeAnnotation,tealFunctionArgComma
	\ skipwhite skipempty skipnl
syn region tealFunctionArgTypeAnnotation contained transparent
	\ start=/:/ end=/\(,\|)\)\@=/ skip=/:/
	\ contains=@tealType
	\ nextgroup=tealFunctionArgName
	\ skipwhite skipempty skipnl
" }}}
" {{{ record ... end
syn region tealRecordBlock
	\ matchgroup=tealRecord transparent
 	\ start=/\<record\>/ end=/\<end\>/
	\ contains=tealRecordItem,
	\ tealRecordAssign,tealRecordGeneric,tealTableType,
	\ tealComment,tealLongComment
syn region tealRecordGeneric contained transparent
	\ matchgroup=tealParens
	\ start=/\(\<record\>\)\@<=\s*</ end=/>/
	\ contains=tealGeneric
	\ nextgroup=tealRecordItem
	\ skipwhite skipnl skipempty
syn match tealRecordItem /\K\k*/ contained
	\ nextgroup=tealTypeAnnotation,tealRecordAssign
	\ skipwhite skipnl skipempty
syn match tealRecordAssign /=/ contained
	\ nextgroup=@tealNewType
	\ skipwhite skipnl skipempty
hi def link tealRecordAssign tealOperator
" }}}
" {{{ enum ... end
syn region tealEnumBlock
	\ matchgroup=tealEnum transparent
	\ start="\<enum\>" end="\<end\>"
	\ contains=tealString,tealLongString,tealComment,tealLongComment
" }}}
" {{{ if ... then, elseif ... then, then ... end, else
syn region tealIfThen
	\ transparent matchgroup=tealIfStatement
	\ start=/\<if\>/ end=/\<then\>/me=e-4
	\ contains=@tealExpression
syn region tealElseifThen
	\ transparent matchgroup=tealIfStatement
	\ start=/\<elseif\>/ end=/\<then\>/
	\ contains=@tealExpression
syn region tealThenEnd
	\ transparent matchgroup=tealIfStatement
	\ start=/\<then\>/ end=/\<end\>/
	\ contains=@tealStatement,tealElseifThen,tealElse
syn keyword tealElse else contained
" }}}
" {{{ for ... do ... end, in
syn region tealForDo
	\ matchgroup=tealFor transparent
	\ contains=tealIn,@tealExpression
	\ start=/\<for\>/ end=/\<do\>/me=e-2
syn keyword tealIn in contained
" }}}
" {{{ while ... do ... end
syn region tealWhileDo
	\ matchgroup=tealWhile transparent
	\ contains=@tealExpression
	\ start=/\<while\>/ end=/\<do\>/me=e-2
" }}}
" {{{ do ... end
syn region tealBlock
	\ matchgroup=tealDoEnd transparent
	\ contains=@tealStatement
	\ start=/\<do\>/ end=/\<end\>/
" }}}
" {{{ repeat ... until
syn region tealRepeatBlock
	\ matchgroup=tealRepeatUntil transparent
	\ contains=@tealStatement
	\ start=/\<repeat\>/ end=/\<until\>/
" }}}
" {{{ Table Constructor
syn region tealTableConstructor
	\ matchgroup=tealTable
	\ start=/{/ end=/}/
	\ contains=@tealExpression,tealTypeAnnotation

" }}}
" {{{ Goto
syn keyword tealGoto goto
syn match tealLabel /::\K\k*::/

" }}}
" {{{ true, false, nil, etc...
syn keyword tealConstant nil true false
" }}}
" {{{ Strings
syn match tealSpecial contained #\\[\\abfnrtvz'"]\|\\x[[:xdigit:]]\{2}\|\\[[:digit:]]\{,3}#
syn region tealLongString matchgroup=tealString start="\[\z(=*\)\[" end="\]\z1\]" contains=@Spell
syn region tealString  start=+'+ end=+'+ skip=+\\\\\|\\'+ contains=tealSpecial,@Spell
syn region tealString  start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=tealSpecial,@Spell
" }}}
" {{{ Numbers
" integer number
syn match tealNumber "\<\d\+\>"
" floating point number, with dot, optional exponent
syn match tealNumber  "\<\d\+\.\d*\%([eE][-+]\=\d\+\)\=\>"
" floating point number, starting with a dot, optional exponent
syn match tealNumber  "\.\d\+\%([eE][-+]\=\d\+\)\=\>"
" floating point number, without dot, with exponent
syn match tealNumber  "\<\d\+[eE][-+]\=\d\+\>"
" hex numbers
syn match tealNumber "\<0[xX][[:xdigit:].]\+\%([pP][-+]\=\d\+\)\=\>"
" }}}
" {{{ Built ins

syn keyword tealBuiltIn assert error collectgarbage
	\ print tonumber tostring type
	\ getmetatable setmetatable
	\ ipairs pairs next
	\ pcall xpcall
	\ _G _ENV _VERSION require
	\ rawequal rawget rawset rawlen
	\ loadfile load dofile select
syn match tealBuiltIn /\<package\.cpath\>/
syn match tealBuiltIn /\<package\.loaded\>/
syn match tealBuiltIn /\<package\.loadlib\>/
syn match tealBuiltIn /\<package\.path\>/
syn match tealBuiltIn /\<coroutine\.running\>/
syn match tealBuiltIn /\<coroutine\.create\>/
syn match tealBuiltIn /\<coroutine\.resume\>/
syn match tealBuiltIn /\<coroutine\.status\>/
syn match tealBuiltIn /\<coroutine\.wrap\>/
syn match tealBuiltIn /\<coroutine\.yield\>/
syn match tealBuiltIn /\<string\.byte\>/
syn match tealBuiltIn /\<string\.char\>/
syn match tealBuiltIn /\<string\.dump\>/
syn match tealBuiltIn /\<string\.find\>/
syn match tealBuiltIn /\<string\.format\>/
syn match tealBuiltIn /\<string\.gsub\>/
syn match tealBuiltIn /\<string\.len\>/
syn match tealBuiltIn /\<string\.lower\>/
syn match tealBuiltIn /\<string\.rep\>/
syn match tealBuiltIn /\<string\.sub\>/
syn match tealBuiltIn /\<string\.upper\>/
syn match tealBuiltIn /\<string\.gmatch\>/
syn match tealBuiltIn /\<string\.match\>/
syn match tealBuiltIn /\<string\.reverse\>/
syn match tealBuiltIn /\<table\.pack\>/
syn match tealBuiltIn /\<table\.unpack\>/
syn match tealBuiltIn /\<table\.concat\>/
syn match tealBuiltIn /\<table\.sort\>/
syn match tealBuiltIn /\<table\.insert\>/
syn match tealBuiltIn /\<table\.remove\>/
syn match tealBuiltIn /\<math\.abs\>/
syn match tealBuiltIn /\<math\.acos\>/
syn match tealBuiltIn /\<math\.asin\>/
syn match tealBuiltIn /\<math\.atan\>/
syn match tealBuiltIn /\<math\.atan2\>/
syn match tealBuiltIn /\<math\.ceil\>/
syn match tealBuiltIn /\<math\.sin\>/
syn match tealBuiltIn /\<math\.cos\>/
syn match tealBuiltIn /\<math\.tan\>/
syn match tealBuiltIn /\<math\.deg\>/
syn match tealBuiltIn /\<math\.exp\>/
syn match tealBuiltIn /\<math\.floor\>/
syn match tealBuiltIn /\<math\.log\>/
syn match tealBuiltIn /\<math\.max\>/
syn match tealBuiltIn /\<math\.min\>/
syn match tealBuiltIn /\<math\.huge\>/
syn match tealBuiltIn /\<math\.fmod\>/
syn match tealBuiltIn /\<math\.modf\>/
syn match tealBuiltIn /\<math\.ult\>/
syn match tealBuiltIn /\<math\.tointeger\>/
syn match tealBuiltIn /\<math\.maxinteger\>/
syn match tealBuiltIn /\<math\.mininteger\>/
syn match tealBuiltIn /\<math\.pow\>/
syn match tealBuiltIn /\<math\.rad\>/
syn match tealBuiltIn /\<math\.sqrt\>/
syn match tealBuiltIn /\<math\.random\>/
syn match tealBuiltIn /\<math\.randomseed\>/
syn match tealBuiltIn /\<math\.pi\>/
syn match tealBuiltIn /\<io\.close\>/
syn match tealBuiltIn /\<io\.flush\>/
syn match tealBuiltIn /\<io\.input\>/
syn match tealBuiltIn /\<io\.lines\>/
syn match tealBuiltIn /\<io\.open\>/
syn match tealBuiltIn /\<io\.output\>/
syn match tealBuiltIn /\<io\.popen\>/
syn match tealBuiltIn /\<io\.read\>/
syn match tealBuiltIn /\<io\.stderr\>/
syn match tealBuiltIn /\<io\.stdin\>/
syn match tealBuiltIn /\<io\.stdout\>/
syn match tealBuiltIn /\<io\.tmpfile\>/
syn match tealBuiltIn /\<io\.type\>/
syn match tealBuiltIn /\<io\.write\>/
syn match tealBuiltIn /\<os\.clock\>/
syn match tealBuiltIn /\<os\.date\>/
syn match tealBuiltIn /\<os\.difftime\>/
syn match tealBuiltIn /\<os\.execute\>/
syn match tealBuiltIn /\<os\.exit\>/
syn match tealBuiltIn /\<os\.getenv\>/
syn match tealBuiltIn /\<os\.remove\>/
syn match tealBuiltIn /\<os\.rename\>/
syn match tealBuiltIn /\<os\.setlocale\>/
syn match tealBuiltIn /\<os\.time\>/
syn match tealBuiltIn /\<os\.tmpname\>/
syn match tealBuiltIn /\<debug\.debug\>/
syn match tealBuiltIn /\<debug\.gethook\>/
syn match tealBuiltIn /\<debug\.getinfo\>/
syn match tealBuiltIn /\<debug\.getlocal\>/
syn match tealBuiltIn /\<debug\.getupvalue\>/
syn match tealBuiltIn /\<debug\.setlocal\>/
syn match tealBuiltIn /\<debug\.setupvalue\>/
syn match tealBuiltIn /\<debug\.sethook\>/
syn match tealBuiltIn /\<debug\.traceback\>/
syn match tealBuiltIn /\<debug\.getmetatable\>/
syn match tealBuiltIn /\<debug\.setmetatable\>/
syn match tealBuiltIn /\<debug\.getregistry\>/
syn match tealBuiltIn /\<debug\.getuservalue\>/
syn match tealBuiltIn /\<debug\.setuservalue\>/
syn match tealBuiltIn /\<debug\.upvalueid\>/
syn match tealBuiltIn /\<debug\.upvaluejoin\>/
syn match tealBuiltIn /\<utf8\.char\>/
syn match tealBuiltIn /\<utf8\.charpattern\>/
syn match tealBuiltIn /\<utf8\.codepoint\>/
syn match tealBuiltIn /\<utf8\.codes\>/
syn match tealBuiltIn /\<utf8\.len\>/
syn match tealBuiltIn /\<utf8\.offset\>/

" }}}
" {{{ Highlight
hi def link tealKeyword               Keyword
hi def link tealFunction              Keyword
hi def link tealFunctionName          Function
hi def link tealFunctionArgName       Identifier
hi def link tealLocal                 Keyword
hi def link tealGlobal                Keyword
hi def link tealBreak                 Keyword
hi def link tealReturn                Keyword
hi def link tealIn                    Keyword
hi def link tealSelf                  Special
hi def link tealTable                 Structure
hi def link tealBasicType             Type
hi def link tealFunctionType          Type
hi def link tealNominalFuncType       Keyword
hi def link tealAttribute             StorageClass
hi def link tealParens                Identifier
hi def link tealRecord                Keyword
hi def link tealEnum                  Keyword
hi def link tealIfStatement           Conditional
hi def link tealElse                  Conditional
hi def link tealFor                   Repeat
hi def link tealWhile                 Repeat
hi def link tealDoEnd                 Keyword
hi def link tealRepeatUntil           Repeat
hi def link tealFunctionCall          Function
hi def link tealGoto                  Keyword
hi def link tealLabel                 Label
hi def link tealString                String
hi def link tealLongString            String
hi def link tealSpecial               Special
hi def link tealComment               Comment
hi def link tealLongComment           Comment
hi def link tealConstant              Constant
hi def link tealNumber                Number
hi def link tealOperator              Operator
hi def link tealBuiltin               Identifier
hi def link tealError                 Error
hi def link tealGeneric               Type
" }}}

let b:current_syntax = "teal"

let &cpo = s:cpo_save
unlet s:cpo_save
