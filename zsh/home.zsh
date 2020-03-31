# vim:ft=zsh

[[ $SSH_CLIENT =~ "192.168.1.102" ]] && TMUX="NO THANKS";

export SSH_ASKPASS="/usr/bin/ksshaskpass"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

load_conf main
load_conf zinit_optional
load_conf zinit_programs
