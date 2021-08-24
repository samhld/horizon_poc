influx_host = "${INFLUX_HOST}"
token = "${INFLUX_TOKEN}"
org = "${INFLUX_ORG}"

from(bucket: "mqtt", host: influx_host, token: token, org: org)
    |> range(start: -10m)
    |> mean()