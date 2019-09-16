#! /bin/zsh

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
  (tmux has-session -t "${HOME/*\//}" &> /dev/null && tmux attach -t "${HOME/*\//}") \
    || tmux new-session -s "${HOME/*\//}"
      exit;
fi

## Vi key bindings
bindkey -v
export KEYTIMEOUT=1

fpath=($HOME/.zsh/completions $fpath)

autoload -Uz is-at-least
if is-at-least 5.1; then

  [ -r "${HOME}/.zsh/plugins_core.zsh" ] \
    && source "${HOME}/.zsh/plugins_core.zsh"

else

  [ -r "${HOME}/.zsh/zplugin/plugins/mjrafferty---apollo-zsh-theme/apollo-zsh-theme.zsh" ] \
    && source "${HOME}/.zsh/zplugin/plugins/mjrafferty---apollo-zsh-theme/apollo-zsh-theme.zsh"

  [ -r "${HOME}/.zsh/zplugin/plugins/trapd00r---LS_COLORS/c.zsh" ] \
    && source "${HOME}/.zsh/zplugin/plugins/trapd00r---LS_COLORS/c.zsh"

  [ -r "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-completions/zsh-completions.plugin.zsh" ] \
    && source "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-completions/zsh-completions.plugin.zsh"

  [ -r "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && source "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh"

  ZSH_AUTOSUGGEST_MANUAL_REBIND="true"
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  ZSH_AUTOSUGGEST_USE_ASYNC="true"
  ZSH_AUTOSUGGEST_STRATEGY=(history match_prev_cmd )

  [ -r "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-history-substring-search/zsh-history-substring-search.plugin.zsh" ] \
    && source "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-history-substring-search/zsh-history-substring-search.zsh"

  bindkey "^[[A" history-substring-search-up
  bindkey "^[[B" history-substring-search-down

  [ -r "${HOME}/.zsh/zplugin/plugins/zdharma---fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] \
    && source "${HOME}/.zsh/zplugin/plugins/zdharma---fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

  autoload -Uz compinit && compinit -C -i

fi

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

## Globbing Options
setopt extended_glob
setopt null_glob
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
