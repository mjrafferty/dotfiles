# vim:ft=zsh

ZHIST_ENABLE_LOG=1

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

  userEnv=($(grep -Poh '^\s*source\s*\K.*' /home/"${USER}"/.bash{rc,_profile}));

  for x in "${userEnv[@]}"; do
    source "$x";
  done

  userPath=($(grep -Poh '\s*(export)?\s*PATH=\K.*' /home/"${USER}"/.bash{rc,_profile} | sed -e "s_\$HOME_/home/${USER}_g"))

  for x in "${userPath[@]}"; do
    PATH="${x/\$PATH/$PATH}";
  done

  source /etc/nexcess/bash_functions.sh

}

# Basic setup to be run on shell startup
_mySetup () {

  # Create directory for preserving client/ticket data
  export TICKETDIR="${HOME}/clients/${TICKET}";
  mkdir -p "${TICKETDIR}";

  [[ -r /etc/nexcess/server_notes.txt ]] && cat /etc/nexcess/server_notes.txt;

  # Source actions provided by login script
  [ -r ~/action.sh ] && source ~/action.sh;

  # Server health check
  serverhealth;

}

# CentOS 7 servers provide sudo access rather than full root so prepare accordingly.
_rootOrSudo() {

  local os_version

  os_version=$(grep -Po 'release \K\d' /etc/centos-release);

  # Only perform action when Im my own user.
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

  # Check to see that Im running as a user thats neither myself or root
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

_isLastShell() {

  local this_pid parent_pid other_shells;

  this_pid="$$"
  parent_pid="$(ps -o ppid "$this_pid" | grep -o '[0-9]*')"

  other_shells="$(pgrep -P "${parent_pid}" | grep -v "$this_pid")"

  if [[ $USER == "${HOME/*\//}" || $USER == "root"  ]]; then
    if [[ -z "$other_shells" ]]; then
      return 0;
    else
      return 1
    fi
  else
    return 1;
  fi

}

_logout () {

  if _isLastShell; then

    cd "$HOME" || return 1;

    # Cleanup home folder on logout
    find . -mindepth 1 \( \
      -path "./*history" -o \
      -path "./.bash_profile" -o \
      -path "./.local" -o \
      -path "./.my.cnf" -o \
      -path "./.mytop" -o \
      -path "./.ssh" -o \
      -path "./.tmux.conf" -o \
      -path "./.zshenv" -o \
      -path "./SNAPS*" -o \
      -path "./bin" -o \
      -path "./clients" -o \
      -path "./vim" -o \
      -path "./zsh" \
      \) -prune -o -exec rm -rf {} + 2> /dev/null;

  fi

}

# Main
main() {

  unfunction main

  # Source environment variables provided by login script
  [ -r ~/.environment.sh ] && source ~/.environment.sh;

  _rootOrSudo;

  load_conf main

  zstyle ':apollo:*:core:modules:left' modules 'git' 'virtualenv' 'quota' 'newline' 'root_indicator' 'context' 'vi_mode' 'dir' 'ruler'
  zstyle ':apollo:*:core:modules:right' modules 'background_jobs' 'command_execution_time' 'public_ip' 'newline' 'clock' 'date' 'newline' 'status' 'php_version' 

  _meOrClient;

  _aliasFunctions;

  # Expand PATH
  export PATH="${PATH}:/var/qmail/bin:/usr/local/bin:/usr/local/interworx/bin"

  autoload -Uz add-zsh-hook \
    && add-zsh-hook zshexit _logout;

  unfunction _aliasFunctions _autoRoot _meOrClient _mySetup _rootOrSudo _sourceClient _sudoAlias

}

main;
