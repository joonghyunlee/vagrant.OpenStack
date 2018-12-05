#!/bin/bash

# metadata_agent
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_uri http://controller:5000
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_url http://controller:35357
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_region RegionOne
crudini --set /etc/neutron/metadata_agent.ini DEFAULT auth_plugin password
crudini --set /etc/neutron/metadata_agent.ini DEFAULT project_domain_id default
crudini --set /etc/neutron/metadata_agent.ini DEFAULT user_domain_id default
crudini --set /etc/neutron/metadata_agent.int DEFAULT project_name service
crudini --set /etc/neutron/metadata_agent.ini DEFAULT username neutron
crudini --set /etc/neutron/metadata_agent.ini DEFAULT password $NEUTRON_USER_PASS
crudini --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip controller
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret 3VWXa7t-NtZFdfc0
crudini --set /etc/neutron/metadata_agent.ini DEFAULT metadata_port 80

systemctl enable neutron-metadata-agent.service
systemctl start neutron-metadata-agent.service
