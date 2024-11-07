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
#sudo kubectl patch svc argocd-server -n argocd --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30500}]'

# Wait for the Argo CD pods to be ready
echo "Waiting for Argo CD to be ready..."
while true; do
    if sudo kubectl get pods -n argocd | grep -q '1/1'; then
        echo "Argo CD is ready."
        break
    else
        echo "Waiting for Argo CD pods to be ready..."
        sleep 5
    fi
done

# Wait for the initial admin secret to be created
echo "Waiting for the Argo CD initial admin secret to be created..."
while true; do
    if sudo kubectl get secret argocd-initial-admin-secret -n argocd &> /dev/null; then
        echo "Initial admin secret is available."
        break
    else
        echo "Waiting for the initial admin secret..."
        sleep 5
    fi
done

# Check if the service is accessible
#echo "Waiting for argocd-server to be accessible..."
#for i in {1..20}; do
#    if nc -zv localhost 30500; then
#        echo "argocd-server is accessible."
#        break
#    else
#        echo "argocd-server not accessible, retrying in 5 seconds..."
#        sleep 5
#    fi
#    if [ "$i" -eq 20 ]; then
#        echo "Error: argocd-server not accessible after multiple attempts."
#        kubectl describe svc argocd-server -n argocd
#        exit 1
#    fi
#done

# REtrive the server address and admin password
#ARGOCD_SERVER=$(sudo kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
#ARGOCD_PASSWORD=$(sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)

# Log the ARGOCD_SERVER value
#echo "Argo CD Server Address: $ARGOCD_SERVER"

# Ensure ARGOCD_SERVER is set correctly
#if [ -z "$ARGOCD_SERVER" ]; then
#    echo "Error: ARGOCD_SERVER is not set. Exiting..."
#    exit 1
#fi


# Get the Argo CD password
PASSWORD=$(sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
echo "The Argo CD initial admin password is: $PASSWORD"

# Wait for Argo CD server pod to be ready
echo "Waiting for Argo CD server pod to be in running state..."
while true; do
    POD_STATUS=$(sudo kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].status.phase}')
    if [[ "$POD_STATUS" == "Running" ]]; then
        echo "Argo CD server pod is running."
        break
    else
        echo "Current status=$POD_STATUS. Waiting for the pod to be running..."
        sleep 5
    fi
done

# Port forward the Argo CD server
echo "Port forwarding Argo CD server to localhost:8080..."
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Give the port-forward command a moment to start
sleep 5

# Login to Argo CD 
echo "Logging in to Argo CD..."
argocd login localhost:8080 --username admin --password "$PASSWORD" --insecure

# Apply the app file
echo "Applying the application.yaml file..."
sudo kubectl apply -f application.yaml

# Create the Argo CD application
#echo "Creating Argo CD application..."
#sudo argocd app create dev-app --path wil --sync-policy auto --dest-server https://kubernetes.default.svc --repo https://github.com/mdarbois/Iot_mdarbois_argoCD --dest-namespace dev

echo "Argo CD setup complete. Access the Argo CD UI at http://localhost:8080"

# Get the initial admin password
#PASSWORD=$(kubectl get secret argocd-secret -n argocd -o jsonpath='{.data.admin\.password}' | base64 -d)

# Login to Argo CD with localhost IP
#argocd login localhost:30500 --username admin --password "${PASSWORD}" --insecure


# Change the image to v2
sudo kubectl set image deployment/wil-playground wil-playground=wil42/playground:v2 -n dev

# Optional: Sync the application immediately
argocd app sync dev-app


