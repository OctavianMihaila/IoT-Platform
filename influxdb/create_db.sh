#!/bin/bash

echo "Creating database 'iot_data' with unlimited retention..."
influx -host localhost -port 8086 -execute "CREATE DATABASE iot_data WITH DURATION INF"
echo "Database 'iot_data' created with unlimited retention."
