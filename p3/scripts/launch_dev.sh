ARGOCD_PASSWORD=$(sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
echo "The Argo CD initial admin password is: $ARGOCD_PASSWORD"

PASS="admin"

argocd --port-forward --port-forward-namespace=argocd login --username=admin --password=$ARGOCD_PASSWORD
# argocd --port-forward --port-forward-namespace=argocd account update-password --current-password $ARGOCD_PASSWORD --new-password $PASS

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

sudo kubectl port-forward svc/wil-playground 8888:8888 -n dev &
