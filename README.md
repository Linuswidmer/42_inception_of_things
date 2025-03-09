# Inception-of-Things: Kubernetes with K3d, K3s, and Vagrant

## Project Overview
The project is divided into three parts:

1. Part 1: K3s and Vagrant
    - Set up two virtual machines using Vagrant with K3s in server and agent modes.
    - Machines communicate over a private network and use SSH for passwordless access.
2. Part 2: K3s and Three Simple Applications
    - Deploy three simple web applications on a K3s cluster.
    - Use Ingress to route traffic based on hostnames (app1.com, app2.com, app3.com).
3. Part 3: K3d and Argo CD
    - Install K3d for local Kubernetes clusters.
    - Set up Argo CD for GitOps-based continuous deployment with two versions of an application.
    
## Technologies Used
- Vagrant for virtual machine setup
- K3s for lightweight Kubernetes
- K3d for Docker-based Kubernetes clusters
- Argo CD for continuous delivery using GitOps

## Setting up the VM to launch the project
This project is supposed to be run inside a Debian/Ubuntu VM. To properly set it up, run the initialization script.
```bash
chmod +x ./config/init.sh
sudo ./config/init.sh
```
To check that the installation is complete
```bash
vagrant --version
VBoxManage --version
```
