# vim:ft=zsh

case "$HOST" in
  "mellon"*)                  TMUX_CONF="${XDG_CONFIG_HOME}/tmux/login_server.conf" ;;
  *".nexcess.net")            TMUX_CONF="${XDG_CONFIG_HOME}/tmux/nexcess.conf" ;;
  *"nxcli.net")               TMUX_CONF="${XDG_CONFIG_HOME}/tmux/nexcess.conf" ;;
  *".liquidweb.com")          TMUX_CONF="${XDG_CONFIG_HOME}/tmux/nexcess.conf" ;;
  *)                          TMUX_CONF="${XDG_CONFIG_HOME}/tmux/default.conf" ;;
esac

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
  (tmux -L "${HOME/*\//}" has-session -t "${HOME/*\//}" &> /dev/null && tmux -L "${HOME/*\//}" attach -t "${HOME/*\//}") \
    || tmux -L "${HOME/*\//}" -f "${TMUX_CONF}" new-session -s "${HOME/*\//}"
      exit;
fi

alias tmux="tmux -f "${TMUX_CONF}""
