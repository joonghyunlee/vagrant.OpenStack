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

cat > /etc/neutron/dnsmasq.conf << EOF
dhcp-option-force=26,1454
EOF

chown root:neutron /etc/neutron/dnsmasq.conf
pkill dnsmasq

yum install -y patch
patch -p0 -d /usr/lib/python2.7/site-packages/ < /vagrant/patches/dhcp.patch

systemctl enable neutron-dhcp-agent.service
systemctl start neutron-dhcp-agent.service
