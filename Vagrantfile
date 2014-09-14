is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

Vagrant.configure("2") do |config|
  config.vm.box = "covex/ubuntu1204-x64"

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
    v.customize ["modifyvm", :id, "--nictype2", "virtio"]
    v.customize ["modifyvm", :id, "--nictype3", "virtio"]
    v.customize ["modifyvm", :id, "--memory", 2048]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.network :private_network, ip: "10.10.10.20"

  if not is_windows
    config.vm.synced_folder "..", "/vagrant", nfs: true
  end

  config.vm.synced_folder "vagrant/config/", "/srv/config"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.vm.hostname = 'dock.projectbench'
  config.hostmanager.aliases = %w(dock.contentbench)

  config.vm.provision "shell", path: "vagrant/provision/bash.sh"
  config.vm.provision "shell", path: "vagrant/provision/apt-get.sh"
  config.vm.provision "shell", path: "vagrant/provision/mysql.sh"
  config.vm.provision "shell", path: "vagrant/provision/apache.sh"
end
