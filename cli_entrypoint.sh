#!/bin/bash -e
apt-get update
apt-get install jq -y

while ! curl -s -k http://influxd:8086/health; do sleep 1; done

influx setup --bucket mqtt -t ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} --org ${DOCKER_INFLUXDB_INIT_ORG} --username=${DOCKER_INFLUXDB_INIT_USERNAME} --password=${DOCKER_INFLUXDB_INIT_PASSWORD} --host=http://influxd:8086 -f --skip-verify


influx task create \
--host http://influxd:8086 \
   --org ${DOCKER_INFLUXDB_INIT_ORG} \
   --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
   -f /average_temp_5m.flux

influx task create \
--host http://influxd:8086 \
   --org ${DOCKER_INFLUXDB_INIT_ORG} \
   --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
   -f /broadcast.flux

export INFLUX_BUCKET_ID=$(curl --get http://influxd:8086/api/v2/buckets --header "Authorization: Token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}"  \
--header "Content-type: application/json" \
--data-urlencode "org=samhld" | jq .buckets | jq 'map(select(.name=="mqtt")) | .[].id' | tr -d '"')

influx v1 dbrp create \
   --bucket-id $INFLUX_BUCKET_ID \
   --org ${DOCKER_INFLUXDB_INIT_ORG} \
   --db "mqtt" \
   --rp "default" \
   --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
   --host http://influxd:8086


# n=0
# until [ "$n" -ge 25 ]
# do
   # influx setup --bucket mqtt -t ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} -o ${DOCKER_INFLUXDB_INIT_ORG} --username=${DOCKER_INFLUXDB_INIT_USERNAME} --password=${DOCKER_INFLUXDB_INIT_PASSWORD} --host=http://influxd:8086 -f --skip-verify && break  # substitute your command here
#    influx setup --bucket mqtt -t ${INFLUX_TOKEN} -org ${INFLUX_ORG} --username=${INFLUX_USERNAME} --password=${INFLUX_PASSWORD} --host=http://influxd:8086 -f --skip-verify && break
#    n=$((n+1)) 
# done