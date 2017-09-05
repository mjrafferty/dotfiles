export PAGER=/usr/bin/less

# formatted at 2000-03-14 03:14:15
export HISTTIMEFORMAT="%F %T "

export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

compctl -W '-h --help -u --user -p --pass -l' htpasswdauth
compctl -W '-h --help -a --all -l --large -u --user' checkquota
compctl -W '-d -e -f -h --list -m -n -p -r -s -x' iworxcredz
compctl -F _whitelist whitelist;
compctl -W 'ftp php mysql http ssh cron all -h --help' logs
compctl -W 'sub rec send sdom radd rdom ladd ldom -h --help' qmq
compctl -W 'send smtp smtp2 pop3 pop3-ssl imap4 imap4-ssl' q
