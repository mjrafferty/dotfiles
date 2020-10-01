# vim:ft=zsh

case "$HOST" in
  "Nexcess-AST-000304.local") TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
  "Home") TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
  "pi") TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
  "mellon"*) TMUX_CONF="${XDG_CONFIG_HOME}/tmux/login_server.conf" ;;
  *".nexcess.net") TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
  *"nxcli.net") TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
  "localhost") TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
  *) TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
esac

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
  (tmux has-session -t "${HOME/*\//}" &> /dev/null && tmux attach -t "${HOME/*\//}") \
    || tmux -f "${TMUX_CONF}" new-session -s "${HOME/*\//}"
      exit;
fi

alias tmux="tmux -f "${TMUX_CONF}""
