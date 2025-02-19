#!/bin/bash

# Kill Airflow webserver and scheduler processes
echo "Stopping Airflow services..."
pkill -f "airflow webserver"
pkill -f "airflow scheduler"

# Wait to ensure processes are terminated
sleep 2

# Verify no Airflow processes are running
if pgrep -f "airflow" > /dev/null; then
    echo "Warning: Some Airflow processes are still running"
    ps aux | grep "airflow"
else
    echo "Airflow services stopped successfully"
fi
