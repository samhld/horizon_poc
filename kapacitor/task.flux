influx_host = "${INFLUX_HOST}"
token = "${INFLUX_TOKEN}"
org = "${INFLUX_ORG}"

option task = {
  name: "kapa-flux-task",
  every: 10m
}

from(bucket: "mqtt", host: influx_host, token: token, org: org)
    |> range(start: task.every)
    |> mean()