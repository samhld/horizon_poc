import paho.mqtt.client as mqtt
import time
import datetime
import random
import logging
import json
import argparse
import os
import sys

logger = logging.getLogger(__name__)

# letters = string.ascii_lowercase

parser = argparse.ArgumentParser(description="Configure client")
parser.add_argument("--interval", type=float, default=5, help="Number of seconds between PUBs (float) -- accepts sub-second")
parser.add_argument("--format", type=str, default="value", help="Can be any of: 'value', 'json-value', 'json', 'lp'")
parser.add_argument("--broker", type=str, default="host.docker.internal", help="Address of broker w/out port")
parser.add_argument("--port", type=int, default=1883)
parser.add_argument("--user", type=str, default="telegraf")
parser.add_argument("--pwd", type=str, default=None)
args = parser.parse_args()

interval = args.interval
format = args.format
broker = args.broker

def on_connect(client, userdata, flags, rc):
    print(f"CONNACK received with code: {rc}")
    print("SUBSCRIBING to Topic: 'things/temp/average'")
    client.subscribe("things/temp/average", qos=1)
    client.subscribe(f"processed/{client_name}/average")

def on_disconnect(client, userdata, rc):
    print(f"DISCONNECT code: {rc}")

def on_publish(client, userdata, mid):
    print(f"PUBLISH mid: {mid}")

def on_log(client, userdata, level, buf):
    print(f"{buf} retain={client._will_retain}")

def on_subscribe(client, userdata, mid, granted_qos):
    print(f"SUBSCRIBE: mid: {mid} granted qos: {granted_qos}")

def on_message(client, userdata, msg):
    print(f"Incoming message:\n\tTopic: {msg.topic}\n\tPayload: {msg.payload.decode('utf-8')}")
    
broker = broker
# broker = "localhost"
port = 1883
# rand_string = ''.join(random.choice(letters) for i in range(3))

client_name = f"py_mqtt_{os.uname().nodename}"
client = mqtt.Client(client_name)
if port == 8883:
    user = args.user
    pwd = args.pwd
    client.username_pw_set(user, pwd)
client.on_connect = on_connect
client.on_publish = on_publish
client.on_disconnect = on_disconnect
client.on_subscribe = on_subscribe
client.on_message = on_message
client.connect(broker, port, keepalive=10)
client.loop_start()

steps = list(range(-5,5))
temp = random.randint(0,100)

try:
    loop = True
    while loop:
        try:
            temp += random.choice(steps)
            if temp < 0:
                temp += 5
            timestamp = round(datetime.datetime.now().timestamp()*(10**9))
            if format == "value":
                point = temp
                topic = f"things/{client_name}/temp"
                print(f"Publishing to topic: {topic}\n\tPayload: {point}")
                sys.stdout.flush()
                (rc, mid) = client.publish(topic, point, 2, retain=True)
            if format == "json-value":
                point = json.dumps({"value": temp})
                topic = f"json-value/things/{client_name}/temp"
                print(f"Publishing to topic: {topic}\n\tPayload: {point}")
                sys.stdout.flush()
                (rc, mid) = client.publish(topic, point, 2, retain=True)
            if format == "json":
                di = {"device_id": client_name,
                       "group": "things",
                       "temp": temp}
                point = json.dumps(di)
                topic = "json/data"
                print(f"Publishing to topic: {topic}\n\tPayload: {point}")
                sys.stdout.flush()
                (rc, mid) = client.publish(topic, point, 2, retain=True)
            if format == "lp":
                point = f"temp value={temp}"
                topic = f"lp/things/{client_name}/temp"
                print(f"Publishing to topic: {topic}\n\tPayload: {point}")
                sys.stdout.flush()
                (rc, mid) = client.publish(topic, point, 2, retain=True)
            time.sleep(interval)
        except:
            logger.error("error during publishing")
            loop = False
    
except Exception as e:
    logger.error(f"Error:{e}")
    client.disconnect()
    client.loop_stop()


