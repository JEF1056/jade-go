#!/usr/bin/env bash

install_gpu="false"
install_docker="false"
env="dev"

while getopts 'gdp' OPTION; do
  case "$OPTION" in
    g)
        install_gpu="true"
        echo "Running script with GPU setup"
        ;;
    d) 
        install_docker="true"
        echo "Running script with docker setup"
        ;;
    p) 
        env="prod"
        echo "Setting up Prod enviornment"
        ;;
    ?)
      echo "script usage: $(basename \$0) [-g] (install with gpu support) [-d] (install with docker)" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

sudo apt update
sudo apt upgrade
sudo apt install -y build-essential

projects=( "bot" "user" "server" "shared" )

cd ${HOME}

wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz
grep -qxF 'export PATH=$PATH:/usr/local/go/bin' ~/.bashrc || echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
grep -qxF 'export GOPRIVATE=github.com/JEF1056/*' ~/.bashrc || echo 'export GOPRIVATE=github.com/JEF1056/*' >> ~/.bashrc
grep -qxF "export ENV=${env}" ~/.bashrc || echo "export ENV=${env}" >> ~/.bashrc
if $env = "prod"; then
    grep -qxF "export WAIT=" ~/.bashrc || echo "export WAIT=" >> ~/.bashrc
else
    grep -qxF "export WAIT=./" ~/.bashrc || echo "export WAIT=./" >> ~/.bashrc
fi
source ~/.bashrc
go version
rm go1.18.3.linux-amd64.tar.gz

git clone https://github.com/JEF1056/jade-go.git

for project in "${projects[@]}"
do
   : 
    git clone https://github.com/JEF1056/jade-go-${project}.git jade-go-${project}
    cd jade-go-${project}
    if project != "shared"
        git submodule update --init --recursive
        cd shared
        git checkout docker
        cd -
    fi
    cd -
done

if $install_docker == "true"; then
    curl https://get.docker.com | sh 
    sudo systemctl --now enable docker

    sudo groupadd docker
    sudo usermod -aG docker $USER
fi

if $install_gpu == "true"; then
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
        && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt update
    sudo apt install -y nvidia-docker2
    sudo systemctl restart docker

    docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
fi

sudo apt autoremove -y