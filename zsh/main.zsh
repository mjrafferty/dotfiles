# vim:ft=zsh

load_conf tmux
load_conf zcomp
load_conf bindings

autoload -Uz is-at-least \
  && is-at-least 5.1 \
  && load_conf zinit_core \
  || load_conf no_zinit

load_conf completion
load_conf alias
load_conf functions
load_conf options
