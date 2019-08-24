#! /bin/zsh

# Automatically open and close tmux session when connecting via SSH
if type tmux &> /dev/null && [[  -z $TMUX && -n $SSH_TTY ]]; then
  (tmux has-session -t "${HOME/*\//}" &> /dev/null && tmux attach -t "${HOME/*\//}") \
    || tmux new-session -s "${HOME/*\//}"
  exit;
fi

if is-at-least 5.1; then

[ -r "${HOME}/.zsh/plugins_core.zsh" ] \
  && source "${HOME}/.zsh/plugins_core.zsh"

else

	[ -r "${HOME}/.zsh/zplugin/plugins/mjrafferty---apollo-zsh-theme/apollo-zsh-theme.zsh" ] \
		&& source "${HOME}/.zsh/zplugin/plugins/mjrafferty---apollo-zsh-theme/apollo-zsh-theme.zsh"

	[ -r "${HOME}/.zsh/zplugin/plugins/trapd00r---LS_COLORS/c.zsh" ] \
		&& source "${HOME}/.zsh/zplugin/plugins/trapd00r---LS_COLORS/c.zsh"

	[ -r "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-completions/zsh-completions.plugin.zsh" ] \
		&& source "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-completions/zsh-completions.plugin.zsh"

	[ -r "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-history-substring-search/zsh-history-substring-search.plugin.zsh" ] \
		&& source "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-history-substring-search/zsh-history-substring-search.zsh"

	[ -r "${HOME}/.zsh/zplugin/plugins/zdharma---fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] \
		&& source "${HOME}/.zsh/zplugin/plugins/zdharma---fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

	[ -r "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
		&& source "${HOME}/.zsh/zplugin/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh"

fi

[ -r "${HOME}/.zsh/env.zsh" ] \
  && source "${HOME}/.zsh/env.zsh"

[ -r "${HOME}/.zsh/completion.zsh" ] \
  && source "$HOME/.zsh/completion.zsh"

[ -r "${HOME}/.zsh/alias.zsh" ] \
  && source "${HOME}/.zsh/alias.zsh"

[ -r "${HOME}/.zsh/functions.zsh" ] \
  && source "${HOME}/.zsh/functions.zsh"

## cd options ##
setopt autocd
setopt auto_pushd
setopt cdable_vars
setopt chase_dots
setopt chase_links

setopt extendedglob
setopt nomatch

setopt appendhistory
setopt hist_ignore_dups
setopt hist_fcntl_lock
setopt hist_verify
unsetopt beep

#setopt nullglob

## Vi key bindings
bindkey -v
export KEYTIMEOUT=1
