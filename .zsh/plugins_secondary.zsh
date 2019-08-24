#### Fuzzies #####

# Install fzf
zplugin ice lucid wait"0b" from"gh-r" as"program"
zplugin load junegunn/fzf-bin

# Install `fzf` bynary and tmux helper script
zplugin ice lucid wait"0c" as"command" pick"bin/fzf-tmux"
zplugin load junegunn/fzf

# Create and bind multiple widgets using fzf
zplugin ice lucid wait"0c" multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zplugin load junegunn/fzf

# Fuzzy movement and directory choosing
zplugin ice lucid wait"0c"
zplugin load rupa/z               # autojump command

zplugin ice lucid wait"0c"
zplugin load andrewferrier/fzf-z  # Pick from most frecent folders with `Ctrl+g`

zplugin ice lucid wait"0c"
zplugin load changyuheng/fz       # lets z+[Tab] and zz+[Tab]

# Like `z` command, but opens a file in vim based on frecency
zplugin ice lucid wait"0c" as"command" pick"v"
zplugin load rupa/v



zplugin ice lucid wait"0c"
zplugin load mafredri/zsh-async




# Command line REST client
zplugin ice lucid wait"1"
zplugin load micha/resty



# Community man pages
zplugin ice lucid wait"0c"
zplugin load tldr-pages/tldr

# Reader pgrogram for tlrd pages
zplugin ice lucid wait"0c" from'gh-r' as'program' wait"0c"
zplugin load isacikgoz/tldr

# Colored man pages
zplugin ice lucid wait"0c"
zplugin load ael-code/zsh-colored-man-pages



# wd command to warp to directory
zplugin ice lucid wait"0c" as'program' atpull'!git reset --hard' pick'wd.sh' mv'_wd.sh -> _wd' atload'wd() { source wd.sh }; WD_CONFIG="$ZPFX/.warprc"' blockf
zplugin load mfaerevaag/wd

# ZSH completion auto generator?
zplugin ice lucid wait"0b" '[[ -n ${ZLAST_COMMANDS[(r)gcom*]} ]]' atload'gcomp(){ \gencomp $1 && zplugin creinstall -q RobSis/zsh-completion-generator; }' pick'zsh-completion-generator.plugin.zsh'
zplugin load RobSis/zsh-completion-generator

zplugin ice lucid wait"0c" atclone"gencomp k; ZPLGM[COMPINIT_OPTS]='-i' zpcompinit" atpull'%atclone'
zplugin load supercrabtree/k
alias l='k -h'


## Highlighter
zplugin ice lucid wait"0c" pick"h.sh"
zplugin load paoloantinori/hhighlighter




# Makes brackets/parentheses easier to manage on command line
zplugin ice lucid wait"0c" nocompletions
zplugin load hlissner/zsh-autopair

# History serach multi word
zplugin ice lucid wait"0c" compile'{hsmw-*,test/*}'
zplugin load zdharma/history-search-multi-word

# Run `fg` command to return to foregrounded (Ctrl+Z'd) vim
zplugin ice lucid wait"0c"
zplugin load mdumitru/fancy-ctrl-z

# Dot expansion for directory paths
zplugin ice lucid wait'2' pick'manydots-magic' compile'manydots-magic'
zplugin load knu/zsh-manydots-magic