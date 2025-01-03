import json
import time
import os
from paho.mqtt.client import Client, CallbackAPIVersion
from influxdb_client import InfluxDBClient, Point, WritePrecision
from datetime import datetime

# Configuration
BROKER = "mqtt-broker"
PORT = 1883
TOPIC = "#"
INFLUXDB_URL = "http://influxdb:8086"
INFLUXDB_TOKEN = "my-token"
INFLUXDB_BUCKET = "iot_data"
INFLUXDB_ORG = "my-org"

# Check if debug mode is enabled
DEBUG_MODE = os.getenv("DEBUG_DATA_FLOW", "false").lower() == "true"

def debug_log(msg: str):
    """
    Print a debug message only if DEBUG_MODE is True.
    Include a timestamp in a similar format to the example.
    """
    if DEBUG_MODE:
        # current local time
        time_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"{time_str} {msg}", flush=True)

def on_message(client, userdata, message):
    topic = message.topic
    payload = message.payload.decode()

    # Debug: we got a new message
    debug_log(f"Received a message by topic [{topic}]")

    try:
        # Parse JSON payload
        data = json.loads(payload)

        # If the JSON has a "timestamp", use it; otherwise, we treat it as "NOW"
        if "timestamp" in data:
            # This is the data's own timestamp
            timestamp = data["timestamp"]
            debug_log(f"Data timestamp is : {timestamp}")
        else:
            # We'll use the current time
            timestamp = time.time()
            debug_log(f"Data timestamp is : NOW")

        # Prepare InfluxDB entries
        series_prefix = topic.replace("/", ".")
        points = []
        for key, value in data.items():
            if isinstance(value, (int, float)):
                point = Point(series_prefix).field(key, value).time(timestamp, WritePrecision.NS)
                points.append(point)
                # Debug: show each measurement
                debug_log(f"{series_prefix}.{key} => {value}")

        # Write to InfluxDB
        if points:
            with InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG) as influx_client:
                write_api = influx_client.write_api()
                write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=points)
                debug_log(f"Data written to InfluxDB: {points}")
    except json.JSONDecodeError:
        print(f"Invalid JSON payload: {payload}", flush=True)
    except Exception as e:
        print(f"Error processing message: {e}", flush=True)

# MQTT client setup
mqtt_client = Client(callback_api_version=CallbackAPIVersion.VERSION2)
mqtt_client.on_message = on_message
mqtt_client.connect(BROKER, PORT)
mqtt_client.subscribe(TOPIC)

print("Adapter is listening for messages...", flush=True)
mqtt_client.loop_forever()
