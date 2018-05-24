#! /bin/bash

[[  -z  $AWK         ]]  &&  readonly  AWK='/bin/awk'
[[  -z  $CHECKQUOTA  ]]  &&  readonly  CHECKQUOTA='/home/nexmrafferty/bin/checkquota'
[[  -z  $CHKCONFIG   ]]  &&  readonly  CHKCONFIG='/sbin/chkconfig'
[[  -z  $CHOWN       ]]  &&  readonly  CHOWN='/bin/chown'
[[  -z  $COLUMN      ]]  &&  readonly  COLUMN='/usr/bin/column'
[[  -z  $CP          ]]  &&  readonly  CP='/bin/cp'
[[  -z  $CURL        ]]  &&  readonly  CURL='/usr/bin/curl'
[[  -z  $CUT         ]]  &&  readonly  CUT='/bin/cut'
[[  -z  $DATE        ]]  &&  readonly  DATE='/bin/date'
[[  -z  $DIG         ]]  &&  readonly  DIG='/usr/bin/dig'
[[  -z  $FIND        ]]  &&  readonly  FIND='/bin/find'
[[  -z  $GETUSR      ]]  &&  readonly  GETUSR='/home/nexmrafferty/bin/getusr'
[[  -z  $GREP        ]]  &&  readonly  GREP='/bin/grep'
[[  -z  $HEAD        ]]  &&  readonly  HEAD='/usr/bin/head'
[[  -z  $IP          ]]  &&  readonly  IP='/sbin/ip'
[[  -z  $LN          ]]  &&  readonly  LN='/bin/ln'
[[  -z  $LS          ]]  &&  readonly  LS='/bin/ls'
[[  -z  $MYSQL       ]]  &&  readonly  MYSQL='/usr/bin/mysql'
[[  -z  $NODEWORX    ]]  &&  readonly  NODEWORX='/usr/bin/nodeworx'
[[  -z  $NSLOOKUP    ]]  &&  readonly  NSLOOKUP='/usr/bin/nslookup'
[[  -z  $PS          ]]  &&  readonly  PS='/bin/ps'
[[  -z  $SED         ]]  &&  readonly  SED='/bin/sed'
[[  -z  $SETFACL     ]]  &&  readonly  SETFACL='/usr/bin/setfacl'
[[  -z  $SORT        ]]  &&  readonly  SORT='/bin/sort'
[[  -z  $STATT       ]]  &&  readonly  STATT='/usr/bin/stat'
[[  -z  $SUDO        ]]  &&  readonly  SUDO='/usr/bin/sudo'
[[  -z  $SWAKS       ]]  &&  readonly  SWAKS='/usr/bin/swaks'
[[  -z  $TOUCH       ]]  &&  readonly  TOUCH='/bin/touch'
[[  -z  $TR          ]]  &&  readonly  TR='/usr/bin/tr'
[[  -z  $UNIQ        ]]  &&  readonly  UNIQ='/usr/bin/uniq'
[[  -z  $XARGS       ]]  &&  readonly  XARGS='/usr/bin/xargs'
[[  -z  $ZLESS       ]]  &&  readonly  ZLESS='/usr/bin/zless'
[[  -z  $MYSHELL     ]]  &&  readonly  MYSHELL="$(readlink /proc/$$/exe)"

if [[ "$MYSHELL" =~ zsh ]]; then
  ARRAY_START="1";
else
  ARRAY_START="0";
fi

##### Change Directory #####

# Change directory to a website's docroot
cdd () {
  local query domains domain alias docroot subdir selection;
  declare -a docroot;

  # Obtain input string
  if [ -n "$1" ]; then
    query=$1;
  else
    query="$(pwd | $SED -e 's_.*home/[^/]*/\([^/]*\)/html.*_\1_' -e 's_.*home/[^/]*/var/\([^/]*\)/.*_\1_')";
  fi
  # Gather relevant domain information
  domains=$($GREP -EH "Server(Name|Alias).* $query" /etc/httpd/{conf.d/vhost_*.conf,tmpdomains.d/*.conf} 2> /dev/null \
    | $SED -r 's/.*_(.*).conf:.* ('"$query"'[^ ]*).*/\1\t\2/' \
    | $SORT -u);

  domain=($(echo "$domains" \
    | $CUT -f1));

  alias=($(echo "$domains" \
    | $CUT -f2));

  for (( i=ARRAY_START; i<${#alias[@]}+ARRAY_START; i++ )); do
    docroot[$i]=$($GREP -Poh '[^#]*DocumentRoot.* \K/([^/]+/?)+' /etc/httpd/{conf.d/vhost_,tmpdomains.d/*_}"${domain[$i]}".conf 2> /dev/null \
      | $HEAD -n1);
  done;

  # Evaluate subdomains
  for (( i=ARRAY_START; i<${#alias[@]}+ARRAY_START; i++ )); do
    if [[ ${alias[$i]} == *.${domain[$i]} ]]; then
      subdir="$(echo "${alias[$i]}" | $SED -nr 's/(.*).'"${domain[$i]}"'/\1/p')";
      if [ -d "${docroot[$i]}"/"$subdir" ]; then
        docroot[$i]="${docroot[$i]}/${subdir}";
      fi;
    fi;
  done;

  # Get rid of duplicate docroots
  docroot=($(printf "%s\n" "${docroot[@]}" | $SORT -u));

  # Evaluate too few or too many docroots
  if [ -z "${docroot[$ARRAY_START]}" ]; then
    echo "Domain not found";
    return;
  elif [ "${docroot[$ARRAY_START+1]}" ]; then
    echo "Domain ambiguous. Select docroot:";
    for (( i=ARRAY_START; i<${#docroot[@]}+ARRAY_START; i++ )); do
      echo "$i  ${docroot[$i]}";
    done | $COLUMN -t;
    echo;
    if [[ "$MYSHELL" =~ zsh ]]; then
      vared -p "Choose docroot number:" -c selection;
    else
      read -rp "Choose docroot number:" selection;
    fi

    docroot[$ARRAY_START]=${docroot[$selection]};

  fi;

  # Change working directory to docroot
  cd "${docroot[$ARRAY_START]}" || echo "Could not locate docroot";
  pwd;
}

# Change directory to a website's log dir
cdlogs () {
  local query vhosts logsdir selection;
  declare -a logsdir;

  if [ -n "$1" ]; then
    query=$1;
  else
    query="$(pwd | $SED -e 's_.*home/[^/]*/\([^/]*\)/html.*_\1_' -e 's_.*home/[^/]*/var/\([^/]*\)/.*_\1_')";
  fi

  # Gather relevant domain information
  vhosts=($($GREP -El "Server(Name|Alias).* $query" /etc/httpd/{conf.d/vhost_*.conf,tmpdomains.d/*.conf}));

  for (( i=ARRAY_START; i<${#vhosts[@]}+ARRAY_START; i++ )); do
    logsdir[$i]=$($GREP -Poh '[^#]*ErrorLog.* \K/([^/]+/)+' "${vhosts[$i]}" \
      | $HEAD -n1);
  done;

  # Evaluate too few or too many directories
  if [ -z "${logsdir[$ARRAY_START]}" ]; then
    echo "Log directory not found";
    return;
  elif [ "${logsdir[$ARRAY_START+1]}" ]; then
    echo "Domain ambiguous. Select log directory:";
    for (( i=ARRAY_START; i<${#logsdir[@]}+ARRAY_START; i++ )); do
      echo "$i  ${logsdir[$i]}";
    done | $COLUMN -t;
    echo;
    if [[ "$MYSHELL" =~ zsh ]]; then
      vared -p "Choose log directory number:" -c selection;
    else
      read -rp "Choose log directory number:" selection;
    fi

    logsdir[$ARRAY_START]=${logsdir[$selection]};

  fi;

  # Change working directory to log directory
  cd "${logsdir[$ARRAY_START]}" || echo "Could not locate log directory";
  pwd;
}


#### Bandwidth ######

# Show top ip addresses by bandwidth usage
ipsbymb () {
  $ZLESS -f "$@" \
    | $GREP -Poa ".*\" \d{3} \d*(?= \")" \
    | $AWK '{gsub(/,/,"",$2); if (index($2,"-") == 0){tx[$2"-X"]+=$(NF)} else {tx[$1]+=$(NF)}} END {for (x in tx) {printf "%10.2fM\t%s\n",tx[x]/1048576,x}}' \
    | $SORT -k1nr \
    | $HEAD -n20 \
    | $COLUMN -t;
}

# Show top user agents by bandwidth usage
uabymb () {
  $ZLESS -f "$@" \
    | $SED -nr 's|.* [0-9]{3} ([0-9]*) \"[^\"]*\" \"([^\"]*)\".*|\1\t\2|p' \
    | $AWK -F "\t" '{tx[$2]+=$1} END {for (x in tx) {printf "%10.2fM\t%s\n",tx[x]/1048576,x}}' \
    | $SORT -hr \
    | $HEAD -n 20;
}

# Show top referers by bandwidth usage
refbymb () {
  $ZLESS -f "$@" \
    | $SED -nr 's|.* [0-9]{3} ([0-9]*) \"([^\"]*)\" \"[^\"]*\".*|\1\t\2|p' \
    | $AWK '{tx[$2]+=$1} END {for (x in tx) {printf "%10.2fM\t%s\n",tx[x]/1048576,x}}' \
    | $SORT -hr \
    | $HEAD -n 20;
}

# Show top uris by bandwidth usage
uribymb () {
  $ZLESS -f "$@" \
    | $SED -nr 's|.*\] \"\S* ([^?, ]*\??)[^\"]*\" [0-9]{3} ([0-9]*) .*|\1\t\2|p' \
    | $AWK '{tx[$1]+=$2} END {for (x in tx) {printf "%10.2fM\t%s\n",tx[x]/1048576,x}}' \
    | $SORT -hr \
    | $HEAD -n 20;
}

# Show top file types by bandwidth usage
typebymb () {
  $ZLESS -f "$@" \
    | $SED -nr 's|.*\] \"\S* [^?, ]*(\.[^?,/, ]*)\??[^\"]*\" [0-9]{3} ([0-9]*) .*|\1\t\2|p' \
    | $AWK '{tx[$1]+=$2} END {for (x in tx) {printf "%10.2fM\t%s\n",tx[x]/1048576,x}}' \
    | $SORT -hr \
    | $HEAD -n 20;
}

# Show total bandwidth usage
totalmb () {
  $ZLESS -f "$@" \
    | $GREP -o '" [0-9][0-9][0-9] [0-9]*' \
    | $AWK '{sum+=$3} END {print sum/1048576 " M"}'
}


##### Traffic #######

# Show top ip addresses by number of hits
topips () {
  $ZLESS -f "$@" \
    | $AWK '{gsub(/,/,"",$2); if (index($2,"-") == 0){freq[$2"-X"]++} else {freq[$1]++}} END {for (x in freq) {print freq[x], x}}' \
    | $SORT -rn \
    | $HEAD -20;
}

# Show top user agents by number of hits
topuseragents () {
  $ZLESS -f "$@" \
    | $GREP -Poa '" "\K[^"]*' \
    | $SORT \
    | $UNIQ -c \
    | $SORT -hr \
    | $HEAD -20;
}

# Show top uris by number of hits
topuri () {
  $ZLESS -f "$@" \
    | $GREP -hva " 403 " \
    | $GREP -Poa "\] \"\S* \K[^?, ]*\??" \
    | $SORT \
    | $UNIQ -c \
    | $SORT -hr \
    | $HEAD;
}

# Top query strings
topquery () {
  $ZLESS -f "$@" \
    | $GREP -va " 403 " \
    | $SED -n 's_.*?\(.*\) HTTP/[0-2]\.[0-2]".*_\1_p' \
    | $SORT \
    | $UNIQ -c \
    | $SORT -hr \
    | $HEAD;
}

# Show top referers by number of hits
topref () {
  $ZLESS -f "$@" \
    | $GREP -av " 403 " \
    | $GREP -Poa "[0-9]{3} ([0-9]*|-) \K\"[^\"]*\"" \
    | $SORT \
    | $UNIQ -c \
    | $SORT -hr \
    | $HEAD;
}

# Show number of requests received on every site in the last hour
reqslasthour () {
  local prevhour regex;
  local -a times;

  times=($($DATE +%Y:%R | $SED -e 's/:/ /g' -e 's/\([0-9]\)\([0-9]\)$/\1 \2/'))

  if [ "${times[ARRAY_START+1]}" -eq 00 ]; then
    prevhour=23;
  else
    prevhour=$(printf "%02d" "$((times[ARRAY_START+1]-1))");
  fi
  if [ "${times[ARRAY_START+2]}" -eq 5 ]; then
    regex="${times[ARRAY_START]}:($prevhour:5[${times[ARRAY_START+3]}-9]|${times[ARRAY_START+1]}:)"
  else
    regex="${times[ARRAY_START]}:($prevhour:(${times[ARRAY_START+2]}[${times[ARRAY_START+3]}-9]|[$((times[ARRAY_START+2]+1))-5][0-9])|${times[ARRAY_START+1]}:)"
  fi

  echo -e "\n";
  $FIND {/var/log/,/home/*/var/*/logs} -name transfer.log -exec "$GREP" -EHc "$regex" {} + \
    | $GREP -v ":0$" \
    | $SED 's_log:_log\t_' \
    | $SORT -nr -k 2 \
    | $AWK 'BEGIN{print "\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2}';
  echo -e "\n"
}

# Show number of requests received on every site in the last hour
phplasthour () {
  local prevhour regex;
  local -a times;

  times=($($DATE +%Y:%R | $SED -e 's/:/ /g' -e 's/\([0-9]\)\([0-9]\)$/\1 \2/'))

  if [ "${times[ARRAY_START+1]}" -eq 00 ]; then
    prevhour=23;
  else
    prevhour=$(printf "%02d" "$((times[ARRAY_START+1]-1))");
  fi
  if [ "${times[ARRAY_START+2]}" -eq 5 ]; then
    regex="${times[ARRAY_START]}:($prevhour:5[${times[ARRAY_START+3]}-9]|${times[ARRAY_START+1]}:)"
  else
    regex="${times[ARRAY_START]}:($prevhour:(${times[ARRAY_START+2]}[${times[ARRAY_START+3]}-9]|[$((times[ARRAY_START+2]+1))-5][0-9])|${times[ARRAY_START+1]}:)"
  fi

  echo -e "\n";
  $FIND {/var/log/,/home/*/var/*/logs} -name transfer.log \
    -exec "$GREP" -HPic "$regex"'.*\] "\S* (?!.*(/static/|(\.(otf|txt|jpeg|ico|svg|jpg|css|js|gif|png|woff)))[^?].* 200 .*)' {} + \
    | $GREP -v ":0$" \
    | $SED 's_log:_log\t_' \
    | $SORT -nr -k 2 \
    | $AWK 'BEGIN{print "\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2}';
  echo -e "\n"
}


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
  $NODEWORX -u -n -c Siteworx -a querySiteworxAccountDetails --domain "$(~iworx/bin/listaccounts.pex | $AWK "/$($GETUSR)/"'{print $2}')"\
    | $SED 's:\([a-zA-Z]\) \([a-zA-Z]\):\1_\2:g;s:\b1\b:YES:g;s:\b0\b:NO:g' \
    | $COLUMN -t
}

## Enable Siteworx backups for an account
addbackups () {
  $NODEWORX -u -n -c Siteworx -a edit --domain "$(~iworx/bin/listaccounts.pex | $AWK "/$($GETUSR)/"'{print $2}')" --OPT_BACKUP 1;
}


######## Miscellaneous ########

## Simple System Status to check if services that should be running are running
srvstatus(){
  local servicelist;
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
  nameservers=($($SED -n 's/ns[1-2]="\([^"]*\).*/\1/p' ~iworx/iworx.ini))
  for (( x=ARRAY_START; x<${#nameservers[@]}+ARRAY_START; x++ )) do
    echo "${nameservers[$x]} ($($DIG +short "${nameservers[$x]}"))";
  done
  echo;
}

# stat the files listed in the given maldet report
maldetstat () {
  local files;
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
  $LS -lah /home/.snapshots/daily.*/localhost/mysql/"$DBNAME".sql.gz;
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

  local user;

  user="$(pwd | "$GREP" -Po "home/\K[^/]*")"

  # Give permissions on my home dir to new user
  $SETFACL -R -m u:"$user":rX "$HOME" 2> /dev/null
  $SETFACL -m u:"$user":rwX "$HOME"
  $SETFACL -R -m u:"$user":rwX "$HOME"/{.zsh_history,clients,.vimfiles} 2> /dev/null

  # Switch user
  $SUDO HOME="$HOME" TMUX="$TMUX" -u "$user" "$MYSHELL"

  # Give me permissions on any files the user created in my home dir
  $SUDO -u "$user" "$FIND" "$HOME" -user "$user" -exec $SETFACL -m u:"$USER":rwX {} +

  # Revoke the permissions given to that user
  $SETFACL -R -x u:"$user" ~/
}
