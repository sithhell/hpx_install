#!/bin/bash -li

# Check proper usage
if [[ $# != 1 ]]
then
    echo "Not enough parameters"
    echo "Usage: $0 /install/path/"
    exit 1
fi

PWD_BAK=$PWD
if [ ! -d $1 ]
then
    mkdir -p $1
fi
BASE_PATH=`dirname $(readlink -e $1)`/`basename $1`

echo $BASE_PATH

# Parse Host ... we do different things on edison and babbage
if hostname | grep -q '^bint'
then
    HOST="babbage"
elif hostname | grep -q '^edison'
then
    HOST="edison"
else
    echo "Unknown host! This script only works on the NERSC machines Edison or Babbage"
    exit 1
fi

echo "Compiling HPX and dependencies on $HOST"

function build_hpx()
{
    if [ ! -d $BASE_PATH/source/hpx ]
    then
        mkdir -p $BASE_PATH/source
        cd $BASE_PATH/source
        git clone --depth=1 https://github.com/STEllAR-GROUP/hpx.git
    fi

    cd $BASE_PATH/source/hpx
    git pull --rebase
    cd $BASE_PATH

    if [[ $HOST == "babbage" ]]
    then
        load_modules "$MODULES_MIC"
        mkdir -p $BASE_PATH/mic/hpx/debug
        cd $BASE_PATH/mic/hpx/debug
        if [ ! -f CMakeCache.txt ]
        then
            echo "Configuring HPX for the XeonPhi (Debug version)..."
            cmake $BASE_PATH/source/hpx \
                -DCMAKE_BUILD_TYPE=Debug \
                -DCMAKE_CXX_FLAGS="-wd68 -mmic" \
                -DCMAKE_TOOLCHAIN_FILE=$BASE_PATH/source/hpx/cmake/toolchains/XeonPhi.cmake \
                -DMPI_CXX_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicxx \
                -DMPI_C_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicc \
                -DHWLOC_ROOT=$BASE_PATH/mic/hwloc \
                -DTBBMALLOC_ROOT=/opt/intel/tbb \
                -DBOOST_ROOT=$BOOST_ROOT \
                -DTAU_ROOT=$TAUROOTDIR \
                -DPAPI_ROOT=$PAPI_PATH \
                -DHPX_WITH_PARCELPORT_MPI=On \
                -DHPX_WITH_PAPI=On
            echo "done"
        fi
        echo "Building HPX for the XeonPhi (Debug version)..."
        make -j8 core
        make -j8 examples
        echo "Building HPX for the XeonPhi (Debug version)... done"
        mkdir -p $BASE_PATH/mic/hpx/release
        cd $BASE_PATH/mic/hpx/release
        if [ ! -f CMakeCache.txt ]
        then
            echo "Configuring HPX for the XeonPhi (Release version)..."
            cmake $BASE_PATH/source/hpx \
                -DCMAKE_BUILD_TYPE=RelWithDebInfo \
                -DCMAKE_CXX_FLAGS="-wd68 -mmic" \
                -DCMAKE_TOOLCHAIN_FILE=$BASE_PATH/source/hpx/cmake/toolchains/XeonPhi.cmake \
                -DMPI_CXX_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicxx \
                -DMPI_C_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicc \
                -DHWLOC_ROOT=$BASE_PATH/mic/hwloc \
                -DTBBMALLOC_ROOT=/opt/intel/tbb \
                -DBOOST_ROOT=$BOOST_ROOT \
                -DTAU_ROOT=$TAUROOTDIR \
                -DPAPI_ROOT=$PAPI_PATH \
                -DHPX_WITH_PARCELPORT_MPI=On \
                -DHPX_WITH_PAPI=On
            echo "done"
        fi
        echo "Building HPX for the XeonPhi (Release version)..."
        make -j8 core
        make -j8 examples
        echo "Building HPX for the XeonPhi (Release version)... done"

        load_modules "$MODULES_HOST"
        mkdir -p $BASE_PATH/host/hpx/debug
        cd $BASE_PATH/host/hpx/debug
        if [ ! -f CMakeCache.txt ]
        then
            echo "Configuring HPX for the Host (Debug version)..."
            cmake $BASE_PATH/source/hpx \
                -DCMAKE_BUILD_TYPE=Debug \
                -DCMAKE_CXX_FLAGS="-wd68 -DBOOST_FUSION_DONT_USE_PREPROCESSED_FILES" \
                -DCMAKE_CXX_COMPILER=icpc \
                -DMPI_C_COMPILER=icc \
                -DHWLOC_ROOT=$BASE_PATH/host/hwloc \
                -DTBBMALLOC_ROOT=/opt/intel/tbb \
                -DHPX_WITH_MALLOC=tbbmalloc \
                -DBOOST_ROOT=$BOOST_ROOT \
                -DTAU_ROOT=$TAUROOTDIR \
                -DPAPI_ROOT=$PAPI_PATH \
                -DHPX_WITH_APEX=On \
                -DAPEX_WITH_ACTIVEHARMONY=On \
                -DHPX_WITH_PARCELPORT_MPI=On \
                -DHPX_WITH_PAPI=On
            echo "done"
        fi
        echo "Building HPX for the Host (Debug version)..."
        make -j8 core
        make -j8 examples
        echo "Building HPX for the Host (Debug version)... done"
        mkdir -p $BASE_PATH/host/hpx/release
        cd $BASE_PATH/host/hpx/release
        if [ ! -f CMakeCache.txt ]
        then
            echo "Configuring HPX for the Host (Release version)..."
            cmake $BASE_PATH/source/hpx \
                -DCMAKE_BUILD_TYPE=RelWithDebInfo \
                -DCMAKE_CXX_FLAGS="-wd68 -DBOOST_FUSION_DONT_USE_PREPROCESSED_FILES" \
                -DCMAKE_CXX_COMPILER=icpc \
                -DMPI_C_COMPILER=icc \
                -DHWLOC_ROOT=$BASE_PATH/host/hwloc \
                -DTBBMALLOC_ROOT=/opt/intel/tbb \
                -DHPX_WITH_MALLOC=tbbmalloc \
                -DBOOST_ROOT=$BOOST_ROOT \
                -DTAU_ROOT=$TAUROOTDIR \
                -DPAPI_ROOT=$PAPI_PATH \
                -DHPX_WITH_APEX=On \
                -DAPEX_WITH_ACTIVEHARMONY=On \
                -DHPX_WITH_PARCELPORT_MPI=On \
                -DHPX_WITH_PAPI=On
            echo "done"
        fi
        echo "Building HPX for the Host (Release version)..."
        make -j8 core
        make -j8 examples
        echo "Building HPX for the Host (Release version)... done"
    else
        mkdir -p $BASE_PATH/build/
    fi
}

function create_modulefile()
{
}

mkdir -p $BASE_PATH

# Compile list of needed modules:
if [[ $HOST == "babbage" ]]
then
    cd $BASE_PATH
    install_hwloc
    MODULES_HOST="cmake intel impi gcc boost/host-1.57.0 tau/host-2.25 papi/host-5.3.0"
    MODULES_MIC="cmake intel impi gcc boost/mic-1.57.0 tau/mic-2.25 papi/mic-5.3.0"
    build_hpx
elif [[ $HOST == "edison" ]]
then
    MODULES=""
fi

