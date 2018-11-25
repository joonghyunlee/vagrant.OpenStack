#!/bin/bash

. common.sh

# The routeable IP of the node is on our eth1 interface
ETH1_IP=$(ifconfig eth1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
ETH2_IP=$(ifconfig eth2 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
ETH3_IP=$(ifconfig eth3 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

PUBLIC_IP=${ETH3_IP}
INT_IP=${ETH1_IP}
ADMIN_IP=${ETH3_IP}

MYSQL_ROOT_PASS=mysql123!@#

cat >> /etc/ntp.conf <EOF
server NTP_SERVER iburst
restrict -4 default kod notrap nomodify
restrict -6 default kod notrap nomodify
EOF

systemctl enable ntpd.service
systemctl start ntpd.service

# MySQL
yum install mariadb mariadb-server MySQL-python
crudini --set /etc/my.cnf.d/mariadb_openstack.cnf mysqld bind-address ETH2_IP

crudini --set /etc/my.cnf.d/mariadb_openstack.cnf mysqld default-storage-engine innodb
crudini --set /etc/my.cnf.d/mariadb_openstack.cnf mysqld innodb_file_per_table
crudini --set /etc/my.cnf.d/mariadb_openstack.cnf mysqld collation-server utf8_general_ci
crudini --set /etc/my.cnf.d/mariadb_openstack.cnf mysqld init-connect 'SET NAMES utf8'
crudini --set /etc/my.cnf.d/mariadb_openstack.cnf mysqld character-set-server utf8

systemctl enable mariadb.service
systemctl start mariadb.service

TEMP_ROOT_DBPASS="`grep 'temporary.*root@localhost' /var/log/mysqld.log | tail -n 1 | sed 's/.*root@localhost: //'`"
systemctl stop mysqld.service
rm -rf /var/lib/mysql/*

systemctl start mysqld.service
