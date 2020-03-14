#! /bin/bash

readonly AWK='/bin/awk'
readonly DATE='/bin/date'
readonly FIND='/bin/find'
readonly GREP='/bin/grep'
readonly HEAD='/usr/bin/head'
readonly MAIL='/bin/mail'
readonly PS='/bin/ps'
readonly SED='/bin/sed'
readonly SORT='/bin/sort'
readonly TR='/usr/bin/tr'
readonly WC='/usr/bin/wc'

readonly OS_VERSION=$("$GREP" -Po 'release \K\d' /etc/centos-release);

LAST_EMAIL=$(cat /root/lastmonitoremail);

#SENDTO=("robert.cowher@grizzlysts.com" "esg@nexcess.net")
SENDTO=("robert.cowher@grizzlysts.com" "esg@nexcess.net" "tgrote@mcfeelys.com" "rcflisik@brilliantnets.com")

# Check low memory in swap or RAM
_memcheck () {

  local active total swptotal swpfree;

  active=$("$SED" -n 's/Active:\s*\([0-9]*\).*/\1/p' /proc/meminfo)
  total=$("$SED" -n 's/MemTotal:\s*\([0-9]*\).*/\1/p' /proc/meminfo)
  swptotal=$("$SED" -n 's/SwapTotal:\s*\([0-9]*\).*/\1/p' /proc/meminfo)
  swpfree=$("$SED" -n 's/SwapFree:\s*\([0-9]*\).*/\1/p' /proc/meminfo)

  if (( active >= (9 * total / 10) )); then

    echo "System memory low.";

  fi

  if (( swpfree > 0 && swpfree <= (swptotal / 10) )); then

    echo "Swap low.";

  fi

}

# Check CPU load
_loadavgchk () {

  local avgs cpucount;

  mapfile -t avgs < <("$TR" ' ' '\n' < /proc/loadavg)

  avgs[0]=$(printf "%.*f\n" 0 "${avgs[0]}")
  avgs[1]=$(printf "%.*f\n" 0 "${avgs[1]}")
  avgs[2]=$(printf "%.*f\n" 0 "${avgs[2]}")


  cpucount="$("$GREP" -c ^processor /proc/cpuinfo)"

  if (( avgs[1] >= cpucount )); then

    echo "5 min load average high";

  fi

}

# Check all users for being at their max php child procs
_maxphpprocs () {

  local phprocs numprocs users max;

  phprocs=$("$PS" -eo args \
    | "$AWK" '/^php-fpm: pool/ && $NF != "www"{  a[$NF] += 1 } END {for(i in a){ printf "%-10s %d\n",i,a[i] } }' \
    | "$SORT" -k2nr);

  mapfile -t numprocs < <(echo "$phprocs" | "$AWK" '{print $2}' | tr ' ' '\n');
  mapfile -t users < <(echo "$phprocs" | "$AWK" '{print $1}' | tr ' ' '\n');

  for ((x=0;x<"${#users[@]}";x++)); do


    if (( OS_VERSION == 7 )); then

      max="$("$FIND" /opt/remi/php*/root/etc/php-fpm.d/*.conf -name "${users[$x]}.conf" \
        -exec /bin/awk -F '=' '/^[^#;]*pm.max_children/{ gsub(/\ [^0-9]*$/,"",$2); gsub(/^\ */,"",$2); print $2  }' {} + \
        | "$HEAD" -n1)"

    else

      max="$("$FIND" {/opt/nexcess/php*/root,}/etc/php-fpm.d/*.conf -name "${users[$x]}.conf" \
        -exec /bin/awk -F '=' '/^[^#;]*pm.max_children/{ gsub(/\ [^0-9]*$/,"",$2); gsub(/^\ */,"",$2); print $2  }' {} + \
        | "$HEAD" -n1)"

    fi

    if (( numprocs[x] >= max )); then

      echo "${users[$x]} at max children.";

    fi

  done

}

# Check for apache being at max clients
_maxclients () {

  local count max;

  count="$(( $("$PS" -Chttpd | "$WC" -l ) -1 ))";
  max="$("$SED" -n 's/^[^#]*MaxClients\s*\([0-9]*\).*/\1/p' /etc/httpd/conf/httpd.conf | "$HEAD" -n1)";

  if (( count >= max )); then

    echo "Apache at MaxClients.";

  fi

}

_mailSupport () {

  local curr_time;
  curr_time="$("$DATE" "+%s")";

  if [[ -n "$1" ]] && (( curr_time > ( LAST_EMAIL + 3600 ) )); then

    LAST_EMAIL="$curr_time";

    "$MAIL" -s "$HOSTNAME: $*" "${SENDTO[@]}"  <<-EOF

$HOSTNAME: $@

Please investigate ASAP and update ticket with client:

https://nocworx.nexcess.net/ticket/1322097

EOF

    echo "$LAST_EMAIL" > /root/lastmonitoremail

    /usr/sbin/snaps

  fi

}

# Main
main () {

  local message func_list

  func_list=(_loadavgchk _memcheck _maxphpprocs _maxclients)
  message=()

  for x in ${func_list[*]}; do

    #shellcheck disable=SC2207
    message+=($($x));

  done

  _mailSupport "${message[@]}";

}

main;
