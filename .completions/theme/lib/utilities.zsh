# vim:ft=bash
################################################################
# Utility functions
# This file holds some utility-functions for
# the powerlevel9k-ZSH-theme
# https://github.com/bhilburn/powerlevel9k
################################################################

# Usage: set_default [OPTION]... NAME [VALUE]...
#
# Options are the same as in `typeset`.
set_default() {
  emulate -L zsh
  local -a flags=(-g)
  while true; do
    case $1 in
      --) shift; break;;
      -*) flags+=$1; shift;;
      *) break;
    esac
  done

  local varname=$1
  shift
  if [[ -n ${(tP)varname} ]]; then
    typeset $flags $varname
  elif [[ "$flags" == *[aA]* ]]; then
    eval "typeset ${(@q)flags} ${(q)varname}=(${(qq)@})"
  else
    typeset $flags $varname="$*"
  fi
}

_p9k_g_expand() {
  (( $+parameters[$1] )) || return
  local -a ts=("${=$(typeset -p $1)}")
  shift ts
  local x
  for x in "${ts[@]}"; do
    [[ $x == -* ]] || break
    # Don't change readonly variables. Ideally, we shouldn't modify any variables at all,
    # but for now this will do.
    [[ $x == -*r* ]] && return
  done
  typeset -g $1=${(g::)${(P)1}}
}

# If we execute `print -P $1`, how many characters will be printed on the last line?
# Assumes that `%{%}` and `%G` don't lie.
#
#   _p9k_prompt_length '' => 0
#   _p9k_prompt_length 'abc' => 3
#   _p9k_prompt_length $'abc\nxy' => 2
#   _p9k_prompt_length $'\t' => 8
#   _p9k_prompt_length '%F{red}abc' => 3
#   _p9k_prompt_length $'%{a\b%Gb%}' => 1
_p9k_prompt_length() {
  emulate -L zsh
  local -i x y=$#1 m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ));
    done
    local xy
    while (( y > x + 1 )); do
      m=$(( x + (y - x) / 2 ))
      typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
    done
  fi
  _P9K_RETVAL=$x
}

typeset -g _P9K_BYTE_SUFFIX=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')

# 42 => 42B
# 1536 => 1.5K
_p9k_human_readable_bytes() {
  typeset -F 2 n=$1
  local suf
  for suf in $_P9K_BYTE_SUFFIX; do
    (( n < 100 )) && break
    (( n /= 1024 ))
  done
  _P9K_RETVAL=$n$suf
}

# Determine if the passed segment is used in the prompt
#
# Pass the name of the segment to this function to test for its presence in
# either the LEFT or RIGHT prompt arrays.
#    * $1: The segment to be tested.
segment_in_use() {
  local key=$1
  [[ -n "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(r)${key}]}" ||
     -n "${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(r)${key}_joined]}" ||
     -n "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(r)${key}]}" ||
     -n "${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(r)${key}_joined]}" ]]
}

_p9k_parse_ip() {
  local desiredInterface=${1:-'^[^ ]+'}

  if [[ $OS == OSX ]]; then
    [[ -x /sbin/ifconfig ]] || return
    local rawInterfaces && rawInterfaces="$(/sbin/ifconfig -l 2>/dev/null)" || return
    local -a interfaces=(${(A)=rawInterfaces})
    local pattern="${desiredInterface}[^ ]?"
    local -a relevantInterfaces
    for rawInterface in $interfaces; do
      [[ "$rawInterface" =~ $pattern ]] && relevantInterfaces+=$MATCH
    done
    local newline=$'\n'
    local interfaceName interface
    for interfaceName in $relevantInterfaces; do
      interface="$(/sbin/ifconfig $interfaceName 2>/dev/null)" || continue
      [[ "${interface}" =~ "lo[0-9]*" ]] && continue
      if [[ "${interface//${newline}/}" =~ "<([^>]*)>(.*)inet[ ]+([^ ]*)" ]]; then
        local ipFound="${match[3]}"
        local -a interfaceStates=(${(s:,:)match[1]})
        if (( ${interfaceStates[(I)UP]} )); then
          _P9K_RETVAL=$ipFound
          return
        fi
      fi
    done
  else
    [[ -x /sbin/ip ]] || return
    local -a interfaces=( "${(f)$(/sbin/ip -brief -4 a show 2>/dev/null)}" )
    local pattern="^${desiredInterface}[[:space:]]+UP[[:space:]]+([^/ ]+)"
    local interface
    for interface in "${(@)interfaces}"; do
      if [[ "$interface" =~ $pattern ]]; then
        _P9K_RETVAL=$match[1]
        return
      fi
    done
  fi

  return 1
}

################################################################
# Show a ratio of tests vs code
build_test_stats() {
  local code_amount="$4"
  local tests_amount="$5"
  local headline="$6"

  (( code_amount > 0 )) || return
  local -F 2 ratio=$(( 100. * tests_amount / code_amount ))

  (( ratio >= 75 )) && "$1_prompt_segment" "${2}_GOOD" "$3" "cyan" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  (( ratio >= 50 && ratio < 75 )) && "$1_prompt_segment" "$2_AVG" "$3" "yellow" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  (( ratio < 50 )) && "$1_prompt_segment" "$2_BAD" "$3" "red" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
}

_p9k_read_file() {
  _P9K_RETVAL=''
  [[ -n $1 ]] && read -r _P9K_RETVAL <$1
  [[ -n $_P9K_RETVAL ]]
}

_p9k_escape_rcurly() {
  _P9K_RETVAL=${${1//\\/\\\\}//\}/\\\}}
}

# Returns 1 if the cursor is at the very end of the screen.
_p9k_left_prompt_end_line() {
  _p9k_get_icon LEFT_SEGMENT_SEPARATOR
  _p9k_escape_rcurly $_P9K_RETVAL
  _P9K_PROMPT+="%k%b"
  _P9K_PROMPT+="\${_P9K_N::=}"
  _P9K_PROMPT+="\${\${\${_P9K_BG:#NONE}:-\${_P9K_N:=1}}+}"
  _P9K_PROMPT+="\${\${_P9K_N:=2}+}"
  _P9K_PROMPT+="\${\${_P9K_T[2]::=%F{\$_P9K_BG\}$_P9K_RETVAL}+}"
  _P9K_PROMPT+="\${_P9K_T[\$_P9K_N]}"
  _P9K_PROMPT+="%f$1%f%k%b"

  if (( ! _P9K_RPROMPT_DONE )); then
    _P9K_PROMPT+=$_P9K_ALIGNED_RPROMPT
    _P9K_RPROMPT_DONE=1
    return 1
  fi
}

_p9k_zle_keymap_select() {
  zle && zle .reset-prompt && zle -R
}

_p9k_prompt_overflow_bug() {
# Does ZSH have a certain off-by-one bug that triggers when PROMPT overflows to a new line?
#
# Bug: https://github.com/zsh-users/zsh/commit/d8d9fee137a5aa2cf9bf8314b06895bfc2a05518.
# ZSH_PATCHLEVEL=zsh-5.4.2-159-gd8d9fee13. Released in 5.5.
#
# Fix: https://github.com/zsh-users/zsh/commit/64d13738357c9b9c212adbe17f271716abbcf6ea.
# ZSH_PATCHLEVEL=zsh-5.7.1-50-g64d137383.
#
# Test: PROMPT="${(pl:$((COLUMNS))::-:)}<%1(l.%2(l.FAIL.PASS).FAIL)> " zsh -dfis <<<exit
# Workaround: PROMPT="${(pl:$((COLUMNS))::-:)}%{%G%}<%1(l.%2(l.FAIL.PASS).FAIL)> " zsh -dfis <<<exit
  [[ $ZSH_PATCHLEVEL =~ '^zsh-5\.4\.2-([0-9]+)-' ]] && return $(( match[1] < 159 ))
  [[ $ZSH_PATCHLEVEL =~ '^zsh-5\.7\.1-([0-9]+)-' ]] && return $(( match[1] >= 50 ))
  is-at-least 5.5 && ! is-at-least 5.7.2
}

_p9k_init_strings() {
# Some people write POWERLEVEL9K_DIR_PATH_SEPARATOR='\uNNNN' instead of
# POWERLEVEL9K_DIR_PATH_SEPARATOR=$'\uNNNN'. There is no good reason for it and if we were
# starting from scratch we wouldn't perform automatic conversion from the former to the latter.
# But we aren't starting from scratch, so convert we do.
  # To find candidates:
