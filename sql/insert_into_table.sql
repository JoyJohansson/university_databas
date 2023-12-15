INSERT INTO university.institutions (name, abbreviation) 
VALUES
    ('Computer Science', 'CS'),
    ('Computer Engineering', 'CE');

INSERT INTO university.programs (name, code)
VALUES
    ('Computer Science Engineering Program', 'CSEP');

INSERT INTO university.program_institutions (program_id, institution_id)
VALUES
(1, 1),
(1, 2);

INSERT INTO university.branches (name, recommended_courses_requirment_minimum, program_id)
VALUES
('Computer Linguistics', 1, 1),
('Algorithms', 2, 1),
('Computer Software technology', 3, 1);

INSERT INTO university.program_branches (program_id, branch_id)
VALUES
(1, 1),
(1, 3),
(1, 2);

INSERT INTO university.classifications (name)
VALUES
  ('Undergraduate'),
  ('Graduate');

INSERT INTO university.grades (symbol, description)
VALUES 
  ('5', 'Excellent'),
  ('4', 'Good'),
  ('3', 'Pass'),
  ('U', 'Fail');

INSERT INTO university.courses (code, name, institution_id, credits, classification_id, grade_ceiling)
VALUES
  ('CS101', 'Introduction to Computer Science', 1, 3, 1, 4),
  ('CS102', 'Data Structures', 1, 3, 1, 4),
  ('CS103', 'Computer Programming', 1, 3, 1, 4),
  ('CS104', 'Object Oriented Programming', 1, 3, 1, 4),
  ('CS105', 'Operating Systems', 1, 3, 1, 4),
  ('CS106', 'Database Management Systems', 1, 3, 1, 4),
  ('CS107', 'Computer Networks', 1, 3, 1, 4),
  ('CS108', 'Software Engineering', 1, 3, 1, 4),
  ('CS109', 'Computer Graphics', 1, 3, 1, 4),
  ('CS110', 'Computer Security', 1, 3, 1, 4),
  ('CS111', 'Artificial Intelligence', 1, 3, 1, 4),
  ('CS112', 'Computer Architecture', 1, 3, 1, 4),
  ('CS113', 'Software Testing', 1, 3, 1, 4),
  ('CS114', 'Software Project Management', 1, 3, 1, 4),
  ('CS115', 'Software Quality Assurance', 1, 3, 1, 4),
  ('CS116', 'Software Maintenance', 1, 3, 1, 4);

INSERT INTO university.prerequisites_courses (course_code, prerequisite_code)
VALUES
  ('CS101', 'CS110'),
  ('CS102', 'CS101'),
  ('CS103', 'CS102'),
  ('CS104', 'CS103'),
  ('CS105', 'CS104');

INSERT INTO university.limited_courses (course_code, max_students)
VALUES
  ('CS101', 20),
  ('CS102', 20),
  ('CS103', 20),
  ('CS104', 10);
 
INSERT INTO university.students (social_security_number, name, program_id, branch_id, current_year, current_term, earned_credits)
  VALUES
  ('1234567890', 'Anna Hansson', 1, 1, 2021, 1, 10),
  ('1234567891', 'Viktor Bengtsson', 1, 1, 2021, 1, 10),
  ('1234567892', 'Frida Andersson', 1, 1, 2021, 1, 10);


INSERT INTO university.student_completed_courses(student_social_security_number,course_code, grade)
VALUES
('1234567890', 'CS101', '3'),
('1234567890', 'CS110', '5'),
('1234567891', 'CS102', '5'),
('1234567890', 'CS104', '5'),
('1234567891', 'CS103', '3'),
('1234567891', 'CS101', '3');

INSERT INTO university.student_course_registrations (student_social_security_number, course_code)
VALUES
  ('1234567890', 'CS102'),
  ('1234567891', 'CS104'),
  ('1234567890', 'CS105');

INSERT INTO university.waitlist (student_social_security_number, course_code)
VALUES
  ('1234567890', 'CS101');

INSERT INTO university.Study_administrators (name)
VALUES
  ('<NAME>');

INSERT INTO university.override_logs (administrator_id, course_code, student_social_security_number)
VALUES
  (1, 'CS101', '1234567890');

INSERT INTO university.program_mandatory_courses (program_id, course_code)
VALUES
  (1, 'CS101'),
  (1, 'CS102');

INSERT INTO university.branch_mandatory_courses (branch_id, course_code)
VALUES
  (1, 'CS101'),
  (1, 'CS102');

INSERT INTO university.branch_recommended_courses (branch_id, course_code)
VALUES
  (1, 'CS103'),
  (1, 'CS104');

INSERT INTO university.courses_classification (course_code, classification_id)
VALUES
('CS101',1),
('CS101', 2);

