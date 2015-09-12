" breakpts.vim
" Author: Hari Krishna Dara (hari.vim at gmail dot com)
" Last Change: 06-May-2004 @ 20:08
" Created: 09-Jan-2003
" Requires: Vim-7.1, genutils.vim(2.4)
" Depends On: foldutil.vim(1.4), cmdalias.vim(1.0)
" Version: 4.0.2
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=618
" Description:
"   Read :help breakpts.
"
" Usage Scenarios {{{
"   - Start the browser using :BreakPts command for the first time with each
"     of the three options.
"   - Switch to a each of the three views using :BreakPts by using each of the
"     three options, make sure the history is gone.
"   - Try switching the views for all unique combinations as below, make sure
"     the history is not gone, and there is no duplicate when switching to the
"     same item (use :BPFunctions, :BPScripts, :BPPoints, :BPListFunc,
"     :BPListScript commands)
"     - Functions -> Functions
"     - Functions -> Breakpoints
"     - Breakpoints -> Breakpoints
"     - Breakpoints -> Scripts
"     - Scripts -> Scripts
"     - Scripts -> Script
"     - Script -> Same Script
"     - Script -> Different Script
"     - Script -> Function
"     - Function -> Same Function
"     - Function -> Different Function
"     - Fuction -> Functions
"   - In each of the five views, try doing a refresh, make sure there is no
"     duplicate in the history and that the cursor position is preserved.
"   - In the Functions, Function, Scripts and Script views, try selecting an
"     item.
"   - In the Breakpoints view, try selecting a func item and a file item. Also
"     try selecting when there are no breakpoints defined.
"   - In Functions and Scripts views, try toggling breakpoint, make sure it is
"     ignored.
"   - In the Function, Script and Breakpoints views, try toggling
"     (enable/disable) breakpoint (both func and file type in Breakpoints
"     view). Navigate to the corresponding list view and make sure that the
"     breakpoints are marked (try toggling breakpoint in the list view, again).
"   - In the scripts window, reload a script after making some changes and
"     make sure it gets reflected.
" Usage Scenarios }}}

if exists('loaded_breakpts')
  finish
endif
if v:version < 701
  echomsg 'breakpts: You need at least Vim 7.1'
  finish
endif
if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 204
  echomsg 'breakpts: You need a version 204 or higher of genutils.vim plugin'
  finish
endif
let loaded_breakpts = 400

" No error if not found.
if !exists('loaded_cmdalias')
  runtime plugin/cmdalias.vim
endif

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" Initialization {{{

command! -nargs=? BreakPts :call breakpts#BrowserMain(<f-args>)
nnoremap <script> <silent> <Plug>BreakPts :BreakPts<cr>
command! -nargs=0 BreakPtsSetupBuf :call breakpts#SetupBuf()
command! -nargs=1 BreakPtsSave :call breakpts#SaveBrkPts(<f-args>)
command! BreakPtsClearBPCounters :call breakpts#ClearBPCounters()
command! BreakPtsClearAll :call breakpts#ClearAllBrkPts()
command! Where :exec breakpts#GenContext() | echo g:BPCurContext
command! -bang -nargs=+ -complete=custom,breakpts#RuntimeComplete Runtime :runtime<bang> <args>
command! -nargs=+ -complete=custom,breakpts#BreakAddComplete Breakadd :breakadd <args>
command! -nargs=+ -complete=custom,breakpts#BreakDelComplete Breakdel :breakdel <args>
command! -complete=command -nargs=+ Debug :debug <args>
if exists('*CmdAlias')
  call CmdAlias('runtime', 'Runtime')
  call CmdAlias('breaka', 'Breaka')
  call CmdAlias('breakad', 'Breakad')
  call CmdAlias('breakadd', 'Breakadd')
  call CmdAlias('breakd', 'Breakd')
  call CmdAlias('breakde', 'Breakde')
  call CmdAlias('breakdel', 'Breakdel')
  call CmdAlias('debug', 'Debug')
endif
if !exists("g:brkptsCreateFolds")
  let g:brkptsCreateFolds = 1
endif
if !exists("g:brkptsFoldContext")
  let g:brkptsFoldContext = 3
endif
if !exists("g:brkptsDefStartMode")
  " Avoid autoloading the plugin.
  "let g:brkptsDefStartMode = breakpts#BM_FUNCTIONS
  let g:brkptsDefStartMode = 'functions'
endif
if !exists("g:brkptsModFuncHeader")
  let g:brkptsModFuncHeader = 1
endif

" WinManager call backs {{{
function! BreakPts_Start()
  call BreakPts_Refresh()
endfunction

function! BreakPts_Refresh()
  call breakpts#WinManagerRefresh()
endfunction

function! BreakPts_IsValid()
  return 1
endfunction

function! BreakPts_ReSize()
endfunction
" WinManager call backs }}}

" Convenience functions (also backwards compatibility) {{{
function! BPBreakIfCount(skipCnt, expireCnt, cond, offset)
  return breakpts#BreakIfCount(a:skipCnt, a:expireCnt, a:cond, a:offset)
endfunction

function! BPBreak(offset)
  return breakpts#Break(a:offset)
endfunction

function! BPBreakIf(cond, offset)
  return breakpts#BreakIf(a:cond, a:offset)
endfunction

function! BPDeBreak(offset)
  return breakpts#DeBreak(a:offset)
endfunction
" }}}

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker sw=2 et
