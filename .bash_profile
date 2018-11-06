#! /bin/bash

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
  (tmux has-session -t "${HOME/*\//}" &> /dev/null && tmux attach -t "${HOME/*\//}") \
    || tmux new-session -s "${HOME/*\//}"
else
  zsh;
fi

# Cleanup home folder on logout
/usr/bin/sudo find "$HOME"/ -mindepth 1 \( \
  -path "*/.bash_profile" -o \
  -path "*/bin" -o \
  -path "*/clients" -o \
  -path "*/.commonrc" -o \
  -path "*/.completions" -o \
  -path "*/.functions.sh" -o \
  -path "*/.mytop" -o \
  -path "*/*history" -o \
  -path "*/.zsh-history.db" -o \
  -path "*/*SNAPS*" -o \
  -path "*/.ssh" -o \
  -path "*/.zlogin*" -o \
  -path "*/.zpr*" -o \
  -path "*/.vim*" -o \
  -path "*/.zshrc" \) -prune -o -exec rm -rf {} + 2> /dev/null;

exit;
