
typeset -g  RIFF_TL_LINK="╭─"
typeset -g  RIFF_ML_LINK="├─"
typeset -g  RIFF_SL_LINK="│ "
typeset -g  RIFF_BL_LINK="╰─"
typeset -g  RIFF_TR_LINK="─╮"
typeset -g  RIFF_MR_LINK="─┤"
typeset -g  RIFF_SR_LINK=" │"
typeset -g  RIFF_BR_LINK="─╯"
typeset -g  RIFF_NL_LINK="  "
typeset -g  RIFF_LINK_COLOR="white"

# Logic for adding link lines. Don't look it's ugly
_riff_add_links() {

  local line line_index start
  local tl ml sl bl tr mr sr br nl

  if (( RIFF_PROFILER > 0 )); then
    start="$EPOCHREALTIME"
  fi

  tl="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_TL_LINK}%f"
  ml="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_ML_LINK}%f"
  sl="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_SL_LINK}%f"
  bl="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_BL_LINK}%f"
  tr="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_TR_LINK}%f"
  mr="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_MR_LINK}%f"
  sr="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_SR_LINK}%f"
  br="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_BR_LINK}%f"
  nl="%F{${__RIFF_COLORS[${RIFF_LINK_COLOR}]}}${RIFF_NL_LINK}%f"

  line_index="$1";

  for ((line=1;line<=line_index;line++)); do

    case "${_RIFF_LINES_META[line]}" in
      3)
        case "$line" in
          "$line_index")
            _RIFF_PROMPT_LINES[line]="${bl}${_RIFF_PROMPT_LINES[line]}${br}" ;;
          1)
            _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${tr}" ;;
          *)
            case "${_RIFF_LINES_META[line-1]}" in
              3)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${br}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${br}";;
                esac
                ;;
              2)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              1)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${tr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${tr}";;
                  1) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              0)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${tr}";;
                  2) _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${tr}";;
                  1) _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${tr}";;
                  0) _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${tr}";;
                esac
                ;;
            esac
            ;;
        esac
        ;;
      2)
        case "$line" in
          "$line_index")
            _RIFF_PROMPT_LINES[line]="${_RIFF_PROMPT_LINES[line]}${br}" ;;
          1)
            _RIFF_PROMPT_LINES[line]="${nl}${_RIFF_PROMPT_LINES[line]}${tr}" ;;
          *)
            case "${_RIFF_LINES_META[line-1]}" in
              3)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              2)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${nl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              1)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              0)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
            esac
            ;;
        esac
        ;;
      1)
        case "$line" in
          "$line_index")
            _RIFF_PROMPT_LINES[line]="${bl}${_RIFF_PROMPT_LINES[line]}" ;;
          1)
            _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}" ;;
          *)
            case "${_RIFF_LINES_META[line-1]}" in
              3)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              2)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              1)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
              0)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  2) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  1) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                  0) _RIFF_PROMPT_LINES[line]="${ml}${_RIFF_PROMPT_LINES[line]}${mr}";;
                esac
                ;;
            esac
            ;;
        esac
        ;;
      0)
        case "$line" in
          "$line_index")
            _RIFF_PROMPT_LINES[line]="${bl}${_RIFF_PROMPT_LINES[line]}" ;;
          1)
            _RIFF_PROMPT_LINES[line]="${tl}${_RIFF_PROMPT_LINES[line]}" ;;
          *)
            case "${_RIFF_LINES_META[line-1]}" in
              3)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  2) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  1) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  0) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                esac
                ;;
              2)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  2) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  1) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  0) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                esac
                ;;
              1)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  2) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  1) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  0) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                esac
                ;;
              0)
                case "${_RIFF_LINES_META[line+1]}" in
                  3) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  2) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  1) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                  0) _RIFF_PROMPT_LINES[line]="${sl}${_RIFF_PROMPT_LINES[line]}${sr}";;
                esac
                ;;
            esac
            ;;
        esac
    esac

  done

  if (( RIFF_PROFILER > 0 )); then
    printf "%25s: %f\n" "line links" "$((EPOCHREALTIME-start))"
  fi

}

