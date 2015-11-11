VALID=false
if hostname | grep -q '^edison'
then
    VALID=true
fi
if hostname | grep -q '^nid'
then
    VALID=true
fi

NAME="Edison"
