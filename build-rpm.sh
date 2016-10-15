#!/bin/bash

set -x

SOURCE_DIR=""
NAME=""
BUILD_DIR=""

param_parse()
{
	if ! TEMP=$(getopt -a -o hfs:n:b --long src:,help,force,build:name -- "$@"); then
		usage
		exit 1
	fi
	eval set -- "$TEMP"
	while true; do
		case "$1" in
			-s|--src)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					SOURCE_DIR=${"$2"//\'/}
				fi
				shift
				;;
			--force)
				force_build=1
				;;
			-n|--name)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					NAME=${"$2"//\'/}
				fi
				shift
				;;
			-b|--build)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					BUILD=${"$2"//\'/}
				fi
				shift
				;;
			-h|--help)
				usage
				exit 0
				;;
			--)
				shift
				break
				;;
			*)
				usage
				exit 1
				;;
			esac
			shift
	done
}

function do_lock()
{
        LOCK_FILE=/tmp/build.lock
        touch ${LOCK_FILE}
        exec 100<>  ${LOCK_FILE}
        flock -n 100
        if [ $? -eq 1 ];then
                echo -e "\n*********rpm is building*********\n"
                exit 1
        fi
        return 0
}

usage()
{
   cat << EOF
  -h --help              show this help.
  -s --spec              specify name of spec file.
  --force		         force to build rpm pkg		
  For example:

  $0 -s specfile -c CODE_ROOT

EOF
}

# Create snapshot package
function snapshot {
    # Determine the nightly build
    DATE=`date +%Y%m%d`
    SHA=`git log --pretty=format:'%h' -n 1`

    # Replace the spec file with the given snapshot value
    sed -ie "s/Version:\s\+XXX/Version:        ${VERSION}/" $HOME/rpmbuild/SPECS/${SPEC_NAME}
    sed -ie "s/Release:\s\+XXX/Release:        0.0.${DATE}git${SHA}/" $HOME/rpmbuild/SPECS/${SPEC_NAME}
    echo "Building ptyhon-neutron-plugin-midonet package for snapshot ${DATE}git${SHA}"
}

function rc {
    # Get the values to build the rc package
    RC=$1

    # Replace the spec file with the given snapshot value
    sed -ie "s/Version:\s\+XXX/Version:        ${VERSION}/" $HOME/rpmbuild/SPECS/${SPEC_NAME}
    sed -ie "s/Release:\s\+XXX/Release:        0.1.${RC}/" $HOME/rpmbuild/SPECS/${SPEC_NAME}
    echo "Building ${SPEC_NAME} package for release candidate ${RC}"
}

function release {
    # Replace the spec file with the given snapshot value
    sed -ie "s/Version:\s\+XXX/Version:        ${VERSION}/" $HOME/rpmbuild/SPECS/${SPEC_NAME}
    sed -ie "s/Release:\s\+XXX/Release:        1/" $HOME/rpmbuild/SPECS/${SPEC_NAME}
    echo "Building ${SPEC_NAME} package for release ${VERSION}"
}

param_parse $*

# Create the target directory where the rpm will be copied
TARGET_DIR=$SOURCE_DIR/RPMS
mkdir -p $TARGET_DIR

# Make sure we are in the source code directory
cd $SOURCE_DIR

# Create the structure of directories to build the rpm
# a new hierarchy will be created in $HOME/rpmbuild
rm -rf $HOME/rpmbuild
rpmdev-setuptree

# Create the tarball into the SOURCES directory
python setup.py sdist --dist-dir $HOME/rpmbuild/SOURCES

SPEC_PATH=$(find "$BUILD" -name "*.spec")
if [ "$SPECS" -eq "" ]; then
	echo "not have spec file!"
	exit 0
fi

SPEC_NAME=`basename $SPEC_PATH`

# Move the spec file to the SPECS directory (Version: and Release: to be replaced)
cp ${SPEC_PATH} $HOME/rpmbuild/SPECS

cp ${BUILD}/* $HOME/rpmbuild/SOURCES
rm -f $HOME/rpmbuild/SOURCES/%{SPEC_NAME}

# Get the version from sources
VERSION=$(cat setup.cfg | grep version | grep -o '[0-9.]*')

# Replace the version and release depending on the version tag
# This command will check if we live in a tag commit or not
version_tag=$(git describe --candidates 0)

# If the command fails, we are in a SNAPSHOT commit
if [ $? -ne 0 ]; then
  snapshot
else
  if [[ "$version_tag" =~ ^[0-9]{4}(\.[0-9]+){2}$ ]]; then
    # Final version tag (no rc)
    echo "Final version ${BASH_REMATCH[0]}"
    if [[ "${BASH_REMATCH[0]}" != $VERSION ]]; then
        echo "Tag version '${BASH_REMATCH[0]}' and source version '$VERSION' mismatch"
        exit 2;
    fi
    release

  elif [[ "$version_tag" =~ ^([0-9]{4}(\.[0-9]+){2})-(rc[0-9]+)$ ]]; then
    # release candidate
    echo "Version ${BASH_REMATCH[1]}"
    echo "Release candidate version ${BASH_REMATCH[3]}"
    if [[ "${BASH_REMATCH[1]}" != $VERSION ]]; then
        echo "Tag version '${BASH_REMATCH[1]}' and source version '$VERSION' mismatch"
        exit 2;
    fi
    rc ${BASH_REMATCH[3]}

  else
    echo "Invalid version tag $version_tag"
    exit 1;
  fi
fi

rpmbuild -ba $HOME/rpmbuild/SPECS/${SPEC_NAME}

cp -r $HOME/rpmbuild/RPMS/noarch/*.rpm $TARGET_DIR



















rpm_root="/root/rpmbuild/RPMS/"
rpm_build_root="/root/rpmbuild/BUILDROOT"
code_build_root="/home/ojj/build"
option=""
spec_file=""
svn_commit=0
CODE_ROOT="/home/ojj/src"
current_dir=$(pwd)
install_dir=""
create_list=0
spec_dir=$(pwd)
code_path=""
export code_build_root
ojj_root="/home/ojj/"
build_fail=0
fail_rpm_name=""
failed_pkgs="/tmp/_rpm_ojj-fails.log"
build_dir_log_file="/tmp/build_log_file"
update_pro_name=""
last_success_dir=""
force_build=0
rpm_base_dir="/home/ojj-rpm"

check_user()
{
	cur_user=$(whoami)
	if [ "$cur_user" != "root" ]; then
		echo "you need to run as root!";
		exit 1
	fi
}

#生成存放rpm包的目录
create_dir()
{
	local version=$1
	num=$(echo "$version"| md5sum | cut -c1-30)
	prefix1=${num:0:2}
	prefix2=${num:2:2}
	prefix3=$num
	dir=${rpm_base_dir}/${prefix1}/${prefix2}/${prefix3}
	mkdir -p "$dir"
	echo "${prefix1}/${prefix2}/${prefix3}"
}

function do_lock()
{
        LOCK_FILE=/tmp/build.lock
        touch ${LOCK_FILE}
        exec 100<>  ${LOCK_FILE}
        flock -n 100
        if [ $? -eq 1 ];then
                echo -e "\n*********rpm is building*********\n"
                exit 1
        fi
        return 0
}

usage()
{
   cat << EOF
  -h --help              show this help.
  -s --spec              specify name of spec file.
  --force		         force to build rpm pkg		
  For example:

  $0 -s specfile -c CODE_ROOT

EOF
}

update_src()
{
    #需要更新代码的项目
    SUB_DIRS=( "./" "../include" "../src" )

    for n in ${SUB_DIRS[*]};do
        cd "${code_build_root}/$n" || exit 1;
        eval "${SVN}" revert --recursive ./ || exit 1;
    done
    cd "${code_build_root}/../" || exit 1;
    eval "${SVN}" update --accept 'theirs-full' || exit 1;
	cd "$current_dir" || exit 1
}

param_parse()
{
	if ! TEMP=$(getopt -a -o hfs:d: --long commit,help,force,spec: -- "$@"); then
		usage
		exit 1
	fi
	eval set -- "$TEMP"
	while true; do
		case "$1" in
			-s|--spec)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					spec_file=${"$2"//\'/}
				fi
				shift
				;;
			--commit)
				svn_commit=1
				;;
			--force)
				force_build=1
				;;
			-d)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					rpm_root=${"$2"//\'/}
				fi
				shift
				;;
			-h|--help)
				usage
				exit 0
				;;
			--)
				shift
				break
				;;
			*)
				usage
				exit 1
				;;
			esac
			shift
	done
}

#解析spec文件
parse_spec_file()
{
	file=$1
	opt=$2
	ret=""
	if [ x"$opt" = x"code_path" ];then
		ret=$(rpmspec -P "$file"|grep "^$opt"|awk -F= '{print$2}')
	elif [ x"$opt" = x"Name" ];then
		ret=$(rpmspec -P "$file"|grep "$opt"|awk  '{print$2}')
	fi
	if [ x"$ret" = x"" ];then
		echo "**********parse $opt spec file failed**********"
		echo -e "**********rpmbuild -bb $1 failed**********"
		exit 1
	fi
	eval echo "$ret"
}

genreports()
{
	dir="/home/jenkins/workspace/基础系统RPM打包/packages/"
	html_head="<!DOCTYPE html>
    <html lang=\"en\">
    <head>
        <title>Sangfor Packaging</title>
        <link rel=\"stylesheet\" href=\"styles.css\">
    </head>
    <body>
    <h1><i class='fa fa-chevron-circle-right pull-left'></i>Sangfor Packaging</h1>
    <table id=\"delorean\">
        <tr>
            <th>Build Date Time</th>
            <th>Commit Date Time</th>
            <th>Project Name</th>
            <th>Status</th>
            <th>Repository</th>
        </tr>"
	echo -e "$html_head" >"$rpm_base_dir/report.html"
	local sql="use $report_database_name;select $column_build_data,$column_commit_data,$column_rpm_name,$column_rpm_status,$column_rpm_dir from $table_name ORDER BY $column_build_data desc"
	ret=$(use_sql "$sql")
	total_rpm=$(echo "$ret"|tr ' ' '\n'|wc -l)
	for (( i=1; i<= total_rpm; i=i+1));do
		table_value=""
		line=$((i+1))
		column=1
		line_info=$(echo "$ret"|tr ' ' '\n'|head -n $line|tail -n 1)
		build_data=$(echo "$line_info"|awk  -v j=$column '{print$j}')
		column=$((column+1))
		commit_data=$(echo "$line_info"|awk  -v j=$column '{print$j}')
		column=$((column+1))
		rpm_name=$(echo "$line_info"|awk  -v j=$column '{print$j}')
		column=$((column+1))
		rpm_status=$(echo "$line_info"|awk  -v j=$column '{print$j}')
		column=$((column+1))
		rpm_dir=$(echo "$line_info"|awk  -v j=$column '{print$j}')
		rpm_dir=$(echo "$rpm_dir"|sed "s/\/home\///" )
		if [ "$rpm_status" = "SUCCESS" ];then
			table_value="<tr class=\"success\"><td>${build_data}</td>"
		else
			table_value="<tr ><td>${build_data}</td>"
		fi
		
		table_value=${table_value}"<td>${commit_data}</td>"

		table_value=${table_value}"<td>${rpm_name}</td>"
		
		table_value=${table_value}"<td><i class='fa fa-thumbs-o-up pull-left' style='color:green'></i>${rpm_status}</td>"
		table_value=${table_value}"<td><i class='fa fa-link pull-left' style='color:#004153'></i><a href=\"$rpm_dir\">repo</a></td></tr>"
		echo "$table_value">>"$rpm_base_dir/report.html"
	done
	echo "</table></html>">>"$rpm_base_dir/report.html"
}

build_rpm()
{
	spec_file="$1"
	
	#通过spec文件获得rpm对应代码的路径，名字
	code_path=$(parse_spec_file "$spec_file" "code_path")
	rpm_name=$(parse_spec_file "$spec_file" "Name")
	
	#从数据库获取rpm版本号
	local rpm_version
	rpm_version=$(get_version "$rpm_database_name" "$rpm_name")
	#将代码，spec文件的版本号组成总的版本号
	svn_code_version=$(get_local_svn_version "$code_path")
	svn_spec_version=$(get_local_svn_version "$SPEC_PATH")
	commit_data=$(${SVN} info "${code_path}" | svn_parse_output "Last Changed Date"|awk '{print $1"_"$2}')
	version=${svn_code_version}.${svn_spec_version}
	
	#版本号不存在，或者不是最新，编译代码
	if [ x"$rpm_version" != x"$version" ];then
		update_pro_name=${spec_file}","${update_pro_name}
		build_data=$(date '+%Y-%m-%d_%H:%M:%S')
		build_dir=$(create_dir "${version}")
		rpmbuild -bb -D "__os_install_post %{nil}" -D "rpm_release ${version}" "$spec_file"
		if [ $? -ne 0 ];then
			build_fail=1
			fail_rpm_name=${rpm_name}","${fail_rpm_name}
			#记录到report数据库中
			insert_data  "$report_database_name" "$build_data" "$commit_data" "$rpm_name" "none" "none" "FAILED"
			return 1
		fi
		
		#每个项目对应着一个目录，此目录除了这个项目的rpm包外其余为链接
		#获取rpmbuild数据库中项目的目录,对非链接文件创建链接
		local sql="use $rpm_database_name;select $column_rpm_dir from $table_name where $column_rpm_name !=\"$rpm_name\";"
		ret=$(use_sql "$sql";)
		total_dir=$(echo "$ret"|sed "s/$column_rpm_dir//")
		for pro_dir in $total_dir;do
			all_rpm=$(ls "${rpm_base_dir}"/"${pro_dir}"/*.rpm)
			for f in $all_rpm;do
				test -L "$f"
				if [ $? -ne 0 ];then
					basename=$(basename "$f")
					ln -sf "$f" "${rpm_base_dir}"/"${build_dir}"/"${basename}"
				fi
			done
		done
		#同时写入rpmbuild和report数据库中
		#svn版本号和打包次数同时记录到数据库中，以逗号(,)区分
		insert_data  "$rpm_database_name" "$build_data" "$commit_data" "$rpm_name" "${version}" "$build_dir" "SUCCESS"
		insert_data  "$report_database_name" "$build_data" "$commit_data" "$rpm_name" "${version}" "$build_dir" "SUCCESS"
		rpm_pkg=$(find "$rpm_root" -name "*.rpm")
		for f in $rpm_pkg;do
			mv "$f" "${rpm_base_dir}"/"${build_dir}"/
		done
		createrepo "${rpm_base_dir}"/"${build_dir}"/
		last_success_dir="$build_dir"
		cp $spec_dir/sangfor-acloud.repo "${rpm_base_dir}"/"${build_dir}"/sangfor-acloud.repo
		sed -i "s|baseurl=.*|baseurl=http://mirrors.vt/repos-acloud/${build_dir}|g" "${rpm_base_dir}"/"${build_dir}"/sangfor-acloud.repo
		date_time=$(date "+%Y-%m-%d_%H:%M:%S")
		sed -i "s|name=.*|name=sanfor-acloud build $BUILD_NUMBER date $date_time|" "${rpm_base_dir}"/"${build_dir}"/sangfor-acloud.repo
		return 0
	fi
	return 0
}

#根据spec，代码版本号进行打包
build_all_rpm()
{
	if [ $force_build -eq 1 ];then
		drop_database "$rpm_database_name"
		create_database "$rpm_database_name" "primary key"
	fi
	local spec_list;
	spec_list="$@"
	for file in $spec_list;do
		SPEC_PATH=$(cd "$(dirname "$file")" || exit 1; pwd)
		export SPEC_PATH
		build_rpm "$file"
	done
	return 0
}

main()
{
	rm -rf "$build_dir_log_file"
	mkdir -p "$rpm_root"
	check_user
	param_parse "$@"
	export CODE_ROOT=$CODE_ROOT
	update_src
	
	if [ x"$spec_file" = x"" ];then
		spec_list=$(find "$spec_dir" -name "*.spec"|sort)
		if [ -z "$spec_list" ];then
			echo "cannot find spec file"
			exit 1
		fi
	else
		spec_list=$(spec_file)
	fi
	if [ $svn_commit -eq 1 ];then
		update_record "$spec_list"
		exit 0
	fi
	build_all_rpm "$spec_list"
	genreports
	if [ $build_fail -eq 1 ];then
		echo "$fail_rpm_name" > $failed_pkgs
		echo "******************************WARNING******************************"
		echo "*******************************************************************"
		echo "****************rpmbuild -bb $fail_rpm_name failed*****************"
		return 1
	fi
	#没有新包
	if [ -z "$update_pro_name" ];then
		echo "none" >$build_dir_log_file
		echo "all rpm are latest" 
		return 0
	fi
	ln -sfT "$rpm_base_dir"/"$last_success_dir" "$rpm_base_dir"/current
	echo "$last_success_dir" >$build_dir_log_file
}
do_lock
main "$@"