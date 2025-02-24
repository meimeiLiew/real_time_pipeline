#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    cat > .env << EOL
AIRFLOW_UID=50000
AIRFLOW_GID=0
AIRFLOW_USERNAME=meimei
AIRFLOW_PASSWORD=meimeiliew
AIRFLOW_EMAIL=meimeiliew95@gmail.com
AIRFLOW_FIRSTNAME=meimei
AIRFLOW_LASTNAME=liew
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow
AIRFLOW__WEBSERVER__SECRET_KEY=$(openssl rand -hex 32)
EOL
fi

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

# Initialize DB without prompts
export AIRFLOW_DB_UPGRADE=yes
export AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False

# Reset and initialize database
airflow db reset --yes
airflow db init
airflow db upgrade

# Remove any existing Airflow config
rm -f $AIRFLOW_HOME/airflow.cfg

# Generate fresh config file
airflow config list > /dev/null 2>&1

# Generate Fernet key for Airflow
FERNET_KEY=$(python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")

# Update Airflow config with custom settings
cat > $AIRFLOW_HOME/airflow.cfg << EOL
[core]
dags_folder = ${AIRFLOW_HOME}/dags
load_examples = False
executor = LocalExecutor
fernet_key = ${FERNET_KEY}
dags_are_paused_at_creation = False
load_default_connections = False

[database]
sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@localhost:5432/airflow
sql_engine_encoding = utf-8
sql_alchemy_pool_enabled = True
sql_alchemy_pool_size = 5
sql_alchemy_pool_recycle = 1800

[webserver]
web_server_host = 0.0.0.0
web_server_port = 8080
rbac = True
authenticate = True
auth_backend = airflow.api.auth.backend.basic_auth
flask_limiter_storage_uri = memory://
rate_limit = 100/minute

[scheduler]
min_file_process_interval = 30
dag_file_processor_timeout = 600

[logging]
base_log_folder = ${AIRFLOW_HOME}/logs
logging_level = INFO
fab_logging_level = WARN

[api]
auth_backends = airflow.api.auth.backend.basic_auth,airflow.api.auth.backend.session

[limiter]
enabled = true
storage_uri = memory://
strategy = fixed-window
EOL

# Ensure correct permissions
chmod 644 $AIRFLOW_HOME/airflow.cfg

# Verify config file
airflow config test

# Initialize Airflow DB again after config changes
airflow db init

# Create DAGs directory after config is set
mkdir -p $AIRFLOW_HOME/dags
cp -r dags/* $AIRFLOW_HOME/dags/ 2>/dev/null || true

# Ensure correct permissions
chmod 644 $AIRFLOW_HOME/airflow.cfg

# Ensure correct Python environment
deactivate 2>/dev/null || true
source venv/bin/activate

# Clean install of core dependencies
pip uninstall -y sqlalchemy alembic
pip install "SQLAlchemy==1.4.50" "alembic<2.0.0"
pip install "apache-airflow[cncf.kubernetes,virtualenv,postgres]==2.6.3"

# Install Airflow with extra providers
pip install "apache-airflow[cncf.kubernetes,virtualenv]==2.6.3"

# Create admin user (after DB is properly initialized)
yes | airflow users create \
    --username meimei \
    --firstname meimei \
    --lastname liew \
    --role Admin \
    --email meimeiliew95@gmail.com \
    --password meimeiliew

# Add environment variables to shell config
echo 'export AIRFLOW_HOME=~/airflow' >> ~/.zshrc
echo 'export PATH=$PATH:$HOME/venv/bin' >> ~/.zshrc

# Database initialization section
export AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://airflow:airflow@localhost:5432/airflow"
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="postgresql+psycopg2://airflow:airflow@localhost:5432/airflow"

# Drop and recreate database
PGPASSWORD=postgres psql -U postgres -c "DROP DATABASE IF EXISTS airflow;"
PGPASSWORD=postgres psql -U postgres -c "CREATE DATABASE airflow;"
PGPASSWORD=postgres psql -U postgres -c "DROP USER IF EXISTS ${POSTGRES_USER};"
PGPASSWORD=postgres psql -U postgres -c "CREATE USER ${POSTGRES_USER} WITH PASSWORD '${POSTGRES_PASSWORD}';"
PGPASSWORD=postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE airflow TO ${POSTGRES_USER};"

# Clear any existing Airflow files
rm -rf $AIRFLOW_HOME/*
mkdir -p $AIRFLOW_HOME/logs
mkdir -p $AIRFLOW_HOME/plugins
mkdir -p $AIRFLOW_HOME/dags

# Initialize fresh database
airflow db init

# Generate fresh config
airflow config list > /dev/null 2>&1

# Update config file with custom settings
cat > $AIRFLOW_HOME/airflow.cfg << EOL
[core]
dags_folder = ${AIRFLOW_HOME}/dags
load_examples = False
executor = LocalExecutor
fernet_key = ${FERNET_KEY}
dags_are_paused_at_creation = False
load_default_connections = False

[database]
sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@localhost:5432/airflow
sql_engine_encoding = utf-8
sql_alchemy_pool_enabled = True
sql_alchemy_pool_size = 5
sql_alchemy_pool_recycle = 1800

[webserver]
web_server_host = 0.0.0.0
web_server_port = 8080
rbac = True
authenticate = True
auth_backend = airflow.api.auth.backend.basic_auth
flask_limiter_storage_uri = memory://
rate_limit = 100/minute

[scheduler]
min_file_process_interval = 30
dag_file_processor_timeout = 600

[logging]
base_log_folder = ${AIRFLOW_HOME}/logs
logging_level = INFO
fab_logging_level = WARN

[api]
auth_backends = airflow.api.auth.backend.basic_auth,airflow.api.auth.backend.session

[limiter]
enabled = true
storage_uri = memory://
strategy = fixed-window
EOL

# Set permissions and initialize DB
chmod 644 $AIRFLOW_HOME/airflow.cfg
export AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False
export AIRFLOW__CORE__LOAD_EXAMPLES=False

# Initialize fresh database
airflow db init
airflow db reset -y
airflow db upgrade

# Copy DAGs
cp -r dags/* $AIRFLOW_HOME/dags/ 2>/dev/null || true

# Reset and upgrade database
export AIRFLOW__DATABASE__LOAD_DEFAULT_CONNECTIONS=False
airflow db reset -y
airflow db init
AIRFLOW_DB_UPGRADE=yes yes | airflow db upgrade

# Verify database connection
airflow db check

# Create admin user with environment variables
airflow users create \
    --username "${AIRFLOW_USERNAME}" \
    --firstname "${AIRFLOW_FIRSTNAME}" \
    --lastname "${AIRFLOW_LASTNAME}" \
    --role Admin \
    --email "${AIRFLOW_EMAIL}" \
    --password "${AIRFLOW_PASSWORD}"

# Update Airflow config with environment variables
sed -i.bak \
    -e "s/^sql_alchemy_conn = .*$/sql_alchemy_conn = postgresql+psycopg2:\/\/${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:5432\/airflow/" \
    -e "s/^secret_key = .*$/secret_key = ${AIRFLOW__WEBSERVER__SECRET_KEY}/" \
    "$AIRFLOW_HOME/airflow.cfg"
