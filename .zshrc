#! /bin/zsh

export OS_VERSION=$(grep -Po 'release \K\d' /etc/centos-release);

# No root access on centos7 servers, so set sudo aliases instead.
if (( $OS_VERSION == 7 )); then

  if [[ $USER == "${HOME/*\//}" ]]; then

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

  if [[ "$USER" == "${HOME/*\//}" ]] ; then

    # Auto switch to root on login for centos6 servers
    /usr/bin/sudo HOME="$HOME" SSH_TTY="$SSH_TTY" TMUX="$TMUX" /bin/zsh

    exit;

  fi
fi

# Load main configuration
[ -r ~/.commonrc ] && source ~/.commonrc;

# Used in combination with the "u" function to pull in the user's environment
if [[ ${HOME/*\//} != "$USER" && "$USER" != "root" ]]; then

  setopt nohistsavebycopy

  userEnv=("$(grep -Poh '^\s*source\s*\K.*' /home/${USER}/.bash{rc,_profile})");

  for x in ${userEnv[*]}; do
    source "$x";
  done

  userPath=("$(grep -Poh '\s*PATH=\K.*' /home/${USER}/.bash{rc,_profile} | sed -e "s_\$HOME_/home/${USER}_g" -e "s_\$PATH_${PATH}_g")")

  for x in ${userPath[*]}; do
    PATH="$x";
  done

else

  # Expand PATH
  PATH="$PATH":/var/qmail/bin

  # Create directories for files used by vim if necessary
  mkdir -p ~/.vimfiles/{backup,swp,undo}

  # Source environment variables provided by login script
  [ -r ~/.environment.sh ] && source ~/.environment.sh;

  # Create directory for preserving client/ticket data
  mkdir -p "$HOME"/clients/"$TICKET";
  export TICKETDIR="${HOME}/clients/${TICKET}";

  # Source actions provided by login script
  [ -r ~/action.sh ] && source ~/action.sh;

  # Server health check
  serverhealth;

fi
