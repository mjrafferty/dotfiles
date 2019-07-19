# vim:ft=bash

typeset -g _RIFF_BYTE_SUFFIX
_RIFF_BYTE_SUFFIX=('B' 'K' 'M' 'G' 'T' 'P' 'E' 'Z' 'Y')

# If we execute `print -P $1`, how many characters will be printed on the last line?
_riff_prompt_length() {

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

  _RIFF_RETURN_MESSAGE=$x
}

_riff_human_readable_bytes() {

  local suf
  typeset -F 2 n
  n=$1

  for suf in $_RIFF_BYTE_SUFFIX; do
    (( n < 100 )) && break
    (( n /= 1024 ))
  done

  _RIFF_RETURN_MESSAGE=$n$suf

}

_riff_parse_ip() {

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

    echo "${relevantInterfaces[*]}"
    for interfaceName in $relevantInterfaces; do

      interface="$(/sbin/ifconfig $interfaceName 2>/dev/null)" || continue

      if [[ "${interface}" =~ "lo[0-9]*" ]]; then
        continue
      fi

      if [[ "${interface//${newline}/}" =~ "<([^>]*)>(.*)inet[ ]+([^ ]*)" ]]; then

        ipFound="${match[3]}"
        interfaceStates=(${(s:,:)match[1]})

        if (( ${interfaceStates[(I)UP]} )); then
          _RIFF_RETURN_MESSAGE=$ipFound
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
        _RIFF_RETURN_MESSAGE=$match[1]
        return
      fi
    done

  fi

  return 1

}

_riff_read_file() {

  _RIFF_RETURN_MESSAGE=''

  if [[ -n $1 ]]; then
    read -r _RIFF_RETURN_MESSAGE <$1
  fi

  [[ -n $_RIFF_RETURN_MESSAGE ]]

}

_riff_escape_rcurly() {
  _RIFF_RETURN_MESSAGE=${${1//\\/\\\\}//\}/\\\}}
}

# Returns 1 if the cursor is at the very end of the screen.
_riff_left_prompt_end_line() {

  _riff_get_icon LEFT_SEGMENT_SEPARATOR
  _riff_escape_rcurly $_RIFF_RETURN_MESSAGE

  _RIFF_PROMPT+="%k%b"
  _RIFF_PROMPT+="\${_RIFF_N::=}"
  _RIFF_PROMPT+="\${\${\${_RIFF_BG:#NONE}:-\${_RIFF_N:=1}}+}"
  _RIFF_PROMPT+="\${\${_RIFF_N:=2}+}"
  _RIFF_PROMPT+="\${\${_RIFF_T[2]::=%F{\$_RIFF_BG\}$_RIFF_RETURN_MESSAGE}+}"
  _RIFF_PROMPT+="\${_RIFF_T[\$_RIFF_N]}"
  _RIFF_PROMPT+="%f$1%f%k%b"

  if (( ! _RIFF_RPROMPT_DONE )); then
    _RIFF_PROMPT+=$_RIFF_ALIGNED_RPROMPT
    _RIFF_RPROMPT_DONE=1
    return 1
  fi
}

_riff_zle_keymap_select() {
  zle && zle .reset-prompt && zle -R
}
