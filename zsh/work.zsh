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

if [[ -e "${HOME}/Dev/nxclient.token" ]]; then
  source "${HOME}/Dev/nxclient.token"
fi

export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PYENV_SHELL=zsh
export PATH="/Users/mrafferty/.local/share/pyenv/shims:${PATH}"
source '/usr/local/opt/pyenv/completions/pyenv.zsh'

setpath /usr/local/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/bin
setpath "${HOME}/.composer/vendor/bin"
