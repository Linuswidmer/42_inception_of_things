Vagrant.configure("2") do |config|
	config.vm.box = "hashicorp/bionic64"
  
	# Define the first VM (lwidmerS)
	config.vm.define "lwidmerS" do |server|
	  server.vm.hostname = "lwidmerS"
	  server.vm.network "private_network", ip: "192.168.56.110"  # Changed to private network
	  server.vm.synced_folder "./lwidmerS_config/", "/etc/rancher/k3s/"
	  server.vm.synced_folder "./token", "/etc/rancher/k3s/token/"
  
	  # Resource allocation for lwidmerS
	  server.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"   # Set memory to 1024 MB
		vb.cpus = 1          # Set to 1 CPU
	  end
  
	  # Installing K3s
	  server.vm.provision "shell", inline: <<-SHELL
		curl -sfL https://get.k3s.io | sh -
		# Save the K3S token to a shared folder before trying to install the worker
		sudo cat /var/lib/rancher/k3s/server/node-token > /etc/rancher/k3s/token/token.txt
	  SHELL
	end
  
	# Define the second VM (lwidmerSW)
	config.vm.define "lwidmerSW" do |worker|
	  worker.vm.hostname = "lwidmerSW"
	  worker.vm.network "private_network", ip: "192.168.56.111"  # Changed to private network
	  worker.vm.synced_folder "./lwidmerSW_config/", "/etc/rancher/k3s/"
	  worker.vm.synced_folder "./token", "/etc/rancher/k3s/token/"
	  
	  # Resource allocation for lwidmerSW
	  worker.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"   # Set memory to 1024 MB
		vb.cpus = 1          # Set to 1 CPU
	  end
  
	  # Installing worker node
	  worker.vm.provision "shell", inline: <<-SHELL
		while [ ! -f /vagrant/k3s_token ]; do
		  echo "Waiting for K3S token..."
		  sleep 5
		done
		curl -sfL https://get.k3s.io | sh -
	  SHELL
	end
end
  