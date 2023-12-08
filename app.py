from flask import Flask, render_template, request



app =Flask(__name__)

@app

"""
@app.route("/", methods=["GET"])
def render_index():
    return render_template("index.html")


@app.route("/submit", methods=["POST"])
def submit():
    salary = request.form.get("salary")
    query_result = execute_query("SELECT first_name, salary FROM employees WHERE salary > %s", (salary,))
    if query_result is None:
        query_result = []
    return render_template("index.html", data=query_result)
"""

if __name__ == "main":
    app.run()
