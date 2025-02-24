#!/bin/bash

echo "Stopping Airflow services..."

# Kill existing Airflow processes
pkill -f "airflow webserver" || true
pkill -f "airflow scheduler" || true

# Wait for processes to terminate
sleep 5

# Set environment variables for non-interactive mode
export AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://airflow:airflow@localhost:5432/airflow"
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://airflow:airflow@localhost:5432/airflow"
export AIRFLOW_DB_UPGRADE=yes
export AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX=True
export FLASK_APP=airflow.www.app
export REDIS_HOST=localhost
export FLASK_LIMITER_STORAGE_URI="memory://"

# Check database
airflow db check

# Upgrade DB without prompting
yes | airflow db upgrade

# Start Airflow services with proper logging
echo "Starting Airflow services..."
airflow webserver --daemon --stdout /tmp/airflow-webserver.out --stderr /tmp/airflow-webserver.err
sleep 5
airflow scheduler --daemon --stdout /tmp/airflow-scheduler.out --stderr /tmp/airflow-scheduler.err

echo "Airflow services restarted successfully"
