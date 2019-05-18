#! /bin/bash

# Script Arguments
readonly ARGS="$*"
readonly ARGA=("$@")

# Configurable Variables

# Alias executables to prevent PATH issues

# Necessary Global Variables

# Print usage
_usage() {

  cat <<- EOF
  This is the usage
EOF

}

# Convert long command line options into short ones for getopts
_cmdline() {

  local x;

  for x in ${ARGA[*]}; do

    case "$x" in
      "--help"|"-h")
        args="${args}-h "
        ;;
      *)
        args="${args}${x} "
        ;;
    esac
  done

  echo "$args";

}

# Main
main () {

  while getopts "h" OPTION $(_cmdline); do

    case $OPTION in
      h)
        _usage;
        exit 0;
        ;;
      *);;
    esac
  done

  for file in "${ARGA[@]}"; do
    if [[ -L "$file" ]]; then
      cksum=$(md5sum "$(readlink "$file")");
      printf "INSERT INTO THING (a,b,c) values ('%s', '%s', '%s')\n" "${cksum/ */}" "${cksum/* /}" "yes";
    elif [[ -f "$file" ]]; then
      cksum=$(md5sum "$file");
      printf "INSERT INTO THING (a,b,c) values ('%s', '%s', '%s')\n" "${cksum/ */}" "${cksum/* /}" "no";
    fi
  done

  vim "${ARGA[@]}"

  for file in "${ARGA[@]}"; do
    if [[ -L "$file" ]]; then
      cksum=$(md5sum "$(readlink "$file")");
      printf "INSERT INTO THING (a,b,c) values ('%s', '%s', '%s')\n" "${cksum/ */}" "${cksum/* /}" "yes";
    elif [[ -f "$file" ]]; then
      cksum=$(md5sum "$file");
      printf "INSERT INTO THING (a,b,c) values ('%s', '%s', '%s')\n" "${cksum/ */}" "${cksum/* /}" "no";
    fi
  done

}

main;
