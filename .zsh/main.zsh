# vim:ft=zsh

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

  [ -r "${HOME}/.zsh/no_zinit.zsh" ] \
    && source "${HOME}/.zsh/no_zinit.zsh"

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
