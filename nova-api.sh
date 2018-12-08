#!/bin/bash

mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "CREATE DATABASE nova;"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DB_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DB_PASS';"

openstack user create --password $NOVA_USER_PASS nova
openstack role add --project service --user nova admin
openstack service create --name nova \
    --description "OpenStack Compute" compute
openstack endpoint create \
    --publicurl "http://controller:8774/v2/%(tenant_id)s" \
    --internalurl "http://controller:8774/v2/%(tenant_id)s" \
    --adminurl "http://controller:8774/v2/%(tenant_id)s" \
    --region RegionOne \
    compute

# openstack endpoint create --region RegionOne --enable compute public "http://controller:8774/v2/%(tenant_id)s"
# openstack endpoint create --region RegionOne --enable compute internal "http://controller:8774/v2/%(tenant_id)s"
# openstack endpoint create --region RegionOne --enable compute admin "http://controller:8774/v2/%(tenant_id)s"

yum install -y openstack-nova-api openstack-nova-cert openstack-nova-conductor \
    openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient

crudini --set /etc/nova/nova.conf database connection "mysql://nova:$NOVA_DB_PASS@controller/nova"
crudini --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $RABBITMQ_PASS
crudini --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password $NOVA_USER_PASS
crudini --set /etc/nova/nova.conf DEFAULT my_ip $MANAGEMENT_IP
crudini --set /etc/nova/nova.conf DEFAULT vncserver_listen $MANAGEMENT_IP
crudini --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $MANAGEMENT_IP
crudini --set /etc/nova/nova.conf glance host controller
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf DEFAULT verbose True
# Neutron
crudini --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
crudini --set /etc/nova/nova.conf DEFAULT security_group_api neutron
crudini --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.LinuxOVSInterfaceDriver
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf neutron url http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_strategy keystone
crudini --set /etc/nova/nova.conf neutron admin_auth_url http://controller:35357/v2.0
crudini --set /etc/nova/nova.conf neutron admin_tenant_name service
crudini --set /etc/nova/nova.conf neutron admin_username neutron
crudini --set /etc/nova/nova.conf neutron admin_password $NEUTRON_USER_PASS
# metadata
crudini --set /etc/nova/nova.conf neutron service_metadata_proxy True
crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret 3VWXa7t-NtZFdfc0

su -s /bin/sh -c "nova-manage db sync" nova

systemctl enable openstack-nova-api.service openstack-nova-cert.service \
    openstack-nova-consoleauth.service openstack-nova-scheduler.service \
    openstack-nova-conductor.service openstack-nova-novncproxy.service
systemctl start openstack-nova-api.service openstack-nova-cert.service \
    openstack-nova-consoleauth.service openstack-nova-scheduler.service \
    openstack-nova-conductor.service openstack-nova-novncproxy.service
