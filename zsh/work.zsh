# vim:ft=zsh

HISTFILE="${XDG_DATA_HOME}/zsh_history"

zstyle ':apollo:*:*:*:dir:*' bookmark_patterns "$HOME/Repositories/*" "$HOME/*"
zstyle ':apollo:*:*:*:dir:*' bookmarks "dotfiles=$HOME/.dotfiles"

load_conf main
#load_conf zinit_optional
#load_conf zinit_programs

if [[ -e "${HOME}/Dev/nxclient.token" ]]; then
  source "${HOME}/Dev/nxclient.token"
fi

export PYENV_ROOT="${XDG_DATA_HOME}/pyenv"
export PYENV_SHELL=zsh
export PATH="/Users/mrafferty/.local/share/pyenv/shims:${PATH}"
[[ -e /opt/homebrew/opt/pyenv/completions/pyenv.zsh ]] && \
  source '/opt/homebrew/opt/pyenv/completions/pyenv.zsh'

## Needed for puppet linting
export BUNDLE_GEMFILE="${HOME}/Repositories/nexcess/Puppet/puppet6-Gemfile"
export PUPPET_GEM_VERSION='~> 6.28.0'

setpath "${HOME}/.composer/vendor/bin"
setpath /opt/homebrew/bin

type exa &> /dev/null && alias ls=exa
