all:
	sudo bash scripts/setup.sh
	$(MAKE) launch

launch:
	sudo bash scripts/launch_argo.sh
	sudo bash scripts/launch_dev.sh

clean:
	sudo k3d cluster delete --all
	sudo docker system prune -a -f
	sudo docker volume prune -f
	sudo rm -rf ~/.kube
	sudo rm -rf ~/.argocd
	sudo rm -f /usr/local/bin/k3d
	sudo rm -f /usr/local/bin/docker-compose
	sudo rm -rf ~/.docker-compose
	sudo rm -f /usr/local/bin/argocd
	sudo apt-get remove --purge kubectl
	sudo apt-get remove --purge k3d




re: clean launch