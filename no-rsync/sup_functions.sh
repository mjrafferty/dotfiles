#! /bin/bash

nex_user_shell="zsh"
# shellcheck disable=SC2154
if [[ "$nex_user_shell" == "zsh" ]]; then
  ARRAY_START="1";
else
  ARRAY_START="0";
fi

# Convert ipv4 IP to binary form
sup_iptobinary() {

  grep -Po '([0-9]{1,3}\.){3}[0-9]{1,3}' \
    | awk '
    function d2b(d,  b) {
      while(d) {
        b=d%2b;
        d=int(d/2);
      }
      return(b);
    }
    {
      split($0,bin,".");
      printf("%08i.%08i.%08i.%08i\n",d2b(bin[1]),d2b(bin[2]),d2b(bin[3]),d2b(bin[4]));
    }'

}

sup_bintoip() {

  tr -d ' .' \
    | fold -w 32 \
    | tee \
    | sed -e 's/.\{8\}/&,".",/g' -e 's/^/ibase=2; print /' -e 's/,".",$//' -e 's/$/,"\\n"/' \
    | bc

}

# Print out subnets containing provided ips in cidr notation
sup_ipstocidr() {

  local current_block max_block num_ips last_ip current_ip;

  max_block="16";
  current_block="32";
  num_ips=0;

  sup_iptobinary \
    | sort -u \
    |  {
    while read -r ip; do

      ((num_ips++));

      ## Read first IP from list
      if [[ -z "${last_ip[ARRAY_START]}" ]]; then

        # shellcheck disable=SC2207
        last_ip=($(echo "$ip" | tr -d '.' | sed 's/./& /g'));
        # shellcheck disable=SC2207
        current_ip=($(echo "$ip" | tr -d '.' | sed 's/./& /g'));
        continue;

      fi

      # Set currently active IP
      # shellcheck disable=SC2207
      current_ip=($(echo "$ip" | tr -d '.' | sed 's/./& /g'));

      # Walk through bits
      for ((x=ARRAY_START;x<${#current_ip[@]}+ARRAY_START;x++)); do

        # if bits match, skip to next bit
        if (( current_ip[x] == last_ip[x] )); then

          continue;

        else

          if (( x-ARRAY_START >= max_block )); then

            # shellcheck disable=SC2030
            current_block="$((x-ARRAY_START))";
            continue 2;

          else

            ((num_ips--));

            echo "${num_ips} $(echo "${last_ip[@]}" | sup_bintoip)/${current_block}";

            num_ips=1;
            last_ip=("${current_ip[@]}")
            current_block="32";

            break;

          fi
        fi

        done

      done

      echo "${num_ips} $(echo "${current_ip[@]}" | sup_bintoip)/${current_block}"

    }

}

# Print lines containing ip within cidr subnet
sup_grepcidr() {

  local bin_ip cidr highs lows regex;

  # matches numbers 0-255
  octet_regex="([0-9]|[1-9][0-9]|(1[0-9]{2}|2([0-4][0-9]|5[0-5])))"

  # shellcheck disable=SC2207
  ips=($(echo "$*" | grep -Po '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{2}'));

  for ((ip=ARRAY_START;ip<${#ips[@]}+ARRAY_START;ip++)); do

    cidr="$(echo "${ips[ip]}" | cut -d'/' -f2)";
    bin_ip="$(echo "${ips[ip]}" | cut -d'/' -f1 | sup_iptobinary | tr -d ' .' | cut -c1-"$cidr")";

    # shellcheck disable=SC2207
    highs=($(printf "%-32s\n" "$bin_ip" | tr ' ' '1' | sup_bintoip | tr '.' '\n'))
    # shellcheck disable=SC2207
    lows=($(printf "%-32s\n" "$bin_ip" | tr ' ' '0' | sup_bintoip | tr '.' '\n'))

    for ((x=ARRAY_START;x<${#lows[@]}+ARRAY_START;x++)); do

      if ((lows[x] == highs[x])); then

        regex+="${lows[x]}";

        if ((x<${#lows[@]}+ARRAY_START-1)); then
          regex+='\.';
        fi

      else

        break;

      fi

    done

    if (( highs[x]-lows[x] > 1 )); then

      if (( x-ARRAY_START == 0 )); then
        mid="";
      elif (( x-ARRAY_START == 1 )); then
        mid="";
      elif (( x-ARRAY_START == 2 )); then
        mid="";
      elif (( x-ARRAY_START == 3 )); then
        mid="";
      fi

      mid+="|";

    fi

    if (( x-ARRAY_START == 0 )); then
      first="${lows[x]}";
      last="${highs[x]}";
    elif (( x-ARRAY_START == 1 )); then
      first="${lows[x]}";
      last="${highs[x]}";
    elif (( x-ARRAY_START == 2 )); then
      first="${lows[x]}";
      last="${highs[x]}";
    elif (( x-ARRAY_START == 3 )); then
      first="${lows[x]}";
      last="${highs[x]}";
    fi

    regex="${regex}(${first}|${mid}${last})"

    echo "$regex";

  done

}
