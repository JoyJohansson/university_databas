CREATE SCHEMA IF NOT EXISTS university;

CREATE TABLE IF NOT EXISTS university.grades (
    symbol VARCHAR(1) PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS university.classifications (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS university.institutions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    abbreviation VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS university.programs (
    id  SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    code VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS university.programs_institution (
    program_id INT,
    FOREIGN KEY (program_id) REFERENCES university.programs (id) ON DELETE CASCADE,
    institution_id INT,
    FOREIGN KEY (institution_id) REFERENCES university.institutions (id) ON DELETE CASCADE,
    PRIMARY KEY (program_id, institution_id)
);

CREATE TABLE IF NOT EXISTS university.branches (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    recommended_courses_requirment_minimum INT,
    program_id INT NOT NULL,
    FOREIGN KEY (program_id) REFERENCES university.programs (id) ON DELETE CASCADE
    UNIQUE (name, program_id);
);

CREATE TABLE IF NOT EXISTS university.courses (
    code VARCHAR(6) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    institution_id INT NOT NULL,
    FOREIGN KEY (institution_id) REFERENCES university.institutions (id) ON DELETE CASCADE,
    credits INT NOT NULL,
    classification_id INT,
    FOREIGN KEY (classification_id) REFERENCES university.classifications (id),
    grade_ceiling VARCHAR(1),
    FOREIGN KEY (grade_ceiling) REFERENCES university.grades (symbol)
);

CREATE TABLE IF NOT EXISTS university.courses_classifications (
    course_code VARCHAR(6),
    FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
    classification_id INT,
    FOREIGN KEY (classification_id) REFERENCES university.classifications (id) ON DELETE CASCADE,
    PRIMARY KEY (course_code, classification_id)
);

CREATE TABLE IF NOT EXISTS university.prerequisites_courses (
    course_code VARCHAR(6),
    prerequisite_code VARCHAR(6),
    PRIMARY KEY (course_code, prerequisite_code),
    FOREIGN KEY (course_code) REFERENCES university.courses (code),
    FOREIGN KEY (prerequisite_code) REFERENCES university.courses (code)
);

CREATE TABLE IF NOT EXISTS university.students (
    social_security_number VARCHAR(10) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    program_id INT NOT NULL,
    FOREIGN KEY (program_id) REFERENCES university.programs (id) ON DELETE CASCADE,
    branch_id INT,
    FOREIGN KEY (branch_id) REFERENCES university.branches (id),
    current_year INT,
    current_term INT,
    earned_credits INT,
    graduation_requirements_fulfilled BOOLEAN DEFAULT FALSE,
    CHECK (LENGTH(social_security_number) = 10)
);

CREATE TABLE IF NOT EXISTS university.limited_courses (
    course_code VARCHAR(6) PRIMARY KEY,
    FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
    max_students INT NOT NULL,
    CHECK (max_students > 0)
);


CREATE TABLE IF NOT EXISTS university.waitlists (
    id SERIAL PRIMARY KEY,
    student_social_security_number VARCHAR(10) NOT NULL,
    FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
    course_code VARCHAR(6) NOT NULL,
    FOREIGN KEY (course_code) REFERENCES university.limited_courses (course_code) ON DELETE CASCADE,
    registration_date TIMESTAMP DEFAULT clock_timestamp(),
    UNIQUE (course_code, student_social_security_number)
);

CREATE TABLE IF NOT EXISTS university.student_course_registrations (
    id SERIAL PRIMARY KEY,
    student_social_security_number VARCHAR(10) NOT NULL,
    FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
    course_code VARCHAR(6) NOT NULL,
    FOREIGN KEY (course_code) REFERENCES university.courses (code),
    registration_date DATE DEFAULT clock_timestamp(),
    UNIQUE (student_social_security_number, course_code)
);

CREATE TABLE IF NOT EXISTS university.study_administrators (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS university.override_logs (
    id SERIAL PRIMARY KEY,
    administrator_id INT NOT NULL,
    FOREIGN KEY (administrator_id) REFERENCES university.study_administrators (id) ON DELETE CASCADE,
    course_code VARCHAR(6),
    FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
    student_social_security_number VARCHAR(10),
    FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
    override_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS university.program_mandatory_courses (
    program_id INT,
    FOREIGN KEY (program_id) REFERENCES university.programs (id) ON DELETE CASCADE,
    course_code VARCHAR(6),
    FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
    PRIMARY KEY (program_id, course_code)
);

CREATE TABLE IF NOT EXISTS university.branch_mandatory_courses (
    branch_id INT,
    FOREIGN KEY (branch_id) REFERENCES university.branches (id) ON DELETE CASCADE,
    course_code VARCHAR(6),
    FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
    PRIMARY KEY (branch_id, course_code)
);

CREATE TABLE IF NOT EXISTS university.branch_recommended_courses (
    branch_id INT,
    FOREIGN KEY (branch_id) REFERENCES university.branches (id) ON DELETE CASCADE,
    course_code VARCHAR(6),
    FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
    PRIMARY KEY (branch_id, course_code)
);

CREATE TABLE IF NOT EXISTS university.student_completed_courses (
  student_social_security_number VARCHAR(10) NOT NULL,
  FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
  course_code VARCHAR(6) NOT NULL,
  FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
  PRIMARY KEY (student_social_security_number, course_code),
  grade VARCHAR NOT NULL,
  FOREIGN KEY (grade) REFERENCES university.grades (symbol) ON DELETE CASCADE,
  completed_date DATE DEFAULT CURRENT_DATE
);


-- Trigger-funktion för att kontrollera förkunskapskrav innan studentregistrering
CREATE OR REPLACE FUNCTION university.check_prerequisites()
RETURNS TRIGGER AS $$
BEGIN
    IF (
      (SELECT prerequisite_code FROM university.Prerequisites_Courses 
        WHERE course_code = NEW.course_code) IS NOT NULL 
    ) THEN 
      IF (
        (SELECT prerequisite_code FROM university.Prerequisites_Courses 
          WHERE course_code = NEW.course_code)
          NOT IN 
        (SELECT course_code FROM university.Student_completed_courses 
          WHERE student_social_security_number = NEW.student_social_security_number)
      ) THEN
        RAISE EXCEPTION 'Förkunskapskrav inte uppfyllda';
      END IF;
    END IF;
    RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

-- Trigger för att kontrollera förkunskapskrav innan studentregistrering
CREATE OR REPLACE TRIGGER before_student_registrations
BEFORE INSERT ON university.Student_course_registrations
FOR EACH ROW
EXECUTE FUNCTION university.check_prerequisites();

-- Trigger-funktion för att kontrollera kursavslutning innan studentregistrering
CREATE OR REPLACE FUNCTION university.check_course_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF (
      (SELECT course_code 
      FROM university.student_completed_courses 
      WHERE student_social_security_number = NEW.student_social_security_number 
      AND course_code = NEW.course_code) IS NOT NULL
    ) THEN
      RAISE EXCEPTION 'Studenten har redan godkänts för denna kurs';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger för att kontrollera kursavslutning innan studentregistrering
CREATE TRIGGER before_student_registration_completion
BEFORE INSERT ON university.Student_course_registrations
FOR EACH ROW
EXECUTE FUNCTION university.check_course_completion();

-- Trigger-funktion för att behandla väntelista
CREATE OR REPLACE FUNCTION university.process_waitlist()
RETURNS TRIGGER AS $$
DECLARE
    next_waitlist_student RECORD;
BEGIN
    -- Hitta nästa student på väntelistan för kursen
    SELECT * INTO next_waitlist_student
    FROM university.Waitlists
    WHERE course_code = NEW.course_code
    ORDER BY registration_date
    LIMIT 1;

    IF next_waitlist_student IS NOT NULL THEN
      -- Ta bort studenten från väntelistan
      DELETE FROM Waitlist
      WHERE waitlist_id = next_waitlist_student.id;

      -- Lägg till studenten i kursregistreringar
      INSERT INTO university.Student_course_registrations (student_social_security_number, course_code, registration_date)
      VALUES (next_waitlist_student.student_social_security_number, NEW.course_code, CURRENT_DATE);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger för att behandla väntelista efter studentavregistrering
CREATE TRIGGER after_student_unregistration
AFTER DELETE ON university.Student_course_registrations
FOR EACH ROW
EXECUTE FUNCTION university.process_waitlist();

-- trigger som hindrar att man lägger till en student på väntelistan för en kurs 
-- ifall samma sudent finns registrerad på den kursen
CREATE OR REPLACE FUNCTION university.restrict_adding_to_waitlist()
RETURNS TRIGGER AS $$
BEGIN
   IF EXISTS (SELECT id 
    FROM university.student_course_registrations
    WHERE student_social_security_number = NEW.student_social_security_number
    AND course_code = NEW.course_code)
   THEN RETURN NULL;
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_adding_to_waitlist
BEFORE INSERT ON university.waitlists
FOR EACH ROW
EXECUTE FUNCTION university.restrict_adding_to_waitlist();