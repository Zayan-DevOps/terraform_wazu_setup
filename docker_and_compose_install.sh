#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Update package list
sudo apt-get update -y

# Install required dependencies
sudo apt-get install -y ca-certificates curl

# Create directory for keyrings
sudo install -m 0755 -d /etc/apt/keyrings

# Download and store the Docker GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list after adding the repository
sudo apt-get update -y

# Install Docker packages
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin




sudo apt-get update -y

sudo apt-get install docker-compose -y 



# git clone https://github.com/wazuh/wazuh-docker.git
# cd wazuh-docker/single-node

git clone git@github.com:Zayan-DevOps/terraform_wazu_setup.git
cd /home/ubuntu/terraform_wazu_setup
sudo docker-compose up -d --build 

# sed -i -e 's#wazuh/wazuh-manager:5.0.0#wazuh/wazuh-manager:4.11.1#g' \
#        -e 's#wazuh/wazuh-indexer:5.0.0#wazuh/wazuh-indexer:4.11.1#g' \
#        -e 's#wazuh/wazuh-dashboard:5.0.0#wazuh/wazuh-dashboard:4.11.1#g' \
#        /home/ubuntu/wazuh-docker/single-node/docker-compose.yml



# sudo docker-compose up -d --build