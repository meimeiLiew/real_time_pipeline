from airflow.contrib.auth.backends.password_auth import PasswordUser
from airflow import settings
import os

def create_user():
    user = PasswordUser(
        username=os.getenv('_AIRFLOW_WWW_USER_USERNAME'),
        email=os.getenv('_AIRFLOW_WWW_USER_EMAIL'),
        password=os.getenv('_AIRFLOW_WWW_USER_PASSWORD'),
        superuser=True
    )

    session = settings.Session()
    session.add(user)
    session.commit()
    session.close()

if __name__ == '__main__':
    create_user()