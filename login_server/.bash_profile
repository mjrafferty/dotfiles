if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

go ()
{
    if [ -z "$1" ]; then
        echo 'No hostname/ip passed';
        return 1;
    else
        echo -ne "\ek$1\e\\";
        if [[ -d ~/dotfiles/ ]]; then
            if [[ $(stat -c '%a' ~/dotfiles/) -ne 700 ]]; then
                chmod 700 ~/dotfiles;
            fi;
						rsync -q --chmod=o-rwx -rpt --exclude .git/ ~/dotfiles/ -e "ssh -q -i ${HOME}/.ssh/nex$(whoami).id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no" nex$(whoami)@$1:~/ && ssh -i ~/.ssh/nex$(whoami).id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no nex$(whoami)@$1;
        echo -ne "\ek$(hostname)\e\\";
        fi;
    fi
}
