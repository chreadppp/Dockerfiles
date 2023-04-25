#!/bin/bash


  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&



LATEST_VERSION(){
local REPOS=$1
curl -s https://api.github.com/repos/$REPOS/releases/latest |grep -oP '"tag_name": "\K(.*)(?=")'
}

echo 'Bootstrap steps start here:'

echo '[STEP 1] Installing k9s awesomeness'
(
  set -x &&
  TAG=$(LATEST_VERSION "derailed/k9s") && 
  wget -c https://github.com/derailed/k9s/releases/download/$TAG/k9s_Linux_amd64.tar.gz -O - | tar -xz &&
  chmod +x k9s &&
  mv k9s /usr/local/bin/
)
echo '[STEP 2] Installing Oh-My-Zsh'
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo '[STEP 3] Installing zsh-autosuggestions plugin'
git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions


echo '[STEP 4] Installing Okteto for local development'
curl https://get.okteto.com -sSfL | sh

echo '[STEP 5] Install tmux with cool customizations'
git clone https://github.com/samoshkin/tmux-config.git
./tmux-config/install.sh

echo '[STEP 6] Setting zsh as default shell'
chsh -s $(which zsh)
