all:
	sudo bash scripts/setup.sh
	$(MAKE) launch

launch:
	sudo bash scripts/launch_argo.sh
	sudo bash scripts/launch_dev.sh

clean:
	sudo k3d cluster delete --all
	docker system prune -a -f

re: clean launch