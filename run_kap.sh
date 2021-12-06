KAPA_TOKEN=`influx2 auth create \
   --org ${INFLUX_ORG} \
   --all-access \
   --json | jq .token`


docker run \
    -v /Users/samdillard/go/src/horizon/kapacitor/kapacitor.conf:/etc/kapacitor/kapacitor.conf \
    -e DOCKER_INFLUXDB_INIT_ORG=${INFLUX_ORG} \
    -e DOCKER_INFLUXDB_INIT_USERNAME=${INFLUX_USERNAME} \
    -e DOCKER_INFLUXDB_INIT_PASSWORD=${INFLUX_PASSWORD} \
    -e KAPA_TOKEN=${KAPA_TOKEN} \
    --network horizon_default \
    --name kapacitor \
    --rm \
    -d \
    kapacitor