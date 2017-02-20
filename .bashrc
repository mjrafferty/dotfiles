# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Source nexcess functions
if [ -f /etc/nexcess/bash_functions.sh ]; then
	. /etc/nexcess/bash_functions.sh
fi

if [ $UID = 0 ]; then
    # nexkit bash completion
    if [ -e '/etc/bash_completion.d/nexkit' ]; then
	source /etc/bash_completion.d/nexkit
    fi
fi

ln -sf .zsh_history .bash_history
zsh
exit
