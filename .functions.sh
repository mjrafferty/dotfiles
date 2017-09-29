#! /bin/bash

##### Change Directory #####

# Change directory to a website's docroot
cdd () {
  local query domains domain alias docroot subdir selection;
  declare -a docroot;

  # Obtain input string
  if [ -n "$1" ]; then
    query=$1;
  else
    query="$(pwd | sed -e 's_.*home/[^/]*/\([^/]*\)/html.*_\1_' -e 's_.*home/[^/]*/var/\([^/]*\)/.*_\1_')";
  fi
  # Gather relevant domain information
  domains=$(grep -EH "Server(Name|Alias).* $query" /etc/httpd/conf.d/vhost_* \
    | sed -r 's/.*vhost_(.*).conf.* ('"$query"'[^ ]*).*/\1\t\2/' \
    | sort -u);

  domain=($(echo "$domains" \
    | cut -f1));

  alias=($(echo "$domains" \
    | cut -f2));

  for (( i=1; i<=${#alias[@]}; i++ )); do
    docroot[$i]=($(sed -nr 's/.*DocumentRoot (.*)/\1/p' /etc/httpd/conf.d/vhost_"${domain[$i]}".conf \
      | head -n1));
  done;

  # Evaluate subdomains
  for (( i=1; i<=${#alias[@]}; i++ )); do
    if [[ ${alias[$i]} == *.${domain[$i]} ]]; then
      subdir="$(echo "${alias[$i]}" | sed -nr 's/(.*).'"${domain[$i]}"'/\1/p')";
      if [ -d "${docroot[$i]}"/"$subdir" ]; then
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

# Change directory to a website's log dir
cdlogs () {
  local query vhosts logsdir selection;
  declare -a logsdir;

  if [ -n "$1" ]; then
    query=$1;
  else
    query="$(pwd | sed -e 's_.*home/[^/]*/\([^/]*\)/html.*_\1_' -e 's_.*home/[^/]*/var/\([^/]*\)/.*_\1_')";
  fi

  # Gather relevant domain information
  vhosts=($(grep -El "Server(Name|Alias).* $query" /etc/httpd/conf.d/vhost_*));

  for (( i=1; i<=${#vhosts[@]}; i++ )); do
    logsdir[$i]=($(sed -nr 's_.*ErrorLog (.*)/error.log_\1_p' "${vhosts[$i]}" \
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


#### Bandwidth ######

# Show top IP addresses by bandwidth usage
ipsbymb () {
  zless -f "$@" \
    | awk '{tx[$1]+=$10} END {for (x in tx) {print x, "\t", tx[x]/1048576, "M"}}' \
    | sort -k 2n \
    | tail -n 20 \
    | tac;
}

# Show top user agents by bandwidth usage
uabymb () {
  zless -f "$@" \
    | cut -d\  -f10- \
    | grep -v "^-" \
    | sed 's_^\([0-9]*\).*" "\(.*\)"$_\1\t\2_' \
    | awk -F "\t" '{tx[$2]+=$1} END {for (x in tx) {print tx[x]/1048576, "M","\t",x}}' \
    | sort -hr \
    | head -n 20;
}

# Show top referers by bandwidth usage
refbymb () {
  zless -f "$@" \
    | cut -d\  -f10,11 \
    | grep -v "^-" \
    | awk '{tx[$2]+=$1} END {for (x in tx) {print tx[x]/1048576, "M","\t",x}}' \
    | sort -hr \
    | head -n 20;
}

# Show top uris by bandwidth usage
uribymb () {
  zless -f "$@" \
    | cut -d\  -f7,10 \
    | grep -v "\-$" \
    | sed 's/?.* / /' \
    | awk '{tx[$1]+=$2} END {for (x in tx) {print tx[x]/1048576, "M","\t",x}}' \
    | sort -hr \
    | head -n 20;
}

# Show total bandwidth usage
totalmb () {
  zless -f "$@" \
    | awk '{sum+=$10} END {print sum/1048576 " M"}'
}


##### Traffic #######

# Show top IP addresses by number of hits
topips () {
  zless -f "$@" \
    | awk '{freq[$1]++} END {for (x in freq) {print freq[x], x}}' \
    | sort -rn \
    | head -20;
}

# Show top user agents by number of hits
topuseragents () {
  zless -f "$@" \
    | cut -d\  -f12- \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -20;
}

# Show top uris by number of hits
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

#Top query strings
topquery () {
  zless -f "$@" \
    | grep -hv " 403 " \
    | sed -n 's_.*?\(.*\) HTTP/[0-2]\.[0-2]".*_\1_p' \
    | sort \
    | uniq -c \
    | sort -hr \
    | head;
}

# Show top referers by number of hits
topref () {
  zless -f "$@" \
    | grep -hv " 403 " \
    | cut -d\  -f11 \
    | sort \
    | uniq -c \
    | sort -hr \
    | head;
}

# Show number of hits per hour
hitsperhour () {
  zless -f "$@" \
    | sed 's_.*../.*/....:\(..\).*_\1_' \
    | sort -h \
    | uniq -c \
    | sed 's_ *\(.*\) \(..\)_\2:00\t\1 hits_'
}

# Show number of hits received on every site in the last hour
hitslasthour () {
  local prevhour regex;
  local -a times;

  times=($(date +%Y:%R | sed -e 's/:/ /g' -e 's/\([0-9]\)\([0-9]\)$/\1 \2/'))

  if [ "${times[2]}" -eq 00 ]; then
    prevhour=23;
  else
    prevhour=$(printf "%02d" "$((times[2]-1))");
  fi
  if [ "${times[3]}" -eq 5 ]; then
    regex="${times[1]}:($prevhour:5[${times[4]}-9]|${times[2]}:)"
  else
    regex="${times[1]}:($prevhour:(${times[3]}[${times[4]}-9]|[$((times[3]+1))-5][0-9])|${times[2]}:)"
  fi

  echo -e "\n";
   find {/var/log/,/home/*/var/*/logs} -name transfer.log -exec grep -EHc "$regex" {} + \
    | grep -v ":0$" \
    | sed 's_log:_log\t_' \
    | sort -nr -k 2 \
    | awk 'BEGIN{print "\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2}';
  echo -e "\n"
}


##### Disk Usage ######

## Find files group owned by username in employee folders or temp directories
savethequota(){
  find /home/tmp -type f -size +100000k -group "$(getusr)" -exec ls -lah {} \;
  find /home/nex* -type f -group "$(getusr)" -exec ls -lah {} \;
}

## Adjust user quota on the fly using Nodeworx CLI
bumpquota(){

  local newQuota primaryDomain;

  if [[ -z "$*" || $1 == "*-h" ]]; then
    echo -e "\n Usage: bumpquota <username> <newquota>\n  Note: <username> can be '.' to get user from PWD\n";
    return 0;
  elif [[ $1 == "^[a-z].*$" ]]; then
    U=$1;
    shift;
  elif [[ $1 == '.' ]]; then
    U=$(getusr);
    shift;
  fi

  newQuota=$1;
  primaryDomain=$(~iworx/bin/listaccounts.pex | grep "$U" | awk '{print $2}')

  nodeworx -u -n -c Siteworx -a edit --domain "$primaryDomain" --OPT_STORAGE "$newQuota" \
    && echo -e "\nDisk Quota for $U has been set to $newQuota MB\n";

  checkquota -u "$U";
}


#### Special Databases ########

# Connect to the iworx database
iworxdb () {
  local user pass database socket;

  user="iworx";
  pass="$(grep '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)";
  database="iworx";
  socket="$(grep '^dsn.orig="mysql://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | awk -F'[()]' '{print $2}')";

  mysql -u"$user" -p"$pass" -S"$socket" -D"$database";
}

# Vpopmail
vpopdb () {
  $(grep -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@";
}

# ProFTPd
ftpdb () {
  $(grep -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@";
}


###### IP addresses ##########

## List server IPs, and all domains configured on them.
domainips () {
  local D;
  echo;
  for I in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.'); do
    printf "  ${BRIGHT}${YELLOW}%-15s${NORMAL}  " "$I";
    D=$(grep -l "$I" /etc/httpd/conf.d/vhost_[^0]*.conf | cut -d_ -f2 | sed 's/.conf$//');
    for x in $D; do
      printf "%s " "$x";
    done;
    echo;
  done;
  echo
}

## Find IPs in use by a Siteowrx account
accountips () {
  domaincheck -a "$1";
}

## Find IPs in use by a Reseller account
resellerips () {
  domaincheck -r "$1";
}

## Find IPs that are not configured in any vhost files
freeips () {
  echo;
  for x in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.'); do
    printf "\n%-15s " "$x";
    grep -l "$x" /etc/httpd/conf.d/vhost_[^0]*.conf 2> /dev/null;
  done \
    | grep -v \.conf$ \
    | column -t;
  echo
}

## Add an IP to a Siteworx account
addip () {
  nodeworx -u -n -c Siteworx -a addIp --domain "$(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')" --ipv4 "$1";
}

# Check several email blacklists for the given IP
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
    swaks -4 -t iflcars.com@gmail.com -li "$b"  \
      | grep -iE 'block|rdns|550|521|554';
    echo;
    echo;
  done;
}


####### Nodeworx ##########

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

# Lookup Siteworx account details
acctdetail () {
  nodeworx -u -n -c Siteworx -a querySiteworxAccountDetails --domain "$(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')"\
    | sed 's:\([a-zA-Z]\) \([a-zA-Z]\):\1_\2:g;s:\b1\b:YES:g;s:\b0\b:NO:g' \
    | column -t
}

## Enable Siteworx backups for an account
addbackups () {
  nodeworx -u -n -c Siteworx -a edit --domain "$(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')" --OPT_BACKUP 1;
}



## Simple System Status to check if services that should be running are running
srvstatus(){
  local servicelist;
  servicelist=($(chkconfig --list | awk '/3:on/ {print $1}' | sort));

  printf "\n%-18s %s\n%-18s %s\n" " Service" " Status" "$(dashes 18)" "$(dashes 55)";

  for x in ${servicelist[*]}; do
    printf "%-18s %s\n" " $x" " $(service "$x" status 2> /dev/null | head -1)";
  done;
  echo
}

## Lookup the DNS Nameservers on the host
nameservers () {
  local nameservers;
  echo;
  nameservers=($(sed -n 's/ns[1-2]="\([^"]*\).*/\1/p' ~iworx/iworx.ini))
  for (( x=1; x<=${#nameservers[@]}; x++ )) do
    echo "${nameservers[$x]} ($(dig +short "${nameservers[$x]}"))";
  done
  echo;
}

# Stat the files listed in the given maldet report
maldetstat () {
  local files;
  files=($(awk '{print $3}' /usr/local/maldetect/sess/session.hits."$1"));
  for (( x=1; x<=${#files[@]}; x++ )); do
    stat "${files[$x]}";
  done
}

# Check for duplicate files
finddups () {
  find "$1" -type f -print0 \
    | xargs -0 md5sum \
    | sort \
    | uniq -w32 --all-repeated=separate
}

## Add date and time with username and open server_notes.txt for editing
srvnotes () {
  echo -e "\n#$(date) - ${SUDO_USER/nex/}" >> /etc/nexcess/server_notes.txt;
  nano /etc/nexcess/server_notes.txt;
}

## Create or add http-auth section for given .htaccess file
htaccessauth () {
  echo -e "\n# ----- Password Protection Section -----
  \nAuthUserFile $(pwd)/.htpasswd
  AuthGroupFile /dev/null
  AuthName \"Authorized Access Only\"
  AuthType Basic
  \nRequire valid-user
  \n# ----- Password Protection Section -----\n" >> .htaccess \
    && chown "$(getusr)". .htaccess;
}

## Generate nexinfo.php to view php info in browser
nexinfo () {
  echo '<?php phpinfo(); ?>' > nexinfo.php \
    && chown "$(getusr)". nexinfo.php;
  echo -e "\nhttp://$(pwd | sed 's:^/chroot::' | cut -d/ -f4-)/nexinfo.php created successfully.\n" \
    | sed 's/html\///';
}

## System resource usage by account
sysusage () {
  local COLSORT=2;

  printf "\n%-10s %10s %10s %10s %10s\n%s\n" "User" "Mem (MB)" "Process" "CPU(%)" "MEM(%)" "$(dashes 54)";
  ps aux \
    | awk ' !/^USER/ { mem[$1]+=$6; procs[$1]+=1; pcpu[$1]+=$3; pmem[$1]+=$4; } END { for (i in mem) { printf "%-10s %10.2f %10d %9.1f%% %9.1f%%\n", i, mem[i]/(1024), procs[i], pcpu[i], pmem[i] } }' \
    | sort -nrk$COLSORT \
    | head;
  echo;
}

## Quick summary of domain DNS info
ddns () {
  local D;
  if [[ -z "$*" ]]; then
    vared -p "Domain Name: " -c D;
  else
    D="$*";
  fi
  for x in $(echo "$D" | sed 's/\// /g'); do
    echo -e "\nDNS Summary: $x\n$(dashes 79)";
    for y in a aaaa ns mx txt soa; do
      dig +time=2 +tries=2 +short $y "$x" +noshort;
      if [[ $y == 'ns' ]]; then
        dig +time=2 +tries=2 +short "$(dig +short ns "$x")" +noshort \
          | grep -v root;
      fi;
    done;
    dig +short -x "$(dig +time=2 +tries=2 +short "$x")" +noshort;
    echo;
  done
}

## Check if gzip is working for domain(s)
chkgzip () {
  local DNAME;
  echo;
  if [[ -z "$*" ]]; then
    vared -p "Domain name(s): " -c DNAME;
  else
    DNAME="$*";
  fi
  for x in $DNAME; do
    curl -I -H 'Accept-Encoding: gzip,deflate' "$x";
  done;
  echo
}

## List the daily snapshots for a database to see the dates/times on the snapshots
lsnapshots () {
  local DBNAME;
  echo;
  if [[ -z "$1" ]]; then
    vared -p "Database Name: " -c DBNAME;
  else
    DBNAME="$1";
  fi
  ls -lah /home/.snapshots/daily.*/localhost/mysql/"$DBNAME".sql.gz;
  echo
}

## Create Magento Multi-Store Symlinks
magsymlinks () {
  local U D yn;
  echo;
  U=$(getusr);
  if [[ -z $1 ]]; then
    vared -p "Domain Name: " -c D;
  else
    D=$1;
  fi
  for X in app includes js lib media skin var; do
    sudo -u "$U" ln -s /home/"$U"/"$D"/html/$X/ $X;
  done;
  echo;
  vared -p "Copy .htaccess and index.php? [y/n]: " -c yn;
  if [[ $yn == "y" ]]; then
    for Y in index.php .htaccess; do
      sudo -u "$U" cp /home/"$U"/"$D"/html/$Y .;
    done;
  fi
}
