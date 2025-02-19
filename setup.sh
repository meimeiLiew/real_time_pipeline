#!/bin/bash

# Remove existing environment and files
rm -rf venv
rm -rf ~/airflow
conda deactivate 2>/dev/null || true

# Create fresh Python virtual environment
python3.9 -m venv venv
source venv/bin/activate

# Install base packages
pip install --upgrade pip setuptools wheel

# Clear pip cache
pip cache purge

# Install critical dependencies in specific order
pip install "numpy==1.23.5"
pip install "pandas==1.5.3"
pip install "pendulum==2.1.2"
pip install "connexion[swagger-ui]==2.14.2"
pip install "openapi-spec-validator<0.6.0"
pip install "apache-airflow==2.6.3" \
    "psycopg2-binary==2.9.9" \
    "SQLAlchemy==1.4.50" \
    "Flask-Session==0.5.0" \
    "werkzeug<2.3.0"

# Install remaining requirements
pip install -r requirements.txt

# Set environment variables
export AIRFLOW_HOME=~/airflow
mkdir -p $AIRFLOW_HOME/logs
mkdir -p $AIRFLOW_HOME/plugins

# Restart PostgreSQL to ensure clean state
brew services restart postgresql@14

# Wait for PostgreSQL to start
sleep 5

# Create postgres role if it doesn't exist
createuser -s postgres || true

# Create database and user
PGPASSWORD=postgres createuser -U postgres airflow -s || true
PGPASSWORD=postgres createdb -U postgres -O airflow airflow || true
PGPASSWORD=postgres psql -U postgres -d airflow -c "ALTER USER airflow WITH PASSWORD 'airflow';"

# Initialize Airflow DB
source venv/bin/activate
export AIRFLOW_HOME=~/airflow

# Reset the database and initialize from scratch
airflow db reset -y
airflow db init

# Generate Fernet key for Airflow
FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")

# Update Airflow config with Fernet key
cat >> $AIRFLOW_HOME/airflow.cfg << EOL

[core]
fernet_key = ${FERNET_KEY}
EOL

# Install Airflow with extra providers
pip install "apache-airflow[cncf.kubernetes,virtualenv]==2.6.3"

# Create admin user
airflow users create \
    --username meimei \
    --firstname meimei \
    --lastname liew \
    --role Admin \
    --email meimeiliew95@gmail.com \
    --password meimeiliew

# Add environment variables to shell config
echo 'export AIRFLOW_HOME=~/airflow' >> ~/.zshrc
echo 'export PATH=$PATH:$HOME/venv/bin' >> ~/.zshrc
