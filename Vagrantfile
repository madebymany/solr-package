# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "solr1" do |config|
    config.vm.box = "precise64"
    config.vm.hostname = "solr1"
    config.vm.network "forwarded_port", guest: 8983, host: 8900
    # solr.vm.network "private_network", type: "dhcp"
    config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

  config.vm.define "solr2" do |config|
    config.vm.box = "precise64"
    config.vm.hostname = "solr2"
    config.vm.network "forwarded_port", guest: 8983, host: 8901
    config.vm.network "private_network", type: "dhcp"
    config.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end
end
