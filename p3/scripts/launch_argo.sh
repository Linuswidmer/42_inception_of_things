# Create k3d cluster
sudo k3d cluster create mycluster

# Create the 2 namespaces
sudo kubectl create namespace argocd
sudo kubectl create namespace dev

# Install Argo CD in the argocd namespace
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

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

sleep 5
# Port forward the Argo CD server
# echo "Port forwarding Argo CD server to localhost:8080..."
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443 &
# sudo kubectl -n argocd port-forward svc/argocd-server 8080:80 &