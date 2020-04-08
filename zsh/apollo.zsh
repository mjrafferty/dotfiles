# vim:ft=zsh

APOLLO_THEME=apollo

zstyle ':apollo:*:core*:modules:left' modules 'git' 'virtualenv' 'quota' 'newline' 'vi_mode' 'root_indicator' 'context' 'dir' 'ruler'
zstyle ':apollo:*:core*:modules:right' modules 'background_jobs' 'command_execution_time' 'public_ip' 'newline' 'clock' 'date' 'newline' 'status' 'php_version' 

zstyle ':apollo:*:*:*:context:default' ignore_users ".*matt.*" ".*raff.*" "root"
zstyle ':apollo:*:*:*:context:ssh' ignore_users ".*matt.*" ".*raff.*" "root"
zstyle ':apollo:*:*:*:context:sudo' ignore_hosts ".*"

zstyle ':apollo:*:*:*:git:*' ignore_submodules true

zstyle ':apollo:*:*:*:dir:*' bookmark_patterns "/home/????*/*/html;/html"
zstyle ':apollo:*:*:*:dir:*' bookmarks "apollo=$HOME/apollo-zsh-theme"
