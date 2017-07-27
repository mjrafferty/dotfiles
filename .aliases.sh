alias r="/usr/bin/sudo HOME=$HOME /bin/zsh"

# protect myself from myself
alias rm='rm --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias ls='ls -F --color=auto'
alias less='less -i -n -S -F'

alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'

alias connections="lsof -n | grep -E 'httpd.*ESTABLISHED|httpd.*CLOSE_WAIT' | sed 's_.*:http.*->\(.*\) .*_\1_' | sort | uniq -c | sort -hr"

alias mountro="mount -o ro,remount /usr && mount -o ro,remount /boot && mount -o ro,remount /"
alias mountrw="mount -o rw,remount /usr; mount -o rw,remount /boot; mount -o rw,remount /"

alias os='echo; cat /etc/redhat-release; echo'
alias getrsync='wget updates.nexcess.net/scripts/rsync.sh; chmod +x rsync.sh'
alias omg='curl -s http://nanobots.robotzombies.net/aboutbashrc | less'
alias wtf="grep -B1 '^[a-z].*(){' /home/nexmcunningham/.bashrc | sed 's/(){.*$//' | less"
alias credits='curl -s http://nanobots.robotzombies.net/credits | less'
alias quotas='checkquota'

alias sshsync="rsync -p -v --progress -e ssh -a -u -z"

alias iworxdb="mysql -u"iworx" -p"$(grep '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)" -S $(grep '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | awk -F'[()]' '{print $2}')"
