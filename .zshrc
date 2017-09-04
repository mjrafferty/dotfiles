if [ "$(id -u)" != "0" ]; then
	HM=$HOME
	/usr/bin/sudo HOME=$HM /bin/zsh
	exit
fi

source ~/.commonrc

export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets line)

ZSH_HIGHLIGHT_STYLES[line]='bold'

# Create directories for files used by vim if necessary
mkdir -p ~/.vimfiles/{backup,swp,undo}

# The following lines were added by compinstall

zstyle ':completion:*' completer _list _oldlist _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' max-errors 2 numeric
zstyle :compinstall filename '/home/nexmrafferty/.zshrc'

autoload -Uz compinit
compinit -u
# End of lines added by compinstall

if [ -f /opt/nexcess/php56u/enable ]; then
  source /opt/nexcess/php56u/enable;
fi

bindkey -v

if [ -f ~/action.sh ]; then
	source ~/action.sh;
	rm ~/action.sh;
fi
