# vim:ft=zsh

## cd options ##
setopt autocd
setopt auto_pushd
setopt cdable_vars
setopt chase_dots

## Globbing Options
setopt extended_glob
setopt nonomatch   # added in place of null_glob. Silences the "no files matched" error without causing the argument to be removed from command
setopt multibyte
setopt numeric_glob_sort

## History Options ##
setopt append_history
setopt extended_history
setopt hist_fcntl_lock
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt hist_verify
setopt inc_append_history

## Input/Output Options ##
setopt clobber
setopt correct
setopt correct_all
unsetopt flow_control      # disable start/stop characters in shell editor.
setopt hash_cmds
setopt hash_dirs
setopt path_dirs           # perform path search even on command names with slashes.
setopt short_loops

## ZLE Options ##
unsetopt beep
