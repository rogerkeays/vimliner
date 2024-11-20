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

## Using Vimliner as a Productivity Tool

Since version 1.3, Vimliner includes the additional query functions below. The
query results are displayed in a quickfix list in a separate tab, and you can
easily jump to the matching lines by pressing `Enter`.

 - `:Filter regexp` displays lines matching `regexp` from the current file
 - `:Find regexp` displays lines matching `regexp` from all `.log` files in
                    the current directory
 - `:Actions` show today's list of deadlines, habits and goals
 - `:Tomorrow` show tomorrow's list of deadlines, habits and goals

Deadlines are defined by adding a date preceded by an exclamation mark. The
date format should be `YYYYMMDD`. A semicolon is required with spacing to
separate the fields. E.g.

    release vimliner 1.3 : !20241120

Habits are defined with three extra fields: frequency, date of next repetition,
and duration. The frequency is any text string; date is as above; and the
duration is a number in minutes. E.g.

    cook real food : every day : 20241120 : 45

Habits are sorted longest first. As you complete them, you must update the
repetition date by hand (`CTRL-A` helps) and rerun the `:Actions` query.

Goals include a countdown field which is either the number of remaining
tasks, or an `>` arrow, which means *in progress*. E.g.

    watch the cities of gold : 19
    conquer the world : >

Of course, you can use whatever tags and symbols you like for any purpose and
query for those entries using `:Filter` and `:Find`.

## News And Updates

 - https://rogerkeays.com/vimliner
 - https://www.vim.org/scripts/script.php?script_id=5343

## Release Notes

 - 20241120_1.3 - added query functions and productivity features
 - 20200430_1.2 - renamed to vimliner to avoid confusion with rival project
 - 20200424_1.1 - allow lines containing only whitespace
 - 20160305_1.0 - initial release

## License

 - https://opensource.org/licenses/Apache-2.0

## Related Resources

  * [Vimcash](https://github.com/rogerkeays/vimcash): an accounting system based on *Vimjournal*.
  * [Vimjournal](https://github.com/rogerkeays/vimjournal): a simple text format for organising large amounts of information.
  * [More stuff you never knew you wanted](https://rogerkeays.com).

