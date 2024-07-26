#!/bin/bash

############################################################
##### Docker Install (including Portainer) - Debian 12 #####
############################################################

echo "Installing Docker..."

# Check if update successful
if ! apt update; then
  echo "Error updating package list!"
  exit 1
fi

# Install dependencies
if ! apt install ca-certificates curl -y; then
  echo "Error installing dependencies!"
  exit 1
fi

# Create directory for keyring
install -m 0755 -d /etc/apt/keyrings || {
  echo "Error creating directory for keyring!"
  exit 1
}

# Download Docker GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc || {
  echo "Error downloading Docker GPG key!"
  exit 1
}

# Set permissions for key
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null || {
  echo "Error adding Docker repository!"
  exit 1
}

# Update package list again
apt update || {
  echo "Error updating package list after adding repository!"
  exit 1
}

# Install Docker packages
if ! apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y; then
  echo "Error installing Docker packages!"
  exit 1
fi

# Add user to docker group
usermod -aG docker $USER

echo "Installing Portainer..."

# Run Portainer container
docker run -d \
  --name=portainer \
  --restart=always \
  -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest || {
  echo "Error starting Portainer container!"
  exit 1
}

echo "Done!"
