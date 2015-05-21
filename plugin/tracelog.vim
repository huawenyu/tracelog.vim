" ============================================================================
" File:        tracelog.vim
" Description: the wrapper of autoload
" ============================================================================


"Init {
if exists('g:loaded_tracelog') || &cp || v:version < 700
    finish
endif

if !exists('g:tracelog_default_dir')
    echom 'Please define trace config dir:'
    echom '    let g:tracelog_default_dir = $HOME . "/script/trace-wad/"'
    echom 'And the dir have files "files, func-add, func-comment, macro-def, macro-imp" '
    finish
endif

let g:loaded_tracelog = 1
"}

"Misc {
command! -nargs=0 Traceadd call tracelog#Traceadd()
command! -nargs=0 Traceadjust call tracelog#Traceadjust()
command! -nargs=0 Tracedel call tracelog#Tracedel()
"}
