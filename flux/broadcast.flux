import "experimental"
import "experimental/mqtt"
import "strings"

option v = {
    timeRangeStart: -1m,
    timeRangeStop: now()
}

option task = {
    name: "broadcast_1m",
    every: 1m,
}

token = "q28ryE1LQecAf9NoXRj0o-ydkS9ppp0flSOdEpjmn_R-wfCrg-DjUUs-iB4Q23c7-03w863ddhNnphnL8rnLew=="
broker = "broker:1883"

getHost = (topic) => {
    split = strings.split(v: topic, t: "/")
    return split[2]
}

genTopic = (source_name) =>
  strings.joinStr(arr: ["processed", source_name, "average"], v: "/")

from(bucket: "mqtt", host: "http://influxd:8086", token: token, org: "samhld")
  |> range(start: v.timeRangeStart)
  |> filter(fn: (r) => r["_measurement"] == "temp")
  |> mean()
  |> experimental.set(o: {_time: now()})
  |> group()
  |> map(fn: (r) => { 
                      topic = genTopic(source_name: getHost(topic: r.topic))
                      send = if mqtt.publish(broker: broker, topic: topic, message: string(v: r._value))
                             then topic
                             else "Failed"
  
                      return { r with sent: send }
  })