#! /bin/bash

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
 (tmux has-session -t "${HOME/*\//}" && tmux attach -t "${HOME/*\//}") \
   || tmux new-session -s "${HOME/*\//}"
 exit;
fi

zsh
exit
