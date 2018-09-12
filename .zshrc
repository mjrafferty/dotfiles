#! /bin/zsh

_autoRoot() {

  /usr/bin/sudo HOME="$HOME" SSH_TTY="$SSH_TTY" TMUX="$TMUX" /bin/zsh;

  exit;

}

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

}

_mySetup () {

  # Expand PATH
  export PATH="$PATH":/var/qmail/bin

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

_rootOrSudo() {

  local os_version

  os_version=$(grep -Po 'release \K\d' /etc/centos-release);

  if (( os_version == 7 )); then

    if [[ $USER == "${HOME/*\//}" ]]; then

      _sudoAlias;

    fi

  else

    if [[ "$USER" == "${HOME/*\//}" ]] ; then

      _autoRoot;

    fi
  fi

}

_meOrClient() {

  if [[ ${HOME/*\//} != "$USER" && "$USER" != "root" ]]; then

    _sourceClient;

  else

    _mySetup;

  fi

}

# Main
main() {

  _rootOrSudo;

  [ -r ~/.commonrc ] && source ~/.commonrc;

  _meOrClient;

}

main;
