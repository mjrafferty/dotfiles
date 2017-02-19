#alias shopt=':'
#source .bashrc

###############################

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git colored-man-pages colorize command-not-found cp extract history history-substring-search tmux fasd)

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias r="/usr/bin/sudo HOME=/home/nexmrafferty/ /bin/zsh"

export PATH=$PATH:/usr/local/sbin:/sbin:/usr/sbin:/var/qmail/bin:/usr/nexkit/bin
export GREP_OPTIONS='--color=auto'
export PAGER=/usr/bin/less

# formatted at 2000-03-14 03:14:15
export HISTTIMEFORMAT="%F %T "

export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

if [ -f /etc/nexcess/bash_functions.sh ]; then
	. /etc/nexcess/bash_functions.sh
fi

# protect myself from myself
alias rm='rm --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias ls='ls -F --color=auto'

function resellers {
( nodeworx -u -n -c Siteworx -a listAccounts | sed 's/ /_/g' | awk '{print $5,$2,$10,$9}';
  nodeworx -u -n -c Reseller -a listResellers | sed 's/ /_/g' | awk '{print $1,"0Reseller",$3, $2}')\
	  | sort -n | column -t | sed 's/\(.*0Re.*\)/\n\1/'  > /tmp/rslr ;
		cat /tmp/rslr | while read line; do awk '{if ($2 == "0Reseller") print "Reseller: " $3, "( "$4" )"; else if ($3 == "master") print ($2,$4); else print ($2,$3);}'; done | sed 's/_/ /g';
}

whichsoft () {
	md5sum /usr/sbin/r1soft/conf/server.allow/* | grep $(md5sum /usr/sbin/r1soft/conf/server.allow/$(grep AUTH /usr/sbin/r1soft/log/cdp.log | grep allow | tail -n1 | grep -Po '(?<=\[)[\d\.]{7,15}(?=:\d+\])') | cut -f1 -d' ') | awk -F'/' '{print $NF}' | xargs -rn1 host -W5 | awk '/name pointer/{sub(/\.$/,"",$NF); printf "https://%s:8001/\n",$NF}'
}

quotacheck () {
	echo; for _user_ in $(grep -E ":/home/[^\:]+:" /etc/passwd | cut -d\: -f1); do echo -n $_user_; quota -g $_user_ 2>/dev/null| perl -pe 's,\*,,g' | tail -n+3 | awk '{print " "$2/$3*100,$2/1000/1024,$3/1024/1000}'; echo; done | grep '\.' | sort -grk2 | awk 'BEGIN{printf "%-15s %-10s %-10s %-10s\n","User","% Used","Used (G)","Total (G)"; for (x=1; x<50; x++) {printf "-"}; printf "\n"} {printf "%-15s %-10.2f %-10.2f %-10.2f\n",$1,$2,$3,$4}'; echo
}

updatequota () {
	if (( $# < 2 )); then
    	echo -e "Must provide two arguments\n\nUsage: nwupdatequota \$master_domain \$new_quota\n\n";
    	return;
    	elif (( $# > 2)); then
    	echo -e "Too many arguments\n\nUsage: nwupdatequota \$master_domain \$new_quota\n\n";
    	return;
	fi
	local master_domain=$1;
	local new_disk_quota=$2;
	nodeworx -u -n -c Siteworx -a edit --OPT_STORAGE $new_disk_quota --domain $master_domain;
}

whodunit () {
	echo -e "\n\n"; find /home/*/var/*/logs/ -name transfer.log -exec awk -v date="$(date +%d/%b/%Y:%H)" -v SUM=0 '$0 ~ date {SUM+=1} END{print "{} " SUM}' {} \; | grep -v :0 |grep -ve "\b0\b" | sort -nr -k 2 |awk 'BEGIN{print "\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2}'; echo -e "\n\n"
}

ttfb () {
				curl -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" -s $1;
}

topips () {
	zless  $* | awk '{freq[$1]++} END {for (x in freq) {print freq[x], x}}' | sort -rn | head -20;
}

topuseragents () {
	zless  $* | cut -d\  -f12- | sort | uniq -c | sort -rn | head -20;
}

ipsbymb () {
	zless  $* | awk '{tx[$1]+=$10} END {for (x in tx) {print x, "\t", tx[x]/1048576, "M"}}' | sort -k 2n | tail -n 20 | tac; 
}

function sshpass() {
	mkpasswd -l 15 -d 3 -C 5 -s 0 $1;
 	nksshd userControl --reset-failures $1;
}

function hitsperhour () {
	for x in $(seq -w 0 23); do echo -n "$x  "; grep -c "$(date +%d/%b/%Y:)$x" $*; done; 
}

function modsecrules () {
	modgrep -s $1 -f /var/log/httpd/modsec_audit.log | grep "id " | grep -aEho "9[5-8][0-9]{4}" | sort | uniq | grep -v 981176;
}

function backup () {
	tar -czvf $1.bak.tar.gz $1;
}

function blacklistcheck () {
	for b in $1; do echo '++++++++++++++++++++++++++++'; echo $b;echo 'PHONE: 866-639-2377';  nslookup $b | grep addr;echo 'http://multirbl.valli.org/lookup/'$b'.html';echo 'http://www.senderbase.org/lookup/ip/?search_string='$b; echo 'https://www.senderscore.org/lookup.php?lookup='$b;echo '++++++++++++++++++++++++++++'; for x in hotmail.com yahoo.com aol.com earthlink.net verizon.net att.net sbcglobal.net comcast.net xmission.com cloudmark.com cox.net charter.net mac.me; do echo; echo $x;echo '--------------------'; swaks -q TO -t postmaster@$x -li $b| grep -iE 'block|rdns|550|521|554';done ;echo; echo 'gmail.com';echo '-----------------------'; swaks -4 -t iflcars.com@gmail.com -li $b| grep -iE 'block|rdns|550|521|554';echo; echo; done;
}
