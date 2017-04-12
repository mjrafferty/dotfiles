if [ "$(id -u)" != "0" ]; then
	/usr/bin/sudo HOME=/home/nexmrafferty /bin/zsh
	exit
fi

export LANG=en_US.UTF-8

if [ -f ~/.functions.sh ]; then
	source ~/.functions.sh
fi

if [ -f ~/.aliases.sh ]; then
	source ~/.aliases.sh
fi

if [ -f ~/.environment.sh ]; then
	source ~/.environment.sh
fi

if [ -f .shell_functions ]; then
	source .shell_functions
fi
export ZSH=~/.oh-my-zsh

ZSH_THEME="matts"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

plugins=(git colored-man-pages colorize command-not-found cp extract history history-substring-search tmux redis-cli fasd zsh-syntax-highlighting zsh-autosuggestions zsh-completions)

# User configuration

export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

# Create directories for files used by vim if necessary
mkdir -p ~/.vimfiles/{backup,swp,undo}

# REMEMBER namei command
