# vim:ft=zsh

ZPLUGINDIR="${ZDOTDIR}/plugins"

plug() {
  local url="${1}"
  local use_file="${2}"
  local plugin_name plugin_dir
  local -a initfiles=()

  [[ ! -d "${ZPLUGINDIR}" ]] && mkdir "${ZPLUGINDIR}"

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
plug zdharma-continuum/fast-syntax-highlighting

plug MichaelAquilina/zsh-you-should-use you-should-use.plugin.zsh
plug RobSis/zsh-completion-generator     #'0b' '[[ -n ${ZLAST_COMMANDS[(r)gcom*]}  ]]' atload'gcomp(){ \gencomp $1 && zinit creinstall -q RobSis/zsh-completion-generator; }' pick'zsh-completion-generator.plugin.zsh'
plug ael-code/zsh-colored-man-pages
plug hlissner/zsh-autopair               #'0c' nocompletions
plug knu/zsh-manydots-magic manydots-magic
plug mdumitru/fancy-ctrl-z
plug seletskiy/zsh-fuzzy-search-and-edit #'0d' atload"bindkey '^T' fzy-file-widget"
plug soimort/translate-shell             #'0c' if'[[ -n "$commands[gawk]" ]]'
plug wfxr/forgit                         #'0c' has'git'
plug zdharma-continuum/history-search-multi-word

#plug tldr-pages/tldr
#plug junegunn/fzf                        #'0c' multisrc"shell/{completion,key-bindings}.zsh" id-as"junegunn/fzf_completions" pick"/dev/null"
#plug aperezdc/zsh-fzy                    #'0c' atload"bindkey '\ec' fzy-cd-widget; bindkey '^T' fzy-file-widget"

## Snippets ##
#zsnip  OMZ::plugins/extract               '0c' svn
#zsnip  OMZ::plugins/git-extras            '0c' svn
