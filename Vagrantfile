Vagrant.configure("2") do |config|
	config.vm.box = "hashicorp/bionic64"
  
	# Define the first VM (lwidmerS)
	config.vm.define "lwidmerS" do |control|
	  control.vm.hostname = "lwidmerS"  # Correctly scoped to "lwidmerS"
	  control.vm.network "public_network", ip: "192.168.56.110"

	  # Resource allocation for lwidmerS
	  control.vm.provider "virtualbox" do |vb|
		vb.memory = "512"   # Set memory to 512 MB (change to 1024 if needed)
		vb.cpus = 1         # Set to 1 CPU
	  end
	end
  
	# Define the second VM (lwidmerSW)
	config.vm.define "lwidmerSW" do |control|
	  control.vm.hostname = "lwidmerSW"  # Correctly scoped to "lwidmerSW"
	  control.vm.network "public_network", ip: "192.168.56.111"

	  # Resource allocation for lwidmerSW
	  control.vm.provider "virtualbox" do |vb|
		vb.memory = "512"   # Set memory to 512 MB (change to 1024 if needed)
		vb.cpus = 1         # Set to 1 CPU
	  end
	end
end
  