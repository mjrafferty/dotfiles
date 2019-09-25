#! /bin/bash

[[  -z  $AWK         ]]  &&  export readonly  AWK='/bin/awk'
[[  -z  $CHECKQUOTA  ]]  &&  export readonly  CHECKQUOTA="$HOME/bin/checkquota"
[[  -z  $CHKCONFIG   ]]  &&  export readonly  CHKCONFIG='/sbin/chkconfig'
[[  -z  $CHOWN       ]]  &&  export readonly  CHOWN='/bin/chown'
[[  -z  $COLUMN      ]]  &&  export readonly  COLUMN='/usr/bin/column'
[[  -z  $CP          ]]  &&  export readonly  CP='/bin/cp'
[[  -z  $CURL        ]]  &&  export readonly  CURL='/usr/bin/curl'
[[  -z  $CUT         ]]  &&  export readonly  CUT='/bin/cut'
[[  -z  $DATE        ]]  &&  export readonly  DATE='/bin/date'
[[  -z  $DIG         ]]  &&  export readonly  DIG='/usr/bin/dig'
[[  -z  $FIND        ]]  &&  export readonly  FIND='/bin/find'
[[  -z  $GETUSR      ]]  &&  export readonly  GETUSR="$HOME/bin/getusr"
[[  -z  $GREP        ]]  &&  export readonly  GREP='/bin/grep'
[[  -z  $HEAD        ]]  &&  export readonly  HEAD='/usr/bin/head'
[[  -z  $IP          ]]  &&  export readonly  IP='/sbin/ip'
[[  -z  $LN          ]]  &&  export readonly  LN='/bin/ln'
[[  -z  $LS          ]]  &&  export readonly  LS='/bin/ls'
[[  -z  $MYSQL       ]]  &&  export readonly  MYSQL='/usr/bin/mysql'
[[  -z  $NODEWORX    ]]  &&  export readonly  NODEWORX='/usr/bin/nodeworx'
[[  -z  $NSLOOKUP    ]]  &&  export readonly  NSLOOKUP='/usr/bin/nslookup'
[[  -z  $PS          ]]  &&  export readonly  PS='/bin/ps'
[[  -z  $READLINK    ]]  &&  export readonly  READLINK='/bin/readlink'
[[  -z  $SED         ]]  &&  export readonly  SED='/bin/sed'
[[  -z  $SETFACL     ]]  &&  export readonly  SETFACL='/usr/bin/setfacl'
[[  -z  $SORT        ]]  &&  export readonly  SORT='/bin/sort'
[[  -z  $STATT       ]]  &&  export readonly  STATT='/usr/bin/stat'
[[  -z  $SUDO        ]]  &&  export readonly  SUDO='/usr/bin/sudo'
[[  -z  $SWAKS       ]]  &&  export readonly  SWAKS='/usr/bin/swaks'
[[  -z  $TOUCH       ]]  &&  export readonly  TOUCH='/bin/touch'
[[  -z  $TR          ]]  &&  export readonly  TR='/usr/bin/tr'
[[  -z  $UNIQ        ]]  &&  export readonly  UNIQ='/usr/bin/uniq'
[[  -z  $XARGS       ]]  &&  export readonly  XARGS='/usr/bin/xargs'
# shellcheck disable=SC2155
[[  -z  $MYSHELL     ]]  &&  export readonly  MYSHELL="$("$READLINK" /proc/$$/exe)"

if [[ "$MYSHELL" =~ zsh ]]; then
  ARRAY_START="1";
else
  ARRAY_START="0";
fi

##### Disk Usage ######

## Adjust user quota on the fly using $NODEWORX CLI
bumpquota(){

  local newQuota primaryDomain;

  if [[ -z "$*" || $1 == "*-h" ]]; then
    echo -e "\n Usage: bumpquota <username> <newquota>\n  Note: <username> can be '.' to get user from PWD\n";
    return 0;
  elif [[ $1 == "^[a-z].*$" ]]; then
    U=$1;
    shift;
  elif [[ $1 == '.' ]]; then
    U=$($GETUSR);
    shift;
  fi

  newQuota=$1;
  primaryDomain=$(~iworx/bin/listaccounts.pex | $GREP "$U" | $AWK '{print $2}')

  $NODEWORX -u -n -c Siteworx -a edit --domain "$primaryDomain" --OPT_STORAGE "$newQuota" \
    && echo -e "\nDisk Quota for $U has been set to $newQuota MB\n";

  $CHECKQUOTA -u "$U";
}


#### Special Databases ########

# Connect to the iworx database
iworxdb () {

  local user pass database socket;

  user="iworx";
  pass="$($GREP '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | $CUT -d: -f3 | $CUT -d\@ -f1)";
  database="iworx";
  socket="$($GREP '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | $AWK -F'[()]' '{print $2}')";

  $MYSQL -u"$user" -p"$pass" -S"$socket" -D"$database";
}

# Vpopmail
vpopdb () {

  local user pass database socket;

  user="iworx_vpopmail"
  pass="$($GREP -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | $CUT -d: -f3 | $CUT -d\@ -f1)"
  database="iworx_vpopmail";
  socket="$($GREP -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | $AWK -F'[()]' '{print $2}')";

  $MYSQL -u"$user" -p"$pass" -S"$socket" -D"$database" "$@";
}

# ProFTPd
ftpdb () {

  local user pass database socket;

  user="iworx_ftp"
  pass="$($GREP -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1 | $CUT -d: -f3 | $CUT -d\@ -f1)"
  database="iworx_ftp";
  socket="$($GREP -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1| $AWK -F'[()]' '{print $2}')";

  $MYSQL -u"$user" -p"$pass" -S"$socket" -D"$database" "$@";
}

# Spam Assassin DB
spamdb () {

  local user pass database socket;

  user="iworx_spam"
  pass="$($GREP bayes_sql_password /etc/mail/spamassassin/local.cf| $AWK '{print $2}')"
  database="iworx_spam";
  socket="$($GREP 'user_scores_dsn' /etc/mail/spamassassin/local.cf | $SED -n 's|.*mysql_socket=\(.*\)|\1|p')";

  $MYSQL -u"$user" -p"$pass" -S"$socket" -D"$database" "$@";
}


###### ip addresses ##########

## List server ips, and all domains configured on them.
domainips () {
  local D;
  echo;
  for I in $($IP addr show | $AWK '/inet / {print $2}' | $CUT -d/ -f1 | $GREP -Ev '^127\.'); do
    printf "  ${BRIGHT}${YELLOW}%-15s${NORMAL}  " "$I";
    D=$($GREP -l "$I" /etc/httpd/conf.d/vhost_[^0]*.conf | $CUT -d_ -f2 | $SED 's/.conf$//');
    for x in $D; do
      printf "%s " "$x";
    done;
    echo;
  done;
  echo
}

## find ips that are not configured in any vhost files
freeips () {
  echo;
  for x in $($IP addr show | $AWK '/inet / {print $2}' | $CUT -d/ -f1 | $GREP -Ev '^127\.|^10\.|^172\.'); do
    printf "\n%-15s " "$x";
    $GREP -l "$x" /etc/httpd/conf.d/vhost_[^0]*.conf 2> /dev/null;
  done \
    | $GREP -v \.conf$ \
    | $COLUMN -t;
  echo
}

## Add an ip to a Siteworx account
addip () {
  $NODEWORX -u -n -c Siteworx -a addip --domain "$(~iworx/bin/listaccounts.pex | $AWK "/$($GETUSR)/"'{print $2}')" --ipv4 "$1";
}

# Check several email blacklists for the given ip
blacklistcheck () {

  ip="$1";

  if [[ -z $ip ]]; then
    ip="$(ifconfig | grep -Po '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)"
	fi

	echo '++++++++++++++++++++++++++++';
	echo "$ip";
	echo 'PHONE: 866-639-2377';
	$NSLOOKUP "$ip" \
		| $GREP addr;
	echo 'http://multirbl.valli.org/lookup/'"$ip"'.html';
	echo 'http://www.senderbase.org/lookup/ip/?search_string='"$ip";
	echo 'https://www.senderscore.org/lookup.php?lookup='"$ip";
	echo '++++++++++++++++++++++++++++';
	for x in hotmail.com yahoo.com aol.com earthlink.net verizon.net att.net sbcglobal.net comcast.net xmission.com cloudmark.com cox.net charter.net mac.me; do
		echo;
		echo $x;
		echo '--------------------';
		$SWAKS -q TO -t postmaster@$x -li "$ip" \
			| $GREP -iE 'block|rdns|550|521|554';
	done ;
	echo;
	echo 'gmail.com';
	echo '-----------------------';
	$SWAKS -4 -t iflcars.com@gmail.com -li "$ip"  \
		| $GREP -iE 'block|rdns|550|521|554';
	echo;
	echo;

}


####### $NODEWORX ##########

# Show sites and their corresponding reseller
resellers () {
  ($NODEWORX -u -n -c Siteworx -a listAccounts \
    | $SED 's/ /_/g' \
    | $AWK '{print $5,$2,$10,$9}';

  $NODEWORX -u -n -c Reseller -a listResellers \
    | $SED 's/ /_/g' \
    | $AWK '{print $1,"0Reseller",$3, $2}') \
    | $SORT -n \
    | $COLUMN -t \
    | $SED 's/\(.*0Re.*\)/\n\1/' > /tmp/rslr;

  while read -r; do
    $AWK '{if ($2 == "0Reseller") print "Reseller: " $3, "( "$4" )"; else if ($3 == "master") print ($2,$4); else print ($2,$3);}';
  done < /tmp/rslr | $SED 's/_/ /g';
}

# Lookup Siteworx account details
acctdetail () {
  $NODEWORX -u -n -c Siteworx -a querySiteworxAccountDetails --domain "$(~iworx/bin/listaccounts.pex | $AWK "/^$($GETUSR)/ {print \$2}")" \
    | $SED 's:\([a-zA-Z]\) \([a-zA-Z]\):\1_\2:g;s:\b1\b:YES:g;s:\b0\b:NO:g' \
    | $COLUMN -t
}

######## Miscellaneous ########

## Simple System Status to check if services that should be running are running
srvstatus(){
  local servicelist;
  # shellcheck disable=SC2207
  servicelist=($($CHKCONFIG --list | $AWK '/3:on/ {print $1}' | sort));

  printf "\n%-18s %s\n%-18s %s\n" " Service" " Status" "$(dashes 18)" "$(dashes 55)";

  for x in ${servicelist[*]}; do
    printf "%-18s %s\n" " $x" " $(service "$x" status 2> /dev/null | $HEAD -1)";
  done;
  echo
}

## Lookup the DNS Nameservers on the host
nameservers () {
  local nameservers;
  echo;
  # shellcheck disable=SC2207
  nameservers=($($SED -n 's/ns[1-2]="\([^"]*\).*/\1/p' ~iworx/iworx.ini))
  for (( x=ARRAY_START; x<${#nameservers[@]}+ARRAY_START; x++ )) do
    echo "${nameservers[$x]} ($($DIG +short "${nameservers[$x]}"))";
  done
  echo;
}

# stat the files listed in the given maldet report
maldetstat () {
  local files;
  # shellcheck disable=SC2207
  files=($($AWK '{print $3}' /usr/local/maldetect/sess/session.hits."$1"));
  for (( x=ARRAY_START; x<${#files[@]}+ARRAY_START; x++ )); do
    $STATT "${files[$x]}";
  done
}

# Check for duplicate files
finddups () {
  $FIND "$1" -type f -print0 \
    | $XARGS -0 md5sum \
    | $SORT \
    | $UNIQ -w32 --all-repeated=separate
}

## Add $DATE and time with username and open server_notes.txt for editing
srvnotes () {
  echo -e "\n#$($DATE) - ${SUDO_USER/nex/}" >> /etc/nexcess/server_notes.txt;
  $EDITOR /etc/nexcess/server_notes.txt;
}

## Generate nexinfo.php to view php info in browser
nexinfo () {
  echo '<?php phpinfo(); ?>' > nexinfo.php \
    && $CHOWN "$($GETUSR)". nexinfo.php;
  echo -e "\nhttp://$(pwd | $SED 's:^/chroot::' | $CUT -d/ -f4-)/nexinfo.php created successfully.\n" \
    | $SED 's/html\///';
}

## System resource usage by account
sysusage () {

  local COLSORT=2;

  printf "\n%-10s %10s %10s %10s %10s\n%s\n" "User" "Mem (MB)" "Process" "$CPU(%)" "MEM(%)" "$(dashes 54)";
  $PS aux \
    | $AWK ' !/^USER/ { mem[$1]+=$6; procs[$1]+=1; pcpu[$1]+=$3; pmem[$1]+=$4; } END { for (i in mem) { printf "%-10s %10.2f %10d %9.1f%% %9.1f%%\n", i, mem[i]/(1024), procs[i], pcpu[i], pmem[i] } }' \
    | $SORT -nrk$COLSORT \
    | $HEAD;
  echo;

}

## Quick summary of domain DNS info
ddns () {
  local D NS;
  if [[ -z "$*" ]]; then
    if [[ "$MYSHELL" =~ zsh ]]; then
      vared -p "Domain Name: " -c D;
    else
      read -rp "Domain Name: " D;
    fi
  else
    D="$*";
  fi
  for x in $(echo "$D" | $SED 's_\(https\?://\)\?\([^/]*\).*_\2_' | $TR "[:upper:]" "[:lower:]"); do
    echo -e "\nDNS Summary: $x\n$(dashes 79)";
    for y in a aaaa ns mx txt soa; do
      $DIG +time=2 +tries=2 +short $y "$x" +noshort;
      if [[ $y == 'ns' ]]; then
        NS="$($DIG +short ns "$x")";
        if [[ -n "$NS" ]]; then
          $DIG +time=2 +tries=2 +short "$NS" +noshort \
            | $GREP -v root;
        fi
      fi;
    done;
    echo;
    $DIG +short txt _domainkey."$x" +noshort;
    echo;
    $DIG +short txt default._domainkey."$x" +noshort;
    echo;
    $DIG +short txt _dmarc."$x" +noshort;
    echo;
    $DIG +short -x "$($DIG +time=2 +tries=2 +short "$x")" +noshort;
    echo;
  done
}

## Check if gzip is working for domain(s)
chkgzip () {
  local DNAME;
  echo;
  if [[ -z "$*" ]]; then
    if [[ "$MYSHELL" =~ zsh ]]; then
      vared -p "Domain name(s): " -c DNAME;
    else
      read -rp "Domain name(s): " DNAME;
    fi
  else
    DNAME="$*";
  fi
  for x in $DNAME; do
    $CURL -I -H 'Accept-Encoding: gzip,deflate' "$x";
  done;
  echo
}

## List the daily snapshots for a database to see the $DATEs/times on the snapshots
lsnapshots () {
  local DBNAME;
  echo;
  if [[ -z "$1" ]]; then
    if [[ "$MYSHELL" =~ zsh ]]; then
      vared -p "Database Name: " -c DBNAME;
    else
      read -rp "Database Name: " DBNAME;
    fi
  else
    DBNAME="$1";
  fi
  $LS -lah /home/.snapshots/daily.*/localhost/mysql/"$DBNAME".sql.xz;
  echo
}

## Create Magento Multi-Store Symlinks
magsymlinks () {
  local U D yn;
  echo;
  U=$($GETUSR);
  if [[ -z $1 ]]; then
    if [[ "$MYSHELL" =~ zsh ]]; then
      vared -p "Domain Name: " -c D;
    else
      read -rp "Domain Name: " D;
    fi
  else
    D=$1;
  fi
  for X in app includes js lib media skin var; do
    sudo -u "$U" "$LN" -s /home/"$U"/"$D"/html/$X/ $X;
  done;
  echo;
  if [[ "$MYSHELL" =~ zsh ]]; then
    vared -p "Copy .htaccess and index.php? [y/n]: " -c yn;
  else
    read -rp "Copy .htaccess and index.php? [y/n]: " -c yn;
  fi
  if [[ $yn == "y" ]]; then
    for Y in index.php .htaccess; do
      sudo -u "$U" "$CP" /home/"$U"/"$D"/html/$Y .;
    done;
  fi
}

## Print some dashes
dashes () {

  local i;

  for ((i=0;i<=$1;i++)); do
    printf -- "-";
  done;

}

## Switch to a user
u () {

  local user home;

  user="$(pwd | "$GREP" -Po "/((chroot/)?home/|local/)\K[^/]*")";
  home="$(mktemp -d)"

	chmod 711 "$HOME"
  $SETFACL -m u:"$user":rwX "$home"

  # Give permissions on my home dir to new user
	find "$HOME" -mindepth 1 -maxdepth 1 ! -name .ssh \
		| while read -r x; do
			$SETFACL -R -m u:"$user":rX "$x" 2> /dev/null
			ln -s "$x" "${home}/${x##*/}"
		done

    if [[ -n "${__ZHIST_INPUT_PIPE}" ]]; then
      $SETFACL -m u:"$user":rw "${__ZHIST_INPUT_PIPE}"
    fi

  if [[ -e "/home/${user}/.composer" ]]; then
    ln -s "/home/${user}/.composer" "${home}/.composer"
  fi

  $SETFACL -R -m u:"$user":rwX "$HOME"/{.zsh_history,.zsh-history*,"${__ZHIST_DIR}",clients,.vimfiles} 2> /dev/null

  # Switch user
  $SUDO HOME="$home" TMUX="$TMUX" -u "$user" "$MYSHELL"

  # Give me permissions on any files the user created in my home dir
  $SUDO -u "$user" "$FIND" "$home" -type f -user "$user" -exec $SETFACL -m u:"$USER":rwX {} +

  # Revoke the permissions given to that user
  $SETFACL -R -x u:"$user" ~/
	chmod 700 "$HOME"

}

## Find broken symbolic links
brokenlinks () {

  local tifs x path link dir;

  path="$1"

  [[ -z "$path" ]] && path="$PWD"

  tifs="$IFS";
  IFS="
"

	for x in $("$FIND" "$path" -type l); do

    link="$("$READLINK" "$x")" 2> /dev/null

    if [[ ! "$link" == "/"* ]]; then

      dir="$PWD"

      cd "${x%/*}" || return 1;

      [[ -e "$link" ]] \
        || printf "%s  ->  %s\n" "$x" "$link";

      cd "$dir" || return 1;

    else

      [[ -e "$link" ]] \
        || printf "%s  ->  %s\n" "$x" "$link";

    fi

	done

  IFS="$tifs";

}

phpunserialize () {

  local value

  value="$*"

  if [[ -z "$value" ]]; then
    value="$(cat)"
  fi

  # shellcheck disable=SC2001
  value="$(echo "$value" | sed "s/'/\\\'/g")"

  php -r "echo print_r(unserialize('${value}'),true);"

}

## Share a file with a quick and dirty web server
shareFile() {

  { printf "HTTP/1.0 200 OK\nContent-Length: %s\r\n\r\n" "$(wc -c "$1")"; cat "$1"; } \
		| nc -l -p 8000

}

# Geoip lookup
geoip () {
	curl -s "https://www.maxmind.com/geoip/v2.1/city/${1}?use-downloadable-db=1&demo=1" \
		| jq .
}
