#!/bin/bash

source /home/vagrant/scripts/variables

yum install -y openstack-magnum-conductor python-pip

pip install --extra-index-url http://pypi.cloud.toastoven.net:8080 --trusted-host pypi.cloud.toastoven.net magnum==9.200.4

IPS=($(hostname -I))
export MY_IP=${IPS[1]}
export API_IP=${IPS[1]}

envsubst < /home/vagrant/config/magnum.conf.template > /tmp/magnum.conf
cp -f /tmp/magnum.conf /etc/magnum/magnum.conf

systemctl enable openstack-magnum-conductor.service
systemctl start openstack-magnum-conductor.service
