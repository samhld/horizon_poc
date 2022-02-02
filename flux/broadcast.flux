import "experimental"
import "experimental/mqtt"
import "strings"

token = "q28ryE1LQecAf9NoXRj0o-ydkS9ppp0flSOdEpjmn_R-wfCrg-DjUUs-iB4Q23c7-03w863ddhNnphnL8rnLew=="
// topic = "things/temp/average"
broker = "broker:1883"

genTopic = (source_name) =>
  strings.joinStr(arr: ["processed", source_name, "average"], v: "/")

from(bucket: "mqtt", host: "http://influxd:8086", token: token, org: "samhld")
  |> range(start: -5m)
  |> filter(fn: (r) => r["_measurement"] == "temp")
  |> mean()
  |> experimental.set(o: {_time: now()})
  |> group()
  |> map(fn: (r) => { 
                      topic = genTopic(source_name: r.device_id)
                      send = if mqtt.publish(broker: broker, topic: topic, message: string(v: r._value))
                             then topic
                             else "Failed"
  
                      return { r with sent: send }
  })