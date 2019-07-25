declare -A ZPLGM
ZPLGM[HOME_DIR]="${HOME}/.zsh/zplugin"

source "${ZPLGM[HOME_DIR]}/bin/zplugin.zsh"

#if [[ ! -e "${HOME}/.zplugin/bin/zmodules/Src/zdharma/zplugin.so" ]]; then
	#zplugin module build
#fi

#module_path+=( "${HOME}/.zplugin/bin/zmodules/Src" )
#zmodload zdharma/zplugin

# ZSH theme
zplugin ice lucid pick'prompt_apollo_setup' compile'{modules/*,lib/*}'
zplugin load mjrafferty/apollo-zsh-theme

# ZSH completions
zplugin ice lucid wait"0c" blockf atpull'zplugin creinstall -q .'
zplugin load zsh-users/zsh-completions

# LS colors
zplugin ice lucid atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh"
zplugin load trapd00r/LS_COLORS

# ZSH history substring search
zplugin ice lucid wait"0c" atload'bindkey "$terminfo[kcuu1]" history-substring-search-up; bindkey "$terminfo[kcud1]" history-substring-search-down'
zplugin load zsh-users/zsh-history-substring-search

# ZSH Syntax highlighting
zplugin ice lucid wait'0d' atload"ZPLGM[COMPINIT_OPTS]=\"-C-i\" zpcompinit; zpcdreplay"
zplugin load zdharma/fast-syntax-highlighting

# ZSH Autosuggestions
zplugin ice lucid wait"0e" atload:'_zsh_autosuggest_start' compile'{src/*.zsh,src/strategies/*}'
zplugin load zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
