#!/bin/bash

BROKER_HOST="localhost" 
BROKER_PORT=1883

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "UPB/RPi_1" \
  -m '{"BAT":99,"HUMID":40,"PRJ":"SCD","TMP":25.3,"status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "Dorinel/Zeus" \
  -m '{"Alarm":0,"RSSI":1500,"AQI":12,"status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "IoT/RandomRoom" \
  -m '{"TEMP":23.5,"HUMID":42,"SENSOR":"DHT11","status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "Sensors/Greenhouse" \
  -m '{"TEMPERATURE":30,"HUMIDITY":80,"CO2":550,"status":"WARN"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "Demo/DeviceA" \
  -m '{"BAT":45,"TMP":18.9,"Volt":3.7,"status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "Home/LivingRoom" \
  -m '{"Lights":1,"Temperature":22.1,"Presence":true,"status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "Office/SensorNode" \
  -m '{"HUMID":55,"VOC":33,"PM25":5,"status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "SmartFarm/Crops" \
  -m '{"soilMoisture":60,"NPK":"8-10-5","pH":6.4,"status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "City/Bucharest" \
  -m '{"Traffic":250,"AQI":45,"NoiseLevel":70,"status":"OK"}'

mosquitto_pub \
  -h "$BROKER_HOST" \
  -p "$BROKER_PORT" \
  -t "Demo/RandomSensors" \
  -m '{"value1":123,"value2":456,"value3":789,"status":"OK"}'

