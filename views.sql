'''
Uppgift 3 Views
Baserat på din tidigare databas ska du skapa följande views.
Om du har andra kolumner i dina views, dubbelkolla detta med mig. Dina views kan också vara godkända.
Inlämning: views.sql med definitionen för alla views.
'''

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
    university.students.social_security_number 
    AS student_social_security_number,
    university.courses.code 
    AS course_code,
    university.student_completed_courses.grade,
    university.courses.credits
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
SELECT
    university.students.social_security_number 
    AS student_social_security_number,
    university.courses.code 
    AS course_code,
    CASE
        WHEN university.waitlist.id IS NOT NULL THEN 'waiting'
        WHEN university.student_course_registrations.id IS NOT NULL THEN 'registered'
        ELSE NULL
    END AS status
FROM
    university.students
JOIN
    university.courses 
    ON true
LEFT JOIN
    university.waitlist 
    ON university.students.social_security_number = university.waitlist.student_social_security_number
    AND university.courses.code = (
        SELECT code 
        FROM university.limited_courses 
        WHERE limited_courses.waitlist_id = university.waitlist.id)
LEFT JOIN
    university.student_course_registrations 
    ON university.students.social_security_number = university.student_course_registrations.student_social_security_number
    AND university.courses.code = university.student_course_registrations.course_code);

SELECT * FROM university.registrations;

-- unread_mandatory(student, course) Olästa obligatoriska kurser för varje student.

CREATE VIEW university.unread_mandatory 
AS(
SELECT
    university.students.social_security_number 
    AS student_social_security_number,
    university.courses.code 
    AS course_code,
    university.courses.name 
    AS course_name
FROM
    university.students
JOIN
    university.program_mandatory_courses 
    ON university.students.program_id = university.program_mandatory_courses.program_id
JOIN
    university.courses 
    ON university.program_mandatory_courses.course_code = university.courses.code
LEFT JOIN
    university.student_completed_courses 
    ON university.students.social_security_number = university.student_completed_courses.student_social_security_number
    AND university.program_mandatory_courses.course_code = university.student_completed_courses.course_code
WHERE
    university.student_completed_courses.student_social_security_number IS NULL);

SELECT * FROM university.unread_mandatory;


-- course_queue_position(course, student, place) Alla väntande studenter, rangordnade i turordning på väntelistan.

CREATE VIEW university.course_queue_position 
AS
SELECT
    university.waitlist.id 
    AS waitlist_id,
    university.courses.code 
    AS course_code,
    university.waitlist.student_social_security_number,
    university.waitlist.registration_date,
    ROW_NUMBER() 
    OVER (
        PARTITION BY university.courses.code 
        ORDER BY university.waitlist.registration_date) 
        AS place
FROM
    university.waitlist
JOIN
    university.student_course_registrations 
    ON university.waitlist.student_social_security_number = university.student_course_registrations.student_social_security_number
JOIN
    university.courses 
    ON university.student_course_registrations.course_code = university.courses.code;

SELECT * FROM university.course_queue_position; 








DROP VIEW IF EXISTS university.course_queue_position;
DROP VIEW IF EXISTS university.registrations;
DROP VIEW IF EXISTS university.passed_courses;
DROP VIEW IF EXISTS university.finished_courses;
DROP VIEW IF EXISTS university.basic_information;
DROP VIEW IF EXISTS university.unread_mandatory; 

