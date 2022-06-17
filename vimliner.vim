"
" Vimliner is the smallest outliner for vim. It uses vim's existing code 
" folding capabilities with some simple configuration. The result is a fast,
" powerful outliner using your favourite text editor.
"
" Install Vimliner by saving this file to $HOME/.vim/ftdetect/vimliner.vim
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

"autocmd FileType vimliner hi Folded ctermbg=black ctermfg=yellow
autocmd FileType vimliner nnoremap <TAB> za

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

