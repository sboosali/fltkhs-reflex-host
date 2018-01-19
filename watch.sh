#!/bin/bash

###########################################

# GHCID_COMMAND='cabal repl fltkhs-reflex' 
# # GHCID_COMMAND='ghci -fobject-code -ferror-spans -ignore-dot-ghci' 
# ghcid -o ghcid.txt --command "${GHCID_COMMAND}"
# 
# can't load .so/.DLL for libHSfltkhs: /nix/store/p032q22qigxr838sn# undefined symbol: Fl_Adjuster_New

# $ ghcid --command 'cat' --test 'cabal build' 

# function set-timestamps () {
#   TIMESTAMP=`date '+%T'`
# }

########################################

BUILD_COMMAND='cabal build'

WATCHED_DIRECTORY=./sources/

WATCHED_EXTENSION="hs"
WATCHED_REGEX='\.'"$WATCHED_EXTENSION"'$'
IGNORED_REGEX='(.*~|\.#.*)' # emacs temp files

INOTIFY_EVENTS='modify,create,delete'

# stubs
OLD_TIMESTAMP="xx:xx:xx"
NEW_TIMESTAMP="yy:yy:yy"

function debounce () {

  # seconds resolution
  NEW_TIMESTAMP=`date '+%T'`

  # string equality
  if [ "$NEW_TIMESTAMP" = "$OLD_TIMESTAMP" ]; then
     EXIT_CODE=1 
     # too soon, exit code failure
  else
     EXIT_CODE=0
     # a second boundary was crossed, later enough, exit code success
  fi

  OLD_TIMESTAMP="$NEW_TIMESTAMP"  
  return $EXIT_CODE
}

echo Watching "$WATCHED_DIRECTORY"
echo

inotifywait --monitor --event $INOTIFY_EVENTS --recursive $WATCHED_DIRECTORY  | grep "$WATCHED_REGEX" --line-buffered  | grep -E -v "$IGNORED_REGEX" --line-buffered  | while read -r directory event filename; do

  if debounce; then
  filepath="${directory}${filename}"
  echo
  echo '----------------------------------------'
  echo ${filepath}
  echo

  # needed for a command with spaces
  eval "$BUILD_COMMAND"
  fi
done

########################################
