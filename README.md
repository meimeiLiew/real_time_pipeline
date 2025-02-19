# Real-time Data Engineering Pipeline

## Table of Contents
- [System Architecture](#system-architecture)
- [Tech Stack](#tech-stack)
- [Local Development Setup](#local-development-setup)
- [Docker Setup](#docker-setup)
- [Project Structure](#project-structure)
- [Data Flow](#data-flow)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Watch the Video Tutorial](#watch-the-video-tutorial)

## System Architecture

![System Architecture] [./Data engineering architecture.png]

## Tech Stack
- Apache Airflow
- Apache Kafka & Zookeeper
- Apache Spark
- Cassandra
- PostgreSQL
- Docker

## Local Development Setup

1. Create and activate virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  
```

2. Install core dependencies:
```bash
pip install apache-airflow kafka-python requests
```

3. Set up Airflow:
```bash
# Set Airflow home
export AIRFLOW_HOME=~/airflow

# Initialize the database
airflow db init

# Create admin user
airflow users create \
    --username admin \
    --firstname admin \
    --lastname admin \
    --role Admin \
    --email admin@example.com \
    --password admin

# Start Airflow webserver (in one terminal)
airflow webserver --port 8080

# Start Airflow scheduler (in another terminal)
airflow scheduler
```

4. Access Airflow UI at http://localhost:8080

## Docker Setup

1. Start all services:
```bash
docker-compose up -d
```

2. Access Services:
- Airflow: http://localhost:8080
- Kafka Control Center: http://localhost:9021
- Spark Master: http://localhost:9090

3. Stop services:
```bash
docker-compose down
```

## Project Structure
```
e2e-data-engineering/
├── dags/                   # Airflow DAGs
├── script/                 # Setup scripts
├── docker-compose.yml      # Docker services configuration
└── requirements.txt        # Python dependencies
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
# realtime-streaming-project
