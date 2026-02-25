# vim:ft=zsh

[[ -r /etc/bashrc.nexcess ]] \
  && source /etc/bashrc.nexcess;

load_conf main

start_agent
source "${HOME}/.venv/bin/activate"
