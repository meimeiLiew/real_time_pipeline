#!/bin/bash

# Kill existing Airflow processes
pkill -f "airflow webserver"
pkill -f "airflow scheduler"

# Wait for processes to terminate
sleep 2

# Start Airflow webserver in background
airflow webserver --port 8080 &

# Start Airflow scheduler in background
airflow scheduler &

echo "Airflow services restarted successfully"
