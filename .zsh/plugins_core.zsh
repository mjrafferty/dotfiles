# Load zplugin
declare -A ZPLGM
ZPLGM[HOME_DIR]="${HOME}/.zsh/zplugin"
source "${ZPLGM[HOME_DIR]}/bin/zplugin.zsh"

# ZSH theme
zplugin ice lucid
zplugin light mjrafferty/apollo-zsh-theme

# LS colors
zplugin ice lucid atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh"
zplugin light trapd00r/LS_COLORS

# ZSH completions
zplugin ice lucid wait'0c' blockf atpull'zplugin creinstall -q .'
zplugin light zsh-users/zsh-completions

# ZSH history substring search
zplugin ice lucid wait'0c' atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down'
zplugin light zsh-users/zsh-history-substring-search

# ZSH Syntax highlighting
zplugin ice lucid wait'0d' atload"ZPLGM[COMPINIT_OPTS]=\"-C -i\" zpcompinit; zpcdreplay"
zplugin light zdharma/fast-syntax-highlighting

# ZSH Autosuggestions
zplugin ice lucid wait'0e' atload:'_zsh_autosuggest_start' compile'{src/*.zsh,src/strategies/*}'
zplugin light zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_MANUAL_REBIND="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
