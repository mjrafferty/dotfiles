# vim:ft=bash

typeset  -g   _RIFF_TIMER_FIFO
typeset  -gi  _RIFF_TIMER_FD=0
typeset  -gi  _RIFF_TIMER_PID=0
typeset  -gi  _RIFF_TIMER_SUBSHELL=0

_riff_on_timer() {
  emulate -L zsh
  local dummy
  while IFS='' read -t -u $_RIFF_TIMER_FD dummy; do true; done
  zle && zle .reset-prompt && zle -R
}

_riff_kill_timer() {
  emulate -L zsh
  if (( ZSH_SUBSHELL == _RIFF_TIMER_SUBSHELL )); then
    (( _RIFF_TIMER_PID )) && kill -- -$_RIFF_TIMER_PID &>/dev/null
    command rm -f $_RIFF_TIMER_FIFO
  fi
}

_riff_start_timer() {
  emulate -L zsh
  setopt err_return no_bg_nice

  _RIFF_TIMER_FIFO=$(mktemp -u "${TMPDIR:-/tmp}"/p9k.$$.timer.pipe.XXXXXXXXXX)
  mkfifo $_RIFF_TIMER_FIFO
  sysopen -rw -o cloexec,sync -u _RIFF_TIMER_FD $_RIFF_TIMER_FIFO
  zsystem flock $_RIFF_TIMER_FIFO

  zle -F $_RIFF_TIMER_FD _riff_on_timer

  # `kill -WINCH $$` is a workaround for a bug in zsh. After a background job completes, callbacks
  # registered with `zle -F` stop firing until the user presses any key or the process receives a
  # signal (any signal at all).
  zsh -c "
  zmodload zsh/system
  while sleep 1 && ! zsystem flock -t 0 ${(q)_RIFF_TIMER_FIFO} && kill -WINCH $$ && echo; do
    true
  done
  command rm -f ${(q)_RIFF_TIMER_FIFO}
  " </dev/null >&$_RIFF_TIMER_FD 2>/dev/null &!

  _RIFF_TIMER_PID=$!
  _RIFF_TIMER_SUBSHELL=$ZSH_SUBSHELL

  add-zsh-hook zshexit _riff_kill_timer
}

_riff_init_timer() {

  if ! _riff_start_timer ; then
    echo "powerlevel10k: failed to initialize background timer" >&2
    if (( _RIFF_TIMER_FD )); then
      zle -F $_RIFF_TIMER_FD
      exec {_RIFF_TIMER_FD}>&-
      _RIFF_TIMER_FD=0
    fi
    if (( _RIFF_TIMER_PID )); then
      kill -- -$_RIFF_TIMER_PID &>/dev/null
      _RIFF_TIMER_PID=0
    fi
    command rm -f $_RIFF_TIMER_FIFO
    _RIFF_TIMER_FIFO=''
    unset -f _riff_on_timer
  fi
}
