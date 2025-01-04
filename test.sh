#!/bin/bash

BROKER_HOST="localhost" 
BROKER_PORT=1883

if [[ "$1" == "show" ]]; then
  echo "Fetching data from InfluxDB..."

  docker exec $(docker ps -q -f name=scd3_influxdb) influx -database iot_data -execute "SHOW MEASUREMENTS" -format csv | tail -n +2 | cut -d, -f2 | while read measurement; do \
    echo "Querying measurement: $measurement"; \
    docker exec $(docker ps -q -f name=scd3_influxdb) influx -database iot_data -execute "SELECT * FROM \"$measurement\" LIMIT 10"; \
  done

  exit 0
fi

if [[ "$1" == "run" ]]; then
    echo "Publishing test messages to MQTT broker..."

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "UPB/RPi_1" \
    -m '{"BAT":99,"HUMID":40,"PRJ":"SCD","TMP":25.3,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "UPB/RPi_1" \
    -m '{"BAT":85,"HUMID":55,"TMP":28.1,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Dorinel/Zeus" \
    -m '{"Alarm":0,"RSSI":1500,"AQI":12,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Dorinel/Zeus" \
    -m '{"Alarm":1,"RSSI":1200,"AQI":15,"status":"WARN"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "IoT/RandomRoom" \
    -m '{"TEMP":23.5,"HUMID":42,"SENSOR":"DHT11","status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "IoT/RandomRoom" \
    -m '{"TEMP":24.1,"HUMID":38,"SENSOR":"DHT11","status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "IoT/RandomRoom" \
    -m '{"TEMP":22.9,"HUMID":45,"SENSOR":"DHT11","status":"WARN"}'

    # Topic 4: Sensors/Greenhouse
    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Sensors/Greenhouse" \
    -m '{"TEMPERATURE":30,"HUMIDITY":80,"CO2":550,"status":"WARN"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Sensors/Greenhouse" \
    -m '{"TEMPERATURE":32,"HUMIDITY":85,"CO2":560,"status":"CRITICAL"}'

    # Topic 5: SmartFarm/Crops
    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "SmartFarm/Crops" \
    -m '{"soilMoisture":60,"NPK":"8-10-5","pH":6.4,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "SmartFarm/Crops" \
    -m '{"soilMoisture":55,"NPK":"10-15-5","pH":6.2,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "SmartFarm/Crops" \
    -m '{"soilMoisture":65,"NPK":"8-10-5","pH":6.6,"status":"OK"}'

    # Topic 6: Home/LivingRoom
    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Home/LivingRoom" \
    -m '{"Lights":1,"Temperature":22.1,"Presence":true,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Home/LivingRoom" \
    -m '{"Lights":0,"Temperature":21.5,"Presence":false,"status":"OK"}'

    # Topic 7: Demo/DeviceA
    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Demo/DeviceA" \
    -m '{"BAT":45,"TMP":18.9,"Volt":3.7,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Demo/DeviceA" \
    -m '{"BAT":40,"TMP":19.5,"Volt":3.8,"status":"OK"}'

    # Topic 8: City/Bucharest
    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "City/Bucharest" \
    -m '{"Traffic":250,"AQI":45,"NoiseLevel":70,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "City/Bucharest" \
    -m '{"Traffic":300,"AQI":50,"NoiseLevel":75,"status":"WARN"}'

    # Topic 9: Office/SensorNode
    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Office/SensorNode" \
    -m '{"HUMID":55,"VOC":33,"PM25":5,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Office/SensorNode" \
    -m '{"HUMID":50,"VOC":35,"PM25":7,"status":"OK"}'

    # Topic 10: New Topic: Lab/Sensors
    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Lab/Sensors" \
    -m '{"Temperature":22.5,"Pressure":1012,"Humidity":55,"status":"OK"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Lab/Sensors" \
    -m '{"Temperature":23.0,"Pressure":1015,"Humidity":58,"status":"WARN"}'

    mosquitto_pub \
    -h "$BROKER_HOST" \
    -p "$BROKER_PORT" \
    -t "Lab/Sensors" \
    -m '{"Temperature":24.1,"Pressure":1010,"Humidity":60,"status":"CRITICAL"}'
    exit 0
fi

# Invalid usage
echo "Usage: $0 {show|run}"
exit 1
