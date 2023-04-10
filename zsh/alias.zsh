# vim:ft=zsh

alias r="/usr/bin/sudo HOME=$HOME $SHELL"

## preserve-root ##
alias rm='rm --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

## nocorrect ##
alias cd='nocorrect cd'
alias cp='nocorrect cp'
alias ebuild='nocorrect ebuild'
alias ln='nocorrect ln'
alias mkdir='nocorrect mkdir -p'
alias mv='nocorrect mv'
alias mysql='nocorrect mysql'
alias sudo='nocorrect sudo'

## noglob ##
alias locate='noglob locate'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'

alias ls='ls -F --color=auto'
alias less='less -inSFR'

alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'

alias mountro="mount -o ro,remount /usr && mount -o ro,remount /boot && mount -o ro,remount /"
alias mountrw="mount -o rw,remount /usr; mount -o rw,remount /boot/efi; mount -o rw,remount /;mount -o rw,remount /opt"

if [[ -x "/usr/bin/colordiff" ]]; then
  alias diff="/usr/bin/colordiff"
fi

alias login='ssh login01'

alias connections="netstat -an | grep -Po '([0-9]{1,3}\.){3}[0-9]{1,3}(?=:\d+\s+[A-Z,_]+\s*$)' | sort | uniq -c | sort -hr"
alias sshsync="rsync -p -v --progress -e ssh -a -u -z"
alias grepphp="grep -Phiav '\] \"\S* (.*(/static/|(\.(otf|txt|jpeg|ico|svg|jpg|css|js|gif|png|woff|ttf))).*\" (200|304) |\" 403 )'"

alias disks="df -h | grep -v tmpfs | grep -Ev '^(dev|run)'"

alias  ..='cd ..'
alias  ...='cd ../..'
alias  ....='cd ../../..'
alias  .....='cd ../../../..'
alias  ......='cd ../../../../..'

alias 1='cd +1'
alias 2='cd +2'
alias 3='cd +3'
alias 4='cd +4'
alias 5='cd +5'
alias 6='cd +6'
alias 7='cd +7'
alias 8='cd +8'
alias 9='cd +9'
alias d='dirs -v'

alias l='ls -1A'
alias la='ll -A'
alias lc='lt -c'
alias lk='ll -Sr'
alias ll='ls -lh'
alias lm="la | $PAGER"
alias lr='ll -R'
alias ls='ls -F --color=auto'
alias lt='ll -tr'
alias lu='lt -u'
alias lx='ll -XB'

alias http-serve='python3 -m http.server'
alias sa='alias | grep -i'

alias o=xdg-open
alias pbc=pbcopy
alias pbp=pbpaste

alias checksums="equery --no-pipe check --only-failures '*'"

alias runpuppet="/opt/puppetlabs/bin/puppet agent --config /etc/puppetlabs/puppet/puppet.conf --onetime --no-daemonize --show_diff --logdest /var/log/puppet/agent.log"
alias suvim='sudo XDG_CACHE_HOME="${XDG_CACHE_HOME}" HOME="${HOME}" VIMINIT="${VIMINIT}" VIM_DATA_DIR="${VIM_DATA_DIR}" VIM_DIR="${VIM_DIR}" /usr/local/bin/vim'
