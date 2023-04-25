#!/bin/bash


  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&



LATEST_VERSION(){
local REPOS=$1
curl -s https://api.github.com/repos/$REPOS/releases/latest |grep -oP '"tag_name": "\K(.*)(?=")'
}


echo '[STEP 1] Creating directory for kubectl config'
mkdir /root/.kube

echo '[STEP 2] Installing Krew'
(
  set -x; cd "$(mktemp -d)" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" && rm ${KREW}.tar.gz 
  ./"${KREW}" install krew
)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

echo '[STEP 3] Installing kubectx and kubens - quickly switch kubernetes context and namespace'
(
  git clone https://github.com/ahmetb/kubectx /opt/kubectx && \
  ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
  ln -s /opt/kubectx/kubens /usr/local/bin/kubens
)

echo '[STEP 4] Installing stern'
(
    TAG=$(LATEST_VERSION "stern/stern")
    TAD=$(echo $TAG | awk -F "v" '{print$2}')
    wget -c  https://github.com/stern/stern/releases/download/${TAG}/stern_${TAD}_linux_amd64.tar.gz -O - | tar -xz && \
    chmod +x stern && \
    mv stern /usr/local/bin/stern
)

echo '[STEP 5] Installing kubectl-images plugin'
(
    set -x &&
    TAG=$(LATEST_VERSION "chenjiandongx/kubectl-images") &&
    wget -c https://github.com/chenjiandongx/kubectl-images/releases/download/${TAG}/kubectl-images_linux_amd64.tar.gz -O - | tar -xz &&
    chmod +x kubectl-images &&
    mv kubectl-images /usr/local/bin/
)

echo '[STEP 6] IInstalling kubectl-neat plugin'
(
    set -x &&
    TAG=$(LATEST_VERSION "itaysk/kubectl-neat") &&
    wget -c https://github.com/itaysk/kubectl-neat/releases/download/${TAG}/kubectl-neat_linux_amd64.tar.gz  -O - | tar -xz &&
    chmod +x kubectl-neat &&
    mv kubectl-neat /usr/local/bin/
)

echo '[STEP 7] IInstalling kubectl-iexec plugin'
(
    # Get latest release
    TAG=$(LATEST_VERSION "gabeduke/kubectl-iexec")

    # Donwload and extract binary to /usr/local/bin
    wget -c  https://github.com/gabeduke/kubectl-iexec/releases/download/${TAG}/kubectl-iexec_${TAG}_${OS:-Linux}_x86_64.tar.gz -O - | tar -xz &&
    chmod +x kubectl-iexec &&
    mv kubectl-iexec /usr/local/bin/
)

echo '[STEP 8] IInstalling kubectl-sniff plugin'
(
    kubectl krew install sniff
)
