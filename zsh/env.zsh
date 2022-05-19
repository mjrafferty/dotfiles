# vim:ft=zsh

setopt no_global_rcs

if [[ "$USER" != "root" ]]; then
  [[ -n "$XDG_CACHE_HOME" ]] || export XDG_CACHE_HOME="${HOME}/.local/cache"
  [[ -n "$XDG_CONFIG_HOME" ]] || export XDG_CONFIG_HOME="${HOME}/.local/config"
  [[ -n "$XDG_DATA_HOME" ]] || export XDG_DATA_HOME="${HOME}/.local/share"
else
  export XDG_CACHE_HOME="${HOME}/.local/cache"
  export XDG_CONFIG_HOME="${HOME}/.local/config"
  export XDG_DATA_HOME="${HOME}/.local/share"
fi

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
export VIM_DIR="${XDG_CONFIG_HOME}/vim"
export VIM_DATA_DIR="${XDG_DATA_HOME}/vim"
export VIMINIT=":source ${VIM_DIR}/vimrc"

[[ -d "${VIM_DATA_DIR}" ]] || mkdir -p "${VIM_DATA_DIR}"/{backup,swp,undo}

##### Environment Variables #####
export LANG="en_US.UTF-8"
export PAGER="less -inSFR"
export MANPAGER="less -inSFR"
export EDITOR="vim"
export VISUAL="vim"

export LESSHISTFILE="${XDG_CACHE_HOME}/lesshist"
export SQLITE_HISTORY="${XDG_CACHE_HOME}/sqlite_history"

[[ -n $TMUX ]] && export TERM="screen-256color"

# Volta nodejs tool manager
export VOLTA_HOME="$HOME/.volta"

## Less colors ##
export LESS_TERMCAP_mb="[01;31m"
export LESS_TERMCAP_md="[01;31m"
export LESS_TERMCAP_me="[0m"
export LESS_TERMCAP_se="[0m"
export LESS_TERMCAP_so="[00;47;30m"
export LESS_TERMCAP_ue="[0m"
export LESS_TERMCAP_us="[01;32m"

## PATH settings ##
setpath () {

  if [[ ! -d "$1" ]]; then
    return
  fi

  case ":${PATH}:" in
    *:"$1":*)
      ;;
    *)
      if [ "$2" = "after" ] ; then
        PATH=$PATH:$1
      else
        PATH=$1:$PATH
      fi
  esac
}

setpath "/usr/local/bin" 
setpath "/usr/local/sbin"
setpath "${HOME}/bin"
setpath "${HOME}/.local/bin"
setpath "${VOLTA_HOME}/bin"
