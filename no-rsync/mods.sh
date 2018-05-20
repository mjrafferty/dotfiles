#! /bin/bash

# Minimum merge size formula (Algebra) : (load_order - no_merge) / (254 - no_merge - ((load_order - no_merge) / minimum) = minimum

readonly MOD_DIR="/mnt/f/Skyrim_Tools/LE mods"
readonly LOAD_ORDER="/mnt/d/Documents/ModOrganizer/Skyrim/profiles/Test/loadorder.txt"
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

  local plugin dependency;

  cd "$MOD_DIR" || exit 1;

  echo "Gathering plugin master data..."

  for plugin in $(tail -n +2 "$LOAD_ORDER_UNIX" | grep -Ev "^($( tr '\n' '|' < "$NO_MERGE_FILE" | sed 's/|$//'))$"); do

    touch "$DEPENDENCIES"/"${plugin/*\//}".txt;

    for dependency in $(head -n50 -- */"$plugin" | grep -Poa "MAST..\K[[:print:]]*\.es."); do

      # Sanitizes masters that may not have correct capitalization
      grep -i "^${dependency}$" "$LOAD_ORDER_UNIX"  \
        | grep -Ev "^$( tr '\n' '|' < "$NO_MERGE_FILE" | sed 's/|$//')$" \
        | tee -a "$DEPENDENCIES"/"${plugin/*\//}".txt;

    done
  done \
    | sort -u > "$MASTERS_FILE"

}

# Plugins that have no masters that are to be merged, and no dependents, can be merged together easily
_easyMerge(){

  local dependency_list;

  cd "$DEPENDENCIES" || exit 1;

  echo "Creating list of easy to merge plugins..."

  for dependency_list in *; do

    if [[ ! -s "$dependency_list" ]]; then

      if ! (grep -q "^${dependency_list/.txt/}$" "$MASTERS_FILE"); then

        echo "${dependency_list/.txt/}";
        rm "$dependency_list";

      fi
    fi
  done > "$EASY_MERGE"

  cd "$FINAL_MERGES" || exit 1;

  split -l  "$MERGE_SIZE" "$EASY_MERGE" "easymerge_";

}

# Find logical merges based on masters and shared dependencies
_findMerges() {

  local master dependents_list

  cd "$DEPENDENCIES" || exit 1;

  echo "Generating dependent info...";

  # For each master file that is to be included in a merge, find its dependents
  for master in $(cat "$MASTERS_FILE"); do

    grep -l "^${master}$" -- * \
      | sed 's/.txt//' > "$DEPENDENTS"/"$master".txt;

  done

  cd "$DEPENDENTS" || exit 1;

  echo "Combining merges with masters..."

  for dependents_list in *; do

    if [[ -e "$dependents_list" ]]; then

      _recurseMasters "$dependents_list";

    fi
  done

  echo "Combining merges based on shared dependents..."

  for dependents_list in *; do

    if [[ -e "$dependents_list" ]]; then

      _recurseShared "$dependents_list";

    fi
  done

}

# Combine merges that share a dependent plugin
_recurseShared () {

  local shares_a_dependent dependent parent dependent_list;

  # Iterate over each plugin that is a dependent of this one
  for dependent in $(cat "$1"); do

    # Find other plugins that contain the same dependent
    mapfile -t shares_a_dependent < <(grep -l "^${dependent}$" -- * | grep -v "$1");

    # If one of them is a parent of this plugin, just remove the entry from this list and skip to the next
    for ((dependent_list=0; dependent_list<${#shares_a_dependent[@]}; dependent_list++)); do

      for parent in $*; do
        if [[ "$parent" == "${shares_a_dependent[dependent_list]}" ]]; then

          sed -i "/^$dependent$/d" "$1";
          shares_a_dependent[dependent_list]="NULL"
          echo "skipping $dependent in $1 as it is already in ${shares_a_dependent[dependent_list]}" >> ~/log && continue 2;


        fi
      done
    done

    # Remove all other instances of shared dependent, since the other lists will be merged with this one
    for dependent_list in ${shares_a_dependent[*]}; do

      [[ "$dependent_list" == "NULL" ]] && continue;

      sed -i "/^$dependent$/d" "$dependent_list";

    done

    [[ -n "${shares_a_dependent[0]}" ]] && echo "$1 shares $dependent with ${shares_a_dependent[*]}" >> ~/log;

    # Merge the other shared plugin lists into this one
    for dependent_list in ${shares_a_dependent[*]}; do

      if [[ -e "$dependent_list" ]]; then

        # Do the same check on the next file before merging
        # "$y" is the plugin file to check, "$* will contain all of its parents including this one
        _recurseShared "$dependent_list" "$*";

        echo "Merging $dependent_list into $1" >> ~/log

        echo "${dependent_list/.txt/}" >> "$1";
        cat "$dependent_list" >> "$1";
        rm "$dependent_list";

      fi
    done
  done

}

# Comibine merges into same merge as their masters
_recurseMasters () {

  local master;

  for master in $(grep -l "^${1/.txt/}$" -- *); do

    echo "Merging $1 into master $master" >> ~/log

    cat "$1" >> "$master";
    rm "$1";

    sort -u "$master" -o "$master";

    _recurseMasters "$master";

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

  #_makeJson;

  ln -sf "$DEPENDENCIES" ~/Dependencies
  ln -sf "$MASTERS_FILE" ~/Masters_File
  ln -sf "$EASY_MERGE" ~/Easy_Merge
  ln -sf "$DEPENDENTS" ~/Dependents
  ln -sf "$FINAL_MERGES" ~/Final_Merges
  ln -sf "$LOAD_ORDER_UNIX" ~/Load_Order

}

main;
