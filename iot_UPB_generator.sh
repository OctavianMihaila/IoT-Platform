#!/bin/bash

BROKER_HOST="localhost"
BROKER_PORT=1883
TOPIC="UPB/RPi_1"

# Function to simulate continuous message generation
generate_data() {
  echo "Generating data for topic: $TOPIC"

  local iterations=${1:-100}
  local interval=${2:-1}

  for ((i = 1; i <= iterations; i++)); do
    local bat=$((RANDOM % 20 + 80))        # Random BAT value between 80 and 100
    local humid=$((RANDOM % 20 + 30))      # Random HUMID value between 30 and 50
    local tmp=$(awk -v min=20 -v max=30 'BEGIN{srand(); print min+rand()*(max-min)}')  # Random TMP value between 20.0 and 30.0

    mosquitto_pub \
      -h "$BROKER_HOST" \
      -p "$BROKER_PORT" \
      -t "$TOPIC" \
      -m "{\"BAT\":$bat,\"HUMID\":$humid,\"TMP\":$tmp,\"status\":\"OK\"}"

    echo "Published message $i/$iterations: {\"BAT\":$bat,\"HUMID\":$humid,\"TMP\":$tmp,\"status\":\"OK\"}"

    sleep "$interval"
  done

  echo "Finished generating $iterations messages for topic: $TOPIC"
}

if [[ "$1" == "run" ]]; then
  generate_data "${2:-100}" "${3:-1}"
  exit 0
fi

if [[ "$1" == "show" ]]; then
  echo "Fetching data from InfluxDB..."

  docker exec $(docker ps -q -f name=scd3_influxdb) influx -database iot_data -execute "SHOW MEASUREMENTS" -format csv | tail -n +2 | cut -d, -f2 | while read measurement; do \
    echo "Querying measurement: $measurement"; \
    docker exec $(docker ps -q -f name=scd3_influxdb) influx -database iot_data -execute "SELECT * FROM \"$measurement\" LIMIT 10"; \
  done

  exit 0
fi

# Invalid usage
echo "Usage: $0 {run <iterations> <interval>|show}"
exit 1

