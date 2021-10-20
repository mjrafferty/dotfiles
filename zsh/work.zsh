# vim:ft=zsh

HISTFILE="${XDG_DATA_HOME}/zsh_history"

zstyle ':apollo:*:*:*:dir:*' bookmark_patterns "$HOME/Repositories/*" "$HOME/*"
zstyle ':apollo:*:*:*:dir:*' bookmarks "dotfiles=$HOME/.dotfiles"

load_conf main
load_conf zinit_optional
load_conf zinit_programs

if [[ -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" ]]; then
  source "${ZDOTDIR}/.iterm2_shell_integration.zsh"
fi
