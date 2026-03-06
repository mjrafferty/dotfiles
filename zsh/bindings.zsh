# vim:ft=zsh

bindkey -v

(( ${+functions[backward-delete-char]} )) \
  && bindkey -v '^?' backward-delete-char

(( ${+functions[history-substring-search-up]} )) \
  && bindkey "^[[A" history-substring-search-up

(( ${+functions[history-substring-search-down]} )) \
  && bindkey "^[[B"  history-substring-search-down

(( ${+functions[__zhist_fzf]} )) \
  && bindkey "^R" __zhist_fzf
