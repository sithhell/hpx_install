function prepare_hpxlua()
{
    if [ ! -d $BASE_PATH/source/hpx_script ]
    then
        mkdir -p $BASE_PATH/source
        cd $BASE_PATH/source
        git clone --depth=1 https://github.com/STEllAR-GROUP/hpx_script.git
    fi

    cd $BASE_PATH/source/hpx_script
    git stash &> /dev/null
    git pull --rebase &> /dev/null
    git stash pop &> /dev/null
    cd $BASE_PATH
}

function hpxlua_cmake()
{
    mkdir -p $BASE_PATH/packages/$PREFIX/hpxlua/$BUILD_TYPE
    cd $BASE_PATH/packages/$PREFIX/hpxlua/$BUILD_TYPE
    TMP_LOG=$BASE_PATH/packages/$PREFIX/hpxlua/$BUILD_TYPE/$$.log
    HPX_BASE=$BASE_PATH/packages/$PREFIX/hpx/$BUILD_TYPE
    if [ ! -f cmake_done ]
    then
        echo -n "Configuring HPX LUA ($BUILD_TYPE)..."
        $HPX_BASE/bin/hpxcmake $BASE_PATH/source/hpx_script/lua \
            -DHPX_DIR=$HPX_BASE/lib/cmake/HPX \
            -DLUA_DIR=$BASE_PATH/packages/$PREFIX/lua &> $TMP_LOG
        if [ $? != 0 ]
        then
            echo "failed"
            tail -n 100 $TMP_LOG
            exit 1
        else
            touch cmake_done
            echo "done"
        fi
    fi

    echo -n "Building HPX LUA ($BUILD_TYPE)..."
    make -j8 &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    else
        echo "done"
    fi

    ln -sf $BASE_PATH/packages/$PREFIX/hpxlua/$BUILD_TYPE/xlua \
        $HPX_BASE/bin/xlua &> /dev/null
    ln -sf $BASE_PATH/packages/$PREFIX/hpxlua/$BUILD_TYPE/hello \
        $HPX_BASE/bin/xlua_hello &> /dev/null
}
