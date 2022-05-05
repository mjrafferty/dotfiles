# vim:ft=zsh

[[ -r /etc/bashrc.nexcess ]] && source /etc/bashrc.nexcess;

load_conf main

SSH_ENV="$HOME/.ssh/environment"

# Source SSH settings, if applicable
if [ -r "${SSH_ENV}" ]; then

  source "${SSH_ENV}" > /dev/null;

  # verify agent is running
  #[[ -r "/proc/${SSH_AGENT_PID}" ]] || start_agent;

else
  start_agent;
fi
