"
" VimFlowy is the simplest outliner for vim. It uses vim's existing code 
" folding capabilities with some simple configuration. The result is a fast,
" powerful outliner using your favourite text editor.
"
" Install VimFlowy by saving this file to $HOME/.vim/ftdetect/vimflowy.vim
" on unix, or $HOME/vimfiles/ftdetect/vimflowy.vim on Windows.
"
" Save your outliner files with a .out extension for VimFlowy to be 
" autodetected. Otherwise, use :set filetype=vimflowy from within vim.
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
" fold from another, use a single dot or a dash on a line by itself.
"
" Check for updates to VimFlowy at https://rogerkeays.com/vimflowy
"
autocmd BufRead,BufNewFile *.out set filetype=vimflowy
autocmd FileType vimflowy set foldmethod=expr foldexpr=VimFlowyFold(v:lnum)
autocmd FileType vimflowy set foldtext=getline(v:foldstart)
autocmd FileType vimflowy set shiftwidth=2 expandtab autoindent
autocmd FileType vimflowy hi Folded ctermbg=black ctermfg=yellow
autocmd FileType vimflowy nnoremap <TAB> za

function! VimFlowyFold(lnum)
    if getline(a:lnum) =~? '\v^\s*$'
        return VimFlowyFold(a:lnum - 1)
    endif

    let this_indent = indent(a:lnum) / &shiftwidth
    let next_indent = indent(NextNonBlankLine(a:lnum)) / &shiftwidth

    if next_indent == this_indent
        return this_indent
    elseif next_indent < this_indent
        return this_indent
    elseif next_indent > this_indent
        return '>' . next_indent
    endif
endfunction

function! NextNonBlankLine(lnum)
    let numlines = line('$')
    let current = a:lnum + 1

    while current <= numlines
        if getline(current) =~? '\v\S'
            return current
        endif

        let current += 1
    endwhile

    return -2
endfunction
