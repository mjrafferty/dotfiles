#! /bin/bash

if [[ -s /etc/nexcess/server_notes.txt && -r /etc/nexcess/server_notes.txt ]]; then
    echo "Server notes"
    echo "------------"
    cat /etc/nexcess/server_notes.txt
fi

if [[ -e /opt/nexcess/php54u/root/usr/bin/php ]]; then
    alias php54='/opt/nexcess/php54u/root/usr/bin/php'
fi
if [[ -e /opt/nexcess/php55u/root/usr/bin/php ]]; then
    alias php55='/opt/nexcess/php55u/root/usr/bin/php'
fi
if [[ -e /opt/nexcess/php56u/root/usr/bin/php ]]; then
    alias php56='/opt/nexcess/php56u/root/usr/bin/php'
fi
if [[ -e /opt/nexcess/php70u/root/usr/bin/php ]]; then
    alias php70='/opt/nexcess/php70u/root/usr/bin/php'
fi
if [[ -e /opt/nexcess/php71u/root/usr/bin/php ]]; then
    alias php71='/opt/nexcess/php71u/root/usr/bin/php'
fi

compctl -u whichphp
whichphp ()
{
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "help" ]]; then
        printf "Usage: whichphp [USERNAME]\n\n";
        printf "[USERNAME] must be the username of target user for which to display the PHP version.\n";
        return 1;
    fi
    phpregex="php[0-9][0-9]"
    bashrcphpregex="^(\t|\ )*source.*?php[0-9][0-9].*enable(\t|\ )*$"
    crontabphpregex="^(\t|\ )*PATH.*?php[0-9][0-9].*(\t|\ )*$";
    defaultphpversion=$(/usr/bin/php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+');
    if ! find /opt/nexcess/*/root/usr/bin/php &> /dev/null; then
        printf "No SCL PHP versions found. System-wide PHP version is: %s\n" "$defaultphpversion";
        return 1;
    elif [[ -z "$1" ]]; then
        printf "No argument given; 1st argument must be a valid user\n";
        return 1;
    elif ! id -u "$1" > /dev/null 2>&1; then
        printf "User $1 doesn't exist.\n";
        return 1;
    fi

    shelluser="$1";
    if [[ ! -e "/var/spool/cron/${shelluser}" ]]; then
        printf "%s (%s) - %s\n" "cron : default php version" "$defaultphpversion" "No crontab found.";
    elif ! grep -qoP "$crontabphpregex" "/var/spool/cron/${shelluser}"; then
        printf "%s (%s) - %s\n" "cron : default php version" "$defaultphpversion" "No php entry found in crontab.";
    else
        phpcronversion=$(grep -oP "$crontabphpregex" "/var/spool/cron/${shelluser}" | grep -oP "$phpregex" | uniq )
        printf "%s %s\n" "cron :" "$phpcronversion";
    fi

    if [[ ! -e "/home/${shelluser}/.bashrc" ]]; then
        printf "%s (%s) - %s\n" "cli  : default php version" "$defaultphpversion" "No bashrc found.";
    elif ! grep -qoP "$bashrcphpregex" "/home/${shelluser}/.bashrc"; then
        printf "%s (%s) - %s\n" "cli  : default php version" "$defaultphpversion" "No PHP entry in bashrc found.";
    else
        phpcliversion=$(grep -oP "$bashrcphpregex" "/home/${shelluser}/.bashrc" | grep -oP "$phpregex")
        printf "%s %s\n" "cli  :" "$phpcliversion";
    fi

    for i in /opt/nexcess/php*u/root/etc/php-fpm.d/${shelluser}.conf; do
        if [[ -e $i ]] && [[ -s $i ]] && grep -qvP "^;" $i; then
            local phpwebversion=$(printf "$i" | grep -oP "$phpregex");
            printf "%s %s\n" "web  :" "$phpwebversion";
        else
            continue;
        fi;
    done;
    if [[ -z "$phpwebversion" ]]; then
        printf "%s (%s) - %s\n" "web  : default php version" "$defaultphpversion" "No fpm pool files in /opt.";
    fi
}

compctl -u switchphp
switchphp ()
{
    pluginenabled=$(nodeworx -u -n -c Plugins -a listPlugins -o json | jq -r ".[] | select(.name == \"nexcess-php-scl\") | .status")
    if [ "$pluginenabled" != "true" ]; then
        printf "Nexcess-php-scl plugin not enabled!\n"
        return 1
    fi

    masterdomain=$(nodeworx -u -n -c Siteworx -a listAccounts -o json | jq -r ".[] | select(.uniqname == \"$1\") | .domain")
    validsclversions=$(find /opt/nexcess/*/root/usr/bin/php | grep -oP '(?<=php)[0-9][0-9]')
    formattedvalidsclversions=$( printf "$validsclversions" | tr '\n' ' ')
    function isValidPhpVersion () {
        grep -q "^${1}$" <( printf "default\n"
        printf "$validsclversions" )
    }


    if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
        printf "Usage: switchphp [USERNAME] [PHPVERSION]\n"
        printf "\n"
        printf "PHPVERSION must be one value from the set [ default %s]\n" "$formattedvalidsclversions"
        return 1
    elif [ -z "$1" ] || [ -z "$2" ]; then
        printf "switchphp requires two arguments or -h for help!\n"
        return 1
    elif ! getent passwd "$1" > /dev/null 2>&1; then
        printf "%s is not a valid user!\n" "$1"
        return 1
    elif ! isValidPhpVersion "$2"; then
        printf "%s is not a valid PHP version!\n" "$2"
        printf "Try one of [ default %s]\n" "$formattedvalidsclversions"
        return 1
    else
        username="$1"
        if [ "$2" = "default" ]; then
            desiredphpversion="php"
            phpversion=$(/usr/bin/php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+')
        else
            desiredphpversion="php${2}u"
            phpversion=$(/opt/nexcess/${desiredphpversion}/root/usr/bin/php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+')
        fi
    fi

    phpswitchoutput=$(siteworx -u -n --login_domain "$masterdomain" -c Nexphp -a setPhpVersion --php_version "$desiredphpversion" 2>&1)
    if [ ! -n "$phpswitchoutput" ]; then
        # it worked
        printf "User %s switched to PHP version: %s\n" "$username" "$phpversion"
        return 0
    elif ( echo "$phpswitchoutput" | grep -qE '^php_version : ".*" This is not a valid option' ) ; then
        # it didn't work and we know why
        printf "PHP switch failed. \"%s\" is not enabled as an available PHP version for this siteworx account.\n" "$desiredphpversion"
        return 1
    else
        # it didn't work and we don't know why
        printf "PHP switch failed. Output from siteworx regarding this failure below:\n%s\n" "$phpswitchoutput"
        return 1
    fi
}

function m {
    mysql -u"$(grep '^rootdsn=' /usr/local/interworx/iworx.ini | cut -d/ -f3 | cut -d: -f1)" -p"$(grep '^rootdsn=' /usr/local/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)" "$1"
}

function md {
    test -z "$1" && echo "Usage: md database" && return
    mysqldump --opt --skip-lock-tables --routines --max_allowed_packet=2G -u"$(grep ^rootdsn= /usr/local/interworx/iworx.ini | cut -d/ -f3 | cut -d: -f1)" -p"$(grep ^rootdsn= /usr/local/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)" "$1" > "$HOME/$1-$(date --iso-8601=minute).sql"
}

function mdz {

    test -z "$1" && echo "Usage: mdz database" && return
    if [ -x /usr/bin/pigz ]; then
	GZIP='/usr/bin/pigz'
    else
	GZIP='/bin/gzip'
    fi
    mysqldump --opt --skip-lock-tables --routines --max_allowed_packet=2G -u"$(grep ^rootdsn= /usr/local/interworx/iworx.ini | cut -d/ -f3 | cut -d: -f1)" -p"$(grep ^rootdsn= /usr/local/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)" "$1" | $GZIP --fast > "$HOME/$1-$(date --iso-8601=minute).sql.gz"
}

function ips {
  if [ "$1" == '-6' ]; then
    /sbin/ip -o -6 addr |awk '{printf "%-10s %-15s\n", $2, $4}'
  elif [ "$1" == '-o' ]; then
    /sbin/ifconfig | awk 'BEGIN{RS="\n\n"} {if ($1 !~ /lo/) {mac=$5; ip=$7;} else {mac=""; ip=$6} {printf "%-9s %-18s %s\n", $1, mac, ip}} '  | /bin/sed -e 's|addr:||'
  else
    /sbin/ip -o -4 addr |awk '{printf "%-10s %-15s\n", $2, $4}'
  fi
}

function smtp {
    test -z "$2" && echo "Usage: smtp from@address.com to@somewhere.com [IP]" && return
    dig +short mx $(echo "$2" | cut -d@ -f2)
    if [ "$3" ]; then
	swaks -4 -q TO --from "$1" --to "$2" -li "$3"
    else
	swaks -4 -q TO --from "$1" --to "$2"
    fi
}

function sudo {
    if [[ $1 == 'su' && $2 == '-' && -z $3 ]]; then
        # sudo su -
        # make sure $3 is unset to we don't catch legit cases like 'sudo su - foobar'
	echo "You're obtaining root access the wrong way."
	echo "You should be using 'r'"
	echo "If you really need to do this, give the full path to sudo in your command like /usr/bin/sudo su -"
    elif [[ $1 == 'su' && $2 == '-' && $3 == 'root' ]]; then
        # sudo su - root
	echo "You're obtaining root access the wrong way."
	echo "You should be using 'r'"
	echo "If you really need to do this, give the full path to sudo in your command like /usr/bin/sudo su - root"
    elif [[ $1 == 'bash' ]]; then
        # sudo bash
	echo "You're obtaining root access the wrong way."
	echo "You should be using 'r'"
	echo "If you really need to do this, give the full path to sudo in your command like /usr/bin/sudo bash"
    else
	/usr/bin/sudo "$@"
    fi
}


function su {
    if [[ $1 == '-' && -z $2 ]]; then
	# su -
	echo "You don't have to run 'su -'"
	echo "Doing that messes up logging and environmental variables"
	echo "If you really need to do this, give the full path to sudo in your command like /bin/su -"
    else
	/bin/su "$@"
    fi
}

function r {
	/usr/bin/sudo HOME=~/ bash
}

function hist {
    [[ -n $ZSH_VERSION ]] && emulate -L sh
    local -x regex=$1 f
    local -a history_files
    while read -r f; do
        # the evals are here to assist with home directory lookups via: ~user
        # you can't just do ~$var
        eval "[[ -s ~$f/.bash_history ]]" &&
            eval 'history_files=("${history_files[@]}"'" ~$f/.bash_history)"
        eval "[[ -s ~$f/.zsh_history ]]"  &&
            eval 'history_files=("${history_files[@]}"'" ~$f/.zsh_history)"
    done < <(lid -n -g nexadmin)

    for f in /home/nexoldemployees/*/.bash_history /home/nexoldemployees/*/.zsh_history
    do
        [[ -s "$f" ]] && history_files=("${history_files[@]}" "$f")
    done

    if [[ -s "/root/.bash_history" ]]; then
        history_files=("${history_files[@]}" /root/.bash_history)
    fi

    perl -MPOSIX -wlne 'BEGIN {$l=0}
            $u = (split(/\//, $ARGV))[-2];
        $shell = (split(/\//, $ARGV))[-1] eq ".zsh_history" ? "zsh" : "bash";
        if ($shell eq "zsh") {
            /^: (\d+):\d+\;(.*)/ || /(.*)/;
            $l = defined $2 ? $1 : 0; $cmd = defined $2 ? $2 : $1;
            /$ENV{regex}/ && printf("%-19s | %-18s | %s\n", strftime("%F %T", localtime($l)), $u, $cmd);
        } else {
            /$ENV{regex}/ && printf("%-19s | %-18s | %s\n", strftime("%F %T", localtime($l)), $u, $_);
            $l = (/^#\d+$/) ? substr $_, 1 : 0;
        }' "${history_files[@]}" | sort -t\| -k1
}

# check TTFB with curl. we ignore all ssl errors with -k
function chkttfb {
    test -z "$1" && echo "Usage: chkttfb domain.com" && return
    domain=$1
    if ! [[ $domain =~ ^https?:// ]]; then
	domain="http://${domain}"
    fi

    curl -kso /dev/null -w "HTTP: %{http_code} Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total}\n" "${domain}"

}

# check TTFB of Magento index.php and robots.txt (requires / [or accurate base_url] upon input; httpd code and redirect url are output for convenience
# we ignore all ssl errors with -k
function chkttfbmage {
    test -z "$1" && echo "Usage: chkttfbmage domain.com" && return
    domain=$1
    if ! [[ $domain =~ ^https?:// ]]; then
	domain="http://${domain}"
    fi


    echo "${domain}/index.php"
    curl -kso /dev/null -w "HTTP: %{http_code} Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total}\n" "${domain}/index.php"
    echo "${domain}/LICENSE.txt"
    curl -kso /dev/null -w "HTTP: %{http_code} Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total}\n" "${domain}/LICENSE.txt"
}

# check ANY records (faster)
function chkany {
    test -z "$1" && echo "Usage: chkany domain.com [optional-lookup-server]" && return

    # For some reason when using one of our recursive lookup servers,
    # the first lookup returns everything, but the second lookup
    # returns only the NS records. This happens even if you run it 1
    # second after the second one finishes.
    #
    # I suspect it is related to DJB's dnscache being weird somehow
    # but not going to waste a day trying to figure it out why
    # dnscache is being weird.
    #
    # wikipedia says using ANY you don't necessarily get all the
    # records but those records aren't expiring out of the cache
    # within one second.
    #
    # https://en.wikipedia.org/wiki/List_of_DNS_record_types says:
    #
    # """The records returned may not be complete. For example, if
    # there is both an A and an MX for a name, but the name server has
    # only the A record cached, only the A record will be returned."""

    # [1505][root@mmckinst-test4 nexadmin]$ dig +short interworx.info  @208.69.120.23 ANY +noshort
    # interworx.info. 2560 IN SOA ns1.nexcess.net. hostmaster.interworx.info. 1331754659 7200 2048 1048576 2560
    # interworx.info. 14400 IN NS ns1.nexcess.net.
    # interworx.info. 14400 IN NS ns3.nexcess.net.
    # interworx.info. 14400 IN MX 10 antispam.nexcess.net.
    # interworx.info. 14400 IN A 207.32.181.142
    # [1505][root@mmckinst-test4 nexadmin]$ dig +short interworx.info  @208.69.120.23 ANY +noshort
    # interworx.info. 14398 IN NS ns1.nexcess.net.
    # interworx.info. 14398 IN NS ns3.nexcess.net.
    # [1505][root@mmckinst-test4 nexadmin]$

    lookup_server="@8.8.8.8"
    if [[ -n $2 ]]; then
	lookup_server="@$2"
    fi

    dig +short $1 ${lookup_server} ANY +noshort
}

# check DNS (cleaner)
function chkdns {
    test -z "$1" && echo "Usage: chkdns domain.com [optional-lookup-server]" && return

    lookup_server=""
    if [[ -n $2 ]]; then
	lookup_server="@${2}"
    fi
    dig +short $1 ${lookup_server} soa +noshort
    dig +short www.$1 ${lookup_server} +noshort | sort
    dig +short $1 ${lookup_server} a +noshort
    dig +short $1 ${lookup_server} aaaa +noshort
    dig +short $1 ${lookup_server} ns +noshort
    dig +short $1 ${lookup_server} mx +noshort
    dig +short $1 ${lookup_server} txt +noshort
    dig -x $(dig +short $1 ${lookup_server}) ${lookup_server} +noshort | grep $1
}

# Same as regular stat, but will also grab file creation time if file is on ext4 partition
function astat
{
    for FILE in $@; do
        FILE=$(readlink -f $FILE)
        DF=$(df -T $FILE | grep -v '^Filesystem *Type.*Used *Available *Use% *Mounted *on')
        FILESYSTEM=$(echo $DF | awk '{print $2}')
        DEVICE=$(echo $DF | awk '{print $1}')
        STAT=$(stat $FILE)
        if [ "$FILESYSTEM" = "ext4" ]; then
            INODE=$(echo "$STAT" | awk '/Inode:/ {print $4}')
            CRTIME=$(debugfs -R "stat <$INODE>" $DEVICE 2> /dev/null | grep crtime | awk '{print $4, $5, $6, $7, $8}')
            CRTIME=$(ruby -e "require 'time'; puts Time.parse('$CRTIME').strftime('%Y-%m-%d %H:%M:%S %z')")
        else
            CRTIME='Not available (not an ext4 partition)'
        fi
        echo "$STAT"
        echo Create: $CRTIME
    done
}

# Grab various volatile information, dump, to directory
function volatile
{
    if [[ -z $1 ]];then
        DIR=$PWD
    else
        DIR=$1
    fi
    TIME=$(date +"%Y-%m-%d_%H:%M:%S")
    ps -ww -eo 'user,pid,ppid,%cpu,%mem,start_time,etime,tty,time,cmd' > $DIR/processes.$TIME
    lsof -n > $DIR/open_files.$TIME
    netstat -natup > $DIR/network_connections.$TIME
    strings -f /proc/*/environ > $DIR/processes_environ.$TIME
}

# Quarantine malware, preserving timestamps, other metadata, and directory structure.
function quar
{
    if [[ -z $case_name ]]; then
        echo -n "please set a case name: "
        read case_name
        case_dir=~/$case_name-quar-$(ldate)/
        case_stat=$case_dir/quarantine-timestamps
    else
        case_dir=~/$case_name-quar-$(ldate)/
        case_stat=$case_dir/quarantine-timestamps
    fi
    if ! [[ -d $case_dir ]]; then
        echo "setting up case directory: $case_dir"
        mkdir -p $case_dir
        mkdir $case_dir/preserve
        touch $case_stat
        chown root:root $case_stat
        chmod 600 $case_stat
        echo 'gathering volatile data..'
        volatile $case_dir
    fi

    for file in $@; do
        orig_path=$(readlink -f -- "$file")
        move_to="$case_dir"$(dirname -- "$orig_path")
        astat "$orig_path" >> "$case_stat"
        cp --parents -- "$orig_path" $case_dir/preserve
        rm -f $orig_path
        chown root:root "$case_dir/preserve/$orig_path"
        chmod 400 "$case_dir/preserve/$orig_path"
    done
}

# Same as quar function, but keeps original copy of file in place.
function pres
{
    if [[ -z $case_name ]]; then
        echo -n "please set a case name: "
        read case_name
        case_dir=~/$case_name-quar-$(ldate)/
        case_stat=$case_dir/preserve-timestamps
    else
        case_dir=~/$case_name-quar-$(ldate)/
        case_stat=$case_dir/preserve-timestamps
    fi
    if ! [[ -d $case_dir ]]; then
        echo "setting up case directory: $case_dir"
        mkdir -p $case_dir
        mkdir $case_dir/preserve
        touch $case_stat
        chown root:root $case_stat
        chmod 600 $case_stat
        echo 'gathering volatile data..'
        volatile $case_dir
    fi

    for file in $@; do
        orig_path=$(readlink -f -- "$file")
        move_to="$case_dir"$(dirname -- "$orig_path")
        astat "$orig_path" >> "$case_stat"
        cp --parents -- "$orig_path" $case_dir/preserve
        chown root:root "$case_dir/preserve/$orig_path"
        chmod 400 "$case_dir/preserve/$orig_path"
    done
}

# use regular expression to search for obfuscated php code and malware not caught by tools like maldet.
# leaving the actual regular expression outside of function so it can be incorporated into other's scripts
REGEX_OBFUSCATION='(?:assert|e(?:val|xec)|shell_exec|passthru)\b.{1,50}(?:base64_decode|gzinflate|stripslashes|str_rot13|\$_(?:FILES|GET|POST|REQUEST|HTTP_POST_FILES|COOKIE|REQUEST|SERVER|SESSION|GLOBALS|HTTP_RAW_POST_DATA))|preg_replace\((.)/\.[*+]/e.|<\?php(?:\s){80,}|wp__wp.*?POST|\$s_name\s?=\s?"b374k"|$b374k\s?=|if\(@\$_COOKIE\[.{1,30}\]\)\s?\(\$_=@\$_REQUEST\[.{1,30}\]\)|if\(strpos\(\$_SERVER\[.REQUEST_URI.\],\s?.checkout.\)|\$log_entry\s?=\s*serialize\(\$ARINFO\)\s?\.\s?|\$iquotes\s?=\s?\d{1,10};\s*\$isize\s?=\s?\d{1,10}|\$log_name\s?\)\s?\>\s?(?:\d{1,10}|\$iquote|\$isize)\s?\*\s?(?:\d{1,10}|$iquote|$isize)|\$magecheck\s?=\s?.checkout.|\$mage(dirsize|quotes)\s?=\s?\d{1,10}|\$_POST\)&&\s?\$GLOBALS\[|\$billing\s?=\s?\$_POST\[.billing.\]|\$payment\s?=\s?\$_POST\[.payment.\]|\$payment\[.cc_(?:number|cid).\].{1,10}\$payment|\$billing\[.(?:customer_password|firstname).\].{1,10}\$billing|fopen\(.+magento\.(?:jpg|png|gif)|\$_POST\[.payment.\]\[.cc_exp_year.\]|\$(?:billing|payment)\s?=\s?Mage:getSingleton|\$post\d{1,10}\s*=.+\$billing->getFirstname\(\).*\$billing->getLastname\(\)|\$post\d{1,10}\s*=.+\$payment->getCcNumber\(\).*\$payment->getCcExpMonth\(\)|^\s*\$post\d{1,10}\s*=\s*base64_encode\(\$post\d{1,10}\);|108\.61\.51\.160/27|108\.61\.31\.128/27|\$GLOBALS(?:.{5,20}\$GLOBALS){3}|\$GLOBALS\[.{1,10}\]\[.{1,10}\]\]?\(';
function malgrep
{
    local d
    if [ -z "$1" ]; then
        set -- "$PWD"
    fi;
    for d in "$@"; do
        if [ -f "$d" ]; then
            d=$(readlink -f "$d")
            pcregrep -o "$REGEX_OBFUSCATION" "$d" /dev/null
        elif [ -d "$d" ]; then
            d=$(readlink -f "$d")
            find "$d" -type f -iregex ".*\.\(php\|pl\|rb\|py\|tcl\|sh\|p?html?\|htaccess\)$" -print0 |  xargs -0 -P2 grep -oaP -m 1 "$REGEX_OBFUSCATION" /dev/null;
        else
            printf '%s\n' "$d is not a file or directory.. what were you thinking?"
        fi
    done
}

# function to allow support techs to create a time-limited rule for troubleshooting
# see https://github.com/nexcess/sysops-issues/issues/84 for discussion
allow_mel () {

  am_mel_office_addr='192.240.191.2'
  am_comment='## Mel Office Access ##'
  am_8601_str="+%Y-%m-%dT%H:%M:%S"
  am_ipt_chain="TALLOW"

  am_show_halp () {
    echo "creates a one-hour rule to allow specific traffic from the Melrose office"
    echo -e "Usage: $ allow_mel {ssh|ftp|sftp|mysql}\n"
  }

  am_add_rule () {
    am_start_date="$(date -u "$am_8601_str")"
    am_stop_date="$(date -u -d "1 hour" "$am_8601_str")"
    iptables -A $am_ipt_chain -p tcp -s $am_mel_office_addr -m tcp --dport $1 \
      -m time --utc --datestart $am_start_date --datestop $am_stop_date \
      -m comment --comment "$am_comment" -j ACCEPT
  }

  case $1 in
    ssh)
      am_add_rule 22
      ;;
    ftp)
      am_add_rule 21
      ;;
    sftp)
      am_add_rule 22
      am_add_rule 24
      ;;
    mysql)
      am_add_rule 3306
      ;;
    *)
      am_show_halp
      ;;
  esac

}

function fixhwaddr {
  # useful for dc-ops, when performing chassis swaps on el6.
  # extglob has to be set at the time of defining an function that uses it,
  # since it changes some parsing rules. since extglob isn't guaranteed to be enabled
  # we just call an second bash process.
  bash -O extglob -c '
  for if in /sys/class/net/@(em|eth)*; do
    read -r address < "$if/address"
    (if [[ -f ${f:=/etc/sysconfig/network-scripts/ifcfg-${if##*/}} ]]; then
      sed -i "/^HWADDR/c\HWADDR=$address" "$f"*
    fi)
  done'
}
