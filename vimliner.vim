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
"  - `:Actions` show current list of actions
"  - `:Tomorrow` show tomorrow's list of actions
"  - `:Filter regexp` displays lines matching `regexp` from the current file
"
" Actions are defined with a priority marker and two optional fields: frequency
" and date of next repetition. Priority is one of the following characters:
" `* + = - x` (where `*` is the highest priority). Additionally, a priority of
" `>` means **undecided**. The frequency is any text string and the date is
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
autocmd FileType vimliner nnoremap <TAB> za
autocmd FileType vimliner noremap <C-j> ddp
autocmd FileType vimliner noremap <C-k> ddkP

function! VimlinerFold(lnum)
    if getline(a:lnum) =~? '^$'
        return VimlinerFold(a:lnum - 1)
    endif

    let this_indent = indent(a:lnum) / &shiftwidth
    let next_indent = indent(a:lnum + 1) / &shiftwidth

    if next_indent == this_indent
        return this_indent
    elseif next_indent < this_indent
        return this_indent
    elseif next_indent > this_indent
        return '>' . next_indent
    endif
endfunction

function FindNextActions(now)
  let lnum = 0
  let bufnr = bufnr()
  let actions = []

  for line in getline(1, '$')
    let lnum += 1

    " parse each line (action : freq : date)
    let splits = line->split(" : ")
    let action = "" | if splits->len() > 0 | let action = splits[0]->trim() | endif
    let freq = "" | if splits->len() > 1 | let freq = splits[1] | endif
    let date = "" | if splits->len() > 2 | let date = splits[2] | endif

    " collect actions: start with a priority marker and date has been reached
    if action->match('^[-*+=x>] ') > -1 && (date == "" || date <= a:now)
      call add(actions, { 'bufnr': bufnr, 'lnum': lnum, 'text': action, 'date': date, 'nr': date[9:] })
    endif
  endfor

  " arrange and display as a quicklist
  let dateline = [ { 'bufnr': bufnr, 'lnum': 1, 'text': a:now } ]
  let separator = [ { 'bufnr': bufnr, 'lnum': 1, 'text': '' } ]
  call sort(actions, { x, y -> CompareActions(x, y) })
  call setqflist(separator + dateline + separator + actions, 'r')
  call DisplayQuickfixWindow()
endfunction
autocmd FileType vimliner command! Actions call FindNextActions(strftime("%Y%m%d_%H%M", localtime()))
autocmd FileType vimliner command! Tomorrow call FindNextActions(strftime("%Y%m%d_2359", localtime() + 24*60*60))

" sort actions by priority, then start time
function CompareActions(x, y)
  let result = GetPriority(a:y.text) - GetPriority(a:x.text)
  if result == 0
    let xstart = a:x.date[9:]
    let ystart = a:y.date[9:]
    let result = xstart == ystart ? 0 : xstart > ystart ? 1 : -1
  endif
  return result
endfunction

function GetPriority(action)
  if a:action[0] == '*' | return 5
  elseif a:action[0] == '+' | return 4
  elseif a:action[0] == '=' | return 3
  elseif a:action[0] == '-' | return 2
  elseif a:action[0] == 'x' | return 1
  else | return 0 | endif
endfunction

function MakeActionCards(dir)
  let actions = getqflist()
  let i = 1
  for line in actions[3:]
    let basename = printf("%04d", i)

    " add the start time (stored in nr field) to the card name if declared
    if line.nr > 0 | let basename = basename."_".line.nr | endif
    call writefile([ line.text ], a:dir."/".basename.".txt")
    let i = i + 1
  endfor
endfunction
autocmd FileType vimliner command! -nargs=1 MakeActionCards call MakeActionCards(<f-args>)

" filter the current file using a regexp and display the results in a separate tab
" if no regexp is supplied, the last search pattern is used
function GrepOutlines(regexp, files)
  execute 'vimgrep /'.a:regexp.'/j '.a:files
  call DisplayQuickfixWindow()
endfunction
autocmd FileType vimliner command! -nargs=? Filter call GrepOutlines(<f-args>, '%')

" opens the quickfix list in a tab with no formatting
function DisplayQuickfixWindow()
  vert copen
  set switchbuf+=usetab nowrap conceallevel=2 concealcursor=nc
  syn match metadata /^.*|[-0-9 col error]\+|/ transparent conceal
  normal =
endfunction
autocmd FileType vimliner hi QuickFixLine ctermbg=None

