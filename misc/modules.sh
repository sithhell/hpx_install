LOADED_MODULES_BAK=`echo $LOADEDMODULES | sed 's/:/ /g'`

function load_modules()
{
    module purge
    LOADED_MODULES=`echo $LOADEDMODULES | sed 's/:/ /g'`
    for module in $1
    do
        echo -n "Trying to load $module... "
        module_name=`echo $module | awk -F'/' '{print $1}'`
        module_version=`echo $module | awk -F'/' '{print $2}'`
        if echo $LOADED_MODULES | grep -vq "$module_name"
        then
            # module has not been loaded yet
            module load $module
            echo "done (loaded)"
        else
            if echo $LOADED_MODULES | grep -q "$module"
            then
                echo "done (already loaded)"
            else
                if [[ "$module_version" == "" ]]
                then
                    echo "done (already loaded, unversioned)"
                else
                    echo ""
                    echo "A module named $module_name is already loaded with a different version and will conflict"
                    module list
                    exit 1
                fi
            fi
        fi
    done
    module list
}

function create_modulefile()
{
    # first argument is name
    # second argument is version
    # third argument are the required modules
    # fourth argument is the root directory
    mkdir -p $BASE_PATH/modulefiles/$1
    cat << EOF > $BASE_PATH/modulefiles/$1/$2
#%Module1.0
##

## Required internal variables

set name HPX
set version 0.9.11
set root $4

# List conflicting modules here

conflict $1

## List prerequesite modules here

EOF
    for req in $3
    do
        echo "module load $req" >> $BASE_PATH/modulefiles/$1/$2
    done

    cat << EOF >> $BASE_PATH/modulefiles/$1/$2

## Required for SVN hook to generate SWDB entry

set fullname HPX
set externalurl https://github.com/STEllAR-GROUP/hpx
set nerscurl https://www.nersc.gov/users/computational-systems/testbeds/babbage/hpx-on-babbage-and-edison/
set maincategory libraries
set subcategory "programming"
set description "HPX - A general purpose C++ runtime system for parallel and distributed applications of any scale"

## Required for "module help ..."

proc ModulesHelp { } {
  global description nerscurl externalurl
  puts stderr "Description - \$description"
  puts stderr "NERSC Docs  - \$nerscurl"
  puts stderr "Other Docs  - \$externalurl"
}


## Required for "module display ..." and SWDB

module-whatis                   "\$description"

## Software-specific settings exported to user environment
setenv          HPX_ROOT          "\$root"
setenv          HPX_DIR           "\$root/lib/cmake/HPX"
prepend-path    CMAKE_PREFIX_PATH \$root
prepend-path    LD_LIBRARY_PATH   \$root/lib
prepend-path    PATH              \$root/bin

## Log "module load ..." commands

if [ module-info mode load ] {
    set usgsbin /global/common/shared/usg/sbin
    if [ expr [ file exists \$usgsbin/logmod ] ] {
        exec \$usgsbin/logmod \${name} \${version}
    }
}

EOF
}
