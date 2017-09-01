# Show sites and their corresponding reseller
resellers () {
  (nodeworx -u -n -c Siteworx -a listAccounts \
    | sed 's/ /_/g' \
    | awk '{print $5,$2,$10,$9}';

  nodeworx -u -n -c Reseller -a listResellers \
    | sed 's/ /_/g' \
    | awk '{print $1,"0Reseller",$3, $2}') \
    | sort -n \
    | column -t \
    | sed 's/\(.*0Re.*\)/\n\1/' > /tmp/rslr;

  while read -r; do
    awk '{if ($2 == "0Reseller") print "Reseller: " $3, "( "$4" )"; else if ($3 == "master") print ($2,$4); else print ($2,$3);}';
  done < /tmp/rslr | sed 's/_/ /g';
}

vhost () {

  local query domain;

  if [  $1 ]; then
    query=$1;
  else
    echo hi;
    query=$(pwd);
  fi
  # Trim any fddat off the domain name
  domain=$(echo "$query" | sed -r -e 's_https?://__' -e 's_/$__' | tr "[:upper:]" "[:lower:]");
}

cdd () {
  local query domains domain alias docroot subdir selection;
  declare -a docroot;

  # Obtain input string
  query=$1;

  # Gather relevant domain information
  domains=$(grep -EH "Server(Name|Alias).* $query" /etc/httpd/conf.d/vhost_* \
    | sed -r 's/.*vhost_(.*).conf.* ('"$query"'[^ ]*).*/\1\t\2/' \
    | sort -u);

  domain=($(echo "$domains" \
    | cut -f1));

  alias=($(echo "$domains" \
    | cut -f2));

  for (( i=1; i<=${#alias[@]}; i++ )); do
    docroot[$i]=($(sed -nr 's/.*DocumentRoot (.*)/\1/p' /etc/httpd/conf.d/vhost_"$domain[$i]".conf \
      | head -n1));
  done;

  # Evaluate subdomains
  for (( i=1; i<=${#alias[@]}; i++ )); do
    if [[ ${alias[$i]} == *.${domain[$i]} ]]; then
      subdir="$(echo "${alias[$i]}" | sed -nr 's/(.*).'"${domain[$i]}"'/\1/p')";
      if [ -d ${docroot[$i]}/$subdir ]; then
        docroot[$i]="${docroot[$i]}/${subdir}";
      fi;
    fi;
  done;

  # Get rid of duplicate docroots
  docroot=($(printf "%s\n" "${docroot[@]}" | sort -u));

  # Evaluate too few or too many docroots
  if [ -z "${docroot[1]}" ]; then
    echo "Domain not found";
    return;
  elif [ "${docroot[2]}" ]; then
    echo "Domain ambiguous. Select docroot:";
    for (( i=1; i<=${#docroot[@]}; i++ )); do
      echo "$i  ${docroot[$i]}";
    done | column -t;
    echo;
    vared -p "Choose docroot number:" -c selection;

    docroot[1]=${docroot[$selection]};

  fi;

  # Change working directory to docroot
  cd "${docroot[1]}" || echo "Could not locate docroot";
  pwd;
}

cdlogs () {
  local query vhosts docroot selection;
  declare -a logsdir;

  # Obtain input string
  query=$1;

  # Gather relevant domain information
  vhosts=($(grep -El "Server(Name|Alias).* $query" /etc/httpd/conf.d/vhost_*));

  for (( i=1; i<=${#vhosts[@]}; i++ )); do
    logsdir[$i]=($(sed -nr 's_.*ErrorLog (.*)/error.log_\1_p' "$vhosts[$i]" \
      | head -n1));
  done;

  # Evaluate too few or too many directories
  if [ -z "${logsdir[1]}" ]; then
    echo "Log directory not found";
    return;
  elif [ "${logsdir[2]}" ]; then
    echo "Domain ambiguous. Select log directory:";
    for (( i=1; i<=${#logsdir[@]}; i++ )); do
      echo "$i  ${logsdir[$i]}";
    done | column -t;
    echo;
    vared -p "Choose log directory number:" -c selection;

    logsdir[1]=${logsdir[$selection]};

  fi;

  # Change working directory to log directory
  cd "${logsdir[1]}" || echo "Could not locate log directory";
  pwd;
}

whichsoft () {
  grep "AUTH.*allow" /usr/sbin/r1soft/log/cdp.log \
    | sed 's_.*server.allow/\(.*\).$_\1_' \
    | tail -n1 \
    | awk -F'/' '{print $NF}' \
    | xargs -rn1 host -W5 \
    | awk '/name pointer/{sub(/\.$/,"",$NF); printf "https://%s:8001/\n",$NF}'
}

quotacheck () {
  echo;
  grep -E ":/home/[^\:]+:" /etc/passwd \
    | cut -d : -f1 \
    | while read	-r _user_; do
  echo -n "$_user_";
  quota -g "$_user_" 2>/dev/null \
    | perl -pe 's,\*,,g' \
    | tail -n+3 \
    | awk '{print " "$2/$3*100,$2/1000/1024,$3/1024/1000}';
  echo;
done \
  | grep '\.' \
  | sort -grk2 \
  | awk 'BEGIN{printf "%-15s %-10s %-10s %-10s\n","User","% Used","Used (G)","Total (G)"; for (x=1; x<50; x++) {printf "-"}; printf "\n"} {printf "%-15s %-10.2f %-10.2f %-10.2f\n",$1,$2,$3,$4}';
echo;
}

iworxdb () {
  local user pass database socket;

  user="iworx";
  pass="$(grep '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)";
  database="iworx";
  socket="$(grep '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | awk -F'[()]' '{print $2}')";

  mysql -u"$user" -p"$pass" -S"$socket" -D"$database";
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

  nodeworx -u -n -c Siteworx -a edit --OPT_STORAGE "$new_disk_quota" --domain "$master_domain";
}

whodunit () {
  echo -e "\n\n";
  grep -c "$(date +%Y:%H)" /home/*/var/*/logs/transfer.log \
    | grep -v ":0$" \
    | sed 's_log:_log\t_' \
    | sort -nr -k 2 \
    |awk 'BEGIN{print "\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2}';
  echo -e "\n\n"
}

ttfb () {
  local output="Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n";

  curl -o /dev/null -w"$output"  -s "$1";
}

topips () {
  zless -f "$@" \
    | awk '{freq[$1]++} END {for (x in freq) {print freq[x], x}}' \
    | sort -rn \
    | head -20;
}

topuseragents () {
  zless -f "$@" \
    | cut -d\  -f12- \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -20;
}

ipsbymb () {
  zless -f "$@" \
    | awk '{tx[$1]+=$10} END {for (x in tx) {print x, "\t", tx[x]/1048576, "M"}}' \
    | sort -k 2n \
    | tail -n 20 \
    | tac;
}

uabymb () {
  zless -f "$@" \
    | cut -d\  -f10- \
    | grep -v ^- \
    | sed 's_^\([0-9]*\).*" "\(.*\)"$_\1\t\2_' \
    | awk -F "\t" '{tx[$2]+=$1} END {for (x in tx) {print tx[x]/1048576, "M","\t",x}}' \
    | sort -hr \
    | head -n 20;
}

refbymb () {
  zless -f "$@" \
    | cut -d\  -f10,11 \
    | grep -v ^- \
    | awk '{tx[$2]+=$1} END {for (x in tx) {print tx[x]/1048576, "M","\t",x}}' \
    | sort -hr \
    | head -n 20;
}

uribymb () {
  zless -f "$@" \
    | cut -d\  -f7,10 \
    | grep -v "\-$" \
    | sed 's/?.* / /' \
    | awk '{tx[$1]+=$2} END {for (x in tx) {print tx[x]/1048576, "M","\t",x}}' \
    | sort -hr \
    | head -n 20;
}

totalmb () {
  zless -f "$@" \
    | awk '{sum+=$10} END {print sum/1048576 " M"}'
}

sshpass() {
  mkpasswd -l 15 -d 3 -C 5 -s 0 "$1";
  nksshd userControl --reset-failures "$1";
}

hitsperhour () {
  zless -f "$@" \
    | sed 's_.*../.*/....:\(..\).*_\1_' \
    | sort -h \
    | uniq -c \
    | sed 's_ *\(.*\) \(..\)_\2:00\t\1 hits_'
}

topuri () {
  zless -f "$@" \
    | grep -hv " 403 " \
    | cut -d\  -f7 \
    | sed 's/?.*//' \
    | sort \
    | uniq -c \
    | sort -hr \
    | head;
}

topref () {
  zless -f "$@" \
    | grep -hv " 403 " \
    | cut -d\  -f11 \
    | sort \
    | uniq -c \
    | sort -hr \
    | head;
}

backup () {
  tar -czvf "$1.tar.gz" "$1";
}

blacklistcheck () {
  for b in $1; do
    echo '++++++++++++++++++++++++++++';
    echo "$b";
    echo 'PHONE: 866-639-2377';
    nslookup "$b" \
      | grep addr;
    echo 'http://multirbl.valli.org/lookup/'"$b"'.html';
    echo 'http://www.senderbase.org/lookup/ip/?search_string='"$b";
    echo 'https://www.senderscore.org/lookup.php?lookup='"$b";
    echo '++++++++++++++++++++++++++++';
    for x in hotmail.com yahoo.com aol.com earthlink.net verizon.net att.net sbcglobal.net comcast.net xmission.com cloudmark.com cox.net charter.net mac.me; do
      echo;
      echo $x;
      echo '--------------------';
      swaks -q TO -t postmaster@$x -li "$b" \
        | grep -iE 'block|rdns|550|521|554';
    done ;
    echo;
    echo 'gmail.com';
    echo '-----------------------';
    swaks -4 -t iflcars.com@gmail.com -li "$b"	\
      | grep -iE 'block|rdns|550|521|554';
    echo;
    echo;
  done;
}

maldetstat () {
  for file in $(awk '{print $3}' /usr/local/maldetect/sess/session.hits.$1); do
    stat $file;
  done
}

botsearch () {
  for x in /home/$1/var/*/logs/transfer.log ; do
    echo -e "\n####### $x" ;
    grep -v ' 403 ' "$x" \
      | grep -iE 'bot|megaindex|crawl|spider|slurp' \
      | cut -d\  -f12- \
      | sort \
      | uniq -c \
      | sort -rn \
      | head ;
  done
}

finddups () {
  find "$1" -type f -print0 \
    | xargs -0 md5sum \
    | sort \
    | uniq -w32 --all-repeated=separate
}

analyzetraffic () {
  zless -f "$@" \
    | cut -d\  -f4,9 \
    | sed 's_.*../.*/....:\(..\):..:.._\1_' \
    | sort -h \
    | uniq -c \
    | less \
    | awk '{print $2"\t"$3"\t"$1}'
}

# Iworx DB
i () {
  $(grep -B1 'dsn.orig=' ~iworx/iworx.ini | head -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@";
}

# Vpopmail
v () {
  $(grep -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@";
}

# ProFTPd
f () {
  $(grep -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@";
}

## Lookup mail account password (http://www.qmailwiki.org/Vpopmail#vuserinfo)
emailpass () {
  echo -e "\nUsername: $1\nPassword: $(~vpopmail/bin/vuserinfo -C $1)\n";
}

## Function to print a number of dashes to the screen
dash () {
  for ((i=1;i<=$1;i++)); do
    printf "-";
  done;
}

## Print the hostname if it resolves, otherwise print the main IP
serverName () {
  if [[ -n $(dig +time=1 +tries=1 +short $(hostname)) ]]; then
    hostname;
  else
    ip addr show \
      | awk '/inet / {print $2}' \
      | cut -d/ -f1 \
      | grep -Ev '^127\.' \
      | head -1;
  fi
}

## Print out most often accessed Nodeworx links
lworx () {
  echo;
  if [[ -z "$1" ]]; then
    (for x in siteworx reseller dns/zone ip; do
    echo "$x : https://$(serverName):2443/nodeworx/$x";
  done;
  echo "webmail : https://$(serverName):2443/webmail") \
    | column -t
else
  echo -e "Siteworx:\nLoginURL: https://$(serverName):2443/siteworx/?domain=$1";
fi;
echo
}

## Add date and time with username and open server_notes.txt for editing
srvnotes () {
  echo -e "\n#$(date) - $(echo $SUDO_USER | sed 's/nex//g')" >> /etc/nexcess/server_notes.txt;
  nano /etc/nexcess/server_notes.txt;
}

## Find files in a directory that were modified a certain number of days ago
recmod () {
  if [[ -z "$@" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "\n Usage: recmod [-p <path>] [days|{sequence}]\n  Note: Paths with * in them need to be quoted\n";
    return 0;
  elif [[ "$1" == "-p" ]]; then
    DIR="$2";
    shift;
    shift;
  else
    DIR=".";
  fi;
  for x in "$@"; do
    echo "Files modified within $x day(s) or $((${x}*24)) hours ago";
    find $DIR -type f -mtime $((${x}-1)) -exec ls -lath {} \; \
      | grep -Ev '(var|log|cache|media|tmp|jpg|png|gif)' \
      | column -t;
    echo;
  done
}

## Update ownership to the username for the PWD
fixowner () {
  U=$(getusr)
  if [[ -z $2 ]]; then
    P='.';
  else
    P=$2;
  fi
  case $1 in
    -u|--user) owner="$U:$U" ;;
    -a|--apache) owner="apache:$U" ;;
    -r|--root) owner="root:root" ;;
    *|-h|--help) echo -e "\n Usage: fixowner [option] [path]\n    -u | --user ..... Change ownership to $U:$U\n    -a | --apache ... Change ownership to apache:$U\n    -r | --root ..... Change ownership to root:root\n    -h | --help ..... Show this help output\n"; return 0 ;;
  esac
  chown -R $owner $P \
    && echo -e "\n Files owned to $owner\n"
}

## Generate .ftpaccess file to create read only FTP user
# http://www.proftpd.org/docs/howto/Limit.html
ftpreadonly () {
  echo;
  if [[ -z "$1" ]]; then
    read -p "FTP Username: " U;
  else
    U="$1";
  fi
  sudo -u $(getusr) echo -e "\n<Limit WRITE>\n  DenyUser $U\n</Limit>\n" >> .ftpaccess \
    && echo -e "\n.ftpaccess file has been updated.\n";
}

## Create or add http-auth section for given .htaccess file
htaccessauth () {
  sudo -u $(getusr) echo -e "\n# ----- Password Protection Section -----
  \nAuthUserFile $(pwd)/.htpasswd
  AuthGroupFile /dev/null
  AuthName \"Authorized Access Only\"
  AuthType Basic
  \nRequire valid-user
  \n# ----- Password Protection Section -----\n" >> .htaccess
}

## Generate nexinfo.php to view php info in browser
nexinfo () {
  sudo -u "$(getusr)" echo '<?php phpinfo(); ?>' > nexinfo.php
  echo -e "\nhttp://$(pwd | sed 's:^/chroot::' | cut -d/ -f4-)/nexinfo.php created successfully.\n" | sed 's/html\///';
}

## System resource usage by account
sysusage () {
  echo;
  colsort="4";
  printf "%-10s %10s %10s %10s %10s\n" "User" "Mem (MB)" "Process" "CPU(%)" "MEM(%)";
  echo "$(dash 54)"
  ps aux \
    | grep -v ^USER \
    | awk '{ mem[$1]+=$6; procs[$1]+=1; pcpu[$1]+=$3; pmem[$1]+=$4; } END { for (i in mem) { printf "%-10s %10.2f %10d %9.1f%% %9.1f%%\n", i, mem[i]/(1024), procs[i], pcpu[i], pmem[i] } }' \
    | sort -nrk$colsort \
    | head;
  echo;
}

# Lookup Siteworx account details
acctdetail () {
  nodeworx -u -n -c Siteworx -a querySiteworxAccountDetails --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')\
    | sed 's:\([a-zA-Z]\) \([a-zA-Z]\):\1_\2:g;s:\b1\b:YES:g;s:\b0\b:NO:g' \
    | column -t
}

## Add an IP to a Siteworx account
addip () {
  nodeworx -u -n -c Siteworx -a addIp --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}') --ipv4 $1;
}

## Enable Siteworx backups for an account
addbackups () {
  nodeworx -u -n -c Siteworx -a edit --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}') --OPT_BACKUP 1;
}

## Adjust user quota on the fly using Nodeworx CLI
bumpquota(){
  if [[ -z $@ || $1 =~ -h ]]; then
    echo -e "\n Usage: bumpquota <username> <newquota>\n  Note: <username> can be '.' to get user from PWD\n";
    return 0;
  elif [[ $1 =~ ^[a-z].*$ ]]; then
    U=$1;
    shift;
  elif [[ $1 == '.' ]]; then
    U=$(getusr);
    shift;
  fi

  newQuota=$1;
  primaryDomain=$(~iworx/bin/listaccounts.pex | grep $U | awk '{print $2}')

  nodeworx -u -n -c Siteworx -a edit --domain $primaryDomain --OPT_STORAGE $newQuota \
    && echo -e "\nDisk Quota for $U has been set to $newQuota MB\n";
  checkquota -u $U;
}

## Lookup the DNS Nameservers on the host
nameserver () {
  echo;
  for x in $(grep ns[1-2] ~iworx/iworx.ini | cut -d\" -f2;); do
    echo "$x ($(dig +short $x))";
  done;
  echo;
}

## Quick summary of domain DNS info
ddns () {
  if [[ -z "$@" ]]; then
    read -p "Domain Name: " D;
  else
    D="$@";
  fi
  for x in $(echo $D | sed 's/\// /g'); do
    echo -e "\nDNS Summary: $x\n$(dash 79)";
    for y in a aaaa ns mx txt soa; do
      dig +time=2 +tries=2 +short $y $x +noshort;
      if [[ $y == 'ns' ]]; then
        dig +time=2 +tries=2 +short $(dig +short ns $x) +noshort \
          | grep -v root;
      fi;
    done;
    dig +short -x $(dig +time=2 +tries=2 +short $x) +noshort;
    echo;
  done
}

## List server IPs, and all domains configured on them.
domainips () {
  echo;
  for I in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.'); do
    printf "  ${BRIGHT}${YELLOW}%-15s${NORMAL}  " "$I";
    D=$(grep -l $I /etc/httpd/conf.d/vhost_[^000_]*.conf | cut -d_ -f2 | sed 's/.conf$//');
    for x in $D; do
      printf "$x ";
    done;
    echo;
  done;
  echo
}

## Find IPs in use by a Siteowrx account
accountips () {
  domaincheck -a $1;
}

## Find IPs in use by a Reseller account
resellerips () {
  domaincheck -r $1;
}

## Find IPs that are not configured in any vhost files
freeips () {
  echo;
  for x in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.'); do
    printf "\n%-15s " "$x";
    grep -l $x /etc/httpd/conf.d/vhost_[^000_]*.conf 2> /dev/null;
  done \
    | grep -v \.conf$ \
    | column -t;
  echo
}

## Check if gzip is working for domain(s)
chkgzip () {
  echo;
  if [[ -z "$@" ]]; then
    read -p "Domain name(s): " DNAME;
  else
    DNAME="$@";
  fi
  for x in "$DNAME"; do
    curl -I -H 'Accept-Encoding: gzip,deflate' $x;
  done;
  echo
}

## CD to document root in vhost containing the given domain
cdomain () {
  if [[ -z "$@" ]]; then
    echo -e "\n  Usage: cdomain <domain.tld>\n";
    return 0;
  fi
  vhost=$(grep -l " $(echo $1 | sed 's/\(.*\)/\L\1/g')" /etc/httpd/conf.d/vhost_[^000]*.conf)
  if [[ -n $vhost ]]; then
    cd $(awk '/DocumentRoot/ {print $2}' $vhost | head -1);
    pwd;
  else
    echo -e "\nCould not find $1 in the vhost files!\n";
  fi
}

## Attempt to list Secondary Domains on an account
ldomains () {
  DIR=$PWD;
  cd /home/$(getusr);
  for x in */html; do
    echo $x \
      | sed 's/\/html//g';
  done;
  cd $DIR
}

## Edit a list of vhosts in a loop for adding temp fixes
tempfix(){
  for x in $(echo "$@" | sed 's/\// /g'); do
    vim /etc/httpd/conf.d/vhost_$x.conf;
  done;
  httpd -t \
    && service httpd reload
}

## List the usernames for all accounts on the server
laccounts () {
  ~iworx/bin/listaccounts.pex \
    | awk '{print $1}';
}

## List Sitworx accouts sorted by Reseller
lreseller () {
  ( nodeworx -u -n -c Siteworx -a listAccounts \
    | sed 's/ /_/g' \
    | awk '{print $5,$2,$10}';
  nodeworx -u -n -c Reseller -a listResellers \
    | sed 's/ /_/g' \
    | awk '{print $1,"0.Reseller",$3}' )\
    | sort -n \
    | column -t \
    | sed 's/\(.*0\.Re.*\)/\n\1/' \
    | grep -Ev '^1 ';
  echo;
}

## List the daily snapshots for a database to see the dates/times on the snapshots
lsnapshots () {
  echo;
  if [[ -z "$1" ]]; then
    read -p "Database Name: " DBNAME;
  else
    DBNAME="$1";
  fi
  ls -lah /home/.snapshots/daily.*/localhost/mysql/$DBNAME.sql.gz;
  echo
}

## Add PHP-FPM fix for pointer method Magento Multistores
fpmfix () {
  if [[ -z $1 || $1 == '.' ]]; then
    D=$(pwd | sed 's:^/chroot::' | cut -d/ -f4);
  else
    D=$(echo $1 | sed 's:/::g');
  fi
  vhost="/etc/httpd/conf.d/vhost_${D}.conf"

  if [[ -f $vhost ]]; then
    sed -i 's/\(RewriteCond.*\.fcgi\)/\1\n  # ----- PHP-FPM-Multistore-Fix -----\n  SetEnvIf REDIRECT_MAGE_RUN_CODE (\.\+) MAGE_RUN_CODE=\$1\n  SetEnvIf REDIRECT_MAGE_RUN_TYPE (\.\+) MAGE_RUN_TYPE=\$1\n  # ----- PHP-FPM-Multistore-Fix -----/g' $vhost
    httpd -t && service httpd reload && echo -e "\nFPM fix has been applied to $(basename $vhost)\n"
  else
    echo -e "\n$(basename $vhost) not found!\n";
  fi
}

## Enable zlib.output_compression for a user's PHP-FPM config pool
fpmgzip () {
  fpmconfig -g;
}

## Enable allow_url_fopen for a users PHP-FPM config pool
fpmfopen () {
  fpmconfig -f;
}

## Create Magento Multi-Store Symlinks
magsymlinks () {
  echo;
  U=$(getusr);
  if [[ -z $1 ]]; then
    read -p "Domain Name: " D;
  else
    D=$1;
  fi
  for X in app includes js lib media skin var; do
    sudo -u $U ln -s /home/$U/$D/html/$X/ $X;
  done;
  echo;
  read -p "Copy .htaccess and index.php? [y/n]: " yn;
  if [[ $yn == "y" ]]; then
    for Y in index.php .htaccess; do
      sudo -u $U cp /home/$U/$D/html/$Y .;
    done;
  fi
}

## Use CSR or CRT, generate a new key and CSR (SHA-256).
sslrekey(){
  if [[ -z $1 ]]; then
    read -p "Domain Name: " domain;
  else
    domain="$(echo $1 | sed 's:/::g')";
  fi

  csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
  crtfile="/home/*/var/${domain}/ssl/${domain}.crt"

  if [[ -f $(echo $csrfile) ]]; then
    subject="$(openssl req -in $csrfile -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
    openssl req -nodes -sha256 -newkey rsa:2048 -keyout new.$domain.priv.key -out new.$domain.csr -subj "$subject" \
      && cat new.${domain}.*
  elif [[ -f $(echo $crtfile) ]]; then
    subject="$(openssl x509 -in $crtfile -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
    openssl req -nodes -sha256 -newkey rsa:2048 -keyout new.$domain.priv.key -out new.$domain.csr -subj "$subject" \
      && cat new.${domain}.*
  else
    echo -e "\nNo CSR/CRT to souce from!\n"
  fi
}

## Use CSR or CRT, and KEY, generate new CSR (SHA-256)
sslrehash(){
  if [[ -z $1 ]]; then
    read -p "Domain Name: " domain;
  else
    domain="$(echo $1 | sed 's:/::g')";
  fi

  keyfile="/home/*/var/${domain}/ssl/${domain}.priv.key"
  csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
  crtfile="/home/*/var/${domain}/ssl/${domain}.crt"

  if [[ -f $(echo $csrfile) && -f $(echo $keyfile) ]]; then
    subject="$(openssl req -in $csrfile -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
    openssl req -nodes -sha256 -new -key $keyfile -out $domain.sha256.csr -subj "${subject}" \
      && cat $domain.sha256.csr
  elif [[ -f $(echo $crtfile) && -f $(echo $keyfile) ]]; then
    subject="$(openssl x509 -in $crtfile -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
    openssl req -nodes -sha256 -new -key $keyfile -out $domain.sha256.csr -subj "${subject}" \
      && cat $domain.sha256.csr
  else
    echo -e "\nNo CSR/CRT or KEY to souce from!\n"
  fi
}

## Generate DCV file from the hash of the CSR for a Domain
dcvfile(){
  if [[ -z $1 ]]; then
    read -p "Domain: " domain;
  elif [[ $1 == '.' ]]; then
    domain=$(pwd -P | sed 's:/chroot::' | cut -d/ -f4);
  else
    domain=$1;
  fi
  csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
  if [[ -f $(echo $csrfile) ]]; then
    md5=$(openssl req -in $csrfile -outform DER | openssl dgst -md5 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
    sha1=$(openssl req -in $csrfile -outform DER | openssl dgst -sha1 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
    echo -e "${sha1}\ncomodoca.com" > ${md5}.txt;
    chown $(getusr). ${md5}.txt
  else
    echo "Could not find csr for ${domain}!";
  fi
}

## Create symlinks to log directories for user
linklogs(){
  DIR=$PWD;
  U=$(getusr);
  cd /home/$U/;
  sudo -u $U mkdir logs
  for x in var/*/logs/; do
    sudo -u $U ln -s ../$x logs/$(echo $x | awk -F/ '{print $2}');
  done;
  if [[ -f var/php-fpm/error.log ]]; then
    sudo -u $U ln -s ../var/php-fpm/ logs/php-fpm;
  fi
  echo -e "\nLinks to log directories created in:\n$PWD/logs/\n";
  cd $DIR
}

## Find files group owned by username in employee folders or temp directories
savethequota(){
  find /home/tmp -type f -size +100000k -group $(getusr) -exec ls -lah {} \;
  find /tmp -type f -size +100000k -group $(getusr) -exec ls -lah {} \;
  find /home/nex* -type f -group $(getusr) -exec ls -lah {} \;
}

## Give a breakdown of user's large disk objects
diskhogs(){
  if [[ $@ =~ "-h" ]]; then
    echo -e "\n Usage: diskhogs [maxdepth] [-d]\n";
    return 0;
  fi;
  if [[ $@ =~ [0-9]{1,} ]]; then
    DEPTH=$(echo $@ | grep -Eo '[0-9]{1,}');
  else
    DEPTH=3;
  fi;
  echo -e "\n---------- Large Directories $(dash 51)";
  du -h --max-depth $DEPTH | grep -E '[0-9]G|[0-9]{3}M';
  if [[ ! $@ =~ '-d' ]]; then
    echo -e "\n---------- Large Files $(dash 57)";
    find . -type f -size +100000k -group $(getusr) -exec ls -lah {} \;;
  fi;
  echo -e "\n---------- Large Databases $(dash 53)";
  du -sh /var/lib/mysql/$(getusr)_* \
    | grep -E '[0-9]G|[0-9]{3}M';
  echo
}

## Give a breakdown of user's disk usage by area of use
diskusage(){
  DIR=$PWD;
  cd /home/$(getusr)
  echo -e "\n---------- File Usage ----------";
  du -h --max-depth 2 \
    | grep -v var;
  echo -e "\n---------- Mail Usage ----------";
  du -sh var/*/mail/*/Maildir;
  echo -e "\n---------- Log File Usage ----------";
  du -sh var/*/logs;
  du -sh var/php-fpm/ 2> /dev/null;
  echo -e "\n---------- Database Usage ----------";
  du -sh /var/lib/mysql/$(getusr)_*;
  echo;
  cd $DIR
}

## Setup SSH for me, so I can transfer files from HOST
givemessh(){
  echo;
  PASS=$(xkcd) && nksshd userControl -Csr $SUDO_USER -p $PASS
  if [[ -z "$1" ]]; then
    echo;
    read -p "Hostname: " HOST;
  else HOST="$1";
  fi
  whitelist ssh $(dig +short $HOST) "# $HOST for file transfer"
}

## Bash completion for Whitelist
_whitelist(){
  local cur prev opts base
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts="ftp mysql other ssh -h --help"

  case ${prev} in
    f|ftp|m|mysql|o|other )
      COMPREPLY=( $(compgen -W "in out" -- ${cur}) )
      return 0 ;;
    *) ;;
  esac

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0;
}

## Shortcut for piping math equation(s) into bc
calc(){
  if [[ -z "$@" ]]; then
    echo -e "\nThis function requires a parameter.\n";
  else
    echo;
    for x in "$@"; do
      printf "$x = ";
      echo "scale=5;$x" \
        | bc;
    done;
    echo;
  fi
}

## Truncate large log files, chown and move the original for later review
trimfile(){
  U=$(getusr);
  if [[ -z "$1" ]]; then
    echo;
    read -p "File Name (without path): " FILE;
  else
    FILE="$1";
  fi
  chown root:root $FILE && tail -n10000 $FILE > temp.txt && mv $FILE ~/"$(pwd | sed 's:^/::;s:/:-:g')--$(date +%Y.%m.%d)--$FILE" && mv temp.txt $FILE && chown $U. $FILE
  echo "Operation completed.";
  echo
}

## List the last 10 reboots
findreboot(){
  last \
    | awk '/boot/ {$4=""; print}' \
    | head -n10 \
    | column -t;
}

## Simple System Status to check if services that should be running are running
srvstatus(){
  echo;
  FORMAT="%-18s %s\n";
  printf "$FORMAT" " Service" " Status";
  printf "$FORMAT" "$(dash 18)" "$(dash 55)";
  for x in $(chkconfig --list | awk '/3:on/ {print $1}' | sort); do
    printf "$FORMAT" " $x" " $(service $x status 2> /dev/null | head -1)";
  done;
  echo
}

## Show geographical and network information about a given IP address
ipinfo(){
  for x in "$@"; do
    echo;
    echo -e "GEO-IP INFO: ($x)\n$(dash 79)";
    curl -s ipinfo.io/$x \
      | sed 's/,\"/\n\"/g' \
      | awk -F\" '/[a-z]/ {printf "%8s : %s\n",$2,$4}';
  done;
  echo
}

## Show requests to all sites on server for the last hour in the transfer logs
hits_lasthour(){
  if [[ -z $1 ]]; then top=10; else top=$1; fi
  echo;
  printf "%-30s %-10s\n" " Domain Name" " Hits";
  printf "%-30s %-10s\n" "$(dash 30)" "$(dash 10)";
  for x in /home/*/var/*/logs/transfer.log; do
    printf "%-30s %-10s\n" " $(echo $x | cut -d/ -f5)" " $(grep -Ec "$(date +%d/%b/%Y:%H:)" $x)";
  done \
    | sort -rn -k2 \
    | head -n$top
  echo
}

## Check for sites getting more than 1000 POST requests from a single IP.
brutecheck(){
  echo;
  if [[ -n $1 ]]; then
    SEARCH="$1";
    echo "Search: $SEARCH";
  else
    read -p 'Search: ' SEARCH;
  fi;
  echo
  for x in $(grep -Ec "POST.*${SEARCH}" /home/*/var/*/logs/transfer.log /var/log/interworx/*/*/logs/transfer.log /var/log/interworx/*/logs/transfer.log 2> /dev/null | grep -E [0-9]{4}$ | cut -d/ -f5); do
    echo $x;
    traffic $x ip -s "POST.*${SEARCH}" \
      | grep -E [0-9]{4};
    echo;
  done
}

## Search send log(s) for a domain (look for error messages)
sendlog(){
  if [[ -n $1 ]]; then
    D=$1;
  else
    read -p "Domain: " D;
  fi
  if [[ $2 == 'all' ]]; then
    cat /var/log/send/* \
      | tai64nlocal \
      | egrep -B2 -A8 "$D" \
      | less;
  else
    cat /var/log/send/current \
      | tai64nlocal \
      | egrep -B2 -A8 "$D" \
      | less;
  fi
}
