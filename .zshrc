if [ "$(id -u)" != "0" ]; then
	HM=$HOME
	/usr/bin/sudo HOME=$HM /bin/zsh
	/usr/bin/sudo /bin/find /home/nexmrafferty/ -mindepth 1 \( -name "*history" -o -name ".mytop" -o -name "*.ssh" -o -name ".zcompdump*" -o -name "clients" \) -prune -o -exec rm -rf {} \;
	exit
fi

source ~/.commonrc

export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

# Create directories for files used by vim if necessary
mkdir -p ~/.vimfiles/{backup,swp,undo}
