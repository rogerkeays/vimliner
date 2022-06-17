# Vimliner: The Simplest Outliner for VIM

Vimliner is the simplest outliner for vim. It uses vim's existing code 
folding capabilities with some simple configuration. The result is a fast,
powerful outliner using your favourite text editor.

Install vimliner by saving `vimliner.vim` to `$HOME/.vim/ftdetect/vimliner.vim`
on unix, or `$HOME/vimfiles/ftdetect/vimliner.vim` on Windows.

Save your outliner files with a `.out` extension for vimliner to be 
autodetected. Otherwise, use `:set filetype=vimliner` from within vim.

![Vimliner screenshot](https://rogerkeays.com/ox/webcore/attachments/27730/vimliner-the-simplest-outliner-for-vim-screenshot.png?width=600&height=350)

The outliner uses an indentation level of 2 white spaces to create 
new levels. You can use vim's default code folding shortcuts to move
throughout your outline, or just use TAB to open and close levels.
 
The most frequent shortcut keys you will use are:

    TAB open or close the current fold
    zx close all other folds  
    dd to delete a fold (when it is closed)
    [p to paste at the current indent level (use with dd to move outlines)

Use `:help fold-commands` in vim for additional shorcuts.

The fold function consumes blank lines. If you need to separate one
fold from another, use a string of space characters that match the
current indent level.

News And Updates:

 - https://rogerkeays.com/vimliner
 - https://www.vim.org/scripts/script.php?script_id=5343

Release Notes:

 - 20200430_1.2 - renamed to vimliner to avoid confusion with rival project
 - 20200424_1.1 - allow lines containing only whitespace
 - 20160305_1.0 - initial release

License: https://opensource.org/licenses/Apache-2.0

