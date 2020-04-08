# vim:ft=zsh

zstyle ':apollo:*:*:*:context:default' ignore_users ".*matt.*" ".*raff.*" "root"
zstyle ':apollo:*:*:*:context:ssh' ignore_users ".*matt.*" ".*raff.*" "root"
zstyle ':apollo:*:*:*:context:sudo' ignore_hosts ".*"

zstyle ':apollo:*:*:*:git:*' ignore_submodules true

zstyle ':apollo:*:*:*:dir:*' bookmark_patterns "/home/????*/*/html;/html"
zstyle ':apollo:*:*:*:dir:*' bookmarks "apollo=$HOME/apollo-zsh-theme"
