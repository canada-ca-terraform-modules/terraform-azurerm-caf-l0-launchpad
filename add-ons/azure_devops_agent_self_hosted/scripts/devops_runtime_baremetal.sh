#!/bin/sh

url=${1}
pat_token=${2}
agent_pool=${3}
agent_prefix=${4}
num_agent=${5}
admin_user=${6}
rover_version="${7}"


#strict mode, fail on error
set -euo pipefail

echo "start"

echo "install Ubuntu packages"

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
export DEBIAN_FRONTEND=noninteractive
echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

apt-get update
apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
        apt-transport-https \
        docker.io

echo "Allowing agent to run docker"

usermod -aG docker ${admin_user}
systemctl daemon-reload
systemctl enable docker
service docker start
docker --version

# Pull rover base image
echo "Rover docker image ${rover_version}"
docker pull "${rover_version}"

echo "Installing Azure CLI"

curl -sL https://aka.ms/InstallAzureCLIDeb | bash

echo "install VSTS Agent"

cd /home/${admin_user}
mkdir -p agent
cd agent

AGENTRELEASE="$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')"
AGENTURL="https://vstsagentpackage.azureedge.net/agent/${AGENTRELEASE}/vsts-agent-linux-x64-${AGENTRELEASE}.tar.gz"
echo "Release "${AGENTRELEASE}" appears to be latest" 
echo "Downloading..."
wget -O agent_package.tar.gz ${AGENTURL} 

az login --identity

for agent_num in $(seq 1 ${num_agent}); do
  agent_dir="agent-$agent_num"
  mkdir -p "$agent_dir"
  cd "$agent_dir"
    name="${agent_prefix}-${agent_num}" 
    echo "installing agent $name"
    tar zxvf ../agent_package.tar.gz
    chmod -R 777 .
    echo "extracted"
    ./bin/installdependencies.sh
    echo "dependencies installed"
    sudo -u ${admin_user} ./config.sh --unattended --url "${url}" --auth pat --token "${pat_token}" --pool "${agent_pool}" --agent "${name}" --acceptTeeEula   --replace --work ./_work --runAsService
    echo "configuration done"
    ./svc.sh install
    echo "service installed"
    ./svc.sh start
    echo "service started"
    echo "config done"
  cd ..
done

