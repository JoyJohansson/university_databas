
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
CREATE OR REPLACE TRIGGER before_student_registration
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
    FROM university.Waitlist
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
BEFORE INSERT ON university.waitlist
FOR EACH ROW
EXECUTE FUNCTION university.restrict_adding_to_waitlist();