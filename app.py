from flask import Flask, render_template, request
import database
import json


app =Flask(__name__)

@app.route("/", methods=["GET"])
def render_index():
    return render_template("index.html")

@app.route("/students", methods=(["GET"]))
def get_students():
    sql_get_students="SELECT * FROM university.students"
    result = database.execute_query(sql_get_students)
    return result

@app.route("/student/<string:student_ssn>/courses", methods=(["GET"]))
def get_student_registered_courses(student_ssn):
    sql_get_students="SELECT * FROM registrations WHERE student = %s"
    result = database.execute_query(sql_get_students, (student_ssn,))
    return result

@app.route("/register_student", methods=["POST"])
def register_student():
    data = request.form
    ssn = data.get("social_security_number")
    name = data.get("name")
    program = data.get("program")
    sql_register = """INSERT INTO university.students 
                    (social_security_number, name, program_id) 
                    VALUES (%s, %s, %s)"""
    database.execute_query(sql_register, (ssn, name, program))

if __name__ == "main":
    app.run()
