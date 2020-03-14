# vim:ft=zsh

##### Environment Variables #####
export LANG="en_US.UTF-8"
export PAGER="less -inSFR"
export MANPAGER="less -inSFR"
export EDITOR="vim"
export VISUAL="vim"

HISTFILE="${HOME}/.zsh_history"
SAVEHIST="10000"
HISTSIZE="10000"

if [[ -n $TMUX ]]; then
  TERM="screen-256color"
else
  TERM="xterm-256color"
fi

export LESS_TERMCAP_mb="[01;31m"
export LESS_TERMCAP_md="[01;31m"
export LESS_TERMCAP_me="[0m"
export LESS_TERMCAP_se="[0m"
export LESS_TERMCAP_so="[00;47;30m"
export LESS_TERMCAP_ue="[0m"
export LESS_TERMCAP_us="[01;32m"

export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin"
