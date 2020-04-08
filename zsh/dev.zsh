#! /bin/zsh

[ -r "${HOME}/apollo-zsh-theme/apollo-zsh-theme.zsh" ] \
  && source "${HOME}/apollo-zsh-theme/apollo-zsh-theme.zsh"

[ -r "${HOME}/zhist/zhist.zsh" ] \
  && source "${HOME}/zhist/zhist.zsh"

load_conf completion
load_conf alias
load_conf functions
load_conf apollo

autoload -Uz compinit && compinit
