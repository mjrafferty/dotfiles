# vim:ft=zsh

# shellcheck disable=SC2155
[[  -z  $MYSHELL     ]]  &&  export readonly MYSHELL="$(readlink /proc/$$/exe)"

if [[ "$MYSHELL" =~ zsh ]]; then
  ARRAY_START="1";
else
  ARRAY_START="0";
fi

##### Disk Usage ######

## Adjust user quota on the fly using nodeworx CLI
bumpquota(){
  local newQuota primaryDomain;

  if [[ -z "$*" || $1 == "*-h" ]]; then
    echo -e "\n Usage: bumpquota <username> <newquota>\n  Note: <username> can be '.' to get user from PWD\n";
    return 0;
  elif [[ "$1" == [a-z,0-9]* ]]; then
    U="$1";
    shift;
  elif [[ "$1" == '.' ]]; then
    U="$(getusr)";
    shift;
  fi

  newQuota="$1";
  primaryDomain="$(~iworx/bin/listaccounts.pex | grep "$U" | awk '{print $2}')"

  nodeworx -u -n -c Siteworx -a edit --domain "$primaryDomain" --OPT_STORAGE "$newQuota" \
    && echo -e "\nDisk Quota for $U has been set to $newQuota MB\n";

  checkquota -u "$U";
}


#### Special Databases ########

# Connect to the iworx database
iworxdb () {
  local user pass database socket;

  user="iworx";
  pass="$(grep '^dsn.orig="mysqli\?://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)";
  database="iworx";
  socket="$(grep '^dsn.orig="mysqli\?://iworx:[A-Za-z0-9]' /usr/local/interworx/iworx.ini | awk -F'[()]' '{print $2}')";

  mysql -u"$user" -p"$pass" -S"$socket" -D"$database";
}

# Vpopmail
vpopdb () {
  local user pass database socket;

  user="iworx_vpopmail"
  pass="$(grep -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | cut -d: -f3 | cut -d\@ -f1)"
  database="iworx_vpopmail";
  socket="$(grep -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | awk -F'[()]' '{print $2}')";

  mysql -u"$user" -p"$pass" -S"$socket" -D"$database" "$@";
}

# ProFTPd
ftpdb () {
  local user pass database socket;

  user="iworx_ftp"
  pass="$(grep -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1 | cut -d: -f3 | cut -d\@ -f1)"
  database="iworx_ftp";
  socket="$(grep -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1| awk -F'[()]' '{print $2}')";

  mysql -u"$user" -p"$pass" -S"$socket" -D"$database" "$@";
}

# Spam Assassin DB
spamdb () {
  local user pass database socket;

  user="iworx_spam"
  pass="$(grep bayes_sql_password /etc/mail/spamassassin/local.cf| awk '{print $2}')"
  database="iworx_spam";
  socket="$(grep 'user_scores_dsn' /etc/mail/spamassassin/local.cf | sed -n 's|.*mysql_socket=\(.*\)|\1|p')";

  mysql -u"$user" -p"$pass" -S"$socket" -D"$database" "$@";
}


###### ip addresses ##########

## List server ips, and all domains configured on them.
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

## find ips that are not configured in any vhost files
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

## Add an ip to a Siteworx account
addip () {
  nodeworx -u -n -c Siteworx -a addip --domain "$(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')" --ipv4 "$1";
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
  nslookup "$ip" \
    | grep addr;
  echo 'http://multirbl.valli.org/lookup/'"$ip"'.html';
  echo 'http://www.senderbase.org/lookup/ip/?search_string='"$ip";
  echo 'https://www.senderscore.org/lookup.php?lookup='"$ip";
  echo '++++++++++++++++++++++++++++';
  for x in hotmail.com yahoo.com aol.com earthlink.net verizon.net att.net sbcglobal.net comcast.net xmission.com cloudmark.com cox.net charter.net mac.me; do
    echo;
    echo $x;
    echo '--------------------';
    swaks -q TO -t postmaster@$x -li "$ip" \
      | grep -iE 'block|rdns|550|521|554';
  done ;
  echo;
  echo 'gmail.com';
  echo '-----------------------';
  swaks -4 -t iflcars.com@gmail.com -li "$ip"  \
    | grep -iE 'block|rdns|550|521|554';
  echo;
  echo;
}


####### nodeworx ##########

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
  nodeworx -u -n -c Siteworx -a querySiteworxAccountDetails --domain "$(~iworx/bin/listaccounts.pex | awk "/^$(getusr)/ {print \$2}")" \
    | sed 's:\([a-zA-Z]\) \([a-zA-Z]\):\1_\2:g;s:\b1\b:YES:g;s:\b0\b:NO:g' \
    | column -t
}

######## Miscellaneous ########

## Simple System Status to check if services that should be running are running
srvstatus(){
  local servicelist;
  # shellcheck disable=SC2207
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
  # shellcheck disable=SC2207
  nameservers=($(sed -n 's/ns[1-2]="\([^"]*\).*/\1/p' ~iworx/iworx.ini))
  for (( x=ARRAY_START; x<${#nameservers[@]}+ARRAY_START; x++ )) do
    echo "${nameservers[$x]} ($(dig +short "${nameservers[$x]}"))";
  done
  echo;
}

# stat the files listed in the given maldet report
maldetstat () {
  local files;
  # shellcheck disable=SC2207
  files=($(awk '{print $3}' /usr/local/maldetect/sess/session.hits."$1"));
    for (( x=ARRAY_START; x<${#files[@]}+ARRAY_START; x++ )); do
      statt "${files[$x]}";
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
  echo -e "\n#$(date) - sudo_USER/nex/}" >> /etc/nexcess/server_notes.txt;
  $EDITOR /etc/nexcess/server_notes.txt;
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
  for x in $(echo "$D" | sed 's_\(https\?://\)\?\([^/]*\).*_\2_' | tr "[:upper:]" "[:lower:]"); do
    echo -e "\nDNS Summary: $x\n$(dashes 79)";
    for y in a aaaa ns mx txt soa; do
      dig +time=2 +tries=2 +short $y "$x" +noshort;
      if [[ $y == 'ns' ]]; then
        NS="$(dig +short ns "$x")";
        if [[ -n "$NS" ]]; then
          dig +time=2 +tries=2 +short "$NS" +noshort \
            | grep -v root;
        fi
      fi;
    done;
    echo;
    dig +short txt _domainkey."$x" +noshort;
    echo;
    dig +short txt default._domainkey."$x" +noshort;
    echo;
    dig +short txt _dmarc."$x" +noshort;
    echo;
    dig +short -x "$(dig +time=2 +tries=2 +short "$x")" +noshort;
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
    curl -I -H 'Accept-Encoding: gzip,deflate' "$x";
  done;
  echo
}

## List the daily snapshots for a database to see the dates/times on the snapshots
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
  ls -lah /home/.snapshots/daily.*/localhost/mysql/"$DBNAME".sql.xz;
  echo
}

## Create Magento Multi-Store Symlinks
magsymlinks () {
  local U D yn;
  echo;
  U=$(getusr);
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
    sudo -u "$U" ln -s /home/"$U"/"$D"/html/$X/ $X;
  done;
  echo;
  if [[ "$MYSHELL" =~ zsh ]]; then
    vared -p "Copy .htaccess and index.php? [y/n]: " -c yn;
  else
    read -rp "Copy .htaccess and index.php? [y/n]: " -c yn;
  fi
  if [[ $yn == "y" ]]; then
    for Y in index.php .htaccess; do
      sudo -u "$U" cp /home/"$U"/"$D"/html/$Y .;
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
  local user home item;
  local -a acls

  user="$(pwd | grep -Po "/(chroot/)?(home(/nexcess.net)?|local|data)/\K[^/]*")";

  if [[ "$user" == "$USER" || "$user" == "$SUDO_USER" ]]; then
    echo "You're already you."
    return 1;
  fi

  home="$(mktemp -d "/dev/shm/${HOME##*/}_tmp-home_XXXX")"

  if [[ -e "/home/${user}/.composer" ]]; then
    ln -s "/home/${user}/.composer" "${home}/.composer"
  fi

  acls=(
    "${HOME}/bin"
    "${HOME}/clients"
    "${HOME}/.local"
    "${HOME}/.my.cnf"
    "${HOME}/.mysql_history"
    "${HOME}/.mytop"
    "${HOME}/vim"
    "${HOME}/zsh"
    "${HOME}/.zshenv"
    "${HOME}/.zsh_history"
  )

  for item in "${acls[@]}"; do
    ln -s "${item}" "${home}"
  done

  _apply_acls() {
    chmod 711 "$HOME"
    setfacl -m "u:${user}:rwX" "${HISTFILE}"
    setfacl -m "u:${user}:rwX" "${home}"

    if [[ -n "${XDG_RUNTIME_DIR}" && -d "${XDG_RUNTIME_DIR}" ]]; then
      setfacl -R -m "u:${user}:rwX" "${XDG_RUNTIME_DIR}"
    fi

    for item in "${acls[@]}"; do
      if [[ -d "${item}" ]]; then
        setfacl -R -m "u:${user}:rwX" "${item}"
      elif [[ -f "${item}" ]]; then
        setfacl -m "u:${user}:rw" "${item}"
      fi
    done
  }

  _apply_acls

  _filewatcher() {
    local start_time current_time
    local max_runtime=7200
    start_time="$(date '+%s')"
    while true; do
      if inotifywait -q -t 600 -e attrib "${HISTFILE}" &> /dev/null; then
        _apply_acls
      fi
      current_time="$(date '+%s')"
      if (( current_time - start_time > max_runtime )); then
        break;
      fi
    done
  }

  _filewatcher &!

  watcher_pid="$!"

  # Switch user
  sudo \
    PM2_HOME="/home/${user}/.pm2" \
    XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" \
    HOME="$home" \
    TMUX="$TMUX" \
    -u "$user" \
    "$MYSHELL"

  kill "$watcher_pid"

  # Give me permissions on any files the user created in my home dir
  sudo -u "$user" find "$home" -user "$user" -exec setfacl -m u:"$USER":rwX {} +
  setfacl -R -x u:"$user" ~/

  # Revoke the permissions given to that user
  if [[ -n "$XDG_RUNTIME_DIR" ]]; then
    sudo -u "$user" find "$XDG_RUNTIME_DIR" -user "$user" -exec setfacl -m u:"$USER":rwX {} +
    setfacl -R -x u:"${user}" "${XDG_RUNTIME_DIR}"
  fi

  chmod 700 "$HOME"

  rm -r "$home"
}

## Find broken symbolic links
brokenlinks () {
  local tifs x check_path link dir;

  check_path="$1"

  [[ -z "$check_path" ]] && check_path="$PWD"

  tifs="$IFS";
IFS="
"

  for x in $(find "$check_path" -type l); do

    link="$(readlink "$x")" 2> /dev/null

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
    | jq '.traits.isp,.city.names.en,.country.names.en,.country.iso_code'
  }

urldecode() {
  perl -pe 's/\+/ /g; s/%([0-9a-f]{2})/chr(hex($1))/eig'
}

urlencode() {
  perl -pe 's/([^\n0-9a-zA-Z$-_.+!*'\''\(\),])/ sprintf "%%%02x", ord $1 /eg;'
}

weather() {
  # https://github.com/chubin/wttr.in
  curl -s wttr.in/$1
}

cht() {
  # https://github.com/chubin/cheat.sh
  curl -s cht.sh/$1
}

bitcoin() {
  # https://github.com/chubin/rate.sx
  curl -s rate.sx/$1
}

wolfram_alpha() {
  # https://github.com/dmi3/bin/blob/master/wa

  APPID=$(cat ~/git/stuff/keys/wolfram_alpha) # Get one at https://products.wolframalpha.com/api/
  VIEWER="kitty +kitten icat"                 # Use `VIEWER="display"` from imagemagick if terminal does not support images
  BG="transparent"                            # Transparent background
  FG="white"                                  # Match color to your terminal

  RESPONSE=$(curl -s "https://api.wolframalpha.com/v1/result?appid=$APPID&units=metric&" --data-urlencode "i=$*" | tee /dev/tty)

# Remove next if you are fine with text only api, and don't want to see any images
test "No short answer available" = "$RESPONSE" \
  && echo ", downloading full answer..." \
  && curl -s "https://api.wolframalpha.com/v1/simple?appid=${APPID}&units=metric&foreground=${FG}&background=${BG}" --data-urlencode "i=$*" \
  | $VIEWER || exit 0
}

unicode_chart() {
  local x y a

  for ((y=0;y<=65535;y++)); do
    for x in 0 1 2 3 4 5 6 7; do
      a=$(([##16]y))
      a="${(l:4::0:)a}"
      printf "%-10s %-10b" "\\u$a" "\\u$a "
      ((y++))
    done
    ((y--))
    echo
  done

  for ((y=65536;y<=1114109;y++)); do
    for x in 0 1 2 3 4 5 6 7; do
      a=$(([##16]y))
      printf "%-10s %-10b" "\\U$a" "\\U$a "
      ((y++))
    done
    ((y--))
    echo
  done
}

update_brew () {
  local f bin

  brew update;
  brew upgrade;
  brew cleanup;

  for f in $(find /usr/local/opt/*/bin/*); do

    bin="${f##*/}";

    if [[ -e /usr/local/bin/${bin} ]]; then
      rm -f "/usr/local/bin/${bin}";
    fi

    ln -sf "$f" "/usr/local/bin/${bin}";

  done

  for f in $(find /usr/local/opt/{grep,gnu-sed,gawk,coreutils,findutils}/bin/g*); do

    bin="${f##*/g}";

    if [[ -e "/usr/local/bin/${bin}" ]]; then
      rm -f "/usr/local/bin/${bin}";
    fi

    ln -sf "$f" "/usr/local/bin/${bin}";

  done
}

organize_pictures() {
  IFS="
"
  SOURCE_DIR="${1}"
  DESTINATION_DIR="${2}"

  for x in "${SOURCE_DIR}" "${DESTINATION_DIR}"; do
    if [[ ! -d "${x}" ]]; then
      echo "${x} is not a valid directory.";
      return 1;
    fi
  done

  for x in $(find "${SOURCE_DIR}" -type f ); do

    date="$(identify -format '%[EXIF:DateTimeOriginal]' "$x" 2> /dev/null)"; 
    [[ -z "$date" ]] && date="$(identify -format '%[EXIF:DateTime]' "$x")"; 
    [[ -z "$date" ]] && date="$(identify -format '%[date:modify]' "$x")";

    if [[ -n $date ]]; then

      year=$(echo $date | grep -Po '[1-2][0-9]{3}(?=.[0-9]{2}.[0-9]{2}.*)');
      month=$(echo $date | grep -Po '[1-2][0-9]{3}.\K[0-9]{2}(?=.[0-9]{2}.*)');

      x=$(echo $x | sed 's/^\.\///');

      echo "mkdir -p ${DESTINATION_DIR:-.}/${year}/${month}";
      mkdir -p "${DESTINATION_DIR:-.}/${year}/${month}";

      echo "mv ${x} ${DESTINATION_DIR:-.}/${year}/${month}/${x##*/}";
      mv "${x}" "${DESTINATION_DIR:-.}/${year}/${month}/${x##*/}";

    fi;

  done 2> pics_error.log
}

orphaned_files () {
  find / \( \
    -path /home/matt \
    -o -path /boot/efi \
    -o -path /dev \
    -o -path /etc/ca-certificates \
    -o -path /etc/ssl \
    -o -path /lib64/firmware \
    -o -path /lib64/modules \
    -o -path /proc \
    -o -path /run \
    -o -path /sys \
    -o -path /tmp \
    -o -path /opt/wine \
    -o -path /opt/Windows_Users \
    -o -path /usr/lib64/clang \
    -o -path /usr/lib64/dracut \
    -o -path /usr/lib64/gcc \
    -o -path /usr/lib64/llvm \
    -o -path /usr/lib64/mono \
    -o -path /usr/lib64/portage \
    -o -path /usr/local/portage \
    -o -path /usr/portage \
    -o -path /usr/share/mime \
    -o -path /usr/src \
    -o -path /var/cache \
    -o -path /var/db \
    -o -path /var/log \
    -o -path /var/lib/sddm/.cache \
    -o -path /var/tmp/portage \) \
    -prune -o -type f -print0 \
    | xargs -0 qfile -o 2>&1 \
    | less
}

get() {
  local -a curl_opts;

  curl_opts=(
    "--location" 
    "--progress-bar" 
    "--remote-name" 
    "--remote-time"
    "--remote-header-name"
    "--compressed" 
    "--retry" "5"
    )

    if [[ -n "$GET_COOKIES" ]]; then
      curl_opts+=("--header" "Cookie: ${GET_COOKIES}")
    fi

    if [[ -n "$GET_USER_AGENT" ]]; then
      curl_opts+=("--user-agent" "${GET_USER_AGENT}")
    fi

  curl ${curl_opts[@]} "${@}"
}

haproxy_api() {
  local cmd socket;

  cmd="$*"
  socket="/var/lib/haproxy/stats"

  if [[ -z "$cmd" ]]; then
    echo "prompt"
    cat
  else
    echo "$cmd"
  fi \
    | nc -U /var/lib/haproxy/stats
}

haproxy_stats () {
  sort="$1"
  header="IP PHP/24h PHP_Rate/1m Conn_Rate/1m Conn_cur HTTP_Req_Rate/1m HTTP_Err_Rate/1m Bytes_In/24h Bytes_Out/24h Unique_Urls/24h Crawl_Rate/1m"

  [[ -z "${sort}" ]] && sort="5"

  {
    echo "$header"

    haproxy_api show table global-rates \
      | awk '
    {
      if(match($1,/^0x/)){
        {
          gsub(/[^ ]*=/,"",$0);
          gsub("::ffff:","",$2);
          $1=""; $3=""; $4="";
          print $0
        }
      }
    }' \
      | sort -k "$sort" -nr \
      | sup_formatbytes 8 \
      | sup_formatbytes 9
  } \
    | column -t
}


userhist() {
  if [[ -n "$1" ]]; then
    file="/home/${1}/.bash_history"
  else
    file="/home/$(getusr)/.bash_history"
  fi

  if [[ -r "${file}" ]]; then
    awk 'BEGIN{counter=0} /^#/ {counter++; gsub(/^#/,"",$1); time=strftime("%Y-%m-%d %H:%M:%S", $1); printf(" %s  %s ",counter,time); next}{print $0}' "${file}"
  else
    echo "${file} does not exist or is not readable."
    return 1;
  fi
}


bw_auto() {
	local bw_status output session_id 

  BW_PASSWORD_FILE="${HOME}/Documents/bw.txt"

	if [[ -n "${BW_PASSWORD_FILE}" && -e "${BW_PASSWORD_FILE}" ]]; then
		bw_status="$(\bw status | jq -r .status)"

		if [[ "${bw_status}" == "locked" ]]; then
			output="$(\bw unlock --passwordfile "${BW_PASSWORD_FILE}")"
			session_id="$(echo "$output" | grep -m1 -Po 'export BW_SESSION="\K[^"]*')"
			export BW_SESSION="${session_id}"
		fi
	fi

  \bw "$@"

}

alias bw=bw_auto
