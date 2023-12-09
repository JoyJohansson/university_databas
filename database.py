# python -m venv venv
# venv/scripts/activate
# pip install psycopg2
# pip install flask

import os
from psycopg2 import connect, DatabaseError


def execute_query(query, parameters=None):
    conn = None
    try:
        conn = connect(
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            host=os.getenv("DB_HOST"),
            password=os.getenv("DB_PASSWORD"),
            port=os.getenv("DB_PORT")
        )

        with conn.cursor() as cursor:
            cursor.execute(query, parameters)
            conn.commit()
            if cursor.description:
                return cursor.fetchall()
    except DatabaseError as e:
        print(e)
    finally:
        if conn:
            conn.close()


