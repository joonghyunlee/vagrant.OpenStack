#!/bin/bash

yum install -y qemu lvm2

systemctl enable lvm2-lvmetad.service
systemctl start lvm2-lvmetad.service

DEVICES=(`lsblk -s -d -o name,type | grep disk | awk '{print $1}'`)
for DEVICE_NAME in ${DEVICES[@]}
do
    echo -e "n\np\n1\n\n\nw" | fdisk /dev/$DEVICE_NAME
done

pvcreate /dev/sdb1
vgcreate cinder-volumes /dev/sdb1

sed -i '0,/# filter = \[.*$/s/# filter = \[.*$/filter = \["a\/sdb\/", "r\/.*\/"\]/' /etc/lvm/lvm.conf

yum install -y openstack-cinder targetcli python-oslo-db python-oslo-log MySQL-python python-crypto

crudini --set /etc/cinder/cinder.conf database connection "mysql://cinder:$CINDER_DB_PASS@controller/cinder"
crudini --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host controller
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password $RABBITMQ_PASS
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password $CINDER_USER_PASS
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip $MANAGEMENT_IP
crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm iscsi_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm iscsi_helper lioadm
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
crudini --set /etc/cinder/cinder.conf DEFAULT glance_host controller
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/lock

systemctl enable openstack-cinder-volume.service target.service
systemctl start openstack-cinder-volume.service target.service
