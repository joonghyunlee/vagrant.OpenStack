#!/bin/bash

DB_NAME=$1

HOST="controller"
PORT=3306

if [ -z $DB_NAME ]
then
    read -p "select db name to connect(nova/neutron/keystone/glance/cinder)" > DB_NAME
fi

if [ "$DB_NAME" = "nova" ]
then
    USER="nova"
    PASSWORD="pN5g-BRJ"
elif [ "$DB_NAME" = "neutron" ]
then
    USER="neutron"
    PASSWORD="89LK1jZw"
elif [ "$DB_NAME" = "keystone" ]
then
    USER="keystone"
    PASSWORD="TCjw-AuJ"
elif [ "$DB_NAME" = "cinder" ]
then
    USER="cinder"
    PASSWORD="1ySl8v_r"
elif [ "$DB_NAME" = "glance" ]
then
    USER="glance"
    PASSWORD="h4cD2D3B"
fi

echo "mysql -h $HOST -u $USER -P $PORT -p$PASSWORD -D $DB_NAME"
mysql -h $HOST -u $USER -P $PORT -p$PASSWORD -D $DB_NAME
