#!/bin/bash
export KEYSTONE_DB_PASS=TCjw-AuJ
export GLANCE_DB_PASS=h4cD2D3B
export GLANCE_USER_PASS=glance123!@#
export NOVA_DB_PASS=pN5g-BRJ
export NOVA_USER_PASS=nova123!@#
export NEUTRON_DB_PASS=89LK1jZw
export NEUTRON_USER_PASS=neutron123!@#
export CINDER_DB_PASS=1ySl8v_r
export CINDER_USER_PASS=cinder123!@#
export RABBITMQ_PASS=rabbitmq123!@#
export MYSQL_ROOT_PASS=92n2ms7W

export ADMIN_TOKEN=29be7b8717ea6d513e92
export ADMIN_USER_PASS=New1234!

export CONTROLLER=192.168.56.200

# The routeable IP of the node is on our eth1 interface
IPS=($(hostname -I))

export MANAGEMENT_IP=${IPS[1]}
export SERVICE_IP=${IPS[2]}

if [ $HOSTNAME != "controller" ]
then
    echo $CONTROLLER controller >> /etc/hosts
fi

echo $MANAGEMENT_IP $HOSTNAME >> /etc/hosts

# Enable the OpenStack repository
yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm

cat > /etc/yum.repos.d/openstack-kilo.repo << EOF
[Openstack-Kilo]
name=OpenStack Kilo
baseurl=http://vault.centos.org/7.3.1611/cloud/x86_64/openstack-kilo/
enabled=1
gpgcheck=0
EOF

yum upgrade
yum install -y openstack-selinux

# ntp
yum -y install ntp

if [ $HOSTNAME == "controller" ]
then

cat >> /etc/ntp.conf << EOF
server $CONTROLLER iburst
restrict -4 default kod notrap nomodify
restrict -6 default kod notrap nomodify
EOF

else

cat >> /etc/ntp.conf << EOF
server $CONTROLLER iburst
EOF

fi

systemctl enable ntpd.service
systemctl start ntpd.service

# common
yum install -y crudini expect wget
