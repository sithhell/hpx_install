function prepare_boost()
{
    mkdir -p ${BASE_PATH}/source
    cd ${BASE_PATH}/source

    if [ ! -f boost_1_59_0.tar.bz2 ]
    then
        echo -n "Downloading boost ..."
        wget -q http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.bz2
        echo "done"
    else
        echo "Downloading boost ...done"
    fi

    if [ ! -d boost_1_59_0 ]
    then
        echo -n "Unpacking boost ..."
        tar xf boost_1_59_0.tar.bz2
        echo "done"
    else
        echo "Unpacking boost ...done"
    fi

    cd ${BASE_PATH}
}

function make_boost()
{
    mkdir -p $BASE_PATH/packages/$1
    ln -sf $BASE_PATH/source/boost_1_59_0/* $BASE_PATH/packages/$1/
    cd $BASE_PATH/packages/$1/
    TMP_LOG=$BASE_PATH/packages/$1/$$.log
    echo -n "Bootstrapping boost ..."
    if [ ! -f b2 ]
    then
        ./bootstrap.sh &> $TMP_LOG
        if [ $? != 0 ]
        then
            echo "failed"
            tail -n 100 $TMP_LOG
            exit 1
        fi
    fi
    echo "done"
    LINKFLAGS=
    if [ x"$LDFLAGS" != x"" ]
    then
        LINKFLAGS="linkflags=\"$LDFLAGS\""
    fi
    echo -n "Building boost ..."
    ./b2 -j8 --without-mpi \
         --withou-python \
         --without-log \
         --without-graph \
         --without-serialization \
         --without-test \
         --without-graph_parallel \
         --without-math \
         --without-iostreams \
         --without-context \
         --without-coroutine \
         --without-coroutine2 \
         --without-signals \
         --without-container \
         --without-locale \
         --without-wave \
         variant=release \
         $2 \
         cxxflags="$CXXFLAGS" \
         $LINKFLAGS &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    fi
    echo "done"
}
