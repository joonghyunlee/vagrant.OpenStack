#!/bin/bash

source /home/vagrant/scripts/variables

yum install -y rabbitmq-server

systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

rabbitmqctl add_user openstack $RABBITMQ_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
