#! /bin/bash

zsh

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
  -path "*/.zsh-history.log" -o \
  -path "*/*SNAPS*" -o \
  -path "*/.ssh" -o \
  -path "*/.zlogin*" -o \
  -path "*/.zpr*" -o \
  -path "*/.vim*" -o \
  -path "*/.zshrc" \) -prune -o -exec rm -rf {} + 2> /dev/null;

exit;
