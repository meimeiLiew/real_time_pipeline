#!/bin/bash
set -e

# Create required directories
mkdir -p ./logs ./plugins ./dags

# Set Airflow UID and GID
echo -e "AIRFLOW_UID=$(id -u)\nAIRFLOW_GID=$(id -g)" > .env

# Start services
docker-compose down -v
docker-compose up -d
