
if exists("loaded_matchit")
	let b:match_ignorecase = 0
	let b:match_words=
		\ '\<\%(do\|enum\|record\|function\|if\)\>:' .
		\ '\<\%(return\|else\|elseif\)\>:' .
		\ '\<end\>,' .
		\ '\<repeat\>:\<until\>'
endif
if exists("loaded_endwise")
	let b:endwise_addition = 'end'
	let b:endwise_words = 'function,do,then,enum,record'
	let b:endwise_pattern = '\zs\%(\<function\>\)\%(.*\<end\>\)\@!\|\<\%(then\|do\|record\|enum\)\ze\s*$'
	let b:endwise_syngroups = 'tealFunction,tealDoEnd,tealIfStatement,tealRecord,tealEnum'
endif

