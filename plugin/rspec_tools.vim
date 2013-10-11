" Note: I took the same approach as vim-rails to enhance the ruby filetype
" settings with rspec specific stuff.

if exists('g:loaded_rspec_tools')
  finish
endif
let g:loaded_rspec_tools = 1

" Ripped from vim-ruby. I wish these weren't script scoped  -------------------- {{{
function! <SID>searchsyn(pattern,syn,flags,mode)
  norm! m'
  if a:mode ==# 'v'
    norm! gv
  endif
  let i = 0
  let cnt = v:count ? v:count : 1
  while i < cnt
    let i = i + 1
    let line = line('.')
    let col  = col('.')
    let pos = search(a:pattern,'W'.a:flags)
    while pos != 0 && <SID>synname() !~# a:syn
      let pos = search(a:pattern,'W'.a:flags)
    endwhile
    if pos == 0
      call cursor(line,col)
      return
    endif
  endwhile
endfunction

function! <SID>synname()
  return synIDattr(synID(line('.'),col('.'),0),'name')
endfunction
" }}}

" focus metadata functions -------------------- {{{
" Adds a focus metadata flag to the rspec group or example.
"
" * Doesn't add focus if its already set
" * errors if the line doesn't look like it starts a group or example
"   definition
function! RspecToolsFocusAdd()
  if !s:RspecToolsIsLineFocusable()
    return
  endif

  if s:RspecToolsHasFocus()
    return
  endif

  call s:Preserve("normal! $gEa, :focus => true\<ESC>")
endfunction

" Deletes a focus metadata flag to the rspec group or example.
"
" * Doesn't do anything if focus doesn't seem to be set
" * errors if the line doesn't look right?
function! RspecToolsFocusDel()
  if !s:RspecToolsIsLineFocusable()
    return
  endif

  if !s:RspecToolsHasFocus()
    return
  endif

  call s:Preserve("normal! " . ':s/\v,\s+:focus(\s+\=\>\s+true)?//' . "\<CR>", 'silent')
endfunction

" Toggles the focus metadata flag to the rspec group or example.
"
" * errors if the line doesn't look right?
function! RspecToolsFocusToggle()
  if !s:RspecToolsIsLineFocusable()
    return
  endif

  if s:RspecToolsHasFocus()
    call RspecToolsFocusDel()
  else
    call RspecToolsFocusAdd()
  endif
endfunction

" Deletes all focus metadata from the file, if any
function! RspecToolsFocusClear()

  " determine the number of matches in the file, by using the 'n' flag.
  redir => l:message
  call s:Preserve("normal! " . ':%s/\v((context|describe|its?).+),\s+:focus(\s+\=\>\s+true)?(.*$)/\1\4/en' . "\<CR>", 'silent')
  redir END
  let l:message = tlib#string#TrimLeft(l:message)

  if strlen(l:message) >=# 1
    call s:Preserve("normal! " . ':%s/\v((context|describe|its?).+),\s+:focus(\s+\=\>\s+true)?(.*$)/\1\4/' . "\<CR>", 'silent')
    echom l:message
  else
    echom "no matches"
  endif
endfunction

" Returns truth whether the line under the cursor can have focus. Also warns.
function! s:RspecToolsIsLineFocusable()
  let l:old_unnamed = @"
  try
    normal! ^y$
    if @" =~# '\v(context|describe|its?).*do\s*$'
      return 1
    else
      echohl WarningMsg
      echom "Line can't have rspec metadata"
      echohl None
      return 0
    endif

  finally
    let @" = l:old_unnamed
  endtry
endfunction

" Returns truth whether the line under the cursor can have focus
function! s:RspecToolsHasFocus()
  let l:old_unnamed = @"
  try
    normal! ^y$
    return @" =~# '\v(context|describe|its?).*:focus.*do\s*$'

  finally
    let @" = l:old_unnamed
  endtry
endfunction

" Run a command without changing the cursor location or last search register
"
" Can pass the string 'silent' which will run the command in silent mode.
function! s:Preserve(command, ...)
  " Preparation - save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")

  try
    if index(a:000, 'silent') ==# -1
      execute a:command
    else
      silent execute a:command
    endif

  finally
    let @/=_s
    call cursor(l, c)
  endtry
endfunction
" }}}

" plugin initialization -------------------- {{{
function! <SID>BufInit()
  " method motions stop on group and example defns like 'describe' and 'it'
  nnoremap <silent> <buffer> [m :<C-U>call <SID>searchsyn('\<\%(def\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','b','n')<CR>
  nnoremap <silent> <buffer> ]m :<C-U>call <SID>searchsyn('\<\%(def\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','','n')<CR>
  xnoremap <silent> <buffer> [m :<C-U>call <SID>searchsyn('\<\%(def\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','b','v')<CR>
  xnoremap <silent> <buffer> ]m :<C-U>call <SID>searchsyn('\<\%(def\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','b','v')<CR>

  nnoremap <silent> <buffer> [[ :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\<Bar>describe\<Bar>context\)\>','rubyModule\<Bar>rubyClass\<Bar>rubyRailsTestMethod','b','n')<CR>
  nnoremap <silent> <buffer> ]] :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\<Bar>describe\<Bar>context\)\>','rubyModule\<Bar>rubyClass\<Bar>rubyRailsTestMethod','','n')<CR>
  xnoremap <silent> <buffer> [[ :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\<Bar>describe\<Bar>context\)\>','rubyModule\<Bar>rubyClass\<Bar>rubyRailsTestMethod','b','v')<CR>
  xnoremap <silent> <buffer> ]] :<C-U>call <SID>searchsyn('\<\%(class\<Bar>module\<Bar>describe\<Bar>context\)\>','rubyModule\<Bar>rubyClass\<Bar>rubyRailsTestMethod','','v')<CR>

  nnoremap <silent> <buffer> <leader>rf :call RspecToolsFocusToggle()<CR>
  nnoremap <silent> <buffer> <leader>rc :call RspecToolsFocusClear()<CR>
endfunction

augroup RspecToolsPluginDetect
  autocmd BufNewFile,BufRead *_spec.rb call <SID>BufInit()
augroup END
" }}}
