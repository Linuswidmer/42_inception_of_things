#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io

    # Enable and start the Docker service
    sudo systemctl enable --now docker
    echo "Docker has been installed and started successfully."
else
    echo "Docker is already installed."
fi

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create k3d cluster
sudo k3d cluster create mycluster

# Install kubectl
sudo snap install kubectl --classic

# Create the 2 namespaces
sudo kubectl create namespace argocd
sudo kubectl create namespace dev

# Install Argo CD in the argocd namespace
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access ArgoCD by exposing the port
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443
