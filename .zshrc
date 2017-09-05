if [ "$(id -u)" != "0" ]; then
  HM=$HOME
  /usr/bin/sudo HOME=$HM /bin/zsh
  exit
fi

if [ -f ~/.commonrc ]; then
  source ~/.commonrc
fi

export ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin:/var/qmail/bin:/usr/nexkit/bin:~/bin

# Create directories for files used by vim if necessary
mkdir -p ~/.vimfiles/{backup,swp,undo}

zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' max-errors 2 numeric
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit -u

if [ -f /opt/nexcess/php56u/enable ]; then
  source /opt/nexcess/php56u/enable;
fi

if [ -f ~/action.sh ]; then
  source ~/action.sh;
  rm ~/action.sh;
fi
