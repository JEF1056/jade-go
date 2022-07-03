#!/usr/bin/env bash

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

if test -z "$commit_message"; then
    echo "Skipping commit"
else
    git submodule foreach git add -A
    git submodule foreach git commit -m "$commit_message"
    git submodule foreach git push
    git add .
    git commit -m "$commit_message"
    git push
fi

git submodule update --recursive

git submodule foreach go mod tidy
git submodule foreach go get -u

cp docker/.envrc .envrc
cp -r docker/.vscode .vscode
cp docker/docker-compose.yml docker-compose.yml

direnv allow .

