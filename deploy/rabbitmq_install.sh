#!/bin/bash

source ./common_var
yum install -y rabbitmq-server

systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

rabbitmqctl add_user openstack ${rabbit_password}
rabbitmqctl set_permissions openstack ".*" ".*" ".*"