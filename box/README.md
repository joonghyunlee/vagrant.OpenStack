# How to create a base box
## 1. Download a Base Image
```bash
$ wget http://archive.kernel.org/centos-vault/7.1.1503/isos/x86_64/CentOS-7-x86_64-Minimal-1503-01.iso
```

## 2. Create a Virtual Machine
### 2-1. Prerequisite
* Register and create a Virtual Machine
```bash
vboxmanage createvm --name box --ostype RedHat_64 --register
vboxmanage showvminfo box
vboxmanage modifyvm box --memory 1024
vboxmanage createhd --filename $HOME/VirtualBox\ VMs/box/box.vmdk --size 20480 --format vmdk
vboxmanage storagectl box --name "SATA Controller" --add sata --controller IntelAhci
vboxmanage storageattach box --storagectl "SATA Controller" --port 0 --device 0 --type hdd \
               --medium $HOME/VirtualBox\ VMs/box/box.vmdk
vboxmanage storagectl box --name "IDE Controller" --add ide --controller PIIX4
vboxmanage storageattach box --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive \
               --medium $PWD/CentOS-7-x86_64-Minimal-1503-01.iso

vboxmanage startvm box
```
* Boot and Start an installation

### 2-2. Prepare a base image
* Register a repository for old-version packages
```bash
# vi /etc/yum.repos.d/CentOS-Vault.repo
...
[C7.1.1503-base]
name=CentOS-7.1.1503 - Base
baseurl=http://vault.centos.org/7.1.1503/os/x86_64/
enabled=1
gpgcheck=0
```
* Install essential packages for Virtualbox Guest Addition
```bash
# yum install bzip2 perl gcc dkms kernel-devel kernel-headers make
# yum install "kernel-devel-$(uname -r)"
```
* Unregister `firewalld` service
```bash
# chkconfig firewalld off
# service firewalld stop
```
* Create a `vagrant` user
```bash
# useradd vagrant
# passwd vagrant  // conventionally use `vagrant` as a password
```
* Set a `vagrant` user as no-password user
```bash
# visudo
...
vagrant ALL=(ALL) NOPASSWD: ALL
Defaults:vagrant !requiretty
```
* Download and Inject a Guest Addition CDROM

* Mount a Guest Addition CDROM
```bash
# mount /dev/cdrom /media
# cd /media
# ./VBoxLinuxAdditions.run
```
* Shutdown
```bash
# shutdown -h now
```

## 3. Create a Box
```bash
$ vagrant package --base "box" --output box/base.box
```

## Reference
* https://www.vagrantup.com/docs/boxes/base.html
* https://wiki.centos.org/HowTos/Network/SecuringSSH
