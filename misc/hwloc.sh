function prepare_hwloc()
{
    mkdir -p ${BASE_PATH}/source
    cd ${BASE_PATH}/source

    if [ ! -f hwloc-1.11.1.tar.bz2 ]
    then
        echo -n "Downloading hwloc ..."
        wget -q http://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-1.11.1.tar.bz2
        echo "done"
    else
        echo "Downloading hwloc ...done"
    fi

    if [ ! -d hwloc-1.11.1 ]
    then
        echo -n "Unpacking hwloc ..."
        tar xf hwloc-1.11.1.tar.bz2
        echo "done"
    else
        echo "Unpacking hwloc ...done"
    fi

    cd ${BASE_PATH}
}

function make_hwloc()
{
    mkdir -p $BASE_PATH/source/hwloc-1.11.1/$1
    cd $BASE_PATH/source/hwloc-1.11.1/$1
    TMP_LOG=$BASE_PATH/source/hwloc-1.11.1/$1/$$.log
    if [ ! -f config.log ]
    then
        echo -n "Configuring hwloc..."
        rm -rf $BASE_PATH/packages/$1
        CC=$CC CXX=$CXX CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS CXXFLAGS=$CXXFLAGS     \
        $BASE_PATH/source/hwloc-1.11.1/configure                               \
            --prefix=$BASE_PATH/packages/$1                                    \
            $2 &> $TMP_LOG

        if [ $? != 0 ]
        then
            echo "failed"
            tail -n 100 $TMP_LOG
            rm -rf *
            cd $BASE_PATH
            exit 1
        fi
        echo "done"
    fi
    echo -n "Building hwloc..."
    make -j8 &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    fi
    echo "done"
    echo -n "Installing hwloc..."
    if [ ! -f $BASE_PATH/packages/$1/lib/libhwloc.so ]
    then
        make install &> $TMP_LOG
        if [ $? != 0 ]
        then
            echo "failed"
            tail -n 100 $TMP_LOG
            exit 1
        fi
    fi
    echo "done"
    cd $BASE_PATH
}
