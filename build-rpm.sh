#!/bin/bash

set -xe

SOURCE_DIR=""
NAME=""
BUILD_DIR=""

param_parse()
{
	if ! TEMP=$(getopt -a -o hfs:n:b: --long src:,help,force,build:name -- "$@"); then
		usage
		exit 1
	fi
	eval set -- "$TEMP"
	while true; do
		case "$1" in
			-s|--src)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					SOURCE_DIR=$2
				fi
				shift
				;;
			--force)
				force_build=1
				;;
			-n|--name)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					NAME=$2
				fi
				shift
				;;
			-b|--build)
				if [ "$2" != "" ] && [ "${2:0:1}" != "-" ];then
					BUILD=$2
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
if [ "$SPECS" = "" ]; then
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

release

rpmbuild -ba $HOME/rpmbuild/SPECS/${SPEC_NAME}

cp -r $HOME/rpmbuild/RPMS/noarch/*.rpm $TARGET_DIR
