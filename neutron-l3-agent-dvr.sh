#!/bin/bash

echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.rp_filter = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter = 0' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.conf
sysctl -p

# neutron
crudini --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
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
crudini --set /etc/neutron/l3_agent.ini DEFAULT external_network_bridge
crudini --set /etc/neutron/l3_agent.ini DEFAULT gateway_external_network_id
crudini --set /etc/neutron/l3_agent.ini DEFAULT verbose True
crudini --set /etc/neutron/l3_agent.ini DEFAULT debug True
crudini --set /etc/neutron/l3_agent.ini DEFAULT enable_metadata_proxy False
crudini --set /etc/neutron/l3_agent.ini DEFAULT agent_mode dvr

systemctl enable neutron-l3-agent.service
systemctl start neutron-l3-agent.service
