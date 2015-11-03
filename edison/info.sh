VALID=false
if hostname | grep -q '^edison'
then
    VALID=true
fi

NAME="Edison"
