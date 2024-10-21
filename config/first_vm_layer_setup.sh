#!/bin/bash

# This script installs Vagrant and VirtualBox in an Ubuntu/Debian based UNIX env
# Launch with sudo rights

DISTRO="jammy"

# Installing Vagrant 
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update && apt-get upgrade && apt-get install -y vagrant

# Installing VirtualBox
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $DISTRO contrib" | tee /etc/apt/sources.list.d/virtualbox.list
apt-get update && apt-get upgrade && apt-get install -y virtualbox

# Installing package to enable vagrant sybnc file 
apt-get update && apt-get upgrade && apt-get install -y vagrant-vbguest
