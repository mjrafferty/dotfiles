# vim:ft=zsh

local rc_conf

load_conf() {
  local file="${ZDOTDIR}/${1}.zsh"
  [ -r "${file}" ] && source "${file}"
}

case "$HOST" in
  "NEX-LW-2181"*)    rc_conf="work" ;;
  "pi")              rc_conf="pi" ;;
  "mellon"*)         rc_conf="login_server" ;;
  *".nexcess.net")   rc_conf="nexcess" ;;
  *"nxcli.net")      rc_conf="nexcess" ;;
  *".liquidweb.com") rc_conf="nexcess";;
  "localhost")       rc_conf="phone" ;;
  *)                 rc_conf="home" ;;
esac

(( DEV_MODE == 1 )) && rc_conf="dev"

load_conf "$rc_conf"

unset rc_conf
unfunction load_conf
