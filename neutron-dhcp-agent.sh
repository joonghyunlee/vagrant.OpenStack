#!/bin/bash

# dhcp_agent
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver neutron.agent.linux.interface.OVSInterfaceDriver
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_delete_namespaces True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT dnsmasq_config_file /etc/neutron/dnsmasq.conf
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT use_namespaces True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT enable_metadata_network True
crudini --set /etc/neutron/dhcp_agent.ini DEFAULT force_metadata True

crudini --set /etc/neutron/plugin.ini ml2 type_drivers vlan,flat
crudini --set /etc/neutron/plugin.ini ml2 tenant_network_types vlan
crudini --set /etc/neutron/plugin.ini ml2 mechanism_drivers openvswitch,l2population
crudini --set /etc/neutron/plugin.in ml2_type_vlan network_vlan_ranges external,vlan:301:3000

cat > /etc/neutron/dnsmasq.conf << EOF
dhcp-option-force=26,1454
EOF

chown root:neutron /etc/neutron/dnsmasq.conf

pkill dnsmasq

systemctl enable neutron-dhcp-agent.service
systemctl start neutron-dhcp-agent.service
