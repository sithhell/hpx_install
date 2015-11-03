function prepare_lua()
{
    mkdir -p ${BASE_PATH}/source
    cd ${BASE_PATH}/source

    if [ ! -f lua-5.2.3.tar.gz ]
    then
        echo -n "Downloading lua ..."
        wget -q http://www.lua.org/ftp/lua-5.2.3.tar.gz
        echo "done"
    else
        echo "Downloading lua ...done"
    fi

    if [ ! -d lua-5.2.3 ]
    then
        echo -n "Unpacking lua ..."
        tar xf lua-5.2.3.tar.gz
        echo "done"
    else
        echo "Unpacking lua ...done"
    fi

    cd ${BASE_PATH}
}

function make_lua()
{
    mkdir -p $BASE_PATH/source/lua-5.2.3-$1
    cp -r $BASE_PATH/source/lua-5.2.3/* $BASE_PATH/source/lua-5.2.3-$1/
    cd $BASE_PATH/source/lua-5.2.3-$1
    TMP_LOG=$BASE_PATH/source/lua-5.2.3-$1/$$.log
    echo -n "Building lua..."
    make -j8 CC="${CC}" MYCFLAGS="${CFLAGS}" MYLDFLAGS="${LDFLAGS}" ansi &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    fi
    echo "done"
    echo -n "Installing lua..."
    if [ ! -f $BASE_PATH/packages/$1/lib/liblua.a ]
    then
        make install INSTALL_TOP=$BASE_PATH/packages/$1 &> $TMP_LOG
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
