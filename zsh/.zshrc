# vim:ft=zsh

load_conf() {
  local file="${ZDOTDIR}/${1}.zsh"
  [ -r "${file}" ] && source "${file}"
}

case "$HOST" in
  "Nexcess-AST-000304.local") load_conf work ;;
  "Home") load_conf home ;;
  "pi") load_conf pi ;;
  *"mellon"*) load_conf login_server ;;
  *) load_conf nexcess ;;
esac

unfunction load_conf
