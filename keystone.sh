#!/bin/bash

mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "CREATE DATABASE keystone;"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DB_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DB_PASS';"

yum install -y openstack-keystone httpd mod_wsgi python-openstackclient

crudini --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
crudini --set /etc/keystone/keystone.conf database connection "mysql://keystone:$KEYSTONE_DB_PASS@controller/keystone"
crudini --set /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
crudini --set /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.sql.Token
crudini --set /etc/keystone/keystone.conf revoke driver keystone.contrib.revoke.backends.sql.Revoke
crudini --set /etc/keystone/keystone.conf DEFAULT verbose True

su -s /bin/sh -c "keystone-manage db_sync" keystone

systemctl enable openstack-keystone.service
systemctl start openstack-keystone.service

cat > /root/keystonerc << EOF
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_USER_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v2.0

openstack service create \
    --name keystone --description "OpenStack Identity" identity
openstack endpoint create \
    --publicurl http://controller:5000/v2.0 \
    --internalurl http://controller:5000/v2.0 \
    --adminurl http://controller:35357/v2.0 \
    --region RegionOne \
    identity
openstack project create --description "Admin Project" admin
openstack user create --password $ADMIN_USER_PASS admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --description "Service Project" service
openstack role create user
