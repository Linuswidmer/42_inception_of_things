ARGOCD_PASSWORD=$(sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
echo "The Argo CD initial admin password is: $ARGOCD_PASSWORD"

PASS="admin"

#argocd --port-forward --port-forward-namespace=argocd login --username=admin --password=$ARGOCD_PASSWORD
# argocd --port-forward --port-forward-namespace=argocd account update-password --current-password $ARGOCD_PASSWORD --new-password $PASS
#sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
argocd login localhost:8080 --username admin --password "$ARGOCD_PASSWORD" --insecure
sudo argocd app sync wil-playground --server localhost:8080 --insecure

echo "Applying the application.yaml file..."
sudo kubectl apply -f application.yaml

echo "Pod is ready. Updating image..."echo "Waiting for pod to be in Running state..."
while [[ $(sudo kubectl get pods -n dev -l app=wil-playground -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  echo "Pod is not ready. Waiting..."
  sleep 5
done

echo "Pod is ready. Updating image..."

# Change the image to v2
sudo kubectl set image deployment/wil-playground wil-playground=wil42/playground:v2 -n dev

sudo argocd app sync wil-playground

#if sudo lsof -i :8888; then
#  echo "Port 8888 is in use. Killing the process..."
#  sudo fuser -k 8888/tcp
#fi

sudo fuser -k 8888/tcp
sudo kubectl port-forward svc/wil-playground 8888:8888 -n dev &
