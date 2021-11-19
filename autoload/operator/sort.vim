" operator-sort - Operator for sort
" Version: 0.0.0
" Copyright (C) 2011 emonkak <emonkak@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! operator#sort#sort(motion_wiseness)  "{{{2
  if a:motion_wiseness == 'char'
    let reg_0 = [@0, getregtype('0')]

    echo "Separator?"
    normal! `[v`]"0y
    let separator = escape(nr2char(getchar()), '\')
    let [xs, ys] = s:partition(@0, '\V\[\n ]\*' . separator . '\[\n ]\*')
    call sort(xs, 's:compare')

    let @0 = join(map(s:transpose([xs, ys]), 'join(v:val, "")'), '')
    normal! `[v`]"0P`[

    call setreg('0', reg_0[0], reg_0[1])
  else  " line or block
    exec "'[,']sort" s:sort_mode
  endif
endfunction




" Comparison  "{{{1
function! s:compare_modeless(x, y)  "{{{2
  if a:x == a:y
    return 0
  elseif a:x > a:y
    return 1
  end
  return -1
endfunction


function! s:compare(x, y)  "{{{2
  if a:x == '' || a:y == ''
    return 0
  elseif s:sort_mode == 'n'
    " Non numbers will return 0. Seems good enough.
    return s:compare_modeless(str2nr(a:x), str2nr(a:y))
  end
  return s:compare_modeless(a:x, a:y)
endfunction



" Misc.  "{{{1
function! operator#sort#set_mode(mode)  "{{{2
  let s:sort_mode = a:mode
endfunction



function! s:partition(expr, pattern)  "{{{2
  let xs = []
  let ys = []
  let p = 0
  let m = match(a:expr, a:pattern)

  while m > -1
    call add(xs, strpart(a:expr, p, m - p))
    let p = m
    let m = matchend(a:expr, a:pattern, p)
    call add(ys, strpart(a:expr, p, m - p))
    let p = m
    let m = match(a:expr, a:pattern, p)
  endwhile

  if p < len(a:expr)
    call add(xs, strpart(a:expr, p))
  endif

  return [xs, ys]
endfunction




function! s:transpose(xss)  "{{{2
  let _ = []

  for x in a:xss[0]
    call add(_, [x])
  endfor
  for xs in a:xss[1:]
    for i in range(min([len(_), len(xs)]))
      call add(_[i], xs[i])
    endfor
  endfor

  return _
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
