
if exists("current_compiler")
	finish
endif
let current_compiler = "tl"

let s:cpo_save = &cpo
set cpo&vim

if exists("g:teal_check_only")
	CompilerSet makeprg=tl\ check\ %
elseif exists("g:teal_check_before_gen")
	CompilerSet makeprg=tl\ check\ %\ &&\ tl\ gen\ %
else
	CompilerSet makeprg=tl\ gen\ %
endif
CompilerSet errorformat=%f:%l:%c:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save
