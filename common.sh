#!/bin/bash
export CONTROLLER_HOST=$(ifconfig | awk '/inet /{print substr($2, 1)}')
export GLANCE_HOST=${CONTROLLER_HOST}
export MYSQL_HOST=${CONTROLLER_HOST}
export KEYSTONE_ADMIN_ENDPOINT=$(ifconfig eth3 | awk '/inet /{print substr($2, 1)}')
export KEYSTONE_ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
export CONTROLLER_EXTERNAL_HOST=${KEYSTONE_ADMIN_ENDPOINT}
export MYSQL_NEUTRON_PASS=mysql123!@#
export SERVICE_TENANT_NAME=service
export SERVICE_PASS=New1234!
export ENDPOINT=${KEYSTONE_ADMIN_ENDPOINT}
export SERVICE_TOKEN=ADMIN
export SERVICE_ENDPOINT=https://${KEYSTONE_ADMIN_ENDPOINT}:35357/v2.0
export MONGO_KEY=mongo123!@#

# ntp
yum -f install ntp

# Enable the OpenStack repository
yum install https://repos.fedorapeople.org/openstack/EOL/openstack-kilo/rdo-release-kilo-2.noarch.rpm
yum upgrade
yum install openstack-selinux
