# syntax=docker/dockerfile:1

FROM golang:1.16-buster

# Required packages
RUN apt-get update && \
    apt-get install pkg-config -y && \
    apt-get install curl -y && \
    apt-get install git -y && \
    go get github.com/influxdata/pkg-config

# Clone repo 
RUN git clone https://github.com/influxdata/flux.git

RUN curl https://sh.rustup.rs -sSf | bash -s -- --default-toolchain "1.53" -y

WORKDIR ./flux

ENV PATH=/root/.cargo/bin:${PATH}

# Temporarily required to build Flux
RUN mkdir /root/.cache/snowflake && \
    curl -v http://ocsp.snowflakecomputing.com/ocsp_response_cache.json >> /root/.cache/snowflake/ocsp_response_cache.json

# Build Flux
RUN go build ./cmd/flux



ENTRYPOINT ["./flux", "repl"]