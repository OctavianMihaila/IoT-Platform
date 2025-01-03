#!/bin/bash
echo "Creating database 'iot_data' in InfluxDB..."
influx -host localhost -port 8086 -execute "CREATE DATABASE iot_data"
echo "Database 'iot_data' created."
