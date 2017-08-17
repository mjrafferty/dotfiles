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

alias connections="lsof -n | grep -E 'httpd.*ESTABLISHED|httpd.*CLOSE_WAIT' | sed 's_.*:http.*->\(.*\):.*_\1_' | sort | uniq -c | sort -hr"

alias mountro="mount -o ro,remount /usr && mount -o ro,remount /boot && mount -o ro,remount /"
alias mountrw="mount -o rw,remount /usr; mount -o rw,remount /boot; mount -o rw,remount /"

alias sshsync="rsync -p -v --progress -e ssh -a -u -z"

alias diff=colordiff

alias dotpush="cd ~/dotfiles; git add .; git commit -a -m updates; git push; cd -;"

alias grepphp='grep -hEiv ".otf|.txt|.jpeg|.ico|.svg|.jpg|.css|.js|.gif|.png| 403 "'
