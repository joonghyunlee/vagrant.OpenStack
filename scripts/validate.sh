#!/bin/bash

source /root/keystonerc
wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

qemu-img convert -p -O raw /tmp/images/cirros-0.3.4-x86_64-disk.img /tmp/images/cirros-0.3.4-x86_64-disk-nokvm.raw
losetup /dev/loop0 /tmp/images/cirros-0.3.4-x86_64-disk-nokvm.raw
partprobe /dev/loop0
mkdir /tmp/images/mnt
mount /dev/loop0p1 /tmp/images/mnt/
sed -i 's/ro console/no_timer_check console/' /tmp/images/mnt/boot/grub/menu.lst
umount /tmp/images/mnt
losetup -d /dev/loop0
qemu-img convert -p -O qcow2 /tmp/images/cirros-0.3.4-x86_64-disk-nokvm.raw /tmp/images/cirros-0.3.4-x86_64-disk-nokvm.img

glance image-create --name "cirros-0.3.4-x86_64" --file /tmp/images/cirros-0.3.4-x86_64-disk-nokvm.img \
    --disk-format qcow2 --container-format bare --visibility public --progress

neutron net-create private-network
neutron subnet-create private-network 192.168.0.0/24 \
    --name private-subnet \
    --dns-nameserver 8.8.8.8 --gateway 192.168.0.1
neutron router-create private-router
neutron router-interface-add private-router private-subnet
neutron router-gateway-set private-router public-network

neutron security-group-rule-create --direction ingress --ethertype IPv4 --port-range-min 22 --port-range-max 22 --protocol tcp default

PUBLIC_NET_ID=`neutron net-list | grep public-network | awk '{print $2}'`
PRIVATE_NET_ID=`neutron net-list | grep private-network | awk '{print $2}'`

nova keypair-add demo-key > /vagrant/demo-key.pem
chmod 0400 /vagrant/demo-key.pem
nova boot --flavor m1.tiny --image cirros-0.3.4-x86_64 --nic net-id=$PRIVATE_NET_ID --security-group default \
    --key-name demo-key demo-instance
NOVA_INSTANCE_ID=`nova list | grep demo-instance | awk '{print $2}'`
FLOATING_IP_ADDRESS=`neutron floatingip-create $PUBLIC_NET_ID | grep floating_ip_address | awk '{print $4}'`
nova floating-ip-associate $NOVA_INSTANCE_ID $FLOATING_IP_ADDRESS

cinder create --display-name volume 1
CINDER_VOLUME_ID=`cinder list | grep volume | awk '{print $2}'`
nova volume-attach $NOVA_INSTANCE_ID $CINDER_VOLUME_ID auto
