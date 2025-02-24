# Real-time Data Engineering Pipeline

A fully tested and configured data engineering environment with Apache Kafka, Spark, Airflow, PostgreSQL, and Cassandra.

## Table of Contents
- [System Architecture](#system-architecture)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Data Flow](#data-flow)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Watch the Video Tutorial](#watch-the-video-tutorial)

## System Architecture

![System Architecture](./Data%20engineering%20architecture.png)

## Tech Stack
- Apache Airflow 2.6.0
- Apache Kafka (Confluent Platform 7.4.0)
- Apache Spark 3.5.4
- Cassandra 4.0
- PostgreSQL
- Docker & Docker Compose

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/meimeiLiew/e2e-data-engineering.git
cd e2e-data-engineering
```

2. Create .env file:
```bash
# Postgres
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow

# Airflow
AIRFLOW_USERNAME=admin
AIRFLOW_PASSWORD=admin
AIRFLOW_EMAIL=admin@example.com
AIRFLOW_FIRSTNAME=Admin
AIRFLOW_LASTNAME=User
AIRFLOW__WEBSERVER__SECRET_KEY=your_secret_key_here
```

3. Start the services:
```bash
# Start core services first
docker-compose up -d zookeeper broker schema-registry postgres

# Wait for 30 seconds
sleep 30

# Start remaining services
docker-compose up -d
```

## Service URLs
- Airflow UI: http://localhost:8080
- Spark Master UI: http://localhost:9090
- Kafka UI: http://localhost:8082
- Control Center: http://localhost:9021

## Project Structure
```
e2e-data-engineering/
├── dags/                   # Airflow DAGs
├── script/                 # Setup scripts
├── docker-compose.yml      # Docker services configuration
├── requirements.txt        # Python dependencies
└── README.md              # Project documentation
```

## Data Flow
1. Random user data fetched from API
2. Data streamed through Kafka
3. Processed with Spark
4. Stored in Cassandra

## Monitoring
- Kafka Control Center: Monitor Kafka clusters, topics, and messages
- Spark UI: Track Spark jobs and executors
- Airflow UI: DAG runs and task status

## Troubleshooting
- Check logs: `docker-compose logs -f [service_name]`
- Restart service: `docker-compose restart [service_name]`
- Clean rebuild: `docker-compose down -v && docker-compose up --build`

## Watch the Video Tutorial

## Service Verification

### 1. Kafka
```bash
# Create test topic
docker exec broker kafka-topics --bootstrap-server broker:29092 \
    --create --topic test-topic --partitions 1 --replication-factor 1

# List topics
docker exec broker kafka-topics --bootstrap-server broker:29092 --list
```

### 2. Spark
```python
# Test PySpark (save as spark_test.py)
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("test") \
    .master("spark://spark-master:7077") \
    .config("spark.driver.host", "spark-master") \
    .config("spark.driver.bindAddress", "0.0.0.0") \
    .config("spark.executor.memory", "512m") \
    .config("spark.driver.memory", "512m") \
    .getOrCreate()

# Create test DataFrame
test_data = [("test1", 1), ("test2", 2)]
df = spark.createDataFrame(test_data, ["name", "value"])
df.show()
spark.stop()
```

### 3. Cassandra
```bash
# Create test keyspace
docker exec -it cassandra_db cqlsh -e "CREATE KEYSPACE IF NOT EXISTS test_keyspace \
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};"

# Create test table
docker exec -it cassandra_db cqlsh -e "
USE test_keyspace;
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    name text,
    email text
);"
```

### 4. PostgreSQL
```bash
# Test connection
docker exec -it postgres psql -U airflow -c "SELECT version();"

# Create test database
docker exec -it postgres psql -U airflow -c "CREATE DATABASE test_db;"
```

## Contributing
Feel free to submit issues, fork the repository and create pull requests for any improvements.

## License
[MIT License](LICENSE)
