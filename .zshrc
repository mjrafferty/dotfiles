if [ "$(id -u)" != "0" ]; then
  HM=$HOME
  /usr/bin/sudo HOME=$HM /bin/zsh
  /usr/bin/sudo find /home/nexmrafferty/ -mindepth 1 \( \
    -path "./.aliases.sh" -o \
    -path "./.bash_profile" -o \
    -path "./bin" -o \
    -path "./clients" -o \
    -path "./.commonrc" -o \
    -path "./.completions" -o \
    -path "./custom" -o \
    -path "./.environment.sh" -o \
    -path "./.functions.sh" -o \
    -path "./.mytop" -o \
    -path "./.oh-my-zsh" -o \
    -path "./*history" -o \
    -path "*.ssh" -o \
    -path "./.zcompdump*" -o \
    -path "./.vimrc" -o \
    -path "./.viminfo" -o \
    -path "./.vimfiles" -o \
    -path "./.zshrc" \) -prune -o -exec rm -rf {} + 2> /dev/null
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
