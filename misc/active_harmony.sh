function prepare_ah()
{
    mkdir -p ${BASE_PATH}/source
    cd ${BASE_PATH}/source

    if [ ! -f ah-4.5.tar.gz ]
    then
        echo -n "Downloading active harmony ..."
        wget -q http://www.dyninst.org/sites/default/files/downloads/harmony/ah-4.5.tar.gz
        echo "done"
    else
        echo "Downloading active harmony ...done"
    fi

    if [ ! -d activeharmony-4.5 ]
    then
        echo -n "Unpacking active harmony ..."
        tar xf ah-4.5.tar.gz
        echo "done"
    else
        echo "Unpacking active harmony ...done"
    fi

    cd ${BASE_PATH}
}

function make_ah()
{
    mkdir -p $BASE_PATH/source/activeharmony-4.5-$1
    cp -r $BASE_PATH/source/activeharmony-4.5/* $BASE_PATH/source/activeharmony-4.5-$1/
    cd $BASE_PATH/source/activeharmony-4.5-$1
    TMP_LOG=$BASE_PATH/source/activeharmony-4.5-$1/$$.log
    echo -n "Building active harmony ..."
    make -j8 MPICC=mpicc_disabled CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    fi
    echo "done"
    echo -n "Installing active harmony ..."
    if [ ! -f $BASE_PATH/packages/$1/lib/libharmony.a ]
    then
        make -j8 MPICC=mpicc_disabled CC="${CC}" CXX="${CXX}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" PREFIX=$BASE_PATH/packages/$1 install &> $TMP_LOG
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
