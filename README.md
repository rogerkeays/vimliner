# VimFlowy: The Simplest Outliner for VIM

VimFlowy is the simplest outliner for vim. It uses vim's existing code 
folding capabilities with some simple configuration. The result is a fast,
powerful outliner using your favourite text editor.

Install VimFlowy by saving this file to $HOME/.vim/ftdetect/vimflowy.vim
on unix, or $HOME/vimfiles/ftdetect/vimflowy.vim on Windows.

Save your outliner files with a .out extension for VimFlowy to be 
autodetected. Otherwise, use :set filetype=vimflowy from within vim.

The outliner uses an indentation level of 2 white spaces to create 
new levels. You can use vim's default code folding shortcuts to move
throughout your outline, or just use <TAB> to open and close levels.
 
The most frequent shortcut keys you will use are:

    TAB open or close the current fold
    zx close all other folds  

Use :help fold-commands in vim for additional shorcuts.

The fold function consumes blank lines. If you need to separate one
fold from another, use a single dot or a dash on a line by itself.

For updates and screenshots, go to https://rogerkeays.com/vimflowy

