zload  wfxr/forgit                          '0c'  has'git'
zload  AlDanial/cloc                        '0c'  as"program" if'[[ -z "$commands[cloc]" ]]' from"gh-r" bpick"*pl" mv"cloc-* -> cloc";
zload  RobSis/zsh-completion-generator      '0b'  '[[ -n ${ZLAST_COMMANDS[(r)gcom*]}  ]]' atload'gcomp(){ \gencomp $1 && zplugin creinstall -q RobSis/zsh-completion-generator; }' pick'zsh-completion-generator.plugin.zsh'
zload  aperezdc/zsh-fzy                     '0c'  atload"bindkey '\ec' fzy-cd-widget; bindkey '^T' fzy-file-widget"
zload  donnemartin/haxor-news               '0c'  as"program" atclone="pip install -e . ;pip install -r requirements-dev.txt" atpull"%atclone"
zload  jhawthorn/fzy                        '0b'  as"program" if'[[ -z "$commands[fzy]" ]]' make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
zload  k-vernooy/tetris                     '0c'  as"program" pick"bin/tetris" make
zload  laggardkernel/git-ignore             '0c'  has'git' pick'init.zsh' atload'alias gi="git-ignore"' blockf
#zload  micha/resty                          '1'
zload  mptre/yank                           '0c'  as"program" pick"yank" make
#zload  mvdan/sh                             '0c'  from"gh-r" as"program" mv"shfmt* -> shfmt"
zload  seletskiy/zsh-fuzzy-search-and-edit  '0d'  atload"bindkey '^T' fzy-file-widget"
zload  soimort/translate-shell              '0c'  if'[[ -n "$commands[gawk]" ]]'
zload  tj/git-extras                        '0c'  as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zload  wustho/epr                           '0c'  as"program" mv"epr.py -> epr"
zload  zdharma/z-p-submods                  '0a'
zload  zdharma/zsh-diff-so-fancy            '0c'  as"program" pick"bin/git-dsf"
#zsnip  OMZ::plugins/aws                     '0c'  svn
zsnip  OMZ::plugins/extract                 '0c'  svn
zsnip  OMZ::plugins/git-extras              '0c'  svn
#zsnip  PZT::modules/fasd                    '0c'  svn submods"clvv/fasd -> external"
