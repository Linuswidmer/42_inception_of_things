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

# Install Argo CD CLI
if ! command -v argocd &> /dev/null; then
    echo "Argo CD CLI is not installed. Installing..."
    # Download the latest version of the Argo CD CLI
    curl -sSL https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 -o /tmp/argocd
    sudo install /tmp/argocd /usr/local/bin/argocd
    echo "Argo CD CLI has been installed."
else
    echo "Argo CD CLI is already installed."
fi


# Create the 2 namespaces
sudo kubectl create namespace argocd
sudo kubectl create namespace dev

# Install Argo CD in the argocd namespace
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Patch argocd service to be a nodePort, to use without portForwarding from the outside
sudo kubectl patch svc argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30500}]'

# Get the initial admin password
PASSWORD=$(kubectl get secret argocd-secret -n argocd -o jsonpath='{.data.admin\.password}' | base64 -d)

# Login to Argo CD
IP_ADDRESS=$(hostname -I | awk '{print $1}')  # Get the host IP address
argocd login ${IP_ADDRESS}:30500 --username admin --password "${PASSWORD}"

# Apply the app file
sudo kubectl apply -f application.yaml

# Optional: Sync the application immediately
argocd app sync dev-app

