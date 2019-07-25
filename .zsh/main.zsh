#! /bin/zsh

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
  (tmux has-session -t "${HOME/*\//}" &> /dev/null && tmux attach -t "${HOME/*\//}") \
    || tmux new-session -s "${HOME/*\//}"
  exit;
fi

[ -r "${HOME}/.zsh/env.zsh" ] \
  && source "${HOME}/.zsh/env.zsh"

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

#[ -r "${HOME}/.zsh/zsh-histdb/sqlite-history.zsh" ] \
  #&& source "$HOME/.zsh/zsh-histdb/sqlite-history.zsh"

[ -r "${HOME}/.zsh/apollo-zsh-theme/prompt_apollo_setup" ] \
  && source "$HOME/.zsh/apollo-zsh-theme/prompt_apollo_setup"

[ -r "${HOME}/.zsh/zsh-completionsu[]/zsh-completions.plugin.zsh" ] \
  && source "$HOME/.zsh/zsh-completions/zsh-completions.plugin.zsh"

#[ -r "${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
  #&& source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

if [ -r "${HOME}/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh" ]; then

  source "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"

  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down

fi

[ -r "${HOME}/.zsh/completion.zsh" ] \
  && source "$HOME/.zsh/completion.zsh"

if [ -r "${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then

  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets line)
  ZSH_HIGHLIGHT_STYLES[line]='bold'

fi

[ -r "${HOME}/.zsh/alias.zsh" ] \
  && source "${HOME}/.zsh/alias.zsh"

[ -r "${HOME}/.zsh/functions.zsh" ] \
  && source "${HOME}/.zsh/functions.zsh"

fpath=($HOME/.zsh/completions $fpath)

setopt nullglob

## Vi key bindings
bindkey -v
