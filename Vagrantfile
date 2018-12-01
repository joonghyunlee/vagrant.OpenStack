# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
    'controller'  => [1, 200],
#    'network'  => [1, 210],
#    'compute' => [1, 220],
}

Vagrant.configure("2") do |config|
  config.vm.box = "box/base.box"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = false
  #config.ssh.private_key_path = "pem/id_rsa"

  nodes.each do |prefix, (count, ip_start)|
    count.times do |i|
      if prefix == "compute"
        hostname = "%s-%02d" % [prefix, (i+1)]
      else
        hostname = "%s" % [prefix, (i+1)]
      end

      config.vm.define "#{hostname}" do |box|
        box.vm.hostname = "#{hostname}"
        box.vm.network :private_network,
          ip: "192.168.56.#{ip_start+i}",
          :netmask => "255.255.255.0",
          nic_type: "virtio"
        box.vm.network :private_network,
          virtualbox__intnet: true,
          ip: "10.161.243.#{ip_start+i}",
          :netmask => "255.255.255.0",
          nic_type: "virtio"

        box.vm.provider :virtualbox do |vbox|
          vbox.customize ["modifyvm", :id, "--cpus", 1]
          vbox.customize ["modifyvm", :id, "--memory", 1024]

          vbox.customize ["modifyvm", :id, "--nictype1", "virtio", "--nictype2", "virtio"]

          if hostname == "compute" or hostname == "controller"
            vbox.customize ["modifyvm", :id, "--cpus", 2]
            vbox.customize ["modifyvm", :id, "--memory", 2048]
          end

          vbox.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
        end

        config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
        config.vm.provision :shell, privileged: true, path: 'controller.sh'
      end
    end
  end
end
