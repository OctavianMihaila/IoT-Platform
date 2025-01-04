import json
import time
import os
from datetime import datetime
from paho.mqtt.client import Client, CallbackAPIVersion
from influxdb_client import InfluxDBClient, Point, WritePrecision

BROKER = "mqtt-broker"
PORT = 1883
TOPIC = "#"
INFLUXDB_URL = "http://influxdb:8086"
INFLUXDB_TOKEN = ""
INFLUXDB_BUCKET = "iot_data"
INFLUXDB_ORG = "my-org"

DEBUG_MODE = os.getenv("DEBUG_DATA_FLOW", "false").lower() == "true"

def debug_log(msg: str):
    if DEBUG_MODE:
        now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"{now_str} {msg}", flush=True)

def on_message(client, userdata, message):
    topic = message.topic
    payload = message.payload.decode()

    debug_log(f"Received a message by topic [{topic}]")

    try:
        data = json.loads(payload)
        # If the JSON has 'timestamp', it is used, otherwise the current time is employed
        if 'timestamp' in data:
            if isinstance(data['timestamp'], (int, float)):
                # It's numeric => convert to datetime
                ts_float = data['timestamp']
                debug_log(f"Data timestamp is numeric => {ts_float}")
                timestamp_dt = datetime.utcfromtimestamp(ts_float)
            else: # It's a string => attempt to parse or fallback to now
                debug_log("Data timestamp is a string => parse it or fallback to now")
                try:
                    timestamp_dt = datetime.fromisoformat(data['timestamp'])
                except ValueError:
                    debug_log("Could not parse string timestamp, falling back to now")
                    timestamp_dt = datetime.utcnow()
        else:
            debug_log("Data timestamp is : NOW")
            timestamp_dt = datetime.utcnow()

        series_prefix = topic.replace("/", ".")
        points = []

        for key, value in data.items():
            if isinstance(value, (int, float)):
                point = Point(series_prefix) \
                    .field(key, value) \
                    .time(timestamp_dt, WritePrecision.NS) # Max time precision
                points.append(point)
                debug_log(f"{series_prefix}.{key} => {value}")

        if points: # Push data to InfluxDB
            with InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG) as influx_client:
                write_api = influx_client.write_api()
                write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=points)
                debug_log(f"Data written to InfluxDB: {points}")

    except json.JSONDecodeError:
        print(f"Invalid JSON payload: {payload}", flush=True)
    except Exception as e:
        print(f"Error processing message: {e}", flush=True)

mqtt_client = Client(callback_api_version=CallbackAPIVersion.VERSION2)
mqtt_client.on_message = on_message
mqtt_client.connect(BROKER, PORT)
mqtt_client.subscribe(TOPIC)

print("Adapter is listening for messages...", flush=True)
mqtt_client.loop_forever()
