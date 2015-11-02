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
    mkdir -p $BASE_PATH/source/boost_1_59_0/$1
    ln -sf $BASE_PATH/source/boost_1_59_0/* $BASE_PATH/source/boost_1_59_0/$1/
    cd $BASE_PATH/source/boost_1_59_0/$1/
    if [ ! -f b2 ]
    then
        ./bootstrap.sh
    fi
    echo $2
    ./b2 -j8 --without-mpi \
         --withou-python \
         --without-log \
         --without-graph \
         --without-serialization \
         --without-test \
         --without-graph_parallel \
         --without-math \
         variant=release \
         $2 \
         cxxflags="$CXXFLAGS" \
         ldflags="$LDFLAGS"
    echo ""
}
