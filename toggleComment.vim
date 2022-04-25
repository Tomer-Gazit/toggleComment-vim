let s:comment_symbol = {
      \ 'python'         : '#',
      \ 'vim'            : '"',
      \ 'c'              : '//',
      \ 'javascript'     : '//'
      \ }
function! ToggleComment_GetCommentSymbol()
  " Check filetype
  let cft = &ft
  if cft ==? '' && exists("b:current_syntax")
    let cft = b:current_syntax
  endif
  if cft ==? ''
    return '-1'
  endif
" Find a value for the CommentSymbol
  let cmsy = get(s:comment_symbol,cft)
  return cmsy
endfunction

function! ToggleComment(mode, inline_mode)
  let save_cursor = getcurpos()
  let line_len = len(getline("."))
  call cursor('.',1)
  let cmsy = ToggleComment_GetCommentSymbol()
  let cmsy_space = cmsy . "\<Space>"
  let cmsy_tab = cmsy . "\<Tab>"
  let cmsy = [cmsy_space, cmsy_tab]
  let cmsy_wsd = '\(' . cmsy[0] . '\|' . cmsy[1] . '\)'
  if cmsy_wsd =~# '#\s*'
    let dlm = '/'
  else
    let dlm = '#'
  endif

  if a:inline_mode == 0
    let search_cmsy = search('^\s*' . cmsy_wsd, 'c', line('.'))
    if search_cmsy != 0
      let rem_cmsy_bol = '\(^\s*'
      let rem_cmsy_subs = '\)' . dlm . dlm . ' | noh'
      let rem_cmsy = 's' . dlm . rem_cmsy_bol . cmsy_wsd . rem_cmsy_subs
      let do_sub = rem_cmsy
    else
      let search_cmsy = search('\s\+' . cmsy_wsd, 'c', line('.'))
      if search_cmsy != 0
        let rem_cmsy_bol = '\(\s\+'
        let rem_cmsy_subs = '\)' . dlm . "\<Space>" . dlm . ' | noh'
        let rem_cmsy = 's'.dlm . rem_cmsy_bol . cmsy_wsd . '\s*'.rem_cmsy_subs
        let do_sub = rem_cmsy
      else
        let do_sub = 's/\(^\)/\=cmsy[0]/|:noh'
      endif
    endif

  else
    let search_cmsy = search('\s\+' . cmsy_wsd . '.*$', 'c', line('.'))
    if search_cmsy != 0
      if getline('.') =~# '^\s\+' . cmsy_wsd . '.*$'
        let do_sub = 's'.dlm .'\s\+'. cmsy_wsd . '\(.*\)$'.dlm.'\2'.dlm.'|noh'
      elseif getline('.') =~# '\s\+' . cmsy_wsd . '.*$'
        let do_sub = 's'.dlm . '\s\+' . cmsy_wsd . '\(.*\)$' . dlm.dlm.'|noh'
      endif
    else
      let do_sub = 's' . dlm . '$' . dlm . "\<Tab>" . cmsy[0] . dlm . '| noh'
    endif
  endif

  execute do_sub

  let cursor_shift = (len(getline(".")) - line_len)
  let cursor_col_new = (save_cursor[2] + cursor_shift)
  call cursor(line('.'), cursor_col_new)

  if a:inline_mode == 0
    if getline(".") =~# '^\s*' . cmsy[0] . '\s*$'
      if a:mode ==? 'n'
        startinsert!
      endif
    endif
  else
    if getline(".") =~# "\<Tab>" . cmsy[0] . '$'
      startinsert!
    else
      call cursor(line('.'), save_cursor[2])
    endif
  endif

endfunction
