# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "solr1" do |solr|
    solr.vm.box = "precise64"
    solr.vm.hostname = "solr1"
    solr.vm.network "forwarded_port", guest: 8983, host: 8900
    solr.vm.network "private_network", type: "dhcp"
    solr.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

  config.vm.define "solr2" do |solr|
    solr.vm.box = "precise64"
    solr.vm.hostname = "solr2"
    solr.vm.network "forwarded_port", guest: 8983, host: 8901
    solr.vm.network "private_network", type: "dhcp"
    solr.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end
end
