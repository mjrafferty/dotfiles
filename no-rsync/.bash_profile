#! /bin/bash
[ -r /etc/bashrc ] && source  /etc/bashrc
[ -r /etc/bashrc.nexcess ] && source /etc/bashrc.nexcess
[ -r ~/.bashrc ] && source  ~/.bashrc
[ -r ~/.aliases.sh ] && source ~/.aliases.sh
[ -r ~/.functions.sh ] && source ~/.functions.sh
[ -r ~/.environment.sh ] && source ~/.environment.sh

export PATH=$PATH:~/bin

SSH_ENV="$HOME/.ssh/environment"

start_agent () {
  echo "Initialising new SSH agent...";
  /usr/bin/ssh-agent -t 43200 | sed 's/^echo/#echo/' > "${SSH_ENV}";
  echo "succeeded";
  chmod 600 "${SSH_ENV}";
  source "${SSH_ENV}" > /dev/null;
  /usr/bin/ssh-add ~/.ssh/nexmrafferty.id_rsa;
}

# Source SSH settings, if applicable
if [ -r "${SSH_ENV}" ]; then
  source "${SSH_ENV}" > /dev/null;

  # verify agent is running
  pgrep -u $UID | grep "^$SSH_AGENT_PID" > /dev/null || start_agent;
else
  start_agent;
fi

me () {
  if [ -z "$1" ]; then
    echo 'No hostname/ip passed'
    return 1
  else
    echo -ne "\ek$1\e\\"
    ssh -t -i ~/.ssh/nex"$(whoami)".id_rsa \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no \
      -o PasswordAuthentication=no nex"$(whoami)"@"$1"
    echo -ne "\ek$(hostname)\e\\"
  fi
}
