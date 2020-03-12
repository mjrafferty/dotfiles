zload   MichaelAquilina/zsh-you-should-use  '0c'  pick"you-should-use.plugin.zsh"
#zload   ael-code/zsh-colored-man-pages      '0c'
zload   andrewferrier/fzf-z                 '0c'
zload   changyuheng/fz                      '0c'
zload   hlissner/zsh-autopair               '0c'  nocompletions
zload   isacikgoz/tldr                      '0c'  from'gh-r' as'program'
zload   junegunn/fzf                        '0c'  as"program" pick"bin/fzf-tmux"
zload   junegunn/fzf                        '0c'  multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zload   junegunn/fzf-bin                    '0b'  from"gh-r" as"program"
zload   knu/zsh-manydots-magic              '2'   pick'manydots-magic' compile'manydots-magic'
zload   mdumitru/fancy-ctrl-z               '0c'
zload   mfaerevaag/wd                       '0c'  as'program' atpull'!git reset --hard' pick'wd.sh' mv'_wd.sh -> _wd' atload'wd() { source wd.sh }; WD_CONFIG="$ZPFX/.warprc"' blockf
zload   paoloantinori/hhighlighter          '0c'  pick"h.sh"
zload   rupa/v                              '0c'  as"program" pick"v"
zload   rupa/z                              '0c'
zload   supercrabtree/k                     '0c'  atclone"gencomp k; ZPLGM[COMPINIT_OPTS]='-i' zpcompinit" atpull'%atclone'
zload   tldr-pages/tldr                     '0c'
zload   zdharma/history-search-multi-word   '0c'  compile'{hsmw-*,test/*}'
alias l='k -h'
