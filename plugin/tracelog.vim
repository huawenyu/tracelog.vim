" ============================================================================
" File:        tracelog.vim
" Description: the wrapper of autoload
" ============================================================================


"Init {
if exists('loaded_tracelog')
    finish
endif
let loaded_tracelog = 1
"}

"Misc {
command! -nargs=0 Traceadd call tracelog#Traceadd()
command! -nargs=0 Traceadjust call tracelog#Traceadjust()
command! -nargs=0 Tracedel call tracelog#Tracedel()
"}
