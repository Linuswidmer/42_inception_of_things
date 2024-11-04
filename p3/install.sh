#!/bin/bash

# Generating TLS Certificates
mkdir -p certs 
openssl req -x509 \
    -newkey rsa:4096 \
    -keyout certs/key.pem \
    -out certs/cert.pem \
    -sha256 \
    -days 3650 \
    -nodes \
    -subj "/C=DE/ST=Berlin/L=Berlin/O=42Berlin/OU=Student/CN=localhost"

# Creating cluster and namespaces
k3d cluster create mycluster
kubectl create namespace argocd
kubectl create namespace dev

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
