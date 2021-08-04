#!/bin/bash

source /home/vagrant/scripts/variables

mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "CREATE DATABASE magnum;"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON magnum.* TO 'magnum'@'localhost' IDENTIFIED BY '$MAGNUM_DB_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON magnum.* TO 'magnum'@'%' IDENTIFIED BY '$MAGNUM_DB_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON magnum.* TO 'magnum'@'magnum-api' IDENTIFIED BY '$MAGNUM_DB_PASS';"

yum install -y openstack-magnum-api python-magnumclient python-pip

pip install --extra-index-url http://pypi.cloud.toastoven.net:8080 --trusted-host pypi.cloud.toastoven.net magnum==9.200.4

IPS=($(hostname -I))
export MY_IP=${IPS[1]}
export API_IP=${IPS[1]}

envsubst < /home/vagrant/config/magnum.conf.template > /tmp/magnum.conf
cp -f /tmp/magnum.conf /etc/magnum/magnum.conf

su -s /bin/sh -c "magnum-db-manage upgrade" magnum

systemctl enable openstack-magnum-api.service
systemctl start openstack-magnum-api.service
