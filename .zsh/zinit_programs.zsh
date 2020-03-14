zload  2mol/pboy                            '0c'  as"program" from"gh-r"
zload  AlDanial/cloc                        '0c'  as"program" from"gh-r" if'[[ -z "$commands[cloc]" ]]' bpick"*pl" mv"cloc-* -> cloc";
zload  BurntSushi/ripgrep                   '0c'  as"program" from"gh-r" mv"ripgrep-* -> ripgrep" pick"ripgrep/rg"
zload  DimitarPetrov/stegify                '0c'  as"program" from"gh-r" mv"stegify* -> stegify"
zload  Rigellute/spotify-tui                '0c'  as"program" from"gh-r" bpick"*.tar.gz" pick"spt"
zload  caderek/gramma                       '0c'  as"program" from"gh-r"
zload  charmbracelet/glow                   '0c'  as"program" from"gh-r"
zload  cjbassi/ytop                         '0c'  as"program" from"gh-r"
zload  cli/cli                              '0c'  as"program" from"gh-r" mv"gh_* gh" pick"gh/bin/gh"
zload  denisidoro/navi                      '0c'  as"program" from"gh-r"
zload  donnemartin/haxor-news               '0c'  as"program" atclone"pip install -e . ;pip install -r requirements-dev.txt" atpull"%atclone"
zload  isacikgoz/gitbatch                   '0c'  as"program" from"gh-r"
zload  isacikgoz/tldr                       '0c'  as'program' from'gh-r'
zload  jallbrit/bonsai.sh                   '0c'  as"program" from"gitlab" mv"bonsai.sh -> bonsai" pick "bonsai"
zload  jarun/bcal                           '0c'  as"program" make
zload  jarun/ddgr                           '0c'  as"program" make
zload  jarun/googler                        '0c'  as"program" make
zload  jarun/nnn                            '0c'  as"program" make
zload  jarun/pdd                            '0c'  as"program"
zload  jhawthorn/fzy                        '0b'  as"program" if'[[ -z "$commands[fzy]" ]]' make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
zload  junegunn/fzf                         '0c'  as"program" pick"bin/fzf-tmux"
zload  junegunn/fzf-bin                     '0b'  as"program" from"gh-r"
zload  k-vernooy/tetris                     '0c'  as"program" pick"bin/tetris" make
zload  mfaerevaag/wd                        '0c'  as'program' atpull'!git reset --hard' pick'wd.sh' mv'_wd.sh -> _wd' atload'wd() { source wd.sh }; WD_CONFIG="$ZPFX/.warprc"' blockf
zload  mptre/yank                           '0c'  as"program" pick"yank" make
zload  mvdan/sh                             '0c'  as"program" from"gh-r" mv"shfmt* -> shfmt"
zload  ogham/exa                            '0c'  as"program" from"gh-r" mv"exa-* -> exa"
zload  rupa/v                               '0c'  as"program" pick"v"
unset AWK
zload  saitoha/libsixel                     '0c'  as"program" atclone"./configure" make pick"converters/img2sixel"
zload  sharkdp/bat                          '0c'  as"program" from"gh-r" mv"bat-* -> bat" pick"bat/bat"
zload  sharkdp/fd                           '0c'  as"program" from"gh-r" mv"fd-* -> fd" pick"fd/fd"
zload  sharkdp/hexyl                        '0c'  as"program" from"gh-r" mv"hexyl-* -> hexyl" pick"hexyl/hexyl"
zload  sharkdp/hyperfine                    '0c'  as"program" from"gh-r" mv"hyperfine-* -> hyperfine" pick"hyperfine/hyperfine"
zload  sharkdp/pastel                       '0c'  as"program" from"gh-r" pick"pastel*/pastel"
zload  sqshq/sampler                        '0c'  as"program" from'gh-r' mv"sampler-* -> sampler"
zload  tj/git-extras                        '0c'  as"program" pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zload  wtfutil/wtf                          '0c'  as"program" from"gh-r" pick"wtfutil"
zload  wustho/epr                           '0c'  as"program" mv"epr.py -> epr"
zload  zdharma/zsh-diff-so-fancy            '0c'  as"program" pick"bin/git-dsf"
