# vim:ft=zsh

zload   MichaelAquilina/zsh-you-should-use  '0c'  pick"you-should-use.plugin.zsh"
zload   RobSis/zsh-completion-generator     '0b'  '[[ -n ${ZLAST_COMMANDS[(r)gcom*]}  ]]' atload'gcomp(){ \gencomp $1 && zinit creinstall -q RobSis/zsh-completion-generator; }' pick'zsh-completion-generator.plugin.zsh'
zload   ael-code/zsh-colored-man-pages      '0c'
zload   aperezdc/zsh-fzy                    '0c'  atload"bindkey '\ec' fzy-cd-widget; bindkey '^T' fzy-file-widget"
zload   hlissner/zsh-autopair               '0c'  nocompletions
zload   junegunn/fzf                        '0c'  multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
zload   knu/zsh-manydots-magic              '2'   pick'manydots-magic' compile'manydots-magic'
zload   laggardkernel/git-ignore            '0c'  has'git' pick'init.zsh' atload'alias gi="git-ignore"' blockf
zload   mdumitru/fancy-ctrl-z               '0c'
zload   paoloantinori/hhighlighter          '0c'  pick"h.sh"
zload   seletskiy/zsh-fuzzy-search-and-edit '0d'  atload"bindkey '^T' fzy-file-widget"
zload   soimort/translate-shell             '0c'  if'[[ -n "$commands[gawk]" ]]'
zload   tldr-pages/tldr                     '0c'
zload   wfxr/forgit                         '0c'  has'git'
zload   zdharma/history-search-multi-word   '0c'  compile'{hsmw-*,test/*}'
zload   zdharma/z-p-submods                 '0a'

## Snippets ##
zsnip  OMZ::plugins/extract                 '0c'  svn
zsnip  OMZ::plugins/git-extras              '0c'  svn
