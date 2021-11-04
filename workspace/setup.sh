#!/usr/bin/env bash

# Install Docker & unzip
echo "Downloading and installing Docker..."
sudo apt -qq update && sudo apt -qq install docker.io unzip -y


# Install Kops
echo "Downloading and installing Kops..."
curl -sLO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops


# Install Kubectl
echo "Downloading and installing Kubectl..."
curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


# Install AWS cli
echo "Downloading and installing AWS cli..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
sudo ./aws/install


# Validate instalations
echo "Validating docker installation..."
docker --version
if [ $? -ne 0 ]; then
    echo FAILED
fi
echo "Validating Kops installation..."
kops version
if [ $? -ne 0 ]; then
    echo FAILED
fi
echo "Validating Kubectl installation..."
kubectl version --client
if [ $? -ne 0 ]; then
    echo FAILED
fi
echo "Validating AWS cli installation..."
aws --version
if [ $? -ne 0 ]; then
    echo FAILED
fi