#!/bin/bash

source /root/keystonerc

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

nova keypair-add demo-key > demo-key.pem
nova boot --flavor m1.tiny --image cirros-0.3.4-x86_64 --nic net-id=$PRIVATE_NET_ID --security-group default \
    --key-name demo-key demo-instance
NOVA_INSTANCE_ID=`nova list | grep demo-instance | awk '{print $2}'`
neutron floatingip-create $PUBLIC_NET_ID
FLOATING_IP_ADDRESS=`neutron floatingip-list | grep 192.168 | awk '{print $6}'`
nova floating-ip-associate $NOVA_INSTANCE_ID $FLOATING_IP_ADDRESS

cinder create --display-name volume 1
CINDER_VOLUME_ID=`cinder list | grep volume | awk '{print $2}'`
nova volume-attach $NOVA_INSTANCE_ID $CINDER_VOLUME_ID auto
