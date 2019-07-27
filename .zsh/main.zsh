#! /bin/zsh

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
  (tmux has-session -t "${HOME/*\//}" &> /dev/null && tmux attach -t "${HOME/*\//}") \
    || tmux new-session -s "${HOME/*\//}"
  exit;
fi

[ -r "${HOME}/.zsh/plugins_core.zsh" ] \
  && source "${HOME}/.zsh/plugins_core.zsh"

[ -r "${HOME}/.zsh/env.zsh" ] \
  && source "${HOME}/.zsh/env.zsh"

[ -r "${HOME}/.zsh/completion.zsh" ] \
  && source "$HOME/.zsh/completion.zsh"

[ -r "${HOME}/.zsh/alias.zsh" ] \
  && source "${HOME}/.zsh/alias.zsh"

[ -r "${HOME}/.zsh/functions.zsh" ] \
  && source "${HOME}/.zsh/functions.zsh"

## cd options ##
setopt autocd
setopt auto_pushd
setopt cdable_vars
setopt chase_dots
setopt chase_links

setopt extendedglob
setopt nomatch

setopt appendhistory
setopt hist_ignore_dups
setopt hist_fcntl_lock
setopt hist_verify
unsetopt beep

#fpath=($HOME/.zsh/completions $fpath)

setopt nullglob

## Vi key bindings
bindkey -v
export KEYTIMEOUT=1
