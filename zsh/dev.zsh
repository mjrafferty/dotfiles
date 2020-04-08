#! /bin/zsh

[ -r "${HOME}/apollo-zsh-theme/apollo-zsh-theme.zsh" ] \
  && source "${HOME}/apollo-zsh-theme/apollo-zsh-theme.zsh"

[ -r "${HOME}/zhist/zhist.zsh" ] \
  && source "${HOME}/zhist/zhist.zsh"

load_conf completion
load_conf alias
load_conf functions
load_conf apollo

HISTFILE="${XDG_DATA_HOME}/zsh_history"

autoload -Uz compinit && compinit -C -i -d ${ZSH_COMPDUMP}
