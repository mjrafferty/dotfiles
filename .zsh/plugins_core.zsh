# Load zplugin
declare -A ZINIT
ZINIT[HOME_DIR]="${HOME}/.zsh/zplugin"
source "${ZINIT[HOME_DIR]}/bin/zplugin.zsh"

# Required by fuzzy-search-and-edit below
zplugin ice lucid
zplugin light mafredri/zsh-async

# ZSH theme
zplugin ice lucid atinit'fpath+=(${XDG_DATA_HOME:-${HOME}/.local/share}/apollo/ $PWD/modules.zwc $PWD/modules)'
zplugin light mjrafferty/apollo-zsh-theme

zplugin ice wait'0c' lucid
zplugin light mjrafferty/zhist

# LS colors
zplugin ice lucid atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh"
zplugin light trapd00r/LS_COLORS

# ZSH completions
zplugin ice lucid wait'0b' blockf atpull'zplugin creinstall -q .'
zplugin light zsh-users/zsh-completions

# ZSH Autosuggestions
zplugin ice lucid wait'0c' atload'_zsh_autosuggest_start' compile'{src/*.zsh,src/strategies/*}'
zplugin light zsh-users/zsh-autosuggestions

# ZSH history substring search
zplugin ice lucid wait'0d' atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down'
zplugin light zsh-users/zsh-history-substring-search

# ZSH Syntax highlighting
zplugin ice lucid wait'0e' atload"ZINIT[COMPINIT_OPTS]=\"-C -i\" zpcompinit; zpcdreplay"
zplugin light zdharma/fast-syntax-highlighting

ZSH_AUTOSUGGEST_MANUAL_REBIND="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC="true"
ZSH_AUTOSUGGEST_STRATEGY=( history match_prev_cmd )
