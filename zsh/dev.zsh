#! /bin/zsh

[ -r "${HOME}/Repositories/mjrafferty/apollo-zsh-theme/apollo-zsh-theme.zsh" ] \
  && source "${HOME}/Repositories/mjrafferty/apollo-zsh-theme/apollo-zsh-theme.zsh"

[ -r "${HOME}/Repositories/mjrafferty/zhist/zhist.zsh" ] \
  && source "${HOME}/Repositories/mjrafferty/zhist/zhist.zsh"

[ -r "${HOME}/Repositories/mjrafferty/ztouch/ztouch.zsh" ] \
  && source "${HOME}/Repositories/mjrafferty/ztouch/ztouch.zsh"

load_conf completion
load_conf alias
load_conf functions
load_conf apollo

HISTFILE="${XDG_DATA_HOME}/zsh_history"

autoload -Uz compinit && compinit -C -i -d ${ZSH_COMPDUMP}
