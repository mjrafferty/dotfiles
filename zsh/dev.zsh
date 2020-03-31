#! /bin/zsh

[ -r "${HOME}/apollo-zsh-theme/apollo-zsh-theme.zsh" ] \
  && source "${HOME}/apollo-zsh-theme/apollo-zsh-theme.zsh"

load_conf completion
load_conf alias
load_conf functions

autoload -Uz compinit && compinit
