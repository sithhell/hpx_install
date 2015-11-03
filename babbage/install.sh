
prepare_hwloc
prepare_jemalloc
prepare_lua
prepare_ah
prepare_boost
prepare_hpx

MODULES_HOST="cmake intel impi gcc papi/host-5.3.0 tau/2.24.2"
MODULES_MIC="cmake intel impi gcc papi/mic-5.3.0 tau/2.24.2"

echo "Building dependencies for the XeonPhi"

MODULEPATH_BAK=$MODULEPATH
MODULEPATH=/project/projectdirs/xpress/tau2-hpx/modulefiles:$MODULEPATH

load_modules "${MODULES_MIC}"
CC=icc
CXX=icpc
CFLAGS="-mmic"
CXXFLAGS="-std=c++14 -mmic -DBOOST_NO_CXX11_ALLOCATOR"
LDFLAGS="-mmic"
make_hwloc "babbage/mic/hwloc" --host=x86_64-k1om-linux
make_jemalloc "babbage/mic/jemalloc" --host=x86_64-k1om-linux
make_lua "babbage/mic/lua"
make_ah "babbage/mic/activeharmony"
make_boost "babbage/mic/boost" toolset=intel

echo ""
echo "Building HPX Debug version for the XeonPhi"
BUILD_TYPE=Debug
PREFIX="babbage/mic"
TOOLCHAIN_FILE=XeonPhi.cmake
MPI_CXX_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicxx
MPI_C_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicc
CXXFLAGS="-std=c++14 -mmic"
hpx_cmake

echo ""
echo "Building HPX Release version for the XeonPhi"
BUILD_TYPE=Release
PREFIX="babbage/mic"
TOOLCHAIN_FILE=XeonPhi.cmake
MPI_CXX_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicxx
MPI_C_COMPILER=/opt/intel/impi/5.1.1.109/mic/bin/mpicc
CXXFLAGS="-std=c++14 -mmic"
hpx_cmake


echo ""
echo "Building dependencies for the Host"

load_modules "${MODULES_HOST}"
CC=icc
CXX=icpc
CFLAGS=
CXXFLAGS="-std=c++14"
LDFLAGS=""
make_hwloc "babbage/host/hwloc"
make_jemalloc "babbage/host/jemalloc"
make_lua "babbage/host/lua"
make_ah "babbage/host/activeharmony"
make_boost "babbage/host/boost" toolset=intel

TOOLCHAIN_FILE=
MPI_CXX_COMPILER=
MPI_C_COMPILER=

echo ""
echo "Building HPX Debug version for the Host"
BUILD_TYPE=Debug
PREFIX="babbage/host"
hpx_cmake

echo ""
echo "Building HPX Release version for the Host"
BUILD_TYPE=Release
PREFIX="babbage/host"
hpx_cmake

MODULES="cmake intel impi gcc papi/mic-5.3.0 tau/2.24.2"
create_modulefile hpx mic-0.9.11-debug "${MODULES}" $BASE_PATH/packages/babbage/mic/hpx/Debug
create_modulefile hpx mic-0.9.11-release "${MODULES}" $BASE_PATH/packages/babbage/mic/hpx/Release
MODULES="cmake intel impi gcc papi/host-5.3.0 tau/2.24.2"
create_modulefile hpx host-0.9.11-debug "${MODULES}" $BASE_PATH/packages/babbage/host/hpx/Debug
create_modulefile hpx host-0.9.11-release "${MODULES}" $BASE_PATH/packages/babbage/host/hpx/Release

MODULEPATH=$MODULEPATH_BAK
