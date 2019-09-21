# Load zplugin
declare -A ZPLGM
ZPLGM[HOME_DIR]="${HOME}/.zsh/zplugin"
source "${ZPLGM[HOME_DIR]}/bin/zplugin.zsh"

# ZSH theme
zplugin ice lucid
zplugin light mjrafferty/apollo-zsh-theme

zplugin ice wait'0c' lucid pick'sqlite-history.zsh'
zplugin light mjrafferty/zsh-histdb

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
zplugin ice lucid wait'0e' atload"ZPLGM[COMPINIT_OPTS]=\"-C -i\" zpcompinit; zpcdreplay"
zplugin light zdharma/fast-syntax-highlighting

ZSH_AUTOSUGGEST_MANUAL_REBIND="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC="true"
ZSH_AUTOSUGGEST_STRATEGY=( history match_prev_cmd )
