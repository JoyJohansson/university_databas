from dotenv import load_dotenv
from psycopg2 import DatabaseError, connect
import os
load_dotenv()
conn = None
try:
    conn = connect(
        dbname="postgres",
        user="postgres",
        host="localhost",
        password=os.getenv("DB_PASSWORD"),
    )

    print(conn)

    cursor = conn.cursor()
    #cursor.execute("SELECT * FROM employees;")
    cursor.execute("INSERT INTO users VALUES ('kristian', '123');")
    #print(cursor.fetchall())
    print(cursor)
    print(cursor.fetchone())
    conn.commit()
    cursor.close()
except DatabaseError as error:
    print(error)
finally:
    if conn is not None:
        conn.close()

    