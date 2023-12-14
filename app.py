from flask import Flask, render_template, request
import database


app =Flask(__name__)

@app.route("/", methods=["GET"])
def render_index():
    return render_template("index.html")

@app.route("/students", methods=(["GET"]))
def get_students():
    sql_get_students="SELECT * FROM university.students"
    result = database.execute_query(sql_get_students)
    return result

# Här öppnar vi för en sql-injektion genom att ta inputen från frontend rakt in i vår query. 
# En person som känner till det kan enkelt ställa till det i vår databas 
# genom att skicka in tex "00; DROP TABLE Students" eller liknande,
# eller få tag i information som inte borde komma ut; med tex "1234' OR 'A'='A"
@app.route("/student/<string:student_ssn>/courses", methods=(["GET"]))
def get_student_registered_courses(student_ssn):
    # TODO Ersätt detta med 
    # sql_get_students="SELECT * FROM registrations WHERE student = %s"
    # result = database.execute_query(sql_get_students, (student_ssn,))
    # För att förhindra sql-injection
    sql_get_students=f"""SELECT course_code FROM university.student_course_registrations 
    WHERE student_social_security_number = '{student_ssn}'"""
    result = database.execute_query(sql_get_students)
    return result

@app.route("/register_student", methods=["POST"])
def register_student():
    data = request.form
    ssn = data.get("ssn")
    name = data.get("name")
    program = data.get("program")
    sql_register = """INSERT INTO university.students 
                    (social_security_number, name, program_id) 
                    VALUES (%s, %s, %s)"""
    database.execute_query(sql_register, (ssn, name, program))

if __name__ == "main":
    app.run()
