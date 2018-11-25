#!/bin/bash

# # install virtualbox and vagrant
# sudo apt -y install virtualbox
# sudo apt -y install vagrant
# 
# set host only network for virtual machines
# vboxmanage hostonlyif remove vboxnet0
# vboxmanage hostonlyif create
# vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1

# sudo iptables -A FORWARD -o eth0 -i vboxnet0 -s 192.168.56.0/24 -m conntrack --ctstate NEW -j ACCEPT
# sudo iptables -A FORWARD -m conntrack --cstate ESTABLISHED,RELATED -j ACCEPT
# sudo iptables -A POSTROUTING -t nat -j MASQUERADE

sudo echo 1 > /proc/sys/net/ipv4/ip_forward

MNGT_NET_CIDR=192.168.56.0/24
echo $MNGT_NET_CIDR | awk -F'[./]' '{print $1; print $2; print $3; print $4; print $5;}'
