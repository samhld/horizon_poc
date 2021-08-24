# syntax=docker/dockerfile:1

FROM golang:1.16-buster

RUN apt-get update && \
    git clone https://github.com/influxdata/influx-cli.git

WORKDIR influx-cli

RUN make

RUN apt-get update && \
    apt-get install jq -y

ENV PATH="/go/influx-cli/bin/linux:$PATH"

# ENTRYPOINT ["./bin/linux/influx"]
