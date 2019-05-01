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

_changeWallpaper () {

  local picture;

  picture="$1"

  dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript "string:
  var Desktops = desktops();
  for (i=0;i<Desktops.length;i++) {
    d = Desktops[i];
    d.wallpaperPlugin = \"org.kde.image\";
    d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");
    d.writeConfig(\"Image\", \"file://${1}\");
  }"

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

  _changeWallpaper "${ARGA[0]}"

}

main;
