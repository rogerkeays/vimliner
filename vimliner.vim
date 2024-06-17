"
" Vimliner is the smallest outliner for vim. It uses vim's existing code 
" folding capabilities with some simple configuration. The result is a fast,
" powerful outliner using your favourite text editor.
"
" Install vimliner by saving this file to $HOME/.vim/ftdetect/vimliner.vim
" on unix, or $HOME/vimfiles/ftdetect/vimliner.vim on Windows.
"
" Save your outliner files with a .out extension for Vimliner to be 
" autodetected. Otherwise, use :set filetype=vimliner from within vim.
"
" The outliner uses an indentation level of 2 white spaces to create 
" new levels. You can use vim's default code folding shortcuts to move
" throughout your outline, or just use <TAB> to open and close levels.
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
" The fold function consumes blank lines. If you need to separate one
" fold from another, use a string of space characters that match the
" current indent level.
"
" News And Updates:
"
" https://rogerkeays.com/vimliner
" https://www.vim.org/scripts/script.php?script_id=5343
"
" Release Notes:
"
" 20200430_1.2 - renamed to vimliner to avoid confusion with rival project
" 20200424_1.1 - allow lines containing only whitespace
" 20160305_1.0 - initial release
"
" License: https://opensource.org/licenses/Apache-2.0
" Author: Roger Keays
"
autocmd BufRead,BufNewFile *.out set filetype=vimliner
autocmd FileType vimliner set foldmethod=expr foldexpr=VimlinerFold(v:lnum)
autocmd FileType vimliner set foldtext=getline(v:foldstart).'\ ›' fillchars= 
autocmd FileType vimliner set shiftwidth=2 expandtab autoindent
autocmd FileType vimliner set linebreak breakindent showbreak=--------------\ 

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

" opens the quickfix list in a tab with no formatting
function DisplayQuickfixTab()
  if !exists("g:vimliner_copened")
    $tab copen
    set switchbuf+=usetab nowrap conceallevel=2 concealcursor=nc
    let g:vimliner_copened = 1

    " switchbuf=newtab is ignored when there are no splits, so we use :tab explicitely
    " https://vi.stackexchange.com/questions/6996
    nnoremap <buffer> <Enter> :-tab .cc<CR>zx
  else
    $tabnext
    normal 1G
  endif

  " hide the quickfix metadata
  syn match metadata /^.*|[0-9 col]\+| / transparent conceal
endfunction
autocmd FileType vimjournal hi QuickFixLine ctermbg=None

" filter the current file using a regexp and display the results in a separate tab
" if no regexp is supplied, the last search pattern is used
function GrepOutlines(regexp, files)
  execute 'vimgrep /'.a:regexp.'/j '.a:files
  call DisplayQuickfixTab()
endfunction
autocmd FileType vimliner command! -nargs=? Filter call GrepOutlines(<f-args>, '%')
autocmd FileType vimliner command! -nargs=? Find call GrepOutlines(<f-args>, '*.out')

" build a list of next actions by collecting scheduled actions and the first 
" unscheduled action of each fold
function FindNextActions()
  let scheduled = []
  let unscheduled = []
  let lnum = 0
  let bufnr = bufnr()
  let lastIndent = 0
  let today = strftime("%Y%m%d", localtime() - 60*60*4) " roll dates at 4am, not midnight

  for line in getline(1, '$')
    let lnum += 1

    " parse each line
    let indent = indent(lnum)
    let splits = line -> split(" : ")
    let action = "" | if splits -> len() > 0 | let action = splits[0] -> trim() | endif
    let date = "" | if splits -> len() > 1 | let date = splits[1] | endif
    let duration = "" | if splits -> len() > 2 | let duration = splits[2] -> str2nr() | endif
    let repeat = "" | if splits -> len() > 3 | let repeat = splits[3] | endif

    " collect scheduled actions and the first unscheduled action in each fold
    if date != "" && date <= today
      let text = printf("%s %03d %s", date, duration, action)
      call add(scheduled, { 'bufnr': bufnr, 'lnum': lnum, 'text': text, 'duration': duration })
    elseif date == "" && match(line, '^\s*>') > -1 && indent > lastIndent
      call add(unscheduled, { 'bufnr': bufnr, 'lnum': lnum, 'text': action })
    endif
    if line != "" && date == ""
      let lastIndent = indent
    endif
  endfor

  " arrange and display as a quicklist
  let separator = [ { 'bufnr': bufnr, 'lnum': 1, 'text':'------------' } ]
  call sort(scheduled, { x, y -> x.duration == y.duration ? 0 : x.duration > y.duration ? -1 : 1 })
  call setqflist(separator + scheduled + separator + unscheduled, 'r')
  call DisplayQuickfixTab()
endfunction
autocmd FileType vimliner command! Actions call FindNextActions()

