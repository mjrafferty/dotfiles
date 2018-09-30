
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
  domains=$($GREP -EH "^[^#]*Server(Name|Alias).* $query" /etc/httpd/{conf.d/vhost_*.conf,tmpdomains.d/*.conf} 2> /dev/null \
    | $SED -r 's/.*_(.*).conf:.* ('"$query"'[^ ]*).*/\1\t\2/' \
    | $SORT -u);

  domain=($(echo "$domains" \
    | $CUT -f1));

  alias=($(echo "$domains" \
    | $CUT -f2));

  for (( i=ARRAY_START; i<${#alias[@]}+ARRAY_START; i++ )); do
    docroot[$i]=$($GREP -Poh '^[^#]*DocumentRoot.* \K/([^/]+/?)+' /etc/httpd/{conf.d/vhost_,tmpdomains.d/*_}"${domain[$i]}".conf 2> /dev/null \
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
  vhosts=($($GREP -El "^[^#]*Server(Name|Alias).* $query" /etc/httpd/{conf.d/vhost_*.conf,tmpdomains.d/*.conf} 2> /dev/null));

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
  $FIND {/var/log/,/home/*/var/*/logs} \( -name "transfer.log" -o -name "transfer-ssl.log" \) \
    -exec "$GREP" -EHc "$regex" {} + \
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
  $FIND {/var/log/,/home/*/var/*/logs} \( -name "transfer.log" -o -name "transfer-ssl.log" \)\
    -exec "$GREP" -HPic "$regex"'.*\] "\S* (?!.*(/static/|(\.(otf|txt|jpeg|ico|svg|jpg|css|js|gif|png|woff)))[^?].* 200 .*)' {} + \
    | $GREP -v ":0$" \
    | $SED 's_log:_log\t_' \
    | $SORT -nr -k 2 \
    | $AWK 'BEGIN{print "\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2}';
  echo -e "\n"
}

