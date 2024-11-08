PASSWORD=$(sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 --decode)
echo "The Argo CD initial admin password is: $PASSWORD"


argocd --port-forward --port-forward-namespace=argocd login --username=admin --password=$PASSWORD

echo "Applying the application.yaml file..."
sudo kubectl apply -f application.yaml


# sudo kubectl port-forward svc/wil-playground 8888:8888 -n dev

# Change the image to v2
# sudo kubectl set image deployment/wil-playground wil-playground=wil42/playground:v2 -n dev


# sudo argocd app sync wil-playground