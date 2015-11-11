VALID=false
if hostname | grep -q '^bint'
then
    VALID=true
fi
if hostname | grep -q '^bc'
then
    VALID=true
fi
NAME="Babbage"
