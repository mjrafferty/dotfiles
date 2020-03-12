zload   MichaelAquilina/zsh-you-should-use  '0c'  pick"you-should-use.plugin.zsh"
#zload   ael-code/zsh-colored-man-pages      '0c'
zload   andrewferrier/fzf-z                 '0c'
zload   changyuheng/fz                      '0c'
zload   hlissner/zsh-autopair               '0c'  nocompletions
zload   junegunn/fzf                        '0c'  multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zload   knu/zsh-manydots-magic              '2'   pick'manydots-magic' compile'manydots-magic'
zload   mdumitru/fancy-ctrl-z               '0c'
zload   paoloantinori/hhighlighter          '0c'  pick"h.sh"
zload   rupa/z                              '0c'
zload   supercrabtree/k                     '0c'  atclone"gencomp k; ZPLGM[COMPINIT_OPTS]='-i' zpcompinit" atpull'%atclone'
zload   tldr-pages/tldr                     '0c'
zload   zdharma/history-search-multi-word   '0c'  compile'{hsmw-*,test/*}'
alias l='k -h'
