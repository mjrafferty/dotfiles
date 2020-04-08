# vim:ft=zsh

zstyle ':apollo:*:*:*:context:default' ignore_users ".*matt.*" ".*raff.*" "root"
zstyle ':apollo:*:*:*:context:ssh' ignore_users ".*matt.*" ".*raff.*" "root"
zstyle ':apollo:*:*:*:context:sudo' ignore_hosts ".*"

zstyle ':apollo:*:*:*:git:*' ignore_submodules true
