#!/bin/bash

mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "CREATE DATABASE neutron;"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$NEUTRON_DB_PASS';"
mysql -u root -p"$MYSQL_ROOT_PASS" -sN -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$NEUTRON_DB_PASS';"

openstack user create --password $NEUTRON_USER_PASS neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron \
    --description "OpenStack Networking" network
openstack endpoint create \
    --publicurl "http://controller:9696" \
    --adminurl "http://controller:9696" \
    --internalurl "http://controller:9696" \
    --region RegionOne \
    network

yum install -y openstack-neutron openstack-neutron-ml2 python-neutronclient

crudini --set /etc/neutron/neutron.conf database connection "mysql://neutron:$NEUTRON_DB_PASS@controller/neutron"
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password $RABBITMQ_PASS
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_plugin password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_id default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_id default
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password $NEUTRON_USER_PASS
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
crudini --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
crudini --set /etc/neutron/neutron.conf DEFAULT nova_url http://controller:8774/v2
crudini --set /etc/neutron/neutron.conf nova auth_url http://controller:35357
crudini --set /etc/neutron/neutron.conf nova auth_plugin password
crudini --set /etc/neutron/neutron.conf nova project_domain_id default
crudini --set /etc/neutron/neutron.conf nova user_domain_id default
crudini --set /etc/neutron/neutron.conf nova region_name RegionOne
crudini --set /etc/neutron/neutron.conf nova project_name service
crudini --set /etc/neutron/neutron.conf nova username nova
crudini --set /etc/neutron/neutron.conf nova password $NOVA_USER_PASS
crudini --set /etc/neutron/neutron.conf DEFAULT verbose True

crudini --set /etc/neutron/plugin.ini ml2 type_drivers vlan,flat
crudini --set /etc/neutron/plugin.ini ml2 tenant_network_types vlan
crudini --set /etc/neutron/plugin.ini ml2 mechanism_drivers openvswitch,l2population
crudini --set /etc/neutron/plugin.ini ml2_type_vlan network_vlan_ranges external,vlan:301:3000
crudini --set /etc/neutron/plugin.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugin.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugin.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head" neutron

systemctl enable neutron-server.service
systemctl start neutron-server.service
