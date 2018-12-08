#!/bin/bash

echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.rp_filter = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter = 0' >> /etc/sysctl.conf
sysctl -p

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

source /root/keystonerc
PUBLIC_NET_ID=`neutron net-list | grep public-network | awk '{print $2}'`

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

crudini --set /etc/neutron/l3_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/l3_agent.ini DEFAULT router_delete_namespaces True
crudini --set /etc/neutron/l3_agent.ini DEFAULT use_namespaces True
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge
crudini --set /etc/neutron/l3_agent.ini DEFAULT gateway_external_network_id $PUBLIC_NET_ID
crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True
crudini --set /etc/neutron/l3_agent.ini DEFAULT debug True
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode dvr_snat

crudini --set /etc/neutron/plugin.ini ml2 type_drivers vlan,flat
crudini --set /etc/neutron/plugin.ini ml2 tenant_network_types vlan
crudini --set /etc/neutron/plugin.ini ml2 mechanism_drivers openvswitch,l2population
crudini --set /etc/neutron/plugin.ini ml2_type_vlan network_vlan_ranges external,vlan:301:3000

systemctl enable neutron-l3-agent.service
systemctl start neutron-l3-agent.service
