function prepare_hpx()
{
    if [ ! -d $BASE_PATH/source/hpx ]
    then
        mkdir -p $BASE_PATH/source
        cd $BASE_PATH/source
        git clone --depth=1 https://github.com/STEllAR-GROUP/hpx.git
    fi

    cd $BASE_PATH/source/hpx
    git stash &> /dev/null
    git checkout release
    git pull --rebase &> /dev/null
    git stash pop &> /dev/null
    cd $BASE_PATH
}

function hpx_cmake()
{
    mkdir -p $BASE_PATH/packages/$PREFIX/hpx/$BUILD_TYPE
    cd $BASE_PATH/packages/$PREFIX/hpx/$BUILD_TYPE
    TMP_LOG=$BASE_PATH/packages/$PREFIX/hpx/$BUILD_TYPE/$$.log
    CMAKE_TOOLCHAIN_FILE=
    if [ x"$TOOLCHAIN_FILE" != x"" ]
    then
        CMAKE_TOOLCHAIN_FILE="-DCMAKE_TOOLCHAIN_FILE=$BASE_PATH/source/hpx/cmake/toolchains/$TOOLCHAIN_FILE"
        CMAKE_BASE="cmake $CMAKE_TOOLCHAIN_FILE"
    else
        CMAKE_BASE="cmake"
    fi
    if [ ! -f cmake_done ]
    then
        echo -n "Configuring HPX ($BUILD_TYPE)..."
        CMAKE_MPI_CXX_COMPILER=
        if [ x"$MPI_CXX_COMPILER" != x"" ]
        then
            CMAKE_MPI_CXX_COMPILER="-DMPI_CXX_COMPILER=${MPI_CXX_COMPILER}"
        fi
        CMAKE_MPI_C_COMPILER=
        if [ x"$MPI_C_COMPILER" != x"" ]
        then
            CMAKE_MPI_C_COMPILER="-DMPI_C_COMPILER=${MPI_C_COMPILER}"
        fi
        TAU_OPTIONS="-icpc-pthread"
        if [ $current_host = "edison" ] ; then
            TAU_OPTIONS="-intel-pthread"
        fi
        cmake $BASE_PATH/source/hpx \
            -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
            $CMAKE_TOOLCHAIN_FILE \
            $CMAKE_MPI_CXX_COMPILER \
            $CMAKE_MPI_C_COMPILER \
            -DCMAKE_CXX_COMPILER=${CXX} \
            -DCMAKE_C_COMPILER=${CC} \
            -DBOOST_ROOT=$BASE_PATH/packages/$PREFIX/boost \
            -DHWLOC_ROOT=$BASE_PATH/packages/$PREFIX/hwloc \
            -DJEMALLOC_ROOT=$BASE_PATH/packages/$PREFIX/jemalloc \
            -DACTIVEHARMONY_ROOT=$BASE_PATH/packages/$PREFIX/activeharmony \
            -DPAPI_ROOT=$PAPI_PATH \
            -DTAU_ROOT=$TAUROOTDIR \
            -DTAU_ARCH=$TAUARCH \
            -DTAU_OPTIONS=$TAU_OPTIONS \
            -DHPX_WITH_MALLOC=jemalloc \
            -DHPX_WITH_PARCELPORT_MPI=On \
            -DHPX_WITH_PAPI=On \
            -DHPX_WITH_APEX=On \
            -DHPX_WITH_TAU=On \
            -DCMAKE_INSTALL_PREFIX=. \
            -DAPEX_WITH_ACTIVEHARMONY=On &> $TMP_LOG
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
    echo -n "Building HPX core ($BUILD_TYPE)..."
    make -j8 core &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    else
        echo "done"
    fi

    echo -n "Building HPX examples ($BUILD_TYPE)..."
    make -j8 examples &> $TMP_LOG
    if [ $? != 0 ]
    then
        echo "failed"
        tail -n 100 $TMP_LOG
        exit 1
    else
        echo "done"
    fi

    cat << EOF > $BASE_PATH/packages/$PREFIX/hpx/$BUILD_TYPE/bin/hpxcmake
#!/bin/bash
$CMAKE_BASE \\
    -DCMAKE_CXX_COMPILER=${CXX} \\
    -DCMAKE_C_COMPILER=${CC} \\
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \\
    -DHPX_WITH_MALLOC=jemalloc \\
    "\$@"
EOF
    chmod +x $BASE_PATH/packages/$PREFIX/hpx/$BUILD_TYPE/bin/hpxcmake

    cd $BASE_PATH
}
