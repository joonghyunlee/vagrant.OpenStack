# How to create a base box
## 1. Download a Base Image
```
$ wget http://vault.centos.org/7.1.1503/isos/x86_64/CentOS-7-x86_64-Minimal-1503-01.iso
```

## 2. Create a Virtual Machine
### 2-1. Prerequisite
* Register a repository for old-version packages
```
$ vi /etc/yum.repos.d/CentOS-Vault.repo
...
[C7.1.1503-base]
name=CentOS-7.1.1503 - Base
baseurl=http://vault.centos.org/7.1.1503/os/x86_64/
enabled=1
gpgcheck=0
```
* Install essential packages for Virtualbox Guest Addition
```
$ yum install perl gcc dkms kernel-devel kernel-headers make
$ yum install "kernel-devel-$(uname -r)"
```
* Unregister `firewalld` service
```
# chkconfig firewalld off
# service firewalld stop
```
* Create a `vagrant` user
```
# useradd vagrant
# passwd vagrant  // conventionally use `vagrant` as a password
```
* Set a `vagrant` user as no-password user
```
# visudo
...
vagrant ALL=(ALL) NOPASSWD: ALL
Defaults:vagrant !requiretty
```

### 2-2. Install Guest Addition
* Mount a Guest Addition CDROM
```
$ sudo mount /dev/cdrom /media
$ cd /media
$ ./VBoxLinuxAdditions.run
```

## 3. Create a Box
```
$ vagrant package --base "Base Box" --output box/base.box
```

## Reference
* https://www.vagrantup.com/docs/boxes/base.html
* https://wiki.centos.org/HowTos/Network/SecuringSSH
