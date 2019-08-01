#! /bin/bash

# shellcheck disable=SC2154
if [[ "$nex_user_shell" == "zsh" ]]; then
  ARRAY_START="1";
else
  ARRAY_START="0";
fi

# Extract domain from URI
sup_normalizedomain () {
  echo "$1" | sed 's_\(https\?://\)\?\([^/]*\).*_\2_' | tr "[:upper:]" "[:lower:]"
}

# Get the owner username from the current directory
sup_getusr() {
  pwd | sed 's:^/chroot::' | cut -d/ -f3;
}

# Change directory to a website's docroot
sup_cdd () {
  local query domains domain alias docroot subdir selection;
  declare -a docroot;

  # Obtain input string
  if [ -n "$1" ]; then
    query=$(sup_normalizedomain "$1");
  else
    query="$(pwd | grep -Po '(/chroot)?/(home|local)/[^/]+(/var)?/\K[^/]*')";
  fi

  if [ -z "$query" ]; then
    echo "No domain specified."
    return 1;
  fi

  # Gather relevant domain information
  domains=$(grep -EH "^[^#]*Server(Name|Alias).* $query" /etc/httpd/{conf.d/vhost_*.conf,tmpdomains.d/*.conf} 2> /dev/null \
    | sed -r 's/.*_(.*).conf:.* ('"$query"'[^ ]*).*/\1\t\2/' \
    | sort -u);
  # shellcheck disable=SC2207
  domain=($(echo "$domains" \
    | cut -f1));

  # shellcheck disable=SC2207
  alias=($(echo "$domains" \
    | cut -f2));

  for (( i=ARRAY_START; i<${#alias[@]}+ARRAY_START; i++ )); do
    docroot[i]=$(grep -Poh '^[^#]*DocumentRoot.* \K/([^/]+/?)+' /etc/httpd/{conf.d/vhost_,tmpdomains.d/*_}"${domain[i]}".conf 2> /dev/null \
      | head -n1);
    matched_alias[i]=${alias[i]};
  done;

  # Evaluate subdomains
  for (( i=ARRAY_START; i<${#alias[@]}+ARRAY_START; i++ )); do
    if [[ ${alias[i]} == *.${domain[i]} ]]; then
      subdir="$(echo "${alias[i]}" | sed -nr 's/(.*).'"${domain[i]}"'/\1/p')";
      if [ -d "${docroot[i]}"/"$subdir" ]; then
        docroot[i]="${docroot[i]}/${subdir}";
      fi;
    fi;
  done;

  # Get rid of duplicate docroots
  # shellcheck disable=SC2207
  docroot=($(printf "%s\n" "${docroot[@]}" | sort -u));

  # Evaluate too few or too many docroots
  if [ -z "${docroot[ARRAY_START]}" ]; then
    echo "Domain not found";
    return;
  elif [ "${docroot[ARRAY_START+1]}" ]; then

    echo "Domain ambiguous. Select docroot:";

    for (( i=ARRAY_START; i<${#docroot[@]}+ARRAY_START; i++ )); do
      echo "$i  ${docroot[i]}";
    done | column -t;

    echo;

    if [[ "$nex_user_shell" =~ zsh ]]; then
      vared -p "Choose docroot number:" -c selection;
    else
      read -rp "Choose docroot number:" selection;
    fi

    docroot[ARRAY_START]=${docroot[selection]};
    matched_alias[ARRAY_START]=${matched_alias[selection]};

  fi;

  # Change working directory to docroot
  cd "${docroot[ARRAY_START]}" || echo "Could not locate docroot";

  # Print matched alias and new working directory
  echo "${matched_alias[ARRAY_START]}";
  pwd;

}

# Change directory to a website's log dir
sup_cdlogs () {

  local query vhosts logsdir selection;
  declare -a logsdir;

  if [ -n "$1" ]; then
    query=$(sup_normalizedomain "$1");
  else
    query="$(pwd | grep -Po '(/chroot)?/(home|local)/[^/]+(/var)?/\K[^/]*')";
  fi

  if [ -z "$query" ]; then
    echo "No domain specified."
    return 1;
  fi

  # Gather relevant domain information
  # shellcheck disable=SC2207
  vhosts=($(grep -El "^[^#]*Server(Name|Alias).* $query" /etc/httpd/{conf.d/vhost_*.conf,tmpdomains.d/*.conf} 2> /dev/null));

  for (( i=ARRAY_START; i<${#vhosts[@]}+ARRAY_START; i++ )); do
    logsdir[i]=$(grep -Poh '[^#]*ErrorLog.* \K/([^/]+/)+' "${vhosts[i]}" \
      | head -n1);
  done;

  # Evaluate too few or too many directories
  if [ -z "${logsdir[ARRAY_START]}" ]; then
    echo "Log directory not found";
    return;
  elif [ "${logsdir[ARRAY_START+1]}" ]; then

    echo "Domain ambiguous. Select log directory:";

    for (( i=ARRAY_START; i<${#logsdir[@]}+ARRAY_START; i++ )); do
      echo "$i  ${logsdir[i]}";
    done | column -t;

    echo;

    if [[ "$nex_user_shell" =~ zsh ]]; then
      vared -p "Choose log directory number:" -c selection;
    else
      read -rp "Choose log directory number:" selection;
    fi

    logsdir[ARRAY_START]=${logsdir[selection]};

  fi;

  # Change working directory to log directory
  cd "${logsdir[ARRAY_START]}" || echo "Could not locate log directory";
  pwd;

}

#### Bandwidth ######

# Show top ip addresses by bandwidth usage
sup_ipsbymb () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | grep -Poa ".*\" \d{3} \d*(?= \")" \
    | awk '{gsub(/,/,"",$2); if (index($2,"-") == 0){tx[$2"-X"]+=$(NF)} else {tx[$1]+=$(NF)}} END {for (x in tx) {printf "%10.2f\t%s\n",tx[x],x}}' \
    | sort -k1nr \
    | head -n "$headnum" \
    | sup_formatbytes 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show top user agents by bandwidth usage
sup_uabymb () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | sed -nr 's|.* [0-9]{3} ([0-9]*) \"[^\"]*\" \"([^\"]*)\".*|\1\t\2|p' \
    | awk -F "\t" '{tx[$2]+=$1} END {for (x in tx) {printf "%10.2f\t%s\n",tx[x],x}}' \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatbytes 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show top referers by bandwidth usage
sup_refbymb () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | sed -nr 's|.* [0-9]{3} ([0-9]*) \"([^\"]*)\" \"[^\"]*\".*|\1\t\2|p' \
    | awk '{tx[$2]+=$1} END {for (x in tx) {printf "%10.2f\t%s\n",tx[x],x}}' \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatbytes 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'
}

# Show top uris by bandwidth usage
sup_uribymb () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | sed -nr 's|.*\] \"\S* ([^?, ]*\??)[^\"]*\" [0-9]{3} ([0-9]*) .*|\1\t\2|p' \
    | awk '{tx[$1]+=$2} END {for (x in tx) {printf "%10.2f\t%s\n",tx[x],x}}' \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatbytes 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show top file types by bandwidth usage
sup_typebymb () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | sed -nr 's|.*\] \"\S* [^?, ]*(\.[^?,/, ]*)\??[^\"]*\" [0-9]{3} ([0-9]*) .*|\1\t\2|p' \
    | awk '{tx[$1]+=$2} END {for (x in tx) {printf "%10.2f\t%s\n",tx[x],x}}' \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatbytes 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show total bandwidth usage
sup_totalmb () {

  sup_catlogs "$@" \
    | grep -o '" [0-9][0-9][0-9] [0-9]*' \
    | awk '{sum+=$3} END {print sum}' \
    | sup_formatbytes 1;

}


##### Traffic #######

# Show top ip addresses by number of hits
sup_topips () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | awk '{colcount=NF; gsub(/,/,"",$2); if (match($2,"-") == 0 && colcount > 1){freq[$2"-X"]++} else {freq[$1]++}} END {for (x in freq) {printf "%10d\t%s\n",freq[x],x}}' \
    | sort -rn \
    | head -n "$headnum" \
    | sup_formatnum 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show top user agents by number of hits
sup_topuseragents () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | grep -Poa '" "\K[^"]*' \
    | sort \
    | uniq -c \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatnum 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show top uris by number of hits
sup_topuri () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | grep -Poa "\] \"\S* \K[^?, ]*\??" \
    | sort \
    | uniq -c \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatnum 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Top query strings
sup_topquery () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | sed -n 's_.*?\(.*\) HTTP/[0-2]\.[0-2]".*_\1_p' \
    | sort \
    | uniq -c \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatnum 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show top referers by number of hits
sup_topref () {

  local headnum=20;

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_catlogs "$@" \
    | grep -Poa "[0-9]{3} ([0-9]*|-) \K\"[^\"]*\"" \
    | sort \
    | uniq -c \
    | sort -hr \
    | head -n "$headnum" \
    | sup_formatnum 1 \
    | awk '{$1=sprintf("%10s\t",$1); print $0;}'

}

# Show number of requests received on every site in the last hour
sup_reqslasthour () {

  local prevhour regex;
  local -a times;

  if [[ $1 == [0-9][0-9]:[0-9][0-9] ]]; then
    # shellcheck disable=SC2207
    times=($(date "+%Y:${1}" | sed -e 's/:/ /g' -e 's/\([0-9]\)\([0-9]\)$/\1 \2/'))
  else
    # shellcheck disable=SC2207
    times=($(date "+%Y:%R" | sed -e 's/:/ /g' -e 's/\([0-9]\)\([0-9]\)$/\1 \2/'))
  fi

  if [ "${times[ARRAY_START+1]}" -eq 00 ]; then
    prevhour=23;
  else
    prevhour=$(printf "%02d" "$((times[ARRAY_START+1]-1))");
  fi

	if [ "${times[ARRAY_START+2]}" -eq 5 ]; then

		regex="${times[ARRAY_START]}:($prevhour:5[${times[ARRAY_START+3]}-9]|${times[ARRAY_START+1]}:([0-4][0-9]|[0-5][0-${times[ARRAY_START+3]}]))"

	elif [ "${times[ARRAY_START+2]}" -eq 0 ]; then

		regex="${times[ARRAY_START]}:($prevhour:(${times[ARRAY_START+2]}[${times[ARRAY_START+3]}-9]|[$((times[ARRAY_START+2]+1))-5][0-9])|${times[ARRAY_START+1]}:0[0-${times[ARRAY_START+3]}])"

	else

		regex="${times[ARRAY_START]}:($prevhour:(${times[ARRAY_START+2]}[${times[ARRAY_START+3]}-9]|[$((times[ARRAY_START+2]+1))-5][0-9])|${times[ARRAY_START+1]}:([0-$((times[ARRAY_START+2]-1))][0-9]|[0-${times[ARRAY_START+2]}][0-${times[ARRAY_START+3]}]))"

  fi

	find {/var/log/interworx/{,*/},/home/*/var/}*/logs/transfer{,-{,ssl-}"$(date "+%F")"}.log -type f \
		-exec grep -EHc "$regex" {} +  2> /dev/null \
    | grep -v ":0$" \
    | sed 's_log:_log\t_' \
    | sort -nr -k 2 \
    | sup_formatnum 2 \
    | awk 'BEGIN{print "\n\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2} END{print "\n"}';

}

# Show number of requests that likely hit php on every site in the last hour
sup_phplasthour () {

  local prevhour regex;
  local -a times;

  phpregex='.*\] "\S* (?!.*(/static/|(\.(otf|txt|jpeg|ico|svg|jpg|css|js|gif|png|woff)))[^?].*" (200|304) .*)'

  if [[ $1 == [0-9][0-9]:[0-9][0-9] ]]; then
    # shellcheck disable=SC2207
    times=($(date "+%Y:${1}" | sed -e 's/:/ /g' -e 's/\([0-9]\)\([0-9]\)$/\1 \2/'))
  else
    # shellcheck disable=SC2207
    times=($(date "+%Y:%R" | sed -e 's/:/ /g' -e 's/\([0-9]\)\([0-9]\)$/\1 \2/'))
  fi

  if [ "${times[ARRAY_START+1]}" -eq 00 ]; then
    prevhour=23;
  else
    prevhour=$(printf "%02d" "$((times[ARRAY_START+1]-1))");
  fi

	if [ "${times[ARRAY_START+2]}" -eq 5 ]; then

		regex="${times[ARRAY_START]}:($prevhour:5[${times[ARRAY_START+3]}-9]|${times[ARRAY_START+1]}:([0-4][0-9]|[0-5][0-${times[ARRAY_START+3]}]))"

	elif [ "${times[ARRAY_START+2]}" -eq 0 ]; then

		regex="${times[ARRAY_START]}:($prevhour:(${times[ARRAY_START+2]}[${times[ARRAY_START+3]}-9]|[$((times[ARRAY_START+2]+1))-5][0-9])|${times[ARRAY_START+1]}:0[0-${times[ARRAY_START+3]}])"

	else

		regex="${times[ARRAY_START]}:($prevhour:(${times[ARRAY_START+2]}[${times[ARRAY_START+3]}-9]|[$((times[ARRAY_START+2]+1))-5][0-9])|${times[ARRAY_START+1]}:([0-$((times[ARRAY_START+2]-1))][0-9]|[0-${times[ARRAY_START+2]}][0-${times[ARRAY_START+3]}]))"

  fi

	find {/var/log/interworx/{,*/},/home/*/var/}*/logs/transfer{,-{,ssl-}"$(date "+%F")"}.log -type f \
    -exec grep -HPic "$regex""$phpregex" {} +  2> /dev/null \
    | grep -v ":0$" \
    | sed 's_log:_log\t_' \
    | sort -nr -k 2 \
    | sup_formatnum 2 \
    | awk 'BEGIN{print "\n\t\t\tTransfer Log\t\t\t\t\tHits Last Hour"}{printf "%-75s %-s\n", $1, $2} END{print "\n"}';

}

# View system call information from strace
sup_stracecalls () {

  __straceCallsAwk () {
    awk '
    {
      gsub(/<|>/,"",$(NF));

      if ( match($3,/^(access|lstat|open|munmap|mmap|stat|brk|chdir|socket|setitimer)\(/) )
      {
        syscall = gensub(/(\().*/,"\\1","G",$3);
      }
      else if ( match($3,/^poll\(/) )
      {
        syscall = gensub(/(\(.{7}).*/,"\\1","G",$3);
      }
      else {
        syscall = gensub(/(\(..).*/,"\\1","G",$3);
      }

      time[syscall]+=$(NF);
      numcalls[syscall]++;
    }

    END {
      for (x in time)
      {
        printf "%s\t%10.4f\t%s\n",x,time[x],numcalls[x];
      }
    }'
  }

  echo;
  (printf "syscall\ttime\tquantity\n%s\t%s\t%s\n" "----------" "----------" "----------"
  cat "$@" \
    | __straceCallsAwk  \
    | sort -k2nr) \
    | head -n30 \
    | column -t

  echo;

}

# Compares Total time vs userspace time throughout an strace
sup_straceanalyze () {

  local file;

  file="$1"

  awk '{ gsub(/<|>/,"",$(NF)); printf "%10.6f %10.6f\n",(total_sum += $2),(user_sum += ($2 - $(NF))) }' "$file" \
    | paste - "$file" \
    | less -S;

}

# Show connections made in strace and their file descriptors.
sup_straceconnect () {

  __straceConnectAwk() {
    awk '
    BEGIN {
      print "Line\tFile_desc\tPort\tSocket/Address";
      print "----\t---------\t----\t--------------";
    }
    {
      gsub(/:/,"",$1);
      gsub(/(connect\(|,)/,"",$2);
      if (match($4,"sin_port")) {
        gsub(/(.*\(|\),)/,"",$4);
        gsub(/(.*\("|"\).*)/,"",$5);
        print $1,$2,$4,$5
      } else {
        gsub(/(.*="|"}.*)/,"",$4);
        print $1,$2,"0",$4
      }
    }
    END {

    }'
  }

  zless "$@" \
    | grep -no ' connect(.*'  \
    | __straceConnectAwk \
    | column -t

}

# List files that had either an open or stat syscall
sup_straceopened () {

  sup_catlogs "$@" \
    | grep -Poh ' (open|stat)\(\"(/chroot/(home|local)/[^/]*/[^/]*/[^/]*/|)\K[^"]*(?!.* = -1)' \
    | sort -u

}

# List all database queries that were performed during strace
sup_stracequeries () {

  local x connections arga;

  arga=("$@")

  # shellcheck disable=SC2207
  connections=($( cat "${arga[@]}" | grep -Pon 'connect\(\K[0-9]*(?=.*(htons\(3306\)|mysql.sock))'));

  if [[ -z "${connections[ARRAY_START]}"  || -n ${arga[ARRAY_START+1]} ]]; then

    # shellcheck disable=SC2016
		sup_catlogs "$@" \
      | grep -Po '(write|sendto)\(\d*, "(\W|\d|\w{1,2}(\W|\d))*\K.*", ' \
      | sed -e 's_", $_;_' -e 's/\\r/ /g' -e 's/\\n/ /g' -e 's/\\t/ /g' \
      | less -SF

  else

    for x in ${connections[*]}; do

      # shellcheck disable=SC2016
      tail -n +"${x/:*/}" "${arga[ARRAY_START]}" \
        | grep -Po '(write|sendto)\('"${x/*:/}"', "(\W|\d|\w{1,2}(\W|\d))*\K.*", ' \
        | sed -e 's_", $_;_' -e 's/\\r/ /g' -e 's/\\n/ /g' -e 's/\\t/ /g'

    done \
      | less -SF

  fi


}

# Print modsec rules triggered by given uniqueid
sup_modsecrules () {

  local exclude_rules modgrep_logs

  exclude_rules="^981176$|^4011015$|^4049";

  if [[ -z "$1" || "$*" =~ --help ]]; then

    cat <<- EOF

  Prints out mod security rules triggered by the provided
  unique id.
  Usage:  sup_modsecrules OPTIONS <unique id>

    -d|--deep     Scan older audit logs as well as todays.
    -h|--help     Print this message

EOF
    return 0;

  elif [[ "$1" == "-d" || "$1" == "--deep" ]]; then
    # shellcheck disable=SC2207
    modgrep_logs=($(find /var/log/httpd -name "modsec_audit*" -ctime -7))
    shift;
  else
    modgrep_logs=("/var/log/httpd/modsec_audit.log")
  fi

  sup_catlogs "${modgrep_logs[@]}" \
    | grep -F "$1" \
    | grep -Po ' \[id\s+\\"\K[0-9]*' \
    | grep -Ev "$exclude_rules" \
    | sort -u;

}

# Print apache block for modsec rules triggered by provided ip
sup_modsecbyip () {

  local ip user uniqueids domain deep uris logs logentries

  user=$(pwd | grep -Po "/((chroot/)?home/|local/)\K[^/]*")
  domain=$(pwd | grep -Po "/((chroot/)?home/|local/)${user}/(|var/)\K[^/]*")

  if [[ -z "$1" || "$*" =~ --help || $* =~ -h ]]; then

		cat <<- EOF

  Identifies all mod security rules triggered by the given IP address
  in the current error.log file. Can be run from any directory associated
  with the desired domain.

  Usage:  sup_modsecbyip OPTIONS <target ip>

    -d|--deep     Scan older error logs as well as todays.
    -h|--help     Print this message

EOF
    return 0;

  elif [[ "$1" == "-d" || "$1" == "--deep" ]]; then
    # shellcheck disable=SC2207
    logs=($(find {/home/"${user}"/var/"${domain}"/logs/,}{error{,-ssl}.log,tmpdomain-error-}* 2> /dev/null))
    shift;
    deep="--deep";
  else
    # shellcheck disable=SC2207
    logs=($(find {/home/"${user}"/var/"${domain}"/logs/,}{error{,-ssl},tmpdomain-error-"$(date "+%F")"}.log 2> /dev/null))
  fi

  ip="$1";

  # Grab necessary data from log
  logentries=$(sup_catlogs "${logs[@]}" | grep -Po "${ip}.*\[uri \K.*" | awk -F\" '{print $4"\t"$2}');

  # Find unique uris
  # shellcheck disable=SC2207
  uris=($(echo "$logentries" | cut -f2 | cut -d/ -f1-4 | sort -u ));

  echo "  <IfModule mod_security2.c>";

  # Print LocationMatch block for each uri
  for ((x=ARRAY_START;x<${#uris[@]}+ARRAY_START;x++)); do

    # shellcheck disable=SC2207
    uniqueids=($(echo "$logentries" | grep "${uris[x]}" | cut -f1));

    echo "    <LocationMatch ${uris[x]} >";
    echo "      # Ticket ID: $TICKET"

    for ((y=ARRAY_START;y<${#uniqueids[@]}+ARRAY_START;y++)); do
      if [[ -n "$deep" ]]; then
        sup_modsecrules "$deep" "${uniqueids[y]}";
      else
        sup_modsecrules "${uniqueids[y]}";
      fi
    done \
      | sort -u \
      | sed 's/^/      SecRuleRemoveById /';

    echo "    </LocationMatch>";

  done;
  echo "  </IfModule>";

}

sup_catlogs () {

  local arg link gzfiles zipfiles xzfiles regfiles

  gzfiles=()
  zipfiles=()
  xzfiles=()
  regfiles=()

  if [[ -n "$1" ]]; then

    for arg in "$@"; do

      if [[ -L "$arg" ]]; then

        link="$(readlink "$arg")"

        if [[ -f "$link" ]];then
          arg="$link"
        else
          arg="${arg%/*}/${link}"
        fi

      fi

      if [[ -f "$arg" ]]; then

        case "$arg" in
          *.gz)
            gzfiles+=("$arg");
            ;;
          *.zip)
            zipfiles+=("$arg");
            ;;
          *.xz)
            xzfiles+=("$arg");
            ;;
          *)
            regfiles+=("$arg");
            ;;
        esac

      fi

    done

    [[ -n "${gzfiles[ARRAY_START]}" ]] && zcat "${gzfiles[@]}"
    [[ -n "${zipfiles[ARRAY_START]}" ]] && zcat "${zipfiles[@]}"
    [[ -n "${xzfiles[ARRAY_START]}" ]] && xzcat "${xzfiles[@]}"
    [[ -n "${regfiles[ARRAY_START]}" ]] && cat "${regfiles[@]}"

  else

    cat;

  fi

}

sup_formatbytes() {

  local column

  column="$1"

  if [[ -z "$column" ]]; then
    column="1"
  fi

  awk "{
    if ( \$${column} >= 1073741824  )
      {
        \$${column}=sprintf(\"%'.1fGB\",\$${column}/1024/1024/1024);
      }
    else if ( \$${column} >= 1048576  )
      {
        \$${column}=sprintf(\"%'.1fMB\",\$${column}/1024/1024);
      }
    else if ( \$${column} >= 1024  )
      {
        \$${column}=sprintf(\"%'.1fKB\",\$${column}/1024);
      }
    else
      {
        \$${column}=sprintf(\"%'.1fB\",\$${column});
      }
    print \$0;
  }";

}

sup_formatnum() {

  local column

  column="$1"

  if [[ -z "$column" ]]; then
    column="1"
  fi

  awk "{
    \$${column}=sprintf(\"%'d\",\$${column});
    print \$0;
  }";

}

# Convert ipv4 IP to binary form
sup_iptobinary() {

  awk '
  function d2b(d,  b) {
    while(d) {
      b=d%2b;
      d=int(d/2);
    }
    return(b);
  }
  BEGIN {
    octet="((1[0-9][0-9]|2([0-4][0-9]|5[0-5]))|[1-9][0-9]|[0-9])";
    ip="^"octet"."octet"."octet"."octet"$";
  }
  {
    for(x=1;x<=NF;x++){
      if(match($(x),ip) > 0){
        split($(x),bin,".");
        $(x)=sprintf("%08i.%08i.%08i.%08i",d2b(bin[1]),d2b(bin[2]),d2b(bin[3]),d2b(bin[4]));
      }
    }
    print $0;
  }'

}

# Convert from binary to ipv4
sup_bintoip() {

  tr -d ' .' \
    | fold -w 32 \
    | tee \
    | sed -e 's/.\{8\}/&,".",/g' -e 's/^/ibase=2; print /' -e 's/,".",$//' -e 's/$/,"\\n"/' \
    | bc

}

_sup_parsecidr () {

  local top current_block max_block num_ips last_ip current_ip total_hits current_hits;

  if [[ "$1" == "top" ]]; then
    top="1";
  fi

  max_block="16";
  current_block="32";
  num_ips=0;

  while read -r ip; do

    ((num_ips++));

    ## Read first IP from list
    if [[ -z "${last_ip[ARRAY_START]}" ]]; then

      # shellcheck disable=SC2207
      last_ip=($(echo "$ip" | awk '{print $1}' | tr -d '.' | sed 's/./& /g'));
      # shellcheck disable=SC2207
      current_ip=($(echo "$ip" | awk '{print $1}' | tr -d '.' | sed 's/./& /g'));
      current_hits="$(echo "$ip" | awk '{print $2}')";
      total_hits="${current_hits}";
      continue;

    fi

    # Set currently active IP
    # shellcheck disable=SC2207
      current_ip=($(echo "$ip" | awk '{print $1}' | tr -d '.' | sed 's/./& /g'));
    current_hits="$(echo "$ip" | awk '{print $2}')";

    # Walk through bits
    for ((x=ARRAY_START;x<${#current_ip[@]}+ARRAY_START;x++)); do

      # if bits match, skip to next bit
      if (( current_ip[x] == last_ip[x] )); then

        continue;

      else

        if (( x-ARRAY_START >= max_block )); then

          # shellcheck disable=SC2030
          current_block="$((x-ARRAY_START))";
          ((total_hits+=current_hits));
          continue 2;

        else

          ((num_ips--));


          if ((top==1)); then
            echo "${total_hits} ${num_ips} $(echo "${last_ip[@]}" | sup_bintoip)/${current_block}";
          else
            echo "${num_ips} $(echo "${last_ip[@]}" | sup_bintoip)/${current_block}";
          fi

          num_ips=1;
          total_hits=${current_hits};
          last_ip=("${current_ip[@]}")
          current_block="32";

          break;

        fi
      fi

    done

  done

  if ((top==1)); then
    echo "${total_hits} ${num_ips} $(echo "${current_ip[@]}" | sup_bintoip)/${current_block}"
  else
    echo "${num_ips} $(echo "${current_ip[@]}" | sup_bintoip)/${current_block}"
  fi

}

# Print out subnets containing provided ips in cidr notation
sup_ipstocidr() {

  local octet="((1[0-9]{2}|2([0-4][0-9]|5[0-5]))|[1-9][0-9]|[0-9])";
  local header="  %-8s      %-12s\n------------------------------\n"

  grep -Po "(${octet}\.){3}${octet}" \
    | sort -u \
    | sup_iptobinary \
    | _sup_parsecidr \
    | sort -k1,2 -nr \
		| awk 'BEGIN{printf("'"$header"'"),"IPs seen","CIDR range"}{printf("%8s  %18s\n",$1,$2);}'

}

sup_topcidr() {

  local headnum=20;
  local header="  %-10s   %-6s      %-12s\n--------------------------------------------\n"

  if [[ $1 == [0-9]* ]]; then
    headnum="$1";
    shift;
  fi

  sup_topips 99999999 \
    | grep -v ':' \
    | sort -k2 \
    | awk '{gsub(/\,/,"",$1); gsub(/-X/,"",$2); print $2"\t"$1}' \
    | sup_iptobinary \
    | _sup_parsecidr "top" \
    | sort -nr \
    | head -n "$headnum" \
    | sup_formatnum 1 \
    | sup_formatnum 2 \
		| awk 'BEGIN{printf("'"$header"'"),"# Requests","IPs seen","CIDR range"}{printf("%10s  %8s    %18s\n",$1,$2,$3);}'

}
