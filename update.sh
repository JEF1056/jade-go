#!/usr/bin/env bash

while getopts 'lha:' OPTION; do
  case "$OPTION" in
    u)
      update="true"
      ;;
    a)
      commit_message="$OPTARG"
      echo "The value provided is $OPTARG"
      ;;
    ?)
      echo "script usage: $(basename \$0) [-l] [-h] [-a somevalue]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [ "$update" = 'true' ]; then
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y direnv
fi
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

cp docker/.envrc .envrc
cp -r docker/.vscode .vscode
cp docker/docker-compose.yml docker-compose.yml

direnv allow .

