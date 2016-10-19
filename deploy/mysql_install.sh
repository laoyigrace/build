#!/bin/bash

source ./common_var

set -xe

yum install -y mariadb mariadb-server python2-PyMySQL
systemctl enable mariadb
systemctl start mariadb

mysql<<EOF
use mysql;
UPDATE user SET Password = PASSWORD('${mysqldbpassword}') WHERE user = 'root';
FLUSH PRIVILEGES;
EOF

cat << EOF >/root/.my.cnf
[mysql]
user=root
host=localhost
password='${mysqldbpassword}'
socket=/var/lib/mysql/mysql.sock
EOF