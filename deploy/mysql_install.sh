#!/bin/bash

source ./common_var
yum install -y mariadb mariadb-server
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