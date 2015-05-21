" ============================================================================
" File:        tracelog.vim
" Description: the wrapper of autoload
" ============================================================================


"Init {
if exists('g:loaded_tracelog') || &cp || v:version < 700
    finish
endif

if !exists('g:tracelog_default_dir')
    echom 'Please define trace dir like: \nlet g:tracelog_default_dir = $HOME . "/script/wad/"'
    finish
endif

let g:loaded_tracelog = 1
"}

"Misc {
command! -nargs=0 Traceadd call tracelog#Traceadd()
command! -nargs=0 Traceadjust call tracelog#Traceadjust()
command! -nargs=0 Tracedel call tracelog#Tracedel()
"}
