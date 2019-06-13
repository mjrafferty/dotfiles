# vim:ft=bash
# Specifies the maximum number of elements in the cache. When the cache grows over this limit,
# it gets cleared. This is meant to avoid memory leaks when a rogue prompt is filling the cache
# with data.

# Caching allows storing array-to-array associations. It should be used like this:
#
#   if ! _p9k_cache_get "$key1" "$key2"; then
#     # Compute val1 and val2 and then store them in the cache.
#     _p9k_cache_set "$val1" "$val2"
#   fi
#   # Here ${_P9K_CACHE_VAL[1]} and ${_P9K_CACHE_VAL[2]} are $val1 and $val2 respectively.
#
# Limitations:
#
#   * Calling _p9k_cache_set without arguments clears the cache entry. Subsequent calls to
#     _p9k_cache_get for the same key will return an error.
#   * There must be no intervening _p9k_cache_get calls between the associated _p9k_cache_get
#     and _p9k_cache_set.
_p9k_cache_set() {
  # Uncomment to see cache misses.
  # echo "caching: ${(@0q)_P9K_CACHE_KEY} => (${(q)@})" >&2
  _P9K_CACHE[$_P9K_CACHE_KEY]="${(pj:\0:)*}0"
  _P9K_CACHE_VAL=("$@")
  (( $#_P9K_CACHE < POWERLEVEL9K_MAX_CACHE_SIZE )) || typeset -gAH _P9K_CACHE
}

_p9k_cache_get() {
  _P9K_CACHE_KEY="${(pj:\0:)*}"
  local v=$_P9K_CACHE[$_P9K_CACHE_KEY]
  [[ -n $v ]] && _P9K_CACHE_VAL=("${(@0)${v[1,-2]}}")
}

_p9k_cached_cmd_stdout() {
  local cmd=$commands[$1]
  [[ -n $cmd ]] || return
  shift
  local -H stat
  zstat -H stat -- $cmd 2>/dev/null || return
  if ! _p9k_cache_get $0 $stat[inode] $stat[mtime] $stat[size] $stat[mode] $cmd "$@"; then
    local out
    out=$($cmd "$@" 2>/dev/null)
    _p9k_cache_set $(( ! $? )) "$out"
  fi
  (( $_P9K_CACHE_VAL[1] )) || return
  _P9K_RETVAL=$_P9K_CACHE_VAL[2]
}

_p9k_cached_cmd_stdout_stderr() {
  local cmd=$commands[$1]
  [[ -n $cmd ]] || return
  shift
  local -H stat
  zstat -H stat -- $cmd 2>/dev/null || return
  if ! _p9k_cache_get $0 $stat[inode] $stat[mtime] $stat[size] $stat[mode] $cmd "$@"; then
    local out
    out=$($cmd "$@" 2>&1)  # this line is the only diff with _p9k_cached_cmd_stdout
    _p9k_cache_set $(( ! $? )) "$out"
  fi
  (( $_P9K_CACHE_VAL[1] )) || return
  _P9K_RETVAL=$_P9K_CACHE_VAL[2]
}
