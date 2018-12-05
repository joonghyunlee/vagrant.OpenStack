#!/bin/bash

mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "CREATE DATABASE cinder;"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DB_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DB_PASS';"

openstack user create --password $CINDER_USER_PASS cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder \
    --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 \
    --description "OpenStack Block Storage" volumev2
openstack endpoint create \
    --publicurl "http://controller:8776/v2/%(tenant_id)s" \
    --internalurl "http://controller:8776/v2/%(tenant_id)s" \
    --adminurl "http://controller:8776/v2/%(tenant_id)s" \
    --region RegionOne \
    volume
openstack endpoint create \
    --publicurl "http://controller:8776/v2/%(tenant_id)s" \
    --internalurl "http://controller:8776/v2/%(tenant_id)s" \
    --adminurl "http://controller:8776/v2/%(tenant_id)s" \
    --region RegionOne \
    volumev2


yum install -y openstack-cinder python-cinderclient python-oslo-db

yum install openstack-cinder python-cinderclient python-oslo-db
chown -R cinder:cinder /etc/cinder/cinder.conf

crudini --set /etc/cinder/cinder.conf database connection "mysql://cinder:$CINDER_DB_PASS@controller/cinder"
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $RABBITMQ_PASS
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password $CINDER_USER_PASS
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip $MANAGEMENT_IP
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lock/cinder

su -s /bin/sh -c "cinder-manage db sync" cinder

systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service
