export OS_VERSION=$(grep -Po 'release \K\d' /etc/centos-release);

# Fixes error when sharing history file among several users
setopt nohistsavebycopy

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

    # Auto switch to root on login
    /usr/bin/sudo HOME=$HOME SSH_TTY=$SSH_TTY /bin/zsh

    # Cleanup home folder on logout
    /usr/bin/sudo find "$HOME"/ -mindepth 1 \( \
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

# Load main configuration
[ -r ~/.commonrc ] && source ~/.commonrc;

if [[ ${HOME/*\//} != "$USER" && "$USER" != "root" ]]; then

	userEnv=("$(grep -Poh '^\s*source\s*\K.*' /home/${USER}/.bash{rc,_profile})");

  for x in ${userEnv[*]}; do
    source "$x";
  done

  userPath=("$(grep -Poh '\s*PATH=\K.*' /home/${USER}/.bash{rc,_profile} | sed -e "s_\$HOME_/home/${USER}_g" -e "s_\$PATH_${PATH}_g")")

  for x in ${userPath[*]}; do
    PATH="$x";
  done

  export PATH;

else

	# Create directories for files used by vim if necessary
	mkdir -p ~/.vimfiles/{backup,swp,undo}

	[ -r ~/environment.sh ] && source ~/.environment.sh;

	mkdir -p "$HOME"/clients/"$TICKET";
	export TICKETDIR="${HOME}/clients/${TICKET}";

	[ -r ~/action.sh ] && source ~/action.sh;

	# Server health check
	serverhealth;

fi
