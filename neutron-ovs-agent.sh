#!/bin/bash

systemctl enable openvswitch.service
systemctl start openvswitch.service

crudini --set /etc/neutron/plugin.ini agent l3_population False
crudini --set /etc/neutron/plugin.ini agent l2_population True
crudini --set /etc/neutron/plugin.ini agent enable_distributed_routing True
crudini --set /etc/neutron/plugin.ini agent arp_responder True
crudini --set /etc/neutron/plugin.ini ovs tunnel_bridge br-tun
crudini --set /etc/neutron/plugin.ini ovs integration_bridge br-int
crudini --set /etc/neutron/plugin.ini ovs bridge_mappings vlan:br-vlan,external:br-external
crudini --set /etc/neutron/plugin.ini ovs enable_tunnelinig True
crudini --set /etc/neutron/plugin.ini securitygroup enable_security_group True
crudini --set /etc/neutron/plugin.ini securitygroup enable_ipset True
crudini --set /etc/neutron/plugin.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

ovs-vsctl add-br br-vlan
ovs-vsctl add-port br-vlan eth2

ovs-vsctl add-br br-external
ovs-vsctl add-port br-external eth3

systemctl enable neutron-openvswitch-agent.service
systemctl start neutron-openvswitch-agent.service
