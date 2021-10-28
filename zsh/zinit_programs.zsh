# vim:ft=zsh

zload 2mol/pboy                        '0c' as"program" trigger-load"!pboy"              from"gh-r"
zload AlDanial/cloc                    '0c' as"program" trigger-load"!cloc"              from"gh-r" if'[[ -z "$commands[cloc]" ]]' bpick"*pl" mv"cloc-* -> cloc";
zload BurntSushi/ripgrep               '0c' as"program" trigger-load"!rg"                from"gh-r" mv"ripgrep-* -> ripgrep" pick"ripgrep/rg"
zload DimitarPetrov/stegify            '0c' as"program" trigger-load"!stegify"           from"gh-r" mv"stegify* -> stegify"
zload Rigellute/spotify-tui            '0c' as"program" trigger-load"!spt"               from"gh-r" bpick"*.tar.gz" pick"spt"
zload caderek/gramma                   '0c' as"program" trigger-load"!gramma"            from"gh-r"
zload charmbracelet/glow               '0c' as"program" trigger-load"!glow"              from"gh-r"
zload cjbassi/ytop                     '0c' as"program" trigger-load"!ytop"              from"gh-r"
zload cli/cli                          '0c' as"program" trigger-load"!gh"                from"gh-r" mv"gh_* gh" pick"gh/bin/gh"
zload denisidoro/navi                  '0c' as"program" trigger-load"!navi"              from"gh-r"
zload donnemartin/haxor-news           '0c' as"program" trigger-load"!haxor-news"        atclone"pip install -e . ;pip install -r requirements-dev.txt" atpull"%atclone"
zload GothenburgBitFactory/taskwarrior '0c' as"program" trigger-load"!task"              from"gh-r"
zload huntrar/nav                      '0c' as"program" trigger-load"!nav"
zload isacikgoz/gitbatch               '0c' as"program" trigger-load"!gitbatch"          from"gh-r"
zload isacikgoz/tldr                   '0c' as"program" trigger-load"!tldr"              from'gh-r'
zload jarun/bcal                       '0c' as"program" trigger-load"!bcal"              make
zload jarun/ddgr                       '0c' as"program" trigger-load"!ddgr"              make
zload jarun/googler                    '0c' as"program" trigger-load"!googler"           make
zload jarun/nnn                        '0c' as"program" trigger-load"!nnn"               make
zload jarun/pdd                        '0c' as"program" trigger-load"!pdd"
zload jhawthorn/fzy                    '0b' as"program" trigger-load"!fzy"               if'[[ -z "$commands[fzy]" ]]' make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
zload junegunn/fzf                     '0c' as"program" trigger-load"!fzf-tmux"          pick"bin/fzf-tmux"
zload junegunn/fzf-bin                 '0b' as"program" trigger-load"!fzy"               from"gh-r"
zload k-vernooy/tetris                 '0c' as"program" trigger-load"!tetris"            pick"bin/tetris" make
zload laggardkernel/git-ignore         '0c' as"program" trigger-load"!git-ignore"        has'git' pick'bin/git-ignore'
zload mfaerevaag/wd                    '0c' as"program" trigger-load"!wd"                atpull'!git reset --hard' pick'wd.sh' mv'_wd.sh -> _wd' atload'wd() { source wd.sh }; WD_CONFIG="$ZPFX/.warprc"' blockf
zload mptre/yank                       '0c' as"program" trigger-load"!yank"              pick"yank" make
zload mvdan/sh                         '0c' as"program" trigger-load"!shfmt"             from"gh-r" mv"shfmt* -> shfmt"
zload ogham/exa                        '0c' as"program" trigger-load"!exa"               from"gh-r" pick"bin/exa" mv"completions/exa.zsh -> _exa"
zload rupa/v                           '0c' as"program" trigger-load"!v"                 pick"v"
zload saitoha/libsixel                 '0c' as"program" trigger-load"!img2sixel"         atclone"./configure" make pick"converters/img2sixel"
zload sharkdp/bat                      '0c' as"program" trigger-load"!bat"               from"gh-r" mv"bat-* -> bat" pick"bat/bat"
zload sharkdp/fd                       '0c' as"program" trigger-load"!fd"                from"gh-r" mv"fd-* -> fd" pick"fd/fd"
zload sharkdp/hexyl                    '0c' as"program" trigger-load"!hexyl"             from"gh-r" mv"hexyl-* -> hexyl" pick"hexyl/hexyl"
zload sharkdp/hyperfine                '0c' as"program" trigger-load"!hyperfine"         from"gh-r" mv"hyperfine-* -> hyperfine" pick"hyperfine/hyperfine"
zload sharkdp/pastel                   '0c' as"program" trigger-load"!pastel"            from"gh-r" pick"pastel*/pastel"
zload sqshq/sampler                    '0c' as"program" trigger-load"!sampler"           from'gh-r' mv"sampler-* -> sampler"
zload tj/git-extras                    '0c' as"program" trigger-load"!git-pr"            pick"$ZPFX/bin/git-*" make"PREFIX=$ZPFX"
zload volta-cli/volta                  '0c' as"program" trigger-load"!volta"             from'gh-r' bpick"*macos.tar.gz"
zload wtfutil/wtf                      '0c' as"program" trigger-load"!wtf"               from"gh-r" pick"wtfutil"
zload wustho/epr                       '0c' as"program" trigger-load"!epr"               mv"epr.py -> epr"
zload zdharma/zsh-diff-so-fancy        '0c' as"program" trigger-load"!zsh-diff-so-fnacy" pick"bin/git-dsf"
