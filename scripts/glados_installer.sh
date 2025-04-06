#!/bin/bash

set -x

PS4='\[\e[32m\]+ ${BASH_SOURCE}:${LINENO}: \[\e[0m\]'


# Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package list again and install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to Docker group (optional, allows running Docker without sudo)
sudo usermod -aG docker $USER
# Necessary on WSL2
sudo chown $USER:$USER /var/run/docker.sock

# Install Ollama Docker
#sudo docker pull ollama/ollama

# Set Nvidia GPU usage for docker
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Install Open WebUI Docker
#sudo docker pull ghcr.io/open-webui/open-webui:latest

#Install unique docker for OpenWebUI and Ollama
sudo docker pull ghcr.io/open-webui/open-webui:ollama


echo "Installation complete. Please log out and log back in for group changes to take effect."i

set +x
