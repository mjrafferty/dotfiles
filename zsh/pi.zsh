# vim:ft=zsh

load_conf main

alias disks="df -h | grep -v tmpfs | grep -Ev '^(dev|run)'"

#export TMUX="NO"

orphaned_files() {

  find / \
    \( \
    -path /home/matt \
    -o -path /home/nextcloud \
    -o -path /dev \
    -o -path /etc/ca-certificates \
    -o -path /etc/ssl \
    -o -path /lib64/firmware \
    -o -path /lib64/modules \
    -o -path /proc \
    -o -path /run \
    -o -path /sys \
    -o -path /tmp \
    -o -path /usr/lib64/clang \
    -o -path /usr/lib64/dracut \
    -o -path /usr/lib64/gcc \
    -o -path /usr/lib64/llvm \
    -o -path /usr/lib64/mono \
    -o -path /usr/lib64/portage \
    -o -path /usr/local/portage \
    -o -path /usr/portage \
    -o -path /usr/share/mime \
    -o -path /usr/src \
    -o -path /var/cache \
    -o -path /var/db \
    -o -path /var/log \
    -o -path /var/tmp/portage \
    \) \
    -prune -o -type f -print0 \
    | xargs -0 qfile -o 2>&1 \
    | less -inSFR
}
