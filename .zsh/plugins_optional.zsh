# Install `cloc` (code summary) binary if not already installed via package manager
#zplugin ice lucid wait"0c" as"command" if'[[ -z "$commands[cloc]" ]]' from"gh-r" bpick"*pl" mv"cloc-* -> cloc";
#zplugin load AlDanial/cloc

# Install `fzy` fuzzy finder, if not yet present in the system
# Also install helper scripts for tmux and dwtm
#zplugin ice lucid wait"0b" as"command" if'[[ -z "$commands[fzy]" ]]' make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
#zplugin load jhawthorn/fzy

# Install fzy-using widgets
#zplugin ice lucid wait"0c" atload"bindkey '\ec' fzy-cd-widget; bindkey '^T'  fzy-file-widget"
#zplugin load aperezdc/zsh-fzy

# Ctrl-P search and edit file
#zplugin ice lucid wait"0c" atload"bindkey '^T'  fzy-file-widget"
#zplugin load seletskiy/zsh-fuzzy-search-and-edit
#export EDITOR=${EDITOR:-vim}

# Interactive git helper
#zplugin ice lucid wait"0c" has'git'
#zplugin load  wfxr/forgit

# Adds additional git functions
#zplugin ice lucid wait"0c" as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
#zplugin load tj/git-extras

# Or with most recent Zplugin and with ~/.zplugin/snippeds directory pruned (rm -rf -- ${ZPLGM[SNIPPETS_DIR]}):
#zplugin ice lucid wait"0c" svn
#zplugin snippet OMZ::plugins/git-extras

#zplugin ice lucid wait"0c" svn
#zplugin snippet OMZ::plugins/extract

#zplugin ice lucid wait"0c" svn
#zplugin snippet OMZ::plugins/aws

# Interactive git ignore creation
#zplugin ice lucid wait"0c"  has'git' pick'init.zsh' atload'alias gi="git-ignore"' blockf
#zplugin load laggardkernel/git-ignore

#zplugin ice lucid wait"0c" as"program" atclone="pip install -e . ;pip install -r requirements-dev.txt" atpull"%atclone"
#zplugin load donnemartin/haxor-news

# Magento 2 completions
#zplugin ice lucid wait"0c" blockf pick"magento-2.plugin.zsh" atload'unalias m2:home'
#zplugin load dambrogia/oh-my-zsh-plugin-magento-2

# Fancy diff
#zplugin ice lucid wait"0c" as"program" pick"bin/git-dsf"
#zplugin load zdharma/zsh-diff-so-fancy

# Automatically ls when changing directory
#zplugin ice lucid wait"0a"
#zplugin load desyncr/auto-ls

# Alias reminder
#zplugin ice lucid wait"0c" make'!'
#zplugin load sei40kr/zsh-fast-alias-tips

# Add command-line online translator
#zplugin ice lucid wait"0c" if'[[ -n "$commands[gawk]" ]]'
#zplugin load soimort/translate-shell

#zplugin ice lucid wait"0a"
#zplugin load zdharma/z-p-submods

#zplugin ice lucid wait"0c" svn submods"clvv/fasd -> external"
#zplugin snippet PZT::modules/fasd

#zplugin ice nocompletions atclone'prompt_zinc_compile' atpull'%atclone' compile"{zinc_functions/*,segments/*,zinc.zsh}"
#zplugin load robobenklein/zinc

# ZINC git info is already async, but if you want it even faster with gitstatus in turbo mode:
# https://github.com/romkatv/gitstatus
#zplugin ice wait'1' atload'zinc_optional_depenency_loaded'
#zplugin load romkatv/gitstatus

#zplugin ice lucid wait"0c"
#zplugin load romkatv/zsh-prompt-benchmark

# Shell interpreter
#zplugin ice lucid wait"0c" from"gh-r" as"program" mv"shfmt* -> shfmt"
#zplugin load mvdan/sh

# Yank CLI output to clipboard
#zplugin ice lucid wait"0c" as"program" pick"yank" make
#zplugin load mptre/yank

