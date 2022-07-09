#!/usr/bin/env bash

projects=( "bot" "user" "server" "shared" )

cd ${HOME}

git clone https://github.com/JEF1056/jade-go.git

for project in "${projects[@]}"
do
   : 
    git clone https://github.com/JEF1056/jade-go-${project}.git jade-go-${project}
    cd jade-go-${project}
    git submodule update --init
    cd -
done