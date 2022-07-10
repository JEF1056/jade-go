#!/usr/bin/env bash

while getopts 'm:' OPTION; do
  case "$OPTION" in
    m)
      commit_message="$OPTARG"
      echo "The value provided is $OPTARG"
      ;;
    ?)
      echo "script usage: $(basename \$0) [-u] [-c commit_message]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

projects=( "bot" "user" "server" "shared" )

cd ${HOME}

for project in "${projects[@]}"
do
   :
    cd jade-go-${project}
    git add .
    git commit -m "${commit_message}"
    git push
    cd -
done

cd -