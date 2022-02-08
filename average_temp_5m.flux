import "experimental/mqtt"
import "experimental"

option v = {
    timeRangeStart: -5m,
    timeRangeStop: now()
}

option task = {
    name: "temp_avg_5m",
    every: 1m,
}
topic = "things/temp/average"
broker = "broker:1883"

from(bucket: "mqtt")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "temp")
  |> mean()
  |> group()
  |> mean()
  |> experimental.set(o: {_time: now()})
  |> mqtt.to(broker: broker, topic: topic, name: "temp", clientid: "flux", timeColumn: "_time", valueColumns: ["_value"])