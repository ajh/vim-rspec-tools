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
function! RspecFocusAdd()
  if !RspecIsLineFocusable()
    return
  endif

  if s:RspecHasFocus()
    return
  endif

  execute "normal! $gEa, :focus => true\<ESC>"
endfunction

" Deletes a focus metadata flag to the rspec group or example.
"
" * Doesn't do anything if focus doesn't seem to be set
" * maybe errors if the line doesn't look right?
function! RspecFocusDel()
  if !RspecIsLineFocusable()
    return
  endif

  if !s:RspecHasFocus()
    return
  endif

  silent execute "normal! " . ':s/\v,\s+:focus(\s+\=\>\s+true)?//' . "\<CR>"
endfunction

" Toggles the focus metadata flag to the rspec group or example.
"
" * maybe errors if the line doesn't look right?
function! RspecFocusToggle()
  if !RspecIsLineFocusable()
    return
  endif

  if s:RspecHasFocus()
    call RspecFocusDel()
  else
    call RspecFocusAdd()
  endif
endfunction

" Deletes all focus metadata from the file, if any
function! RspecFocusClear()
  silent execute "normal! " . ':%s/\v((context|describe|its?).+),\s+:focus(\s+\=\>\s+true)?(.*$)/\1\4/' . "\<CR>"
endfunction

" Returns truth whether the line under the cursor can have focus. Also warns.
function! RspecIsLineFocusable()
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
function! s:RspecHasFocus()
  let l:old_unnamed = @"
  try
    normal! ^y$
    return @" =~# '\v(context|describe|its?).*:focus.*do\s*$'

  finally
    let @" = l:old_unnamed
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

  nnoremap <silent> <buffer> <leader>rf :call RspecFocusToggle()<CR>
  nnoremap <silent> <buffer> <leader>rc :call RspecFocusClear()<CR>
endfunction

augroup rspecPluginDetect
  autocmd BufNewFile,BufRead *_spec.rb call <SID>BufInit()
augroup END
" }}}
