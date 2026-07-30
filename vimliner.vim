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
" The Action list is sorted by priority and duration (longest first).
"
" Actions are defined with additional metadata separated by a colon. The format
" is `priority.[duration].[date]`, where priority is a number from 1-5 (the
" highest priority being 1), the duration is a time in minutes, and the date is
" `YYYYMMDD` or `YYYYMMDD_HHMM`. E.g.
"
"     release vimliner : 2
"     release vimliner : 2.120
"     release vimliner : 2.120.20260723
"
" Repeating actions can a frequency as a separate field before the priority. This
" field is not read by vimliner, but it is useful for planning.
"
"     stretch : every day : 1.15.20241120
"     cook a hot meal : every day : 1.45.20241120_1900
"
" As you complete actions, you must update the next repetition date by hand
" (`CTRL-A` helps) and rerun the `:Actions` query.
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
autocmd FileType vimliner noremap <C-a> $<C-a>
autocmd FileType vimliner noremap <C-x> $<C-x>

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
    return indent(a:lnum) / &shiftwidth
endfunction

function FindNextActions(now, start_line=0)
  let actions = []
  let bufnr = bufnr()
  let last = line('$')
  let lnum = a:start_line
  let line = getline(lnum)
  let start_indent = IndentLevel(lnum)
  while lnum <= last

    " parse each line
    if line->stridx(" : ") > 0
      let fields = line->split(" : ")
      let action = fields[0]->trim()
      let metadata = fields[-1]->split("\\.")
      let priority = metadata[0]
      let duration = metadata->len() > 1 ? printf("%03d", metadata[1]) : "000"
      let date = metadata->len() > 2 ? metadata[2] : ""
      let datetime = date->len() == 8 ? date."_0400" : date

      " collect deadlines and actions: start with a priority marker and date has been reached
      if priority != "" && datetime <= a:now
        call add(actions, { 'bufnr': bufnr, 'lnum': lnum, 'text': "[".priority." ".duration."] ".action })
      endif
    endif

    " break if end of fold reached
    let lnum += 1
    let line = getline(lnum)
    if a:start_line > 0 && line->len() > 0 && IndentLevel(lnum) <= start_indent
      break
    endif
  endwhile

  " format and sort results
  let heading = [ { 'bufnr': bufnr, 'lnum': 1, 'text': 'Actions' } ]
  let sep = [ { 'bufnr': bufnr, 'lnum': 1, 'text': '' } ]
  call sort(actions, { x, y -> y.text[1] == x.text[1] ? y.text[3:5] > x.text[3:5] : y.text[1] < x.text[1] })
  call setqflist(sep + heading + sep + actions + sep, 'r')

  " display quickfix list
  vert copen
  set switchbuf+=usetab nowrap conceallevel=2 concealcursor=nc
  syn match metadata /^.*|[-0-9 col error]\+|/ transparent conceal
  normal =7<
endfunction
autocmd FileType vimliner command! Actions call FindNextActions(strftime("%Y%m%d_%H%M", localtime()))
autocmd FileType vimliner command! Tomorrow call FindNextActions(strftime("%Y%m%d_2359", localtime() + 20*60*60)) " rollover a 4am
autocmd FileType vimliner command! SubActions call FindNextActions(strftime("%Y%m%d_%H%M", localtime()), line("."))

function GetPriority(action)
  if a:action[1] == '*' | return 5
  elseif a:action[1] == '+' | return 4
  elseif a:action[1] == '=' | return 3
  elseif a:action[1] == '-' | return 2
  elseif a:action[1] == 'x' | return 1
  else | return 0 | endif
endfunction
