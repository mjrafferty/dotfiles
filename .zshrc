if [ "$(id -u)" != "0" ]; then
  HM=$HOME
  /usr/bin/sudo HOME=$HM /bin/zsh
  /usr/bin/sudo find /home/nexmrafferty/ -mindepth 1 \( \
    -name ".aliases.sh" -o \
    -name ".bash_profile" -o \
    -name "bin" -o \
    -name "clients" -o \
    -name ".commonrc" -o \
    -name ".completions" -o \
    -name "custom" -o \
    -name ".environment.sh" -o \
    -name ".functions.sh" -o \
    -name ".mytop" -o \
    -name ".oh-my-zsh" -o \
    -name "*history" -o \
    -name "*.ssh" -o \
    -name ".zcompdump*" -o \
    -name ".vimrc" -o \
    -name ".viminfo" -o \
    -name ".vimfiles" -o \
    -name ".zshrc" \) -prune -o -delete {} \;
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

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ”
zstyle ':completion:*' completer _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' max-errors 2 numeric
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit -u

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets line)
ZSH_HIGHLIGHT_STYLES[line]='bold'

if [ -f /opt/nexcess/php56u/enable ]; then
  source /opt/nexcess/php56u/enable;
fi

if [ -f ~/action.sh ]; then
  source ~/action.sh;
fi

# Server health check
echo;
parallel -- \
  longrunqueries \
  maxphpprocs \
  maxclients \
  memcheck \
  loadavgchk;
echo;
