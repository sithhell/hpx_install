#!/bin/bash

BASE_PATH=`dirname $(readlink -e $BASH_SOURCE)`

function do_exit()
{
    unset HOSTS
    unset BASE_PATH
    unset HOST_PATH
    unset MODULEPATH_BAK
}

HOSTS=
for host in `find $BASE_PATH -maxdepth 1 -type d`
do
    if [ -e ${host}/info.sh ]
    then
        HOSTS="${host} ${HOSTS}"
    fi
done

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
    echo "Loading environment for $current_host"
    echo ""
else
    echo "hostname \"$(hostname)\" is not supported."
    do_exit
fi

. $HOST_PATH/env.sh

MODULEPATH_BAK=$MODULEPATH

MODULEPATH=$TAU_MODULEPATH:$HPX_MODULEPATH
echo "Newly available modules:"
module avail

MODULEPATH=$MODULEPATH_BAK:$MODULEPATH

do_exit
