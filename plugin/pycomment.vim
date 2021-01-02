let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/parse.py'

nnoremap <silent> <buffer> <Plug>(pycomment_mark) :call MarkMapping()<CR>
nnoremap <silent> <buffer> <Plug>(pycomment) :call Parse()<CR>
if get(g:, 'pycomment_mark_mapping', 1)
    nmap <silent> <buffer> <leader><leader> <Plug>(pycomment_mark)
endif

if get(g:, 'pycomment_enable', 1)
    nmap <silent> <buffer> <M-c> <Plug>(pycomment)
endif

function! MarkMapping()
    execute("normal \<ESC>/<++>\<CR>:nohl\<CR>c4l")
endfunction

function! Parse()
    " get cursor line content
    let curLineText = getline('.')
    " get cursor line number
    let startCurPos = line('.')
    try
        let returnStatus = execute('/return')
        let returnLineText = getline('.')
        execute('?def\|class')
        let funcHeadPos = line('.')

        execute('py3f ' . expand(s:path))
        if funcType == 'def'
            if funcHeadPos == startCurPos
                call WriteDefParameters()
                call WriteDefReturns()
                call IsEnd()
            else
                call WriteDefParameters()
                call IsEnd()
            endif
        elseif funcType == 'class'
            execute("normal" . eval(startCurPos) . "GA\n\"\"\"\r\<BS>\<BS>" . expand(funcName) . ". \n\n")
            call IsEnd()
        endif
    catch /return$/
        let returnStatus = 'False'
        " parse function
        execute('py3f ' . expand(s:path))
        if funcType == 'def'
            call WriteDefParameters()
            call IsEnd()
        elseif funcType == 'class'
            execute("normal" . eval(startCurPos) . "GA\n\"\"\"\r\<BS>\<BS>" . expand(funcName) . ". \n\n")
            call IsEnd()
        endif
    endtry
endfunction

function! WriteDefParameters()
    execute("normal" . eval(startCurPos) . "GA\n\"\"\"\r\<BS>\<BS>" . expand(funcName) . ". \n\n")

    " write parameters
    execute("normal AParameters\<ESC>>>o----------\n")
    let n = len(b:parameterName)
    for i in range(n)
        execute("normal A" . expand(b:parameterName[i]) .  " : " . expand(b:parameterType[i]) . ". <++>\<ESC>>>o \<ESC>>>o")
    endfor
endfunction

function! WriteDefReturns()
    " write returns
    execute("normal A\nReturns\<ESC>>>o-------\n")
    let n = len(b:returnVar)
    for i in range(n)
        execute("normal A" . expand(b:returnVar[i]) .  " : " . expand(b:returnType[i]) . ". <++>\<ESC>>>o \<ESC>>>o")
    endfor
endfunction

function! IsEnd()
    let endCurPos = line('.')
    let marks = getline(endCurPos+1)
    let n_marks = len(marks)
    if marks[n_marks-1] == "\""
        execute("normal dd" . eval(startCurPos+1) . "G$")
    else
        execute("normal" . eval(endCurPos) . "GA\"\"\"\<ESC>>>")
        execute("normal" . eval(startCurPos+1) . "G$")
    endif
endfunction

