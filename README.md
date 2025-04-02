# Real-time Data Engineering Pipeline

A production-ready data engineering environment with Apache Kafka, Spark, Airflow, PostgreSQL, and Cassandra. This project demonstrates a complete end-to-end data pipeline with real-time processing capabilities.

## System Architecture

![System Architecture](./Data%20engineering%20architecture.png)

## Features
- Real-time data streaming with Apache Kafka
- Distributed processing with Apache Spark
- Workflow orchestration with Apache Airflow
- Data storage in PostgreSQL and Cassandra
- Containerized environment with Docker
- Comprehensive monitoring and logging
- Fully tested components

## Tech Stack
- Apache Airflow 2.6.0
- Apache Kafka (Confluent Platform 7.4.0)
- Apache Spark 3.5.4
- Cassandra 4.0
- PostgreSQL
- Docker & Docker Compose

## Prerequisites
- Docker and Docker Compose installed
- Git
- Minimum 8GB RAM recommended
- 20GB free disk space

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/meimeiLiew/real_time_pipeline.git
cd real_time_pipeline
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

3. Start the services (recommended order):
```bash
# Start core services first
docker-compose up -d zookeeper broker schema-registry postgres
sleep 30

# Start Airflow services
docker-compose up -d webserver scheduler
sleep 20

# Start processing services
docker-compose up -d spark-master spark-worker cassandra_db

# Start monitoring services
docker-compose up -d kafka-ui control-center
```

## Service URLs and Credentials
- Airflow UI: http://localhost:8080 
  - Username: admin
  - Password: admin
- Spark Master UI: http://localhost:9090
- Kafka UI: http://localhost:8082
- Control Center: http://localhost:9021

## Project Structure
```
real_time_pipeline/
├── dags/                   # Airflow DAG files
│   ├── test_dag.py        # Test DAG
│   └── kafka_stream.py    # Kafka streaming DAG
├── script/                 # Setup and utility scripts
├── tests/                  # Test files
├── docker-compose.yml      # Docker services configuration
├── requirements.txt        # Python dependencies
├── create_user.py         # Airflow user creation script
├── spark_test.py          # Spark testing script
└── README.md              # Project documentation
```

## Component Testing

### 1. Kafka Testing
```bash
# Create test topic
docker exec broker kafka-topics --bootstrap-server broker:29092 \
    --create --topic test-topic --partitions 1 --replication-factor 1

# List topics
docker exec broker kafka-topics --bootstrap-server broker:29092 --list

# Produce test message
docker exec -i broker kafka-console-producer --bootstrap-server broker:29092 \
    --topic test-topic

# Consume messages
docker exec broker kafka-console-consumer --bootstrap-server broker:29092 \
    --topic test-topic --from-beginning
```

### 2. Spark Testing
```python
# Run the spark_test.py script
docker exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    --driver-memory 512m \
    --executor-memory 512m \
    /opt/bitnami/spark/spark_test.py
```

### 3. Cassandra Testing
```bash
# Test connection
docker exec -it cassandra_db cqlsh -e "SELECT release_version FROM system.local"

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

### 4. PostgreSQL Testing
```bash
# Test connection
docker exec -it postgres psql -U airflow -c "SELECT version();"

# Create test database
docker exec -it postgres psql -U airflow -c "CREATE DATABASE test_db;"

# Create test table
docker exec -it postgres psql -U airflow -d test_db -c "
CREATE TABLE test_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"
```

## Monitoring and Maintenance

### Health Checks
```bash
# Check service status
docker-compose ps

# Check logs
docker-compose logs -f [service_name]

# Monitor resource usage
docker stats
```

### Common Issues and Solutions

1. **Service Won't Start**
```bash
# Check logs
docker-compose logs [service_name]

# Restart service
docker-compose restart [service_name]
```

2. **Memory Issues**
```bash
# Clean Docker system
docker system prune -a
docker volume prune
```

3. **Connection Issues**
- Ensure all services are healthy: `docker-compose ps`
- Check network connectivity: `docker network ls`
- Verify port mappings: `docker-compose port [service_name] [port]`

4. **Complete Reset**
```bash
docker-compose down -v
docker-compose up -d
```

