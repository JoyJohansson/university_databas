# python -m venv venv
# venv/scripts/activate
# pip install psycopg2
# pip install flask

from flask import Flask, render_template, request
from psycopg2 import connect, DatabaseError


def execute_query(query, parameters=None):
    """Ansluter till databasen"""
    conn = None
    try:
        conn = connect(
            dbname="postgres",
            user="postgres",
            host="localhost",
            password=os.getenv("DB_PASSWORD"),
        )
        with conn.cursor() as cursor: #returnerar en cursor
            cursor.execute(query, parameters) # kör en query
            conn.commit() #committar ändringarna i databasen
            if cursor.description: #Om queryn är en SELECT
                return cursor.fetchall() # returnerar alla rader från queryn.
    # vid ett stort resultat kan man använda exempelvis .fetchone() för att förhindra memory overflow
    except DatabaseError as e:
        print(e)
    finally:
        if conn:
            conn.close()