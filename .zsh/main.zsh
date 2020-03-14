#! /bin/zsh

[ -r "${HOME}/.zsh/tmux.zsh" ] \
  && source "${HOME}/.zsh/tmux.zsh"

## Vi key bindings
bindkey -v
export KEYTIMEOUT=1

fpath=($HOME/.zsh/completions $fpath)

autoload -Uz is-at-least
if is-at-least 5.1; then

  [ -r "${HOME}/.zsh/zinit_core.zsh" ] \
    && source "${HOME}/.zsh/zinit_core.zsh"

else

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

fi

[ -r "${HOME}/.zsh/env.zsh" ] \
  && source "${HOME}/.zsh/env.zsh"

[ -r "${HOME}/.zsh/completion.zsh" ] \
  && source "$HOME/.zsh/completion.zsh"

[ -r "${HOME}/.zsh/alias.zsh" ] \
  && source "${HOME}/.zsh/alias.zsh"

[ -r "${HOME}/.zsh/functions.zsh" ] \
  && source "${HOME}/.zsh/functions.zsh"

[ -r "${HOME}/.zsh/options.zsh" ] \
  && source "${HOME}/.zsh/options.zsh"
