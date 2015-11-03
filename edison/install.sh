
prepare_hwloc
prepare_jemalloc
prepare_lua
prepare_ah
prepare_boost
prepare_hpx
prepare_hpxlua

MODULES="cmake/3.0.0 PrgEnv-intel cray-mpich gcc papi tau/2.24.2"

echo "Building dependencies for the Compute Nodes"

MODULEPATH_BAK=$MODULEPATH
MODULEPATH=/project/projectdirs/xpress/tau2-hpx-edison/modulefiles:$MODULEPATH

CC=gcc
CXX=g++
CFLAGS=
CXXFLAGS="-std=c++14"
LDFLAGS=""

load_modules "${MODULES}"
make_hwloc "edison/hwloc"
make_jemalloc "edison/jemalloc"
make_lua "edison/lua"
make_ah "edison/activeharmony"
CC=
CXX=
CFLAGS=
CXXFLAGS="-std=c++14"
LDFLAGS=""
make_boost "edison/boost" toolset=intel

echo ""
echo "Building HPX Debug version for the Compute Nodes"
BUILD_TYPE=Debug
PREFIX="edison"
TOOLCHAIN_FILE=Cray-Intel.cmake
hpx_cmake
hpxlua_cmake

echo ""
echo "Building HPX Release version for the Compute Nodes"
BUILD_TYPE=Release
PREFIX="edison"
TOOLCHAIN_FILE=Cray-Intel.cmake
hpx_cmake
hpxlua_cmake

create_modulefile hpx 0.9.11-debug "${MODULES}" $BASE_PATH/packages/edison/hpx/Debug
create_modulefile hpx 0.9.11-release "${MODULES}" $BASE_PATH/packages/edison/hpx/Release

MODULEPATH=$MODULEPATH_BAK
