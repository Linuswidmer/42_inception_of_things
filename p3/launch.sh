#!/bin/bash

# 1. Create a K3d Cluster
echo "Creating K3d cluster 'development'..."
k3d cluster create development --api-port 6550 --port '8080:80@loadbalancer' --agents 2
if [ $? -ne 0 ]; then
  echo "Failed to create K3d cluster. Exiting."
  exit 1
fi

# 2. Install Argo CD in K3d Cluster
echo "Creating namespace for Argo CD..."
kubectl create namespace argocd

echo "Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
if [ $? -ne 0 ]; then
  echo "Failed to install Argo CD. Exiting."
  exit 1
fi

# 3. Verify that Argo CD is running
echo "Waiting for Argo CD pods to be in 'Running' state..."
kubectl -n argocd wait --for=condition=Ready pods --all --timeout=300s
if [ $? -ne 0 ]; then
  echo "Argo CD pods are not ready. Exiting."
  exit 1
fi

# 4. Port-Forward Argo CD to Access UI
echo "Port-forwarding Argo CD UI to localhost:8081..."
kubectl port-forward svc/argocd-server -n argocd 8081:443 &
if [ $? -ne 0 ]; then
  echo "Failed to port-forward Argo CD UI. Exiting."
  exit 1
fi

# 5. Check if Argo CD is available at https://localhost:8081
echo "Checking if Argo CD is available at https://localhost:8081..."
sleep 5  # Wait a few seconds for the service to start
curl --insecure https://localhost:8081 > /dev/null
if [ $? -ne 0 ]; then
  echo "Argo CD is not available at https://localhost:8081. Exiting."
  exit 1
fi

# 6. Get the initial password
echo "Getting the initial password for Argo CD..."
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > argocd_pwd
if [ $? -ne 0 ]; then
  echo "Failed to retrieve Argo CD password. Exiting."
  exit 1
fi

echo "Argo CD initial password saved to 'argocd_pwd'."

# 7. Log in to Argo CD CLI
echo "Logging in to Argo CD CLI..."
argocd login localhost:8081 --username admin --password $(cat argocd_pwd)
if [ $? -ne 0 ]; then
  echo "Failed to log in to Argo CD. Exiting."
  exit 1
fi

# 8. Create an Argo CD Application
echo "Creating Argo CD application 'wil-playground'..."
argocd app create wil-playground \
    --repo https://github.com/mdarbois/Iot_mdarbois_argoCD.git \
    --path ./wil/ \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace default
if [ $? -ne 0 ]; then
  echo "Failed to create Argo CD application. Exiting."
  exit 1
fi

# 9. Sync the application
echo "Syncing the Argo CD application..."
argocd app sync wil-playground
if [ $? -ne 0 ]; then
  echo "Failed to sync the Argo CD application. Exiting."
  exit 1
fi

echo "Argo CD application 'wil-playground' created and synced successfully!"

