#! /bin/bash

_sup_octetregex() {

  local low high;

	low="$1";
	high="$2";

  if (( high < max )); then
    return 1;
  fi

  if (( low == high )); then

    echo "${high}";

  elif (( low < 10 )); then

    if (( high < 10 )); then
      echo "[${low}-${high}]";
    elif (( high < 100 )); then
      #echo "[1-9][0-9]|[${low}-9]";
    elif (( high < 200 )); then
      #echo "[1-9][0-9]|[${low}-9]";
    else
      #echo "((1[0-9]{2}|2([0-4][0-9]|5[0-5]))|[1-9][0-9]|[0-9])";
    fi

  elif (( low < 100 )); then

    if (( high < 100 )); then
      #echo "[1-9][0-9]";
    elif (( high < 200 )); then
      #echo "[1-9][0-9]";
    else
      #echo "(1[0-9]{2}|2([0-4][0-9]|5[0-5]))|[1-9][0-9]";
    fi

  elif (( low < 200 )); then

    if (( high < 200 )); then
      #echo "[1-9][0-9]";
    else
      #echo "(1[0-9]{2}|2([0-4][0-9]|5[0-5]))|[1-9][0-9]";
    fi

  else
    #echo "(1[0-9]{2}|2([0-4][0-9]|5[0-5]))";
  fi

}

# Print lines containing ip within cidr subnet
sup_grepcidr() {

  local bin_ip cidr highs lows regex;

  # matches numbers 0-255
  local octet="((1[0-9]{2}|2([0-4][0-9]|5[0-5]))|[1-9][0-9]|[0-9])";

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
