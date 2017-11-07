if [ "$(id -u)" != "0" ]; then

  /usr/bin/sudo HOME=$HOME SSH_TTY=$SSH_TTY /bin/zsh

  /usr/bin/sudo find /home/nexmrafferty/ -mindepth 1 \( \
    -path "*/.bash_profile" -o \
    -path "*/bin" -o \
    -path "*/clients" -o \
    -path "*/.commonrc" -o \
    -path "*/.completions" -o \
    -path "*/.functions.sh" -o \
    -path "*/.mytop" -o \
    -path "*/*history" -o \
    -path "*/*SNAPS*" -o \
    -path "*/.ssh" -o \
    -path "*/.zcomp*" -o \
    -path "*/.zlogin*" -o \
    -path "*/.zpr*" -o \
    -path "*/.vim*" -o \
    -path "*/.zshrc" \) -prune -o -exec rm -rf {} + 2> /dev/null;

  exit;

fi

[ -r ~/.commonrc ] && source ~/.commonrc;

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin:/var/qmail/bin:/usr/nexkit/bin:~/bin

# Create directories for files used by vim if necessary
mkdir -p ~/.vimfiles/{backup,swp,undo}

[ -r /opt/nexcess/php56u/enable ] && source /opt/nexcess/php56u/enable;

[ -r ~/action.sh ] && source ~/action.sh;

# Server health check
serverhealth;
