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
