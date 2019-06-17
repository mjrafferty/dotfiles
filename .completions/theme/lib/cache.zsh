# vim:ft=bash
# Specifies the maximum number of elements in the cache. When the cache grows over this limit,
# it gets cleared. This is meant to avoid memory leaks when a rogue prompt is filling the cache
# with data.

typeset  -gA  _RIFF_CACHE
typeset  -g   _RIFF_CACHE_KEY

# Caching allows storing array-to-array associations. It should be used like this:
#
#   if ! _riff_cache_get "$key1" "$key2"; then
#     # Compute val1 and val2 and then store them in the cache.
#     _riff_cache_set "$val1" "$val2"
#   fi
#   # Here ${_RIFF_CACHE_VAL[1]} and ${_RIFF_CACHE_VAL[2]} are $val1 and $val2 respectively.
#
# Limitations:
#
#   * Calling _riff_cache_set without arguments clears the cache entry. Subsequent calls to
#     _riff_cache_get for the same key will return an error.
#   * There must be no intervening _riff_cache_get calls between the associated _riff_cache_get
#     and _riff_cache_set.
_riff_cache_set() {
  # Uncomment to see cache misses.
  # echo "caching: ${(@0q)_RIFF_CACHE_KEY} => (${(q)@})" >&2
  _RIFF_CACHE[$_RIFF_CACHE_KEY]="${(pj:\0:)*}0"
  _RIFF_CACHE_VAL=("$@")
  (( $#_RIFF_CACHE < RIFF_MAX_CACHE_SIZE )) || typeset -gAH _RIFF_CACHE
}

_riff_cache_get() {
  _RIFF_CACHE_KEY="${(pj:\0:)*}"
  local v=$_RIFF_CACHE[$_RIFF_CACHE_KEY]
  [[ -n $v ]] && _RIFF_CACHE_VAL=("${(@0)${v[1,-2]}}")
}

_riff_cached_cmd_stdout() {
  local cmd=$commands[$1]
  [[ -n $cmd ]] || return
  shift
  local -H stat
  zstat -H stat -- $cmd 2>/dev/null || return
  if ! _riff_cache_get $0 $stat[inode] $stat[mtime] $stat[size] $stat[mode] $cmd "$@"; then
    local out
    out=$($cmd "$@" 2>/dev/null)
    _riff_cache_set $(( ! $? )) "$out"
  fi
  (( $_RIFF_CACHE_VAL[1] )) || return
  _RIFF_RETVAL=$_RIFF_CACHE_VAL[2]
}

_riff_cached_cmd_stdout_stderr() {
  local cmd=$commands[$1]
  [[ -n $cmd ]] || return
  shift
  local -H stat
  zstat -H stat -- $cmd 2>/dev/null || return
  if ! _riff_cache_get $0 $stat[inode] $stat[mtime] $stat[size] $stat[mode] $cmd "$@"; then
    local out
    out=$($cmd "$@" 2>&1)  # this line is the only diff with _riff_cached_cmd_stdout
    _riff_cache_set $(( ! $? )) "$out"
  fi
  (( $_RIFF_CACHE_VAL[1] )) || return
  _RIFF_RETVAL=$_RIFF_CACHE_VAL[2]
}
