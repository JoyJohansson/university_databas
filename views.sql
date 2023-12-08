
--Uppgift 3 Views
--Baserat på din tidigare databas ska du skapa följande views.
-- Om du har andra kolumner i dina views, dubbelkolla detta med mig. Dina views kan också vara godkända.

-- Inlämning: views.sql med definitionen för alla views.


-- basic_information(idnr, name, program, branch) Visar information om alla studenter. Branch tillåts vara NULL.
CREATE VIEW university.basic_information 
AS(
    SELECT social_security_number, name, program_id, branch_id
    FROM university.students
);

SELECT * 
FROM university.basic_information;


--finished_courses(student, course, grade, credits) Alla avslutade kurser för varje student, 
--tillsammans med betyg och högskolepoäng.
CREATE VIEW university.finished_courses
AS(
    SELECT student_social_security_number, course_code, grade, credits
    FROM university.student_completed_courses
    LEFT JOIN university.courses
    ON student_completed_courses.course_code = courses.code
);

SELECT * 
FROM university.finished_courses;

-- passed_courses(student, course, credits) Alla godkända kurser för varje student.
CREATE VIEW university.passed_courses
AS(
    SELECT student_social_security_number, course_code, grade, credits
    FROM university.student_completed_courses
    LEFT JOIN university.courses
    ON student_completed_courses.course_code = courses.code
);

SELECT * 
FROM university.passed_courses 
WHERE grade != 'U';


-- registrations(student, course, status) Alla registrerade och väntande studenter för olika kurser. 
-- Statusen kan antingen vara ’waiting’ eller ’registered’.
CREATE VIEW university.registrations 
AS(
    SELECT student_social_security_number,
        university.student_course_registrations.course_code,
        'registered' AS status
    FROM university.student_course_registrations
        LEFT JOIN university.limited_courses 
        ON university.student_course_registrations.course_code = university.limited_courses.course_code
    UNION
    SELECT student_social_security_number,
        CAST(university.waitlist.id AS VARCHAR),
        'waiting' AS status
    FROM university.waitlist
);

SELECT * 
FROM registrations;

'''
--UNION och CAST är två SQL-komponenter som används för att kombinera och omvandla data, respektive.
-- UNION används för att kombinera resultaten av två eller flera SELECT-frågor i en enda uppsättning resultat.
-- Resultaten från varje SELECT måste ha samma antal kolumner, och kolumnernas datatyper måste matcha eller vara kompatibla.
-- Dubletter tas bort från det slutliga resultatet.
-- UNION används här för att kombinera resultaten från två olika SELECT-frågor som hämtar data från 
-- "student_course_registrations" och "waitlist" tabeller.
-- CAST används för att omvandla en uttryck eller en kolumn till en annan datatyp.
-- CAST(university.waitlist.id AS VARCHAR) används här för att konvertera "id" från waitlist-tabellen till en VARCHAR (teckensträng). 
-- Detta kan vara nödvändigt om datatypen för "id" inte är kompatibel med datatypen för "course_code" i den första SELECT-frågan i UNION.
-- Exempelvis, om "id" är av typen `INT` och "course_code" är av typen `VARCHAR`, så används `CAST` för att se till att båda sidor av `UNION` har samma datatyp för "course_code".
-- Sammanfattningsvis kombinerar `UNION` resultatet av två `SELECT`-frågor, medan `CAST` används för att ändra datatypen för en kolumn eller ett uttryck.
'''


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


SELECT * 
FROM university.unread_mandatory;


-- course_queue_position(course, student, place) Alla väntande studenter, rangordnade i turordning på väntelistan.
CREATE VIEW university.course_queue_position 
AS(
SELECT
    university.waitlist.id AS waitlist_id,
    university.courses.code AS course_code,
    university.waitlist.student_social_security_number,
    university.waitlist.registration_date,
    ROW_NUMBER() 
    OVER 
    (PARTITION BY 
    university.courses.code 
    ORDER BY 
    university.waitlist.registration_date) 
    AS 
    place
FROM
    university.waitlist
JOIN
    university.student_course_registrations 
    ON university.waitlist.student_social_security_number = university.student_course_registrations.student_social_security_number
JOIN
    university.courses 
    ON university.student_course_registrations.course_code = university.courses.code);

SELECT  * 
FROM university.course_queue_position;    

