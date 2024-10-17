# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"

  config.vm.define "lwidmerS" do |control|
    config.vm.hostname = "lwidmerS"
    config.vm.network "public_network", ip: "192.168.56.110"
  end

  config.vm.define "lwidmerSW" do |control|
    config.vm.hostname = "lwidmerSW"
    config.vm.network "public_network", ip: "192.168.56.111"
  end
end
