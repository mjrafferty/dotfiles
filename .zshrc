if [ "$(id -u)" != "0" ]; then
	/usr/bin/sudo HOME=/home/nexmrafferty /bin/zsh
	exit
fi

export LANG=en_US.UTF-8

if [ -f ~/.zsh_functions ]; then
	source ~/.zsh_functions
fi

if [ -f ~/.zsh_aliases ]; then
source ~/.zsh_aliases
fi

if [ -f ~/.zsh_environment ]; then
source ~/.zsh_environment
fi

if [ -f .shell_functions ]; then
source .shell_functions 
fi
export ZSH=~/.oh-my-zsh

ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

plugins=(git colored-man-pages colorize command-not-found cp extract history history-substring-search tmux redis-cli fasd zsh-syntax-highlighting zsh-autosuggestions zsh-completions)

# User configuration

export ZSH_TMUX_AUTOSTART=true
source $ZSH/oh-my-zsh.sh
mkdir -p .vimfiles/backup
mkdir -p .vimfiles/swp
mkdir -p .vimfiles/undo

# REMEMBER namei command
