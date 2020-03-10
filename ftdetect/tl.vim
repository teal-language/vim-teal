fun! s:DetectTL()
    if getline(1) =~# '^#!.*/bin/env\s\+tl\>'
        setfiletype tl
    endif
endfun

autocmd BufRead,BufNewFile *.tl setlocal filetype=tl
autocmd BufNewFile,BufRead * call s:DetectTL()
