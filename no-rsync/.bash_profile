if [ -f /etc/bashrc ]; then
        source  /etc/bashrc
fi
if [ -f /etc/bashrc.nexcess ]; then
        source /etc/bashrc.nexcess
fi
if [ -f ~/.bashrc ]; then
				source  ~/.bashrc
fi
if [ -f ~/.aliases.sh ]; then
        source ~/.aliases.sh
fi
if [ -f ~/.functions.sh ]; then
        source ~/.functions.sh
fi
if [ -f ~/.environment.sh ]; then
        source ~/.environment.sh
fi

export PATH=$PATH:~/bin

SSH_ENV="$HOME/.ssh/environment"

start_agent () {
    echo "Initialising new SSH agent...";
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}";
    echo "succeeded";
    chmod 600 "${SSH_ENV}";
    source "${SSH_ENV}" > /dev/null;
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    source "${SSH_ENV}" > /dev/null;
    ps -ef \
			| grep ${SSH_AGENT_PID} \
			| grep ssh-agent$ > /dev/null || start_agent;
else
    start_agent;
fi

me () {
        if [ -z "$1" ]; then
                echo 'No hostname/ip passed'
                return 1
        else
                echo -ne "\ek$1\e\\"
                ssh -t -i ~/.ssh/nex$(whoami).id_rsa  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no nex$(whoami)@$1
                echo -ne "\ek$(hostname)\e\\"
        fi
}

go () {
    if [ -z "$1" ]; then
        echo 'No hostname/ip passed';
        return 1;
    else
        echo -ne "\ek$1\e\\";
        if [[ -d ~/dotfiles/ ]]; then
            if [[ $(stat -c '%a' ~/dotfiles/) -ne 700 ]]; then
                chmod 700 ~/dotfiles;
            fi;
						rsync -q --chmod=o-rwx -rpt --exclude '*history' --exclude '.ssh' --exclude 'clients' --exclude '.zcompdump*' --exclude '.mytop' --exclude '.git' --exclude 'YouCompleteMe' --exclude 'no-rsync' --exclude '.vimfiles/*/.*' ~/dotfiles/ -e "ssh -q -i ${HOME}/.ssh/nex$(whoami).id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no" nex$(whoami)@$1:~/ &&
						ssh -i ~/.ssh/nex$(whoami).id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no nex$(whoami)@$1;
        echo -ne "\ek$(hostname)\e\\";
        fi;
    fi
}
