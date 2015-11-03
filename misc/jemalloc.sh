function prepare_jemalloc()
{
    mkdir -p ${BASE_PATH}/source
    cd ${BASE_PATH}/source

    if [ ! -f jemalloc-4.0.4.tar.bz2 ]
    then
        echo -n "Downloading jemalloc ..."
        wget -q https://github.com/jemalloc/jemalloc/releases/download/4.0.4/jemalloc-4.0.4.tar.bz2
        echo "done"
    else
        echo "Downloading jemalloc ...done"
    fi

    if [ ! -d jemalloc-4.0.4 ]
    then
        echo -n "Unpacking jemalloc ..."
        tar xf jemalloc-4.0.4.tar.bz2
        echo "done"
    else
        echo "Unpacking jemalloc ...done"
    fi

    cd ${BASE_PATH}
}

function make_jemalloc()
{
    mkdir -p $BASE_PATH/source/jemalloc-4.0.4/$1
    cd $BASE_PATH/source/jemalloc-4.0.4/$1
    TMP_LOG=$BASE_PATH/source/jemalloc-4.0.4/$1/$$.log
    if [ ! -f config.log ]
    then
        echo -n "Configuring jemalloc..."
        rm -rf $BASE_PATH/packages/$1
        CC=$CC CXX=$CXX CFLAGS=$CFLAGS LDFLAGS=$LDFLAGS CXXFLAGS=$CXXFLAGS     \
        $BASE_PATH/source/jemalloc-4.0.4/configure                             \
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
    echo -n "Building jemalloc..."
    touch doc/jemalloc.html &> /dev/null
    touch doc/jemalloc.3 &> /dev/null
    make -j8 &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    fi
    echo "done"
    echo -n "Installing jemalloc..."
    if [ ! -f $BASE_PATH/packages/$1/lib/libjemalloc.so ]
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
