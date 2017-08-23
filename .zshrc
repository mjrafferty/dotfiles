if [ "$(id -u)" != "0" ]; then
	HM=$HOME
	/usr/bin/sudo HOME=$HM /bin/zsh
	exit
fi

source ~/.commonrc

export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

# Create directories for files used by vim if necessary
mkdir -p ~/.vimfiles/{backup,swp,undo}

if [ -f ~/action.sh ]; then
	source ~/action.sh;
	rm ~/action.sh;
fi
