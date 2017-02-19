# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Source nexcess functions
if [ -f /etc/nexcess/bash_functions.sh ]; then
	. /etc/nexcess/bash_functions.sh
fi

export PATH=$PATH:/usr/local/sbin:/sbin:/usr/sbin:/var/qmail/bin:/usr/nexkit/bin
export GREP_OPTIONS='--color=auto'
export PAGER=/usr/bin/less

# formatted at 2000-03-14 03:14:15
export HISTTIMEFORMAT="%F %T "

export EDITOR=/usr/bin/nano
export VISUAL=/usr/bin/nano

# protect myself from myself
alias rm='rm --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# With -F, on listings append the following
#    '*' for executable regular files
#    '/' for directories
#    '@' for symbolic links
#    '|' for FIFOs
#    '=' for sockets        
alias ls='ls -F --color=auto'

# only append to bash history to prevent it from overwriting it when you have
# multiple ssh windows open 
shopt -s histappend
# save all lines of a multiple-line command in the same history entry
shopt -s cmdhist
# correct minor errors in the spelling of a directory component
shopt -s cdspell
# check the window size after each command and, if necessary, updates the values of LINES and COLUMNS
shopt -s checkwinsize


txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
txtrst='\[\e[0m\]'    # Text Reset

if [ $UID = 0 ]; then
    # nexkit bash completion
    if [ -e '/etc/bash_completion.d/nexkit' ]; then
	source /etc/bash_completion.d/nexkit
    fi
    PS1="[${txtcyn}\$(date +%H%M)${txtrst}][${bldred}\u${txtrst}@\h \W]\$ "
else
    PS1="[${txtcyn}\$(date +%H%M)${txtrst}][\u@\h \W]\$ "
fi
