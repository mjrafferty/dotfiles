#! /bin/bash

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
    {
      split($0,bin,".");
      printf("%08i.%08i.%08i.%08i\n",d2b(bin[1]),d2b(bin[2]),d2b(bin[3]),d2b(bin[4]));
    }'
}

# Print out subnets containing provided ips in cidr notation
sup_ipstocidr() {

  local current_block max_block last_ip;

  max_block="16";
  current_block="32";

  sup_iptobinary \
    | sort -u \
    | while read -r ip; do
      if [[ -z "$last_ip" ]]; then
        last_ip="$ip";
        continue;
      fi
      for ((x=1;x<32;x++)); do
        if (( current_block <= max_block )); then
          echo "${ip}/${current_block}";
          current_block="32";
          continue;
        fi
      done
    done

  }

# Print lines containing ip within cidr subnet
sup_grepcidr() {
  echo "";
}
