# vim:ft=zsh

ZPLUGINDIR="${ZDOTDIR}/plugins"

plug() {
  local url use_file plugin_name plugin_dir
  local -a initfiles
  url="${1}"
  use_file="${2}"
  initfiles=()

  if [[ ! -d "${ZPLUGINDIR}" ]]; then
    mkdir "${ZPLUGINDIR}"
  fi

  plugin_name="${url:t}"
  plugin_dir="${ZPLUGINDIR}/${plugin_name}"

  if [[ ! -d "${plugin_dir}" ]]; then
    printf "Cloning %s..." "${url}"
    git clone --depth 1 "https://github.com/${url}" "${plugin_dir}" &> /dev/null
    printf "Done\n"
  fi

  if [[ -n "${use_file}" ]]; then
    initfiles+=( "${plugin_dir}/${use_file}" )
  fi

  initfiles+=(
    $plugin_dir/${plugin_name}.{plugin.,}{z,}sh{-theme,}(N)
    $plugin_dir/*.{plugin.,}{z,}sh{-theme,}(N)
  )

  if (( $#initfiles )); then
    source ${initfiles[1]}
  else
    echo "Failed loading ${url}" >&2
  fi
}

plug mafredri/zsh-async
plug mjrafferty/apollo-zsh-theme
plug mjrafferty/zhist
plug trapd00r/LS_COLORS
plug zsh-users/zsh-completions
plug zsh-users/zsh-autosuggestions
plug zsh-users/zsh-history-substring-search
plug zsh-users/zsh-syntax-highlighting
plug hlissner/zsh-autopair
plug mdumitru/fancy-ctrl-z
#plug zdharma-continuum/history-search-multi-word
