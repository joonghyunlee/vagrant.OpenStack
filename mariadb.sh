#!/bin/bash
yum install -y mariadb mariadb-server MySQL-python

cat > /etc/my.cnf.d/mariadb_openstack.cnf << EOF
[mysqld]
bind-address=$MANAGEMENT_IP
default-storage-engine=innodb
innodb_file_per_table
collation-server=utf8_general_ci
init-connect='SET NAMES utf8'
character-set-server=utf8
EOF

systemctl enable mariadb.service
systemctl start mariadb.service

expect -c "
    set timeout 3
    spawn mysql_secure_installation
    expect \"Enter current password for root (enter for none):\"
    send \"\r\"
    expect \"root password?\"
    send \"y\r\"
    expect \"New password:\"
    send \"$MYSQL_ROOT_PASS\r\"
    expect \"Re-enter new password:\"
    send \"$MYSQL_ROOT_PASS\r\"
    expect \"Remove anonymous users?\"
    send \"y\r\"
    expect \"Disallow root login remotely?\"
    send \"y\r\"
    expect \"Remove test database and access to it?\"
    send \"y\r\"
    expect \"Reload privilege tables now?\"
    send \"y\r\"
    expect eof
"
