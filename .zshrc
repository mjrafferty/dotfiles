#! /bin/zsh

HISTDB_ENABLE_LOG=1

# Login as root
_autoRoot() {

  /usr/bin/sudo HOME="$HOME" SSH_TTY="$SSH_TTY" TMUX="$TMUX" /bin/zsh;

  exit;

}

# Automatically aliases sudo commands to avoid typing sudo
_sudoAlias() {

  local sudo_cmds x y

  sudo_cmds=($(sudo -l | grep -Po "\(ALL\) NOPASSWD:\K.*" | tr -d '\n|,'));

  for x in ${sudo_cmds[*]}; do

    if [[ "$x" =~ "/usr/nexkit/bin/nk" ]]; then

      for y in /usr/nexkit/bin/nk*; do

        alias "${y/*\//}"="sudo $y";

      done
    elif [[ ! "$x" =~ "^-" ]]; then

      alias "${x/*\//}"="sudo $x";

    fi
  done

}

# Used with the "u" function to pull the client's configuration into mine.
_sourceClient() {

  local userEnv userPath x;

  setopt nohistsavebycopy

  userEnv=("$(grep -Poh '^\s*source\s*\K.*' /home/"${USER}"/.bash{rc,_profile})");

  for x in ${userEnv[*]}; do
    source "$x";
  done

  userPath=("$(grep -Poh '\s*PATH=\K.*' /home/"${USER}"/.bash{rc,_profile} | sed -e "s_\$HOME_/home/${USER}_g" -e "s_\$PATH_${PATH}_g")")

  for x in ${userPath[*]}; do
    PATH="$x";
  done

  source /etc/nexcess/bash_functions.sh

}

# Basic setup to be run on shell startup
_mySetup () {

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

}

# CentOS 7 servers provide sudo access rather than full root so prepare accordingly.
_rootOrSudo() {

  local os_version

  os_version=$(grep -Po 'release \K\d' /etc/centos-release);

  # Only perform action when I'm my own user.
  if [[ $USER == "${HOME/*\//}" ]]; then

    if (( os_version == 7 )); then

      _sudoAlias;

    else

      _autoRoot;

    fi
  fi

}

# Determines whether or not shell is being started as part of the "u" function or normal startup.
_meOrClient() {

  # Check to see that I'm running as a user that's neither myself or root
  if [[ ${HOME/*\//} != "$USER" && "$USER" != "root" ]]; then

    _sourceClient;

  else

    _mySetup;

  fi

}

# Alias Support functions to remove prefix
_aliasFunctions() {

  local x

  for x in $(print -l ${(ok)functions} | grep "^sup_") ; do
    alias ${x/sup_/}="$x";
  done

}

# Main
main() {

  _rootOrSudo;

  [ -r ~/.commonrc ] && source ~/.commonrc;

  _meOrClient;

  _aliasFunctions;

  # Expand PATH
  export PATH="${PATH}:/var/qmail/bin:/usr/local/bin:/usr/local/interworx/bin"

}

main;
