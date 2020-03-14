# vim:ft=zsh

[ -r "${HOME}/.zsh/zinit/plugins/mjrafferty---apollo-zsh-theme/apollo-zsh-theme.zsh" ] \
  && source "${HOME}/.zsh/zinit/plugins/mjrafferty---apollo-zsh-theme/apollo-zsh-theme.zsh"

[ -r "${HOME}/.zsh/zinit/plugins/mjrafferty---zhist/zhist.zsh" ] \
  && source "${HOME}/.zsh/zinit/plugins/mjrafferty---zhist/zhist.zsh"

[ -r "${HOME}/.zsh/zinit/plugins/trapd00r---LS_COLORS/c.zsh" ] \
  && source "${HOME}/.zsh/zinit/plugins/trapd00r---LS_COLORS/c.zsh"

[ -r "${HOME}/.zsh/zinit/plugins/zsh-users---zsh-completions/zsh-completions.plugin.zsh" ] \
  && source "${HOME}/.zsh/zinit/plugins/zsh-users---zsh-completions/zsh-completions.plugin.zsh"

[ -r "${HOME}/.zsh/zinit/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
  && source "${HOME}/.zsh/zinit/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh"

ZSH_AUTOSUGGEST_MANUAL_REBIND="true"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
#ZSH_AUTOSUGGEST_USE_ASYNC="true"
ZSH_AUTOSUGGEST_STRATEGY=(history match_prev_cmd )

[ -r "${HOME}/.zsh/zinit/plugins/zsh-users---zsh-history-substring-search/zsh-history-substring-search.plugin.zsh" ] \
  && source "${HOME}/.zsh/zinit/plugins/zsh-users---zsh-history-substring-search/zsh-history-substring-search.zsh"

bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

[ -r "${HOME}/.zsh/zinit/plugins/zdharma---fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] \
  && source "${HOME}/.zsh/zinit/plugins/zdharma---fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

autoload -Uz compinit && compinit -C -i
