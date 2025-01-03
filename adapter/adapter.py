import json
import time
from paho.mqtt.client import Client, CallbackAPIVersion
from influxdb_client import InfluxDBClient, Point, WritePrecision

# Configuration
BROKER = "mqtt-broker"
PORT = 1883
TOPIC = "#"
INFLUXDB_URL = "http://influxdb:8086"
INFLUXDB_TOKEN = "my-token"
INFLUXDB_BUCKET = "iot_data"
INFLUXDB_ORG = "my-org"

def on_message(client, userdata, message):
    # TODO

# MQTT client setup
mqtt_client = Client(callback_api_version=CallbackAPIVersion.VERSION2)
mqtt_client.on_message = on_message
mqtt_client.connect(BROKER, PORT)
mqtt_client.subscribe(TOPIC)

print("Adapter is listening for messages...")
mqtt_client.loop_forever()
