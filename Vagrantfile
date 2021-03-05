
Vagrant.configure("2") do |config|
  
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname="host"
  config.vm.network "public_network" ,bridge: "wlp2s0" ,ip: "192.168.1.50"
  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end

  config.vm.provision "shell",
  run: "always",
  inline: "route add default gw 192.168.1.1 eth1"


  config.vm.provision "shell", path: "asterisk.sh"

end
