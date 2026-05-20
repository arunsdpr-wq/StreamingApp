#!/bin/bash
# Jenkins installation script

set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Java
apt-get install -y openjdk-17-jdk

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y jenkins

# Install Docker
apt-get install -y docker.io

# Add Jenkins to Docker group
usermod -aG docker jenkins

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install AWS CLI
apt-get install -y awscli

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Start Jenkins
systemctl start jenkins
systemctl enable jenkins
systemctl restart docker
systemctl enable docker

echo "Jenkins installation complete!"
echo "Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080"
