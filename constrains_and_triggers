
-- Exempel: Lägg till en ny kursklassificering
INSERT INTO university.Classifications (classification_name)
VALUES ('Ny Klassificering');

-- Lägg till kartläggning för en kurs med den nya klassificeringen
INSERT INTO university.Courses_classification(course_code, classification_id)
VALUES ('KURS001', 
(SELECT classification_id 
FROM CourseClassifications 
WHERE classification_name = 'Ny Klassificering')
);

-- Trigger-funktion för att kontrollera förkunskapskrav innan studentregistrering
CREATE OR REPLACE FUNCTION check_prerequisites()
RETURNS TRIGGER AS $$
BEGIN
    IF (
      (SELECT prerequisite_code FROM Prerequisites WHERE course_code = NEW.course_code) IS NOT NULL
      AND NOT (SELECT course_code FROM Student_course_registrations WHERE student_social_security_number = NEW.student_social_security_number AND is_completed = TRUE AND course_code = (SELECT prerequisite_code FROM Prerequisites WHERE course_code = NEW.course_code))
    ) THEN
      RAISE EXCEPTION 'Förkunskapskrav inte uppfyllda';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger för att kontrollera förkunskapskrav innan studentregistrering
CREATE TRIGGER before_student_registration
BEFORE INSERT ON StudentRegistrations
FOR EACH ROW
EXECUTE FUNCTION check_prerequisites();

-- Trigger-funktion för att kontrollera kursavslutning innan studentregistrering
CREATE OR REPLACE FUNCTION check_course_completion()
RETURNS TRIGGER AS $$
BEGIN
    IF (
      (SELECT is_completed 
      FROM Student_course_registrations 
      WHERE student_social_security_number = NEW.student_social_security_number 
      AND course_code = NEW.course_code) = TRUE
    ) THEN
      RAISE EXCEPTION 'Studenten har redan godkänts för denna kurs';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger för att kontrollera kursavslutning innan studentregistrering
CREATE TRIGGER before_student_registration_completion
BEFORE INSERT ON Student_course_registrations
FOR EACH ROW
EXECUTE FUNCTION check_course_completion();

-- Trigger-funktion för att behandla väntelista
CREATE OR REPLACE FUNCTION process_waitlist()
RETURNS TRIGGER AS $$
DECLARE
    next_waitlist_student RECORD;
BEGIN
    -- Hitta nästa student på väntelistan för kursen
    SELECT * INTO next_waitlist_student
    FROM Waitlist
    WHERE course_code = NEW.course_code
    ORDER BY registration_date
    LIMIT 1;

    IF next_waitlist_student IS NOT NULL THEN
      -- Ta bort studenten från väntelistan
      DELETE FROM Waitlist
      WHERE waitlist_id = next_waitlist_student.waitlist_id;

      -- Lägg till studenten i kursregistreringar
      INSERT INTO Student_course_registrations (student_social_security_number, course_code, registration_date, is_from_waitlist)
      VALUES (next_waitlist_student.student_social_security_number, NEW.course_code, CURRENT_DATE, TRUE);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger för att behandla väntelista efter studentavregistrering
CREATE TRIGGER after_student_unregistration
AFTER DELETE ON Student_course_registrations
FOR EACH ROW
EXECUTE FUNCTION process_waitlist();

-- Trigger-funktion för att uppdatera tillgängliga platser
CREATE OR REPLACE FUNCTION update_available_seats()
RETURNS TRIGGER AS $$
BEGIN
    -- Uppdatera tillgängliga platser baserat på registrering eller avregistrering
    UPDATE university.Courses
    SET available_seats = available_seats + 1
    WHERE course_code = NEW.course_code;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger för att uppdatera tillgängliga platser efter studentregistrering
CREATE TRIGGER after_student_registration
AFTER INSERT ON university.Student_course_registrations
FOR EACH ROW
EXECUTE FUNCTION update_available_seats();

-- Trigger för att uppdatera tillgängliga platser efter studentavregistrering
CREATE TRIGGER after_student_unregistration
AFTER DELETE ON university.Student_course_registrations
FOR EACH ROW
EXECUTE FUNCTION update_available_seats();


-- trigger som hindrar att man lägger till en student på väntelistan för en kurs 
-- ifall samma sudent finns registrerad på den kursen
CREATE OR REPLACE FUNCTION restrict_adding_to_waitlist()
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
BEFORE INSERT ON university.waitlist
FOR EACH ROW
EXECUTE FUNCTION restrict_adding_to_waitlist();




--Constrains


-- En student som inte har tagit några kurser:
-- Lägg till en NOT NULL-begränsning för course_code i tabellen StudentRegistrations.

ALTER TABLE university.Student_course_registrations
ALTER COLUMN course_code SET NOT NULL;

-- En student som bara har fått underkänt:
-- Lägg till en unik begränsning för kombinationen av student_social_security_number och course_code i tabellen StudentRegistrations.

ALTER TABLE university.Student_course_registrations
ADD CONSTRAINT unique_student_course_registration UNIQUE (student_social_security_number, course_code);

-- En student som inte har valt någon gren:
-- Lägg till en NOT NULL-begränsning för branch_id i tabellen Students.

ALTER TABLE university.Students
ALTER COLUMN branch_id SET NOT NULL;


-- En väntelista kan bara finnas för kurser med begränsade platser:
-- Ändra utlösarfunktionen process_waitlist för att endast bearbeta väntelistor för kurser med begränsade platser.

CREATE OR REPLACE FUNCTION process_waitlist()
RETURNS TRIGGER AS $$
DECLARE
    next_waitlist_student RECORD;
BEGIN
    -- Hitta nästa student på waitlist för kursen
    SELECT * INTO next_waitlist_student
    FROM university.Waitlist
    WHERE course_code = NEW.course_code
    ORDER BY registration_date
    LIMIT 1;

    IF next_waitlist_student IS NOT NULL THEN
      -- Ta bort en student från  waitlist
      DELETE FROM university.Waitlist
      WHERE waitlist_id = next_waitlist_student.waitlist_id;

      -- Lägga till en student till course registrations
      INSERT INTO university.Student_course_registrations (student_social_security_number, course_code, registration_date, is_from_waitlist)
      VALUES (next_waitlist_student.student_social_security_number, NEW.course_code, CURRENT_DATE, TRUE);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Unik identifierare för Institutions och Programs:

ALTER TABLE university.Institutions
ADD CONSTRAINT unique_institution_id UNIQUE (institution_id);

ALTER TABLE university.Programs
ADD CONSTRAINT unique_program_id UNIQUE (program_id);


-- Unik identifierare för Grades:

ALTER TABLE university.Grades
ADD CONSTRAINT unique_grade_symbol UNIQUE (grade_symbol);

-- Begränsning för Program_mandatory_courses:
-- en constraint för att säkerställa att de obligatoriska kurserna för ett program verkligen tillhör det programmet.

ALTER TABLE university.Program_mandatory_courses
ADD CONSTRAINT fk_program_mandatory_courses
FOREIGN KEY (program_id) REFERENCES ProgramCodes (program_id) ON DELETE CASCADE;


-- Begränsning för Branch_mandatory_courses:
-- Se till att branch_id och course_code refererar till befintliga poster.

ALTER TABLE university.Branch_mandatory_courses

ADD CONSTRAINT fk_branch_mandatory_courses
FOREIGN KEY (branch_id) REFERENCES Branches (branch_id) ON DELETE CASCADE;

ADD CONSTRAINT fk_branch_mandatory_courses_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;


-- Begränsning för Branch_recommended_courses:
-- Se till att branch_id och course_code refererar till befintliga poster.

ALTER TABLE university.Branch_recommended_courses

ADD CONSTRAINT fk_branch_recommended_courses
FOREIGN KEY (branch_id) REFERENCES Branches (branch_id) ON DELETE CASCADE;

ADD CONSTRAINT fk_branch_recommended_courses_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;


-- Begränsning för OverrideLogs:
--Se till att administrator_id, course_code, och student_social_security_number refererar till befintliga poster.
-- Se till att course_code, student_social_security_number, och administrator_id refererar till befintliga kurser, studenter och administratörer.

ALTER TABLE university.Override_logs

ADD CONSTRAINT fk_override_logs_administrator
FOREIGN KEY (administrator_id) REFERENCES Study_administrators (administrator_id) ON DELETE CASCADE;

ADD CONSTRAINT fk_override_logs_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;

ADD CONSTRAINT fk_override_logs_student
FOREIGN KEY (student_social_security_number) REFERENCES Students (student_social_security_number) ON DELETE CASCADE;


ADD CONSTRAINT fk_override_logs_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;

ADD CONSTRAINT fk_override_logs_student
FOREIGN KEY (student_social_security_number) REFERENCES Students (student_social_security_number) ON DELETE CASCADE;

ADD CONSTRAINT fk_override_logs_administrator
FOREIGN KEY (administrator_id) REFERENCES StudyAdministrators (administrator_id) ON DELETE CASCADE;

--Begränsning för Course_limits:
-- Se till att course_code refererar till befintliga kurser och att max_students är en positiv siffra.

ALTER TABLE university.Course_limits

ADD CONSTRAINT fk_course_limits_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;

ADD CONSTRAINT chk_positive_max_students
CHECK (max_students > 0);

--Begränsning för Waitlist:
-- Se till att course_code och student_social_security_number refererar till befintliga kurser och studenter.

ALTER TABLE university.Waitlist

ADD CONSTRAINT fk_waitlist_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;

ADD CONSTRAINT fk_waitlist_student
FOREIGN KEY (student_social_security_number) REFERENCES Students (student_social_security_number) ON DELETE CASCADE;


--Begränsning för Student_course_registrations:
--Se till att course_code och student_social_security_number refererar till befintliga kurser och studenter.

ALTER TABLE university.Student_course_registrations

ADD CONSTRAINT fk_student_registrations_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;

ADD CONSTRAINT fk_student_registrations_student
FOREIGN KEY (student_social_security_number) REFERENCES Students (student_social_security_number) ON DELETE CASCADE;



-- Begränsning för Course_classification:
-- Se till att course_code och classification_id refererar till befintliga kurser och klassifikationer.

ALTER TABLE university.Courses_classification

ADD CONSTRAINT fk_course_classification_mapping_classification
FOREIGN KEY (classification_id) REFERENCES CourseClassifications (classification_id) ON DELETE CASCADE;

ADD CONSTRAINT fk_course_classification_mapping_course
FOREIGN KEY (course_code) REFERENCES Courses (course_code) ON DELETE CASCADE;