-- basic_information(idnr, name, program, branch) Visar information om alla studenter. Branch tillåts vara NULL.

CREATE VIEW university.basic_information
AS(
    SELECT university.students.social_security_number,
    university.students.name 
    AS student_name,
    university.programs.name
    AS program_name,
    university.branches.name
    AS branch_name
    FROM university.students
    JOIN university.programs
    ON university.students.program_id = university.programs.id
    JOIN university.branches
    ON university.students.branch_id = university.branches.id);


SELECT * FROM university.basic_information;


-- finished_courses(student, course, grade, credits) Alla avslutade kurser för varje student, tillsammans med betyg och högskolepoäng.

CREATE VIEW university.finished_courses 
AS(
SELECT
    Students.name AS student,
    courses.name AS course,
    student_completed_courses.grade,
    courses.credits
FROM
    university.students
JOIN
    university.student_completed_courses 
    ON university.students.social_security_number = university.student_completed_courses.student_social_security_number
JOIN
    university.courses 
    ON university.student_completed_courses.course_code = university.courses.code);

SELECT * FROM university.finished_courses;


-- passed_courses(student, course, credits) Alla godkända kurser för varje student.
-- (samma som finished_courses, men med WHERE grade IS NOT NULL och grade!= 'U')

CREATE VIEW university.passed_courses 
AS(
SELECT *
FROM
    university.finished_courses
WHERE
    grade IS NOT NULL
    AND grade != 'U');

SELECT * FROM university.passed_courses;


-- registrations(student, course, status) Alla registrerade och väntande studenter för olika kurser. Statusen kan antingen vara ’waiting’ eller ’registered’.

CREATE VIEW university.registrations 
AS(
SELECT student_social_security_number AS student, course_code,
    CASE
        WHEN university.student_course_registrations.id IS NOT NULL THEN 'registered'
    END AS status
FROM university.student_course_registrations
UNION
SELECT student_social_security_number AS student, course_code,
    CASE
        WHEN university.waitlists.id IS NOT NULL THEN 'waiting'
    END AS status
FROM university.waitlists
ORDER BY course_code);

SELECT * FROM university.registrations;

-- unread_mandatory(student, course) Olästa obligatoriska kurser för varje student.

CREATE VIEW university.unread_mandatory 
AS(
SELECT
    students.name AS student,
    courses.name
FROM
    university.students
JOIN
    university.program_mandatory_courses 
    USING(program_id)
JOIN
    university.courses 
    ON program_mandatory_courses.course_code = courses.code
LEFT JOIN
    university.student_completed_courses 
    ON students.social_security_number = student_completed_courses.student_social_security_number
    AND program_mandatory_courses.course_code = student_completed_courses.course_code
WHERE
    student_completed_courses.student_social_security_number IS NULL 
    ORDER BY student);

SELECT * FROM university.unread_mandatory;

-- course_queue_position(course, student, place) Alla väntande studenter, rangordnade i turordning på väntelistan.

CREATE VIEW university.course_queue_position 
AS(
SELECT
    courses.name AS course,
    students.name,
    ROW_NUMBER() 
    OVER (
        PARTITION BY waitlists.course_code 
        ORDER BY waitlists.registration_date) 
        AS place
FROM
    university.waitlists
JOIN
    university.courses 
    ON waitlists.course_code = university.courses.code
JOIN
    university.students
    ON waitlists.student_social_security_number = students.social_security_number);

SELECT * FROM university.course_queue_position; 
