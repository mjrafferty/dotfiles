# vim:ft=zsh

## Load zinit ##
declare -gA ZINIT
ZINIT[HOME_DIR]="${ZDOTDIR:-${HOME}/.zsh}/zinit"
ZPFX="${ZDOTDIR:-${HOME}/.zsh}/zinit/polaris"
ZINIT[COMPINIT_OPTS]="-C -i -d ${ZSH_COMPDUMP}"
source "${ZINIT[HOME_DIR]}/bin/zinit.zsh"

zload() {

  local plugin="$1"
  local wait="$2"

  shift; shift;

  if [[ "$wait" == "no" ]]; then
    zinit ice lucid ${@}
    zinit "light" "$plugin"
  else
    zinit ice lucid wait"$wait" ${@}
    zinit "light" "$plugin"
  fi

}

zsnip() {

  local plugin="$1"
  local wait="$2"

  shift; shift;

  if [[ "$wait" == "no" ]]; then
    zinit ice lucid ${@}
    zinit "snippet" "$plugin"
  else
    zinit ice lucid wait"$wait" ${@}
    zinit "snippet" "$plugin"
  fi

}

zload mafredri/zsh-async                     'no'
zload mjrafferty/apollo-zsh-theme            'no' atinit'fpath+=(${XDG_DATA_HOME:-${HOME}/.local/share}/apollo/ $PWD/modules.zwc $PWD/modules)'
zload mjrafferty/zhist                       '0c'
#zload mjrafferty/ztouch                      '0c'
zload trapd00r/LS_COLORS                     'no' atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh"
zload zsh-users/zsh-completions              '0b' blockf atpull'zinit creinstall -q  .'
zload zsh-users/zsh-autosuggestions          '0c' atload'_zsh_autosuggest_start' compile'{src/*.zsh,src/strategies/*}'
zload zsh-users/zsh-history-substring-search '0d' atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B"  history-substring-search-down'
zload zdharma/fast-syntax-highlighting       '0e' atload"zpcompinit; zpcdreplay"

ZSH_AUTOSUGGEST_MANUAL_REBIND="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC="true"
ZSH_AUTOSUGGEST_STRATEGY=( history match_prev_cmd )
