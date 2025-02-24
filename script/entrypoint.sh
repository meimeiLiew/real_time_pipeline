#!/bin/bash
set -e

if [ -e "/opt/airflow/requirements.txt" ]; then
    $(command -v pip) install --upgrade pip
    $(command -v pip) install --user -r requirements.txt
fi

# Initialize Airflow db
airflow db init

# Create default admin user if not exists
airflow users create \
    --username ${AIRFLOW_USERNAME:-meimei} \
    --firstname ${AIRFLOW_FIRSTNAME:-meimei} \
    --lastname ${AIRFLOW_LASTNAME:-liew} \
    --role Admin \
    --email ${AIRFLOW_EMAIL:-meimeiliew95@gmail.com} \
    --password ${AIRFLOW_PASSWORD:-meimeiliew} \
    || true

# Upgrade the database
airflow db upgrade

exec airflow webserver