if exists('g:loaded_rspec_tools')
  finish
endif
let g:loaded_rspec_tools = 1

" Ripped from vim-ruby. I wish these weren't script scoped  -------------------- {{{
function! <SID>:searchsyn(pattern,syn,flags,mode)
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
    while pos != 0 && <SID>:synname() !~# a:syn
      let pos = search(a:pattern,'W'.a:flags)
    endwhile
    if pos == 0
      call cursor(line,col)
      return
    endif
  endwhile
endfunction

function! <SID>:synname()
  return synIDattr(synID(line('.'),col('.'),0),'name')
endfunction
" }}}

" This kinda works! But it shouldn't add focus if its already there.
"function! Rspec:focus()
  "call <SID>:searchsyn('\<context\|describe\|it\|its\>', 'rubyRailsTestMethod', 'b', 'n')
  "execute "normal! $gEa, :focus => true\<ESC>"
"endfunction

" focus metadata functions -------------------- {{{
" Adds a focus metadata flag to the rspec group or example.
"
" * Doesn't add focus if its already set
" * errors if the line doesn't look like it starts a group or example
"   definition
function! Rspec:AddFocus()
endfunction

" Deletes a focus metadata flag to the rspec group or example.
"
" * Doesn't do anything if focus doesn't seem to be set
" * maybe errors if the line doesn't look right?
function! Rspec:DelFocus()
endfunction

" Toggles the focus metadata flag to the rspec group or example.
"
" * maybe errors if the line doesn't look right?
function! Rspec:ToggleFocus()
endfunction

" }}}

function! <SID>:BufInit()
  " method motions stop on group and example defns like 'describe' and 'it'
  nnoremap <silent> <buffer> [m :<C-U>call <SID>:searchsyn('\<\%(context\<Bar>def\<Bar>describe\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','b','n')<CR>
  nnoremap <silent> <buffer> ]m :<C-U>call <SID>:searchsyn('\<\%(context\<Bar>def\<Bar>describe\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','','n')<CR>
  xnoremap <silent> <buffer> [m :<C-U>call <SID>:searchsyn('\<\%(context\<Bar>def\<Bar>describe\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','b','v')<CR>
  xnoremap <silent> <buffer> ]m :<C-U>call <SID>:searchsyn('\<\%(context\<Bar>def\<Bar>describe\<Bar>it\<Bar>its\)\>', 'rubyDefine\<Bar>rubyRailsTestMethod','b','v')<CR>
endfunction

augroup rspecPluginDetect
  autocmd BufNewFile,BufRead *_spec.rb call <SID>:BufInit()
augroup END
