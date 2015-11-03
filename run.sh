#!/bin/bash -li
#
###############################################################################
#
# This set of scripts compiles HPX and provides a set of modulefiles that can
# be loaded. All dependencies that are needed to compile and run a HPX version
# will be installed.
#
# Run run.sh --help for more information
#
###############################################################################

BASE_PATH=`dirname $(readlink -e $0)`

echo "HPX will be installed to $BASE_PATH/packages/hpx."
echo "Module files will be placed in $BASE_PATH/modulefiles."

HOSTS=
for host in `find $BASE_PATH -maxdepth 1 -type d`
do
    if [ -e ${host}/info.sh ]
    then
        HOSTS="${host} ${HOSTS}"
    fi
done

echo $hosts

if [ x"$1" == x"--help" ]
then
    echo "Available hosts:"
fi
    for host in $HOSTS
    do
        source ${host}/info.sh
        if [ x"$1" == x"--help" ]
        then
            echo "  - ${NAME}"
        fi
        if [ x"${VALID}" == x"true" ]
        then
            current_host=${NAME}
            HOST_PATH=${host}
        fi
    done

if [ x"$1" == x"--help" ]
then
    echo ""
fi

if [ x"${current_host}" != x"" ]
then
    echo "The script is running on $current_host"
else
    echo "hostname \"$(hostname)\" is not supported."
    exit 1
fi

if [ x"$1" == x"--help" ]
then
    exit 1
fi

. $BASE_PATH/misc/modules.sh
. $BASE_PATH/misc/hwloc.sh
. $BASE_PATH/misc/jemalloc.sh
. $BASE_PATH/misc/boost.sh
. $BASE_PATH/misc/lua.sh
. $BASE_PATH/misc/active_harmony.sh
. $BASE_PATH/misc/hpx.sh

. $HOST_PATH/install.sh

# Running scripts for Babbage
#if hostname | grep -q '^bint'
#then
#    . $BASE_PATH/run.sh
#    exit $?
#fi
