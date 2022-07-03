#!/usr/bin/env bash

go_projects=( "jade-go-bot" "jade-go-server" "jade-go-shared" )

while getopts 'uc:' OPTION; do
  case "$OPTION" in
    u)
      sudo apt update
      sudo apt upgrade -y
      sudo apt install -y direnv
      ;;
    c)
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

grep -qxF 'eval "$(direnv hook bash)"' ~/.bashrc || echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

source ~/.bashrc

git submodule --quiet update --recursive

if test -z "$commit_message"; then
    echo "Skipping commit"
else
    git submodule --quiet foreach git add --all
    git submodule --quiet foreach git commit -m "$commit_message"
    git submodule --quiet foreach git push
    git add --all
    git commit -m "$commit_message"
    git push
fi

git submodule --quiet update --recursive

for i in "${go_projects[@]}"
do
   : 
    cd $i
    go mod tidy
    go get -u
    cd ..
done

if test -z "$commit_message"; then
    echo "Skipping commit"
else
    git submodule --quiet foreach git add --all
    git submodule --quiet foreach git commit -m "$commit_message"
    git submodule --quiet foreach git push
    git add -A
    git commit -m "$commit_message"
    git push
fi

cp docker/.envrc .envrc
cp -r docker/.vscode .vscode
cp docker/docker-compose.yml docker-compose.yml

direnv allow .

