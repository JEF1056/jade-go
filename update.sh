#!/usr/bin/env bash

sudo apt update
sudo apt upgrade -y
sudo apt install -y direnv

grep -qxF 'eval "$(direnv hook bash)"' ~/.bashrc || echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

source ~/.bashrc

git submodule update --init --recursive

cp docker/.envrc .envrc
cp -r docker/.vscode .vscode
cp docker/docker-compose.yml docker-compose.yml

direnv allow .

