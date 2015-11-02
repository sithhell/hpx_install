echo $BASE_PATH

prepare_hwloc
prepare_jemalloc
prepare_boost

echo "Building dependencies for the XeonPhi"

CC=icc
CXX=icpc
CFLAGS="-mmic"
CXXFLAGS="-std=c++14 -mmic"
LDFLAGS="-mmic"
make_hwloc "babbage/hwloc/mic" --host=x86_64-k1om-linux
make_jemalloc "babbage/jemalloc/mic" --host=x86_64-k1om-linux
make_boost "babbage/boost/mic" toolset=intel

echo "Building dependencies for the Host"
CC=
CXX=
CFLAGS=
CXXFLAGS="-std=c++14"
LDFLAGS=
make_hwloc "babbage/hwloc/host"
make_jemalloc "babbage/jemalloc/mic"
make_boost "babbage/boost/host" toolset=intel
