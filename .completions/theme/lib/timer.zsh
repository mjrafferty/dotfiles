# vim:ft=bash

typeset  -g   _P9K_TIMER_FIFO
typeset  -gi  _P9K_TIMER_FD=0
typeset  -gi  _P9K_TIMER_PID=0
typeset  -gi  _P9K_TIMER_SUBSHELL=0

_p9k_on_timer() {
  emulate -L zsh
  local dummy
  while IFS='' read -t -u $_P9K_TIMER_FD dummy; do true; done
  zle && zle .reset-prompt && zle -R
}

_p9k_kill_timer() {
  emulate -L zsh
  if (( ZSH_SUBSHELL == _P9K_TIMER_SUBSHELL )); then
    (( _P9K_TIMER_PID )) && kill -- -$_P9K_TIMER_PID &>/dev/null
    command rm -f $_P9K_TIMER_FIFO
  fi
}

_p9k_start_timer() {
  emulate -L zsh
  setopt err_return no_bg_nice

  _P9K_TIMER_FIFO=$(mktemp -u "${TMPDIR:-/tmp}"/p9k.$$.timer.pipe.XXXXXXXXXX)
  mkfifo $_P9K_TIMER_FIFO
  sysopen -rw -o cloexec,sync -u _P9K_TIMER_FD $_P9K_TIMER_FIFO
  zsystem flock $_P9K_TIMER_FIFO

  zle -F $_P9K_TIMER_FD _p9k_on_timer

  # `kill -WINCH $$` is a workaround for a bug in zsh. After a background job completes, callbacks
  # registered with `zle -F` stop firing until the user presses any key or the process receives a
  # signal (any signal at all).
  zsh -c "
  zmodload zsh/system
  while sleep 1 && ! zsystem flock -t 0 ${(q)_P9K_TIMER_FIFO} && kill -WINCH $$ && echo; do
    true
  done
  command rm -f ${(q)_P9K_TIMER_FIFO}
  " </dev/null >&$_P9K_TIMER_FD 2>/dev/null &!

  _P9K_TIMER_PID=$!
  _P9K_TIMER_SUBSHELL=$ZSH_SUBSHELL

  add-zsh-hook zshexit _p9k_kill_timer
}

_p9k_init_timer() {

  if ! _p9k_start_timer ; then
    echo "powerlevel10k: failed to initialize background timer" >&2
    if (( _P9K_TIMER_FD )); then
      zle -F $_P9K_TIMER_FD
      exec {_P9K_TIMER_FD}>&-
      _P9K_TIMER_FD=0
    fi
    if (( _P9K_TIMER_PID )); then
      kill -- -$_P9K_TIMER_PID &>/dev/null
      _P9K_TIMER_PID=0
    fi
    command rm -f $_P9K_TIMER_FIFO
    _P9K_TIMER_FIFO=''
    unset -f _p9k_on_timer
  fi
}
