import paho.mqtt.client as mqtt
import time
import datetime
import random
import string
import logging

logger = logging.getLogger(__name__)

letters = string.ascii_lowercase

def on_connect(client, userdata, flags, rc):
    print(f"CONNACK received with code: {rc}")
    print("SUBSCRIBING to Topic: 'things/temp/average'")
    client.subscribe("things/temp/average", qos=1)

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
    
broker = "host.docker.internal"
port = 1883
rand_string = ''.join(random.choice(letters) for i in range(3))
client_name = f"py_mqtt_{rand_string}"
client = mqtt.Client(client_name)
client.on_connect = on_connect
# client.on_log = on_log
client.on_publish = on_publish
client.on_disconnect = on_disconnect
client.on_subscribe = on_subscribe
client.on_message = on_message
client.connect(broker, port, keepalive=10)
client.loop_start()

try:
    loop = True
    while loop:
        try:
            temp = random.randint(0,100)
            timestamp = round(datetime.datetime.now().timestamp()*(10**9))
            point = f"temp value={temp} {timestamp}"
            (rc, mid) = client.publish(f"/things/{client_name}/temp", point, 2, retain=True)
            time.sleep(5)
        except:
            logger.error("error during publishing")
            loop = False
    
except Exception as e:
    logger.error(f"Error:{e}")
    client.disconnect()
    client.loop_stop()


