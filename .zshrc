export OS_VERSION=$(grep -Po 'release \K\d' /etc/centos-release);

[[ -z $ME ]] && export ME=$USER

if (( $OS_VERSION == 7 )); then

  if [[ $USER == $ME ]]; then

    ##### Set alias for all sudo commands to eliminate typing sudo #####
    sudo_cmds=($(sudo -l | grep -Po "\(ALL\) NOPASSWD:\K.*" | tr -d '\n|,'));

    for x in ${sudo_cmds[*]}; do

      if [[ "$x" =~ "/usr/nexkit/bin/nk" ]]; then

        for y in /usr/nexkit/bin/nk*; do

          alias "${y/*\//}"="sudo $y";

        done
      else

        alias "${x/*\//}"="sudo $x";

      fi
    done

    ######################################################################
  fi

else

  if [[ "$UID" != "0" ]] ; then

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
      -path "*/.zlogin*" -o \
      -path "*/.zpr*" -o \
      -path "*/.vim*" -o \
      -path "*/.zshrc" \) -prune -o -exec rm -rf {} + 2> /dev/null;

    exit;

  fi

  [ -r /opt/nexcess/php56u/enable ] && source /opt/nexcess/php56u/enable;

fi

[ -r ~/.commonrc ] && source ~/.commonrc;

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin:/var/qmail/bin:/usr/nexkit/bin:~/bin

# Create directories for files used by vim if necessary
mkdir -p ~/.vimfiles/{backup,swp,undo}

[ -r ~/environment.sh ] && source ~/.environment.sh;

mkdir -p "$HOME"/clients/"$TICKET";
export TICKETDIR="${HOME}/clients/${TICKET}";

[ -r ~/action.sh ] && source ~/action.sh;

# Server health check
serverhealth;
