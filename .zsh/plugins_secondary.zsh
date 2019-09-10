#### Fuzzies #####

# Install fzf
zplugin ice lucid wait'0b' from"gh-r" as"program"
zplugin light junegunn/fzf-bin

# Install `fzf` bynary and tmux helper script
zplugin ice lucid wait'0c' as"command" pick"bin/fzf-tmux"
zplugin light junegunn/fzf

# Create and bind multiple widgets using fzf
zplugin ice lucid wait'0c' multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zplugin light junegunn/fzf

# Fuzzy movement and directory choosing
zplugin ice lucid wait'0c'
zplugin light rupa/z               # autojump command

zplugin ice lucid wait'0c'
zplugin light andrewferrier/fzf-z  # Pick from most frecent folders with `Ctrl+g`

zplugin ice lucid wait'0c'
zplugin light changyuheng/fz       # lets z+[Tab] and zz+[Tab]

# Like `z` command, but opens a file in vim based on frecency
zplugin ice lucid wait'0c' as"command" pick"v"
zplugin light rupa/v

# Community man pages
zplugin ice lucid wait'0c'
zplugin light tldr-pages/tldr

# Reader pgrogram for tlrd pages
zplugin ice lucid wait'0c' from'gh-r' as'program'
zplugin light isacikgoz/tldr

# Colored man pages
zplugin ice lucid wait'0c'
zplugin light ael-code/zsh-colored-man-pages

# wd command to warp to directory
zplugin ice lucid wait'0c' as'program' atpull'!git reset --hard' pick'wd.sh' mv'_wd.sh -> _wd' atload'wd() { source wd.sh }; WD_CONFIG="$ZPFX/.warprc"' blockf
zplugin light mfaerevaag/wd

zplugin ice lucid wait'0c' atclone"gencomp k; ZPLGM[COMPINIT_OPTS]='-i' zpcompinit" atpull'%atclone'
zplugin light supercrabtree/k
alias l='k -h'

## Highlighter
zplugin ice lucid wait'0c' pick"h.sh"
zplugin light paoloantinori/hhighlighter

# Makes brackets/parentheses easier to manage on command line
zplugin ice lucid wait'0c' nocompletions
zplugin light hlissner/zsh-autopair

# History serach multi word
zplugin ice lucid wait'0c' compile'{hsmw-*,test/*}'
zplugin light zdharma/history-search-multi-word

# Run `fg` command to return to foregrounded (Ctrl+Z'd) vim
zplugin ice lucid wait'0c'
zplugin light mdumitru/fancy-ctrl-z

# Dot expansion for directory paths
zplugin ice lucid wait'2' pick'manydots-magic' compile'manydots-magic'
zplugin light knu/zsh-manydots-magic

# Alias reminder
zplugin ice lucid wait'0c' pick"you-should-use.plugin.zsh"
zplugin light MichaelAquilina/zsh-you-should-use
