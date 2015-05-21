" ============================================================================
" File:        tracelog.vim
" Description: vim global plugin to add/remove the trace macros to your source
" Maintainer:  Wilson Huawen Yu <wilson.yuu@gmail.com>
" Notes:       Should have a dir to hold the file name's list of the processing
" ============================================================================

" precondition: cursor stop at begin brace
" auto insert _WAD_TRACE_; into function's enter
fun! s:InsertTraceLine()
    let stringtrace = ":normal o\<TAB>_WAD_TRACE_;\<ESC>"
    if search('\<_WAD_TRACE_', 'pnc', (line(".")+2)) == 0
        exec stringtrace
    endif
endfun

" precondition: cursor stop at begin brace
fun! s:InsertTraceMsg(msg)
    let stringtrace = ":normal o\<TAB>" . a:msg . "\<ESC>"
    if search(a:msg, 'pnc', (line(".")+2)) == 0
        exec stringtrace
    endif
endfun

fun! s:InsertTraceFile()
    exec ":normal gg"
    exec ":normal ]]"
    while search('{', 'pnc', line(".")) > 0
        " macro define
        if search('\\', 'pnc', line(".")) > 0
        "
        else
            exec ":normal %"
            " struct definition or inline function
            if search('\(}.*,\)\|\(}.*;\)', 'pnc', line(".")) > 0
                exec ":normal %"
                if search('\<inline\>', 'pnbc', (line(".")-1)) > 0
                    call s:InsertTraceLine()
                endif
            else
                exec ":normal %"
                call s:InsertTraceLine()
            endif
        endif
        exec ":normal ]]"
    endwhile
endfun

fun! s:InsertTraceAll(action)
    " adjust(clear) specific function
    if a:action == "adjust"
        if filereadable($HOME . "/script/trace.func.del")
            exec ":silent e ~/script/trace.func.del"
            exec ":silent g/^\_s$/normal dd"
            exec ":silent g/(/normal f(d$"
            for line in range(line("1"),line("$"))
                if !empty(getline(line))
                    let stringcmd = ":tjump " . getline(line)
                    "echom stringcmd
                    exec stringcmd
                    if search('\s_WAD_TRACE_', 'c', (line(".")+4)) > 0
                        exec ":silent .g/_WAD_TRACE_/norm I//"
                    endif
                    exec ":silent b ~/script/trace.func.del"
                endif
            endfor
        endif

        if filereadable($HOME . "/script/trace.func.add")
            exec ":silent e ~/script/trace.func.add"
            exec ":silent g/^\_s$/normal dd"
            exec ":silent g/(/normal f(d$"
            for line in range(line("1"),line("$"))
                if !empty(getline(line))
                    let stringcmd = ":cs f g " . getline(line)
                    "echom stringcmd
                    exec stringcmd
                    if search('\s_WAD_TRACE_', 'c', (line(".")+3)) > 0
                        exec ":silent .g/_WAD_TRACE_/norm dd"
                    endif

                    exec stringcmd
                    if search('^{', 'c', (line(".")+2)) > 0
                        call s:InsertTraceLine()
                    endif

                    exec ":silent b ~/script/trace.func.add"
                endif
            endfor
        endif

        " DEBUG: add memset to free, force crash
        if filereadable("daemon/wad/wad_memtrack.c")
            exec ":silent e daemon/wad/wad_memtrack.c"
            exec ":silent normal gg"
            if search('\swad_memtrack_free') > 0
                exec ":silent normal ]]"
                call s:InsertTraceMsg("memset(ptr, 0, size);")
            endif
        endif

        exec ":wa"
        "exec ":qa"
        echo "Traceadjust() Finish!"
        return
    endif

    " check process file list exist
    if !filereadable($HOME . "/script/trace.files")
        echo $HOME . "/script/trace.files not exists"
        return
    endif

    if !filereadable("daemon/wad/ui/fg/wad_ui.c")
                \ || !filereadable("daemon/wad/ui/fg/wad_debug_impl.h")
                \ || !filereadable("daemon/wad/ui/fg/wad_debug_impl.c")
        echo "wad_ui.c wad_debug_impl.[ch] not exists, exit!"
        return
    endif

    " insert trace init
    exec ":silent e daemon/wad/ui/fg/wad_ui.c"
    exec ":normal gg"
    if a:action == "clear"
        exec ":silent g/_WAD_TRACE_/norm dd"
    else
        if search("wad_ui_main") > 0
            exec ":normal ]]"
            let stringtrace = ":normal o\<TAB>_WAD_TRACE_INIT_;\<ESC>"
            if search('\<_WAD_TRACE_', 'pnc', (line(".")+2)) == 0
                exec stringtrace
            endif
        endif
    endif

    " insert trace implement
    exec ":silent e daemon/wad/ui/fg/wad_debug_impl.h"
    exec ":normal gg"
    if a:action == "clear"
        if search("begin-wad-trace") > 0
            exec ":normal ma"
            if search("end-wad-trace") > 0
                exec ":normal mb"
                exec ":'a,'bd"
            endif
        endif
    else
        if search(" WAD_TRACE(") == 0
            if search(" WAD_DEBUG(") == 0
                echo "debug_impl.h have no WAD_TRACE or WAD_DEBUG, exit!"
            endif
        endif
        if search("wad_trace_backtrace_init", 'n') == 0
            exec "/^\s*$"
            exec "r! cat ~/script/trace.macro.def"
        endif
    endif

    exec ":silent e daemon/wad/ui/fg/wad_debug_impl.c"
    exec ":normal gg"
    if a:action == "clear"
        if search("begin-wad-trace") > 0
            exec ":normal ma"
            if search("end-wad-trace") > 0
                exec ":normal mb"
                exec ":'a,'bd"
            endif
        endif
    else
        if search("wad_trace_backtrace_init", 'n') == 0
            exec ":normal G"
            exec "r! cat ~/script/trace.macro.imp"
        endif
    endif

    " insert trace log
    " avoid dead loop
    exec ":silent e ~/script/trace.files"
    exec ":silent g/wad_debug_impl/normal dd"
    exec ":silent g/wad_ui.c/normal dd"
    exec ":silent g/^\_s$/normal dd"
    for line in range(line("1"),line("$"))
        let stringfile = getline(line)
        if filewritable(stringfile)
            exec ":silent e " . stringfile
            if a:action == "clear"
                exec ":silent g/_WAD_TRACE_/norm dd"
            else
                call s:InsertTraceFile()
            endif
            exec ":silent b ~/script/trace.files"
        endif
    endfor

    if a:action == "clear"
        if filereadable($HOME . "/script/trace.func.add")
            exec ":silent e ~/script/trace.func.add"
            exec ":silent g/^\_s$/normal dd"
            exec ":silent g/(/normal f(d$"
            for line in range(line("1"),line("$"))
                if !empty(getline(line))
                    let stringcmd = ":cs f g " . getline(line)
                    "echom stringcmd
                    exec stringcmd
                    if search('\s_WAD_TRACE_', 'c', (line(".")+3)) > 0
                        exec ":silent .g/_WAD_TRACE_/norm dd"
                    endif
                    exec ":silent b ~/script/trace.func.add"
                endif
            endfor
        endif

        "remove: call s:InsertTraceMsg("memset(ptr, 0, size);")
        if filereadable("daemon/wad/wad_memtrack.c")
            exec ":silent e daemon/wad/wad_memtrack.c"
            exec ":silent normal gg"
            if search('\swad_memtrack_free') > 0
                exec ":silent normal ]]"
                if search('\smemset', 'c', (line(".")+3)) > 0
                    exec ":silent .g/memset/norm dd"
                endif
            endif
        endif
    endif

    exec ":wa"
    "exec ":qa"
    echo "Traceadd() Finish!"
    echo "Cont. :call s:Traceadjust() after gen cscope and ctags index"
endfun





"Misc {

fun! s:Traceadd()
    call s:InsertTraceAll("add")
endfun
" Have you cscope first?
fun! s:Traceadjust()
    call s:InsertTraceAll("adjust")
endfun
fun! s:Tracedel()
    call s:InsertTraceAll("clear")
endfun

"}


"Export {

fun! tracelog#Traceadd()
    call s:Traceadd()
endfun

fun! tracelog#Traceadjust()
    call s:Traceadjust()
endfun

fun! tracelog#Tracedel()
    call s:Tracedel()
endfun

"}
