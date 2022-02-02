#!/bin/bash

docker build ./client -t python-mqtt-client

number=5
interval=1
format=value
broker=host.docker.internal
port=1883

while getopts ":n:i:f:" opt; do
    case ${opt} in 
        n ) number=$OPTARG
        ;;
        i ) interval=$OPTARG
        ;;
        f ) format=$OPTARG
        ;;
        b ) broker=$OPTARG
        ;;
        p ) port=$OPTARG
        ;;
    esac
done

echo ${number}
echo ${interval}

for ((i=0; i<number; i++)); do
    docker run -d --rm --network mqtt-demo_default --name py-mqtt-client${i} python-mqtt-client /mqtt_client.py --interval ${interval} --format ${format} --broker ${broker}
done