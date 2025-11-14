"
" Vimliner is the smallest outliner for vim. It uses vim's existing code folding
" capabilities with some simple configuration. The result is a fast, powerful
" outliner using your favourite text editor.
"
" The outliner uses an indentation level of two white spaces to create new
" levels. You can use vim's default code folding shortcuts to move throughout
" your outline, or just use <TAB> to open and close levels.
"
" The most frequent shortcut keys you will use are:
"
" <TAB> open or close the current fold
"   zx  close all other folds
"   dd to delete a fold (when it is closed)
"   [p to paste at the current indent level (use with dd to move outlines)
"  C-k  move item up
"  C-j  move item down
"
" Use :help fold-commands in vim for additional shorcuts.
"
" The fold function consumes blank lines. If you need to separate one fold from
" another, use a string of space characters that match the current indent level.
"
" Installation:
"
" Copy this file to $HOME/.vim/ftdetect/ on unix, or $HOME/vimfiles/ftdetect/
" on Windows.
"
" Save your outliner files with a .out extension for Vimliner to be
" autodetected. Otherwise, use :set filetype=vimliner from within vim.
"
" Using Vimliner as a Productivity Tool:
"
" Since version 1.3, Vimliner includes the query functions below. The query
" results are displayed in a quickfix list in a separate tab, and you can easily
" jump to the matching lines by pressing `Enter`.
"
"  - `:Actions` show a list of all current actions
"  - `:Tomorrow` show a list of all tomorrow's actions
"  - `:SubActions` show a list of current actions under the fold at the cursor
"
" Actions are defined with a priority marker and two optional fields: frequency
" and date of next repetition. Priority is one of the following characters:
" `* + = - x` (where `*` is the highest priority). Additionally, a priority of
" `>` means **undecided**. The priority marker can appear in the indent margin
" to keep text aligned. The frequency is any text string and the date is
" `YYYYMMDD` or `YYYYMMDD_HHMM.  "
"
"     * stretch : every day : 20241120
"     * cook dinner : every day : 20241120_1900
"
" As you complete actions, you must update the repetition date by hand (`CTRL-A`
" helps) and rerun the `:Actions` query.
"
" Of course, you can use whatever tags and symbols you like for any purpose and
" query for those entries using `:Filter`.
"
" News And Updates:
"
" https://rogerkeays.com/vimliner
" https://github.com/rogerkeays/vimliner
" https://www.vim.org/scripts/script.php?script_id=5343
"
" Release Notes:
"
" 20241120_1.3 - added query functions and productivity features
" 20200430_1.2 - renamed to vimliner to avoid confusion with rival project
" 20200424_1.1 - allow lines containing only whitespace
" 20160305_1.0 - initial release
"
" License: https://opensource.org/licenses/Apache-2.0
" Author: Roger Keays
"
autocmd BufRead,BufNewFile *.out set filetype=vimliner
autocmd FileType vimliner set foldmethod=expr foldexpr=VimlinerFold(v:lnum)
autocmd FileType vimliner set foldtext=getline(v:foldstart).'\ ›' fillchars=fold:\ 
autocmd FileType vimliner set shiftwidth=2 expandtab autoindent
autocmd FileType vimliner set linebreak breakindent showbreak=\|\ 

autocmd FileType vimliner hi Folded ctermbg=NONE ctermfg=NONE
autocmd FileType vimliner hi QuickFixLine ctermbg=None
autocmd FileType vimliner nnoremap <TAB> za
autocmd FileType vimliner noremap <C-j> ddp
autocmd FileType vimliner noremap <C-k> ddkP

" open a new fold when the indent level increases
function! VimlinerFold(lnum)
    if getline(a:lnum)->len() == 0 | return "=" | endif
    let current = IndentLevel(a:lnum)
    let next = IndentLevel(a:lnum + 1)
    if next > current | return '>' . next | endif
    return current
endfunction

" allow priority markers in indent margin
function IndentLevel(lnum)
    let spaces = indent(a:lnum)
    if getline(a:lnum)[spaces:] =~ '^[-*+=x>] ' | let spaces += 2 | endif
    return spaces / &shiftwidth
endfunction

function FindNextActions(now, start_line=0)
  let actions = []
  let bufnr = bufnr()
  let last = line('$')
  let lnum = a:start_line
  let line = getline(lnum)
  let start_indent = IndentLevel(lnum)
  while lnum <= last

    " parse each line (action : freq : date_time)
    let splits = line->split(" : ")
    let action = "" | if splits->len() > 0 | let action = splits[0]->trim() | endif
    let freq = "" | if splits->len() > 1 | let freq = splits[1] | endif
    let date = "" | if splits->len() > 2 | let date = splits[2] | endif
    let time = "" | if date->len() > 8 | let time = date[9:] | endif
    if date->len() == 8 | let date = date."_0400" | endif

    " collect actions: start with a priority marker and date has been reached
    if (action->match('^[-*+=x>] ') > -1) && (date <= a:now) && (time <= a:now[9:])
      call add(actions, { 'bufnr': bufnr, 'lnum': lnum, 'text': action, 'nr': date[9:] })
    endif

    " break if end of fold reached
    let lnum += 1
    let line = getline(lnum)
    if a:start_line > 0 && line->len() > 0 && IndentLevel(lnum) <= start_indent
      break
    endif
  endwhile

  " format and sort results
  let dateline = [ { 'bufnr': bufnr, 'lnum': 1, 'text': a:now } ]
  let separator = [ { 'bufnr': bufnr, 'lnum': 1, 'text': '' } ]
  call sort(actions, { x, y -> GetPriority(y.text) - GetPriority(x.text) })
  call setqflist(separator + dateline + separator + actions, 'r')

  " display quickfix list
  vert copen
  set switchbuf+=usetab nowrap conceallevel=2 concealcursor=nc
  syn match metadata /^.*|[-0-9 col error]\+|/ transparent conceal
  normal =
endfunction
autocmd FileType vimliner command! Actions call FindNextActions(strftime("%Y%m%d_%H%M", localtime()))
autocmd FileType vimliner command! Tomorrow call FindNextActions(strftime("%Y%m%d_2359", localtime() + 20*60*60)) " rollover a 4am
autocmd FileType vimliner command! SubActions call FindNextActions(strftime("%Y%m%d_%H%M", localtime()), line(".") + 1)

function GetPriority(action)
  if a:action[0] == '*' | return 5
  elseif a:action[0] == '+' | return 4
  elseif a:action[0] == '=' | return 3
  elseif a:action[0] == '-' | return 2
  elseif a:action[0] == 'x' | return 1
  else | return 0 | endif
endfunction

