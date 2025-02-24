#!/usr/bin/env python3

import uuid
from datetime import datetime
from airflow import DAG
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'meimei',
    'start_date': datetime(2023, 9, 3, 10, 00)
}

def get_data():
    import requests

    res = requests.get("https://randomuser.me/api/")
    res = res.json()
    res = res['results'][0]

    return res

def format_data(res):
    data = {}
    location = res['location']
    data['id'] = uuid.uuid4()
    data['first_name'] = res['name']['first']
    data['last_name'] = res['name']['last']
    data['gender'] = res['gender']
    data['address'] = f"{str(location['street']['number'])} {location['street']['name']}, " \
                      f"{location['city']}, {location['state']}, {location['country']}"
    data['post_code'] = location['postcode']
    data['email'] = res['email']
    data['username'] = res['login']['username']
    data['dob'] = res['dob']['date']
    data['registered_date'] = res['registered']['date']
    data['phone'] = res['phone']
    data['picture'] = res['picture']['medium']

    return data

def stream_data():
    try:
        from kafka import KafkaProducer
        import json
        import time
        import logging
    except ImportError as e:
        logging.error(f"Failed to import Kafka: {e}")
        raise

    try:
        producer = KafkaProducer(
            bootstrap_servers=['broker:29092'],  # Changed from localhost:9093
            api_version=(0, 10, 2),
            max_block_ms=5000,
            value_serializer=lambda x: json.dumps(x).encode('utf-8')
        )
    except Exception as e:
        logging.error(f"Failed to create Kafka producer: {e}")
        raise

    curr_time = time.time()

    while True:
        if time.time() > curr_time + 60:
            break
        try:
            res = get_data()
            res = format_data(res)
            producer.send('users_created', res)
            time.sleep(0.5)  # Add small delay between messages
        except Exception as e:
            logging.error(f'An error occurred: {e}')
            continue

with DAG('user_automation',
         default_args=default_args,
         schedule='@daily',  # Updated from schedule_interval
         catchup=False) as dag:

    streaming_task = PythonOperator(
        task_id='stream_data_from_api',
        python_callable=stream_data
    )
