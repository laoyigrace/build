#!/bin/bash

source ./common_var

set -xe

if [ -e /root/adminrc ]; then
    source /root/adminrc
elif [ -e /root/keystonerc_admin ]; then
    source /root/keystone_adminrc
fi

HOST_IP=`ip addr |grep inet|grep -v 127.0.0.1|grep -v inet6|grep -E "ens|eth"|awk '{print $2}'|tr -d "addr:" | awk -F '/' '{print $1}'`

CONF_FILE=

# 打印帮助信息
usage()
{
cat << HELP
	-f,--conf				subject deploy config file
HELP
	exit 1;
}

#打印错误代码并退出
die()
{
	ecode=$1;
	shift;
	echo -e "${CRED}$*, exit $ecode${C0}" | tee -a $LOG_NAME;
	exit $ecode;
}
#[ $#  -lt 2 ] && usage

#解析参数
param_parse()
{
	# 可输入的选项参数设置
	ARGS=`getopt -a -o f: -l conf: -- "$@"`
	[ $? -ne 0 ] && usage

	eval set -- "${ARGS}"
	while true
	do
		case "$1" in
		-f|--conf)
			CONF_FILE="$2";
			shift
			;;
		--)
			shift
			break
			;;
			esac
	shift
	done
}

conf_registry_init(){
   #database
    crudini --set /etc/subject/subject-registry.conf database connection "mysql+pymysql://${subjectdbuser}:${subjectdbpass}@${dbbackendhost}:${mysqldbport}/${subjectdbname}"
    crudini --set /etc/subject/subject-registry.conf database retry_interval 10
    crudini --set /etc/subject/subject-registry.conf database idle_timeout 3600
    crudini --set /etc/subject/subject-registry.conf database min_pool_size 1
    crudini --set /etc/subject/subject-registry.conf database max_pool_size 10
    crudini --set /etc/subject/subject-registry.conf database max_retries 100
    crudini --set /etc/subject/subject-registry.conf database pool_timeout 10

    # keystone
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken auth_uri "${auth_uri}"
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken auth_url "${auth_url}"
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken auth_type "${auth_type}"
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken project_domain_name "${project_domain_name}"
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken user_domain_name "${user_domain_name}"
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken project_name "${service_project_name}"
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken username "${subject_username}"
    crudini --set /etc/subject/subject-registry.conf keystone_authtoken password "${subject_password}"

    #compute
    crudini --set /etc/subject/subject-registry.conf paste_deploy flavor ${flavor}


}
conf_init()
{
    #配置文件的设置
    crudini --set /etc/subject/subject-api.conf DEFAULT bind_host "${bind_host}"
    crudini --set /etc/subject/subject-api.conf DEFAULT bind_port "${bind_port}"
    crudini --set /etc/subject/subject-api.conf DEFAULT backlog "${backlog}"
    crudini --set /etc/subject/subject-api.conf DEFAULT registry_host "${registry_host}"
    crudini --set /etc/subject/subject-api.conf DEFAULT registry_port "${registry_port}"
    crudini --set /etc/subject/subject-api.conf DEFAULT log_dir "${log_dir}"
    crudini --set /etc/subject/subject-api.conf DEFAULT debug "true"

	#subject_store
    crudini --set /etc/subject/subject-api.conf subject_store stores "${stores}"
    crudini --set /etc/subject/subject-api.conf subject_store default_store "${default_store}"
    crudini --set /etc/subject/subject-api.conf subject_store filesystem_store_datadir "${filesystem_store_datadir}"

    #database
    crudini --set /etc/subject/subject-api.conf database connection "mysql+pymysql://${subjectdbuser}:${subjectdbpass}@${dbbackendhost}:${mysqldbport}/${subjectdbname}"
    crudini --set /etc/subject/subject-api.conf database retry_interval 10
    crudini --set /etc/subject/subject-api.conf database idle_timeout 3600
    crudini --set /etc/subject/subject-api.conf database min_pool_size 1
    crudini --set /etc/subject/subject-api.conf database max_pool_size 10
    crudini --set /etc/subject/subject-api.conf database max_retries 100
    crudini --set /etc/subject/subject-api.conf database pool_timeout 10

    # keystone
    crudini --set /etc/subject/subject-api.conf keystone_authtoken auth_uri "${auth_uri}"
    crudini --set /etc/subject/subject-api.conf keystone_authtoken auth_url "${auth_url}"
    crudini --set /etc/subject/subject-api.conf keystone_authtoken auth_type "${auth_type}"
    crudini --set /etc/subject/subject-api.conf keystone_authtoken project_domain_name "${project_domain_name}"
    crudini --set /etc/subject/subject-api.conf keystone_authtoken user_domain_name "${user_domain_name}"
    crudini --set /etc/subject/subject-api.conf keystone_authtoken project_name "${service_project_name}"
    crudini --set /etc/subject/subject-api.conf keystone_authtoken username "${subject_username}"
    crudini --set /etc/subject/subject-api.conf keystone_authtoken password "${subject_password}"

    # rabbit
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit rabbit_host $rabbit_host
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit rabbit_port $rabbit_port
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit rabbit_hosts $rabbit_hosts
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit rabbit_use_ssl ${rabbit_use_ssl}
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit rabbit_password ${rabbit_password}
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit rabbit_virtual_host $rabbit_virtual_host
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit rabbit_ha_queues ${rabbit_ha_queues}
    crudini --set /etc/subject/subject-api.conf oslo_messaging_rabbit heartbeat_rate ${heartbeat_rate}

    #compute
    crudini --set /etc/subject/subject-api.conf paste_deploy flavor ${flavor}

}

db_init()
{
    #  数据库部署
    mysqlcommand="mysql --port=$mysqldbport --password=$mysqldbpassword --user=$mysqldbadm --host=$dbbackendhost"

    echo "CREATE DATABASE IF NOT EXISTS $subjectdbname default character set utf8;"|$mysqlcommand
    echo "GRANT ALL ON $subjectdbname.* TO '$subjectdbuser'@'%' IDENTIFIED BY '$subjectdbpass';"|$mysqlcommand
    echo "GRANT ALL ON $subjectdbname.* TO '$subjectdbuser'@'localhost' IDENTIFIED BY '$subjectdbpass';"|$mysqlcommand
    echo "GRANT ALL ON $subjectdbname.* TO '$subjectdbuser'@'${HOST_IP}' IDENTIFIED BY '$subjectdbpass';"|$mysqlcommand

    subject-manage db sync
}

main()
{
    script_dir=`dirname $0`
    param_parse $*
    if [ "x$CONF_FILE" = "x" ]; then
        script_dir=`dirname $0`
        CONF_FILE="${script_dir}/subject_conf.ini"
    fi

    if [ ! -e "$CONF_FILE" ]; then
        usage
    fi

    conf_init
    db_init

    #keystone中设置subject
    source /root/keystone_adminrc
    openstack user show $subject_username --domain default || openstack user create --domain default --password \
    ${subject_password} $subject_username
    #keystone user-get $admin_user || keystone user-create --name $admin_user \
    #--tenant $admin_tenant_name --pass $admin_password --email "subject@email"

    openstack role add --project $service_project_name --user $subject_username admin

    openstack service show $subject_service || openstack service create --name \
    $subject_service --description "Ojj Subject" subject

    openstack endpoint create --region $endpointsregion \
    $subject_service public http://${HOST_IP}:9292

    openstack endpoint create --region $endpointsregion \
    $subject_service internal http://${HOST_IP}:9292

    openstack endpoint create --region $endpointsregion \
    $subject_service admin http://${HOST_IP}:9292

    #keystone user-role-add --user $admin_user --role admin --tenant
    # $admin_tenant_name
    #keystone service-get $subject_service || keystone service-create --name
    # $subject_service --description "OpenStack subject service" --type subject

    #keystone endpoint-get --service $subject_service || keystone
    # endpoint-create --region $endpointsregion --service $subject_service \
    #--publicurl "${publicurl}" \
    #--adminurl "${adminurl}" \
    #--internalurl "${internalurl}"

    service ojj-subject-api restart
    service ojj-subject-registry restart
}

main $*
exit 0
