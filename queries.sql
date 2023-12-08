•	Två grenar med samma namn, fast på olika program.
SELECT * FORM Program_Branches WHERE Branches_Names = 

•	En student som inte har tagit några kurser.
SELECT * FORM Student WHERE COUNT(SELECT Student_social_security_number FROM Student_completed_courses) < 1
AND COUNT(SELECT Student_social_security_number FROM Student_course_registrations) < 1;

•	En student som bara har fått underkänt.
SELECT grade_id FROM Student_completed_courses

•	En student som inte har valt någon gren.
SELECT * FROM Student WHERE branch_id IS NULL;

•	En väntelista kan bara finnas för platsbegränsade kurser.

•	Och så vidare..

CREATE VIEW finished_courses AS (
    SELECT student_social_security_number, course_code, grade_id 
    FROM university.Student_completed_courses
    LEFT JOIN university.courses 
    ON university.courses.code = university.Student_completed_courses.course_code);

DROP VIEW finished_courses;
SELECT * FROM finished_courses;
    LEFT JOIN categories ON products.category_id = categories.category_id;

CREATE VIEW finished_courses AS (
SELECT student_social_security_number, course_code, grade, credits 
FROM university.Student_completed_courses
LEFT JOIN university.courses
ON university.courses.code = university.Student_completed_courses.course_code
);

'''
passed_courses(student, course, credits) Alla godkända kurser för varje student.
'''
CREATE VIEW passed_courses AS (
SELECT * FROM finished_courses WHERE grade != 'U');

SELECT * FROM passed_courses;

'''
registrations(student, course, status) Alla registrerade 
och väntande studenter för olika kurser. 
Statusen kan antingen vara ’waiting’ eller ’registered’.
'''

