# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
    'controller'  => [1, 200],
    'network'  => [1, 210],
    'compute' => [1, 220],
}

Vagrant.configure("2") do |config|
  config.vm.box = "box/base.box"
  config.ssh.password = "vagrant"
  config.ssh.insert_key = false
  #config.ssh.private_key_path = "pem/id_rsa"
  
  config.vm.provider :virtualbox do |vbox|
    if !File.exist?("lvm.vmdk")
      vbox.customize ["createmedium", "disk", "--filename", "lvm.vmdk", "--format", "vmdk", "--size", 1024 * 50]
    end
  end

  nodes.each do |prefix, (count, ip_start)|
    count.times do |i|
      if prefix == "compute"
        hostname = "%s-%02d" % [prefix, (i+1)]
      else
        hostname = "%s" % prefix
      end

      config.vm.define "#{hostname}" do |box|
        box.vm.hostname = "#{hostname}"
        box.vm.network :private_network,
          ip: "192.168.56.#{ip_start+i}",
          :netmask => "255.255.255.0",
          nic_type: "virtio"
        box.vm.network :private_network,
          virtualbox__intnet: true,
          ip: "10.0.0.#{ip_start+i}",
          :netmask => "255.255.255.0",
          nic_type: "virtio"
        if prefix == "compute" or prefix == "network"
          box.vm.network :private_network,
            ip: "10.161.243.#{ip_start+i}",
            :netmask => "255.255.255.0",
            nic_type: "virtio"
        end

        box.vm.provider :virtualbox do |vbox|
          vbox.customize ["modifyvm", :id, "--cpus", 1]
          vbox.customize ["modifyvm", :id, "--memory", 1024]
          vbox.customize ["modifyvm", :id, "--nictype1", "virtio", "--nictype2", "virtio"]

          if prefix == "compute" or prefix == "controller"
            vbox.customize ["modifyvm", :id, "--cpus", 2]
            vbox.customize ["modifyvm", :id, "--memory", 2048]
          end

          vbox.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]

          if prefix == "compute" or prefix == "network"
            vbox.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
          end

          if prefix == "compute"
              vbox.customize ["storageattach", :id, "--storagectl", "SATA Controller",
                              "--port", 1, "--device", 0, "--type", "hdd", "--medium", "lvm.vmdk"]
          end
        end
        
        box.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
        box.vm.provision :shell, privileged: true, inline: "/sbin/ifdown eth1 && /sbin/ifup eth1"
        box.vm.provision :shell, privileged: true, inline: "/sbin/ifdown eth2 && /sbin/ifup eth2"

        if prefix == "compute" or prefix == "network"
          box.vm.provision :shell, privileged: true, inline: "/sbin/ifdown eth3 && /sbin/ifup eth3"
        end

        box.vm.provision :shell, privileged: true, :path => "#{prefix}.sh"
      end
    end
  end
end
