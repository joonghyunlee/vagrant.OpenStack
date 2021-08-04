#!/bin/bash

yum install -y centos-release-openstack-stein epel-release

yum upgrade
yum install -y openstack-selinux

# ntp
yum -y install ntp

if [ $HOSTNAME == "misc" ]
then

cat >> /etc/ntp.conf << EOF
server misc iburst
restrict -4 default kod notrap nomodify
restrict -6 default kod notrap nomodify
EOF

else

cat >> /etc/ntp.conf << EOF
server misc iburst
EOF

fi

systemctl enable ntpd.service
systemctl start ntpd.service

# common
yum install -y crudini expect wget
