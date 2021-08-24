# syntax=docker/dockerfile:1

FROM python:3.8-slim-buster

# COPY . .

ADD requirements.txt /
ADD mqtt_client.py /

RUN pip3 install -r requirements.txt

# CMD ["python3", "./mqtt_client.py"]
CMD ["/mqtt_client.py"]

ENTRYPOINT ["/usr/local/bin/python3"]