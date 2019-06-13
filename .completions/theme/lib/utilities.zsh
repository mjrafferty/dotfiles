# vim:ft=bash

typeset -g _P9K_BYTE_SUFFIX
_P9K_BYTE_SUFFIX=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')

# Usage: set_default [OPTION]... NAME [VALUE]...
set_default() {

  emulate -L zsh

  local varname
  local -a flags=(-g)

  while true; do
    case $1 in
      --) shift; break;;
      -*) flags+=$1; shift;;
      *) break;
    esac
  done

  varname=$1

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

  local x
  local -a ts
  ts=("${=$(typeset -p $1)}")

  shift ts

  for x in "${ts[@]}"; do
    [[ $x == -* ]] || break
    # Don't change readonly variables. Ideally, we shouldn't modify any variables at all,
    # but for now this will do.
    [[ $x == -*r* ]] && return
  done

  typeset -g $1=${(g::)${(P)1}}
}

# If we execute `print -P $1`, how many characters will be printed on the last line?
_p9k_prompt_length() {

  emulate -L zsh

  local -i x y m
  y=$#1

  if (( y )); then

    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ));
    done

    while (( y > x + 1 )); do
      m=$(( x + (y - x) / 2 ))
      typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
    done

  fi

  _P9K_RETVAL=$x
}

_p9k_human_readable_bytes() {

  local suf
  typeset -F 2 n
  n=$1

  for suf in $_P9K_BYTE_SUFFIX; do
    (( n < 100 )) && break
    (( n /= 1024 ))
  done

  _P9K_RETVAL=$n$suf
}

_p9k_parse_ip() {

  local desiredInterface rawInterfaces pattern relevantInterfaces newline interfaceName interface ipFound
  local -a interfaces relevantInterfaces interfaceStates

  desiredInterface=${1:-'^[^ ]+'}

  if [[ $OS == OSX ]]; then

    if [[ ! -x /sbin/ifconfig ]]; then
      return
    fi

    rawInterfaces="$(/sbin/ifconfig -l 2>/dev/null)";

    if [[ -z $rawInterfaces ]]; then
      return
    fi

    interfaces=(${(A)=rawInterfaces})
    pattern="${desiredInterface}[^ ]?"

    for rawInterface in $interfaces; do
      if [[ "$rawInterface" =~ $pattern ]]; then
        relevantInterfaces+=$MATCH
      fi
    done

    newline=$'\n'

    for interfaceName in $relevantInterfaces; do

      interface="$(/sbin/ifconfig $interfaceName 2>/dev/null)" || continue

      if [[ "${interface}" =~ "lo[0-9]*" ]]; then
        continue
      fi

      if [[ "${interface//${newline}/}" =~ "<([^>]*)>(.*)inet[ ]+([^ ]*)" ]]; then

        ipFound="${match[3]}"
        interfaceStates=(${(s:,:)match[1]})

        if (( ${interfaceStates[(I)UP]} )); then
          _P9K_RETVAL=$ipFound
          return
        fi

      fi
    done
  else

    if [[ ! -x /sbin/ip ]]; then
      return
    fi

    interfaces=( "${(f)$(/sbin/ip -brief -4 a show 2>/dev/null)}" )
    pattern="^${desiredInterface}[[:space:]]+UP[[:space:]]+([^/ ]+)"

    for interface in "${(@)interfaces}"; do
      if [[ "$interface" =~ $pattern ]]; then
        _P9K_RETVAL=$match[1]
        return
      fi
    done

  fi

  return 1

}

# Show a ratio of tests vs code
build_test_stats() {

  local code_amount tests_amount headline
  local -F 2 ratio

  code_amount="$4"
  tests_amount="$5"
  headline="$6"

  if (( code_amount <= 0 )); then
    return
  fi

 ratio=$(( 100. * tests_amount / code_amount ))

  if (( ratio >= 75 )); then
    "$1_prompt_segment" "${2}_GOOD" "$3" "cyan" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  elif (( ratio >= 50 )); then
    "$1_prompt_segment" "$2_AVG" "$3" "yellow" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  else
    "$1_prompt_segment" "$2_BAD" "$3" "red" "$DEFAULT_COLOR" "$6" 0 '' "$headline: $ratio%%"
  fi
}

_p9k_read_file() {

  _P9K_RETVAL=''

  if [[ -n $1 ]]; then
    read -r _P9K_RETVAL <$1
  fi

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
  if [[ $ZSH_PATCHLEVEL =~ '^zsh-5\.4\.2-([0-9]+)-' ]]; then
    return $(( match[1] < 159 ))
  elif [[ $ZSH_PATCHLEVEL =~ '^zsh-5\.7\.1-([0-9]+)-' ]]; then
    return $(( match[1] >= 50 ));
  fi

  is-at-least 5.5 && ! is-at-least 5.7.2

}

_p9k_init_strings() {
  # To find candidates:
  #
  #   egrep 'set_default [^-]' powerlevel9k.zsh-theme | egrep -v '(true|false)$'
  _p9k_g_expand POWERLEVEL9K_ANACONDA_LEFT_DELIMITER
  _p9k_g_expand POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER
  _p9k_g_expand POWERLEVEL9K_CONTEXT_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_DATE_FORMAT
  _p9k_g_expand POWERLEVEL9K_DIR_PATH_SEPARATOR
  _p9k_g_expand POWERLEVEL9K_HOME_FOLDER_ABBREVIATION
  _p9k_g_expand POWERLEVEL9K_HOST_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_SHORTEN_DELIMITER
  _p9k_g_expand POWERLEVEL9K_TIME_FORMAT
  _p9k_g_expand POWERLEVEL9K_USER_TEMPLATE
  _p9k_g_expand POWERLEVEL9K_VCS_LOADING_TEXT
  _p9k_g_expand POWERLEVEL9K_VI_COMMAND_MODE_STRING
  _p9k_g_expand POWERLEVEL9K_VI_INSERT_MODE_STRING
  _p9k_g_expand POWERLEVEL9K_WHITESPACE_BETWEEN_LEFT_SEGMENTS
  _p9k_g_expand POWERLEVEL9K_WHITESPACE_BETWEEN_RIGHT_SEGMENTS
}
