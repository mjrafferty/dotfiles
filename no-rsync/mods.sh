#! /bin/bash

# Minimum merge size formula (Algebra) : (load_order - no_merge) / (254 - no_merge - ((load_order - no_merge) / minimum) = minimum

readonly MOD_DIR="/mnt/f/Skyrim_Tools/LE mods"
readonly LOAD_ORDER="/mnt/f/Skyrim_Tools/Mod Organizer/profiles/Test/loadorder.txt"
readonly NO_MERGE_FILE="$HOME/no_merge.txt"

readonly MERGE_SIZE="50";

readonly IFS="
"

LOAD_ORDER_UNIX=$(mktemp);
DEPENDENCIES=$(mktemp -d);
DEPENDENTS=$(mktemp -d);
MASTERS_FILE=$(mktemp);
EASY_MERGE=$(mktemp);
FINAL_MERGES=$(mktemp -d);

# Obtain dependency info from plugin files
_checkMasters() {

  local x i;

  cd "$MOD_DIR" || exit 1;

  echo "Gathering plugin master data..."

  for x in $(tail -n +2 "$LOAD_ORDER_UNIX" | grep -Ev "^($( tr '\n' '|' < "$NO_MERGE_FILE" | sed 's/|$//'))$"); do

    touch "$DEPENDENCIES"/"${x/*\//}".txt;

    for i in $(head -n50 -- */"$x" | grep -Poa "MAST..\K[[:print:]]*\.es."); do

      # Sanitizes masters that may not have correct capitalization
      grep -i "^${i}$" "$LOAD_ORDER_UNIX"  \
        | grep -Ev "^$( tr '\n' '|' < "$NO_MERGE_FILE" | sed 's/|$//')$" \
        | tee -a "$DEPENDENCIES"/"${x/*\//}".txt;

    done
  done \
    | sort -u > "$MASTERS_FILE"

}

# Plugins that have no masters that are to be merged, and no dependents, can be merged together easily
_easyMerge(){

  local x;

  cd "$DEPENDENCIES" || exit 1;

  echo "Creating list of easy to merge plugins..."

  for x in *; do

    if [[ ! -s "$x" ]]; then

      if ! (grep -q "^${x/.txt/}$" "$MASTERS_FILE"); then

        echo "${x/.txt/}";
        rm "$x";

      fi
    fi
  done > "$EASY_MERGE"

  cd "$FINAL_MERGES" || exit 1;

  split -l  "$MERGE_SIZE" "$EASY_MERGE" "easymerge_";

}

# Find logical merges based on masters and shared dependencies
_findMerges() {

  local x y z

  cd "$DEPENDENCIES" || exit 1;

  echo "Generating dependent info...";

  # For each master file that is to be included in a merge, find its dependents
  for x in $(cat "$MASTERS_FILE"); do

    grep -l "^${x}$" -- * \
      | sed 's/.txt//' > "$DEPENDENTS"/"$x".txt;

  done

  cd "$DEPENDENTS" || exit 1;

  echo "Combining merges with masters..."

  for y in *; do

    if [[ -e "$y" ]]; then

      _recurseMasters "$y";

    fi
  done

  echo "Combining merges based on shared dependents..."

  for z in *; do

    if [[ -e "$z" ]]; then

      _recurseShared "$z";

    fi
  done

}

# Combine merges that share a dependent plugin
_recurseShared () {

  local dupes x i d y;

  # Iterate over each plugin that is a dependent of this one
  for x in $(cat "$1"); do

    # Find other plugins that contain the same dependent
    mapfile -t dupes < <(grep -l "^${x}$" -- * | grep -v "$1");

    # If one of them is a parent of this plugin, just remove the entry from this list and skip to the next
    for i in ${dupes[*]}; do

      if [[ "$*" == "$i" ]]; then

        sed -i "/^$x$/d" "$1";
        echo "skipping $x in $1 as it is already in $i" >> ~/log && continue 2;

      fi
    done

    # Remove all other instances of shared dependent, since the other lists will be merged with this one
    for d in ${dupes[*]}; do

      sed -i "/^$x$/d" "$d";

    done

    [[ -n "${dupes[0]}" ]] && echo "$1 shares $x with ${dupes[*]}" >> ~/log;

    # Merge the other shared plugin lists into this one
    for y in ${dupes[*]}; do

      if [[ -e "$y" ]]; then

        # Do the same check on the next file before merging
        # "$y" is the plugin file to check, "$* will contain all of its parents including this one
        _recurseShared "$y" "$*";

        echo "Merging $y into $1" >> ~/log

        echo "${y/.txt/}" >> "$1";
        cat "$y" >> "$1";
        rm "$y";

      fi
    done
  done

}

# Comibine merges into same merge as their masters
_recurseMasters () {

  local x;

  for x in $(grep -l "^${1/.txt/}$" -- *); do

    echo "Merging $1 into master $x" >> ~/log

    cat "$1" >> "$x";
    rm "$1";

    sort -u "$x" -o "$x";

    _recurseMasters "$x";

  done

}

# Combine merges based on size
_combineMerges () {

  local tempdata merge_name merge_quantity x y;

  echo "Combining merges based on size...";

  tempdata=$(wc -l -- * | sort -k1nr | tail -n +2)

  mapfile -t merge_quantity < <(echo "$tempdata" | awk '{count=$1+1; print count}');
  mapfile -t merge_name < <(echo "$tempdata" | grep -Po "\s*\d*\s*\K.*");

  # Iterate through merges
  for ((x=0;x<${#merge_quantity[@]};x++)); do

    # Check if merge file still exists and has less than $MERGE_SIZE plugins in it
    if [[ -e "${merge_name[x]}" && "${merge_quantity[x]}" -lt "$MERGE_SIZE" ]]; then

      # Search for suitable merges to comine into this one.
      for ((y=x+1;y<${#merge_quantity[@]};y++)); do

        # Make sure second file still exists and see if its size will fit well with current merge file
        if [[ -e "${merge_name[y]}" && $(( merge_quantity[x] + merge_quantity[y] )) -le "$MERGE_SIZE" ]]; then

          echo "${merge_name[y]/.txt/}" >> "${merge_name[x]}";
          cat "${merge_name[y]}" >> "${merge_name[x]}";
          rm "${merge_name[y]}";

          merge_quantity[x]=$(( merge_quantity[x] + merge_quantity[y] ));

          if [[ ! "${merge_quantity[x]}" -lt "$MERGE_SIZE" ]]; then

            continue 2;

          fi
        fi
      done
    fi
  done

}

# Create json output for MergePlugins utility
_makeJson () {

  cat <<- EOF | tr -d '\n'
  {
    "merges":[
    {
      "ignoredDependencies":[],
      "method":"Overrides",
      "dateBuilt":"12\/30\/1899",
      "masters":[],
      "filename":"NewMerge.esp",
      "pluginHashes":[],
      "bIgnoreNonContiguous":false,
      "files":[],
      "fails":[],
      "name":"Errors",
      "plugins":[
      "MoonAndStar_MAS.esp"
      ],
      "renumbering":"Conflicting"
    },
    {
      "ignoredDependencies":[],
      "method":"Overrides",
      "dateBuilt":"12\/30\/1899",
      "masters":[],
      "filename":"NewMerge1.esp",
      "pluginHashes":[],
      "bIgnoreNonContiguous":false,
      "files":[],
      "fails":[],
      "name":"NewMerge",
      "plugins":[
      "ApachiiHair.esm"
      ],
      "renumbering":"Conflicting"
    }
    ]
  }
EOF

}

main() {

  #Make load order unix friendly
  cp "$LOAD_ORDER" "$LOAD_ORDER_UNIX";
  dos2unix -q "$LOAD_ORDER_UNIX"

  _checkMasters;

  _easyMerge;

  _findMerges;

  _combineMerges

  _makeJson;

  cat <<- EOF

  Dependencies: $DEPENDENCIES
  Masters:      $MASTERS_FILE
  Easy Merge:   $EASY_MERGE
  Dependents:   $DEPENDENTS

  Final Merges: $FINAL_MERGES

EOF

}

main;
