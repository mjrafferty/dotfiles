# vim:ft=zsh

[[ -n "$XDG_CACHE_HOME" ]] || export XDG_CACHE_HOME="${HOME}/.local/cache"
[[ -n "$XDG_CONFIG_HOME" ]] || export XDG_CONFIG_HOME="${HOME}/.local/config"
[[ -n "$XDG_DATA_HOME" ]] || export XDG_DATA_HOME="${HOME}/.local/share"

[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"

## Shell ##
ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

HISTFILE="${XDG_DATA_HOME}/zsh_history"
SAVEHIST="10000"
HISTSIZE="10000"

KEYTIMEOUT=1

fpath=(${ZDOTDIR}/completions $fpath)

ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh_compdump"

## Vim ##
export VIMDIR="${XDG_CONFIG_HOME}/vim"
export VIMINIT=":source ${VIMDIR}/vimrc"

##### Environment Variables #####
export LANG="en_US.UTF-8"
export PAGER="less -inSFR"
export MANPAGER="less -inSFR"
export EDITOR="vim"
export VISUAL="vim"

export PATH="${PATH}:${HOME}/bin:${HOME}/.local/bin"

export LESSHISTFILE="${XDG_CACHE_HOME}/lesshist"
export SQLITE_HISTORY="${XDG_CACHE_HOME}/sqlite_history"

[[ -n $TMUX ]] && export TERM="screen-256color"

## Less colors ##
export LESS_TERMCAP_mb="[01;31m"
export LESS_TERMCAP_md="[01;31m"
export LESS_TERMCAP_me="[0m"
export LESS_TERMCAP_se="[0m"
export LESS_TERMCAP_so="[00;47;30m"
export LESS_TERMCAP_ue="[0m"
export LESS_TERMCAP_us="[01;32m"
