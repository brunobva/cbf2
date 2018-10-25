#!/bin/bash

# Mapping ports
DEFAULT_PORTS=( "httpPort:8080"
                "httpsPort:8443"
                "ajp13Port:8009"
                "pgPort:5432"
                "debugPort:8044"
                "disPort:9001"
                "lumadaLocalPort:1337"
                "wsLocalPort:2337"
              )
      
NAMES=()
DEFAULTS=()
USED=()

PORTS=("${DEFAULT_PORTS[@]}" "${PROJ_PORTS[@]}")
        
n=-1        
for port in "${PORTS[@]}" ; do

    ((n++))
    
    portName=${port%%:*}
    portValue=${port#*:}

    # Check if the port is already been used
    #opened=$(lsof -i :$portValue)
    opened=$(netstat -na | grep -i -E "^tcp.*[\.|:]$portValue\s+")

    if [ "$portName" == "debugPort" ]
    then

        # If the port is used, look for the next one free
        while ! [ -z "$opened" ]; do

            ((portValue++))
            #opened=$(lsof -i :$portValue)
            opened=$(netstat -na | grep -i -E "^tcp.*[\.|:]$portValue\s+")

        done

        read $portName <<<$portValue

    else

        NAMES[$n]=$portName
        DEFAULTS[$n]=$portValue

        # If the port is used, look for the next one free
        while ! [ -z "$opened" ]; do

            ((portValue++))
            #opened=$(lsof -i :$portValue)
            opened=$(netstat -na | grep -i -E "^tcp.*[\.|:]$portValue\s+")

        done

        USED[$n]=$portValue

    fi
    
done

CBF2_BINDING_INTERFACE_OPT=""
if [ ! -z ${CBF2_BINDING_INTERFACE+x} ]
then
	CBF2_BINDING_INTERFACE_OPT="${CBF2_BINDING_INTERFACE}:"
fi


exposePorts=""
for index in ${!NAMES[*]}
do
    exposePorts+=" -p ${CBF2_BINDING_INTERFACE_OPT}${USED[$index]}:${DEFAULTS[$index]}"
done

#echo $exposePorts
#echo $debugPort
