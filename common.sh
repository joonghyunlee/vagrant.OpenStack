#!/bin/bash
# export GLANCE_HOST=${CONTROLLER_HOST}
# export MYSQL_HOST=${CONTROLLER_HOST}
# export KEYSTONE_ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
# export CONTROLLER_EXTERNAL_HOST=${KEYSTONE_ADMIN_ENDPOINT}
# export MYSQL_NEUTRON_PASS=mysql123!@#
# export SERVICE_TENANT_NAME=service
# export SERVICE_PASS=New1234!
# export ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
# export SERVICE_TOKEN=ADMIN
# export SERVICE_ENDPOINT=https://${KEYSTONE_ADMIN_ENDPOINT}:35357/v2.0
# export MONGO_KEY=mongo123!@#
export MYSQL_ROOT_PASS=mysql123!@#

# The routeable IP of the node is on our eth1 interface
IPS=($(hostname -I))

export MANAGEMENT_IP=${IPS[1]}
export SERVICE_IP=${IPS[2]}

# PUBLIC_IP=${ETH3_IP}
# INT_IP=${ETH1_IP}
# ADMIN_IP=${ETH3_IP}

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

cat >> /etc/ntp.conf <EOF
server NTP_SERVER iburst
restrict -4 default kod notrap nomodify
restrict -6 default kod notrap nomodify
EOF

systemctl enable ntpd.service
systemctl start ntpd.service

# common
yum install -y crudini expect
