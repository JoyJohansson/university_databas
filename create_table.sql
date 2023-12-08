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
    namSERIALe VARCHAR(255) UNIQUE NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS university.program_institutions (
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
    program_id INT,
    FOREIGN KEY (program_id) REFERENCES university.programs (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS university.program_branches (
    program_id INT,
    branch_id INT,
    PRIMARY KEY (program_id, branch_id),
    FOREIGN KEY (program_id) REFERENCES university.programs (id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES university.branches (id) ON DELETE CASCADE
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

CREATE TABLE IF NOT EXISTS university.courses_classification (
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
    social_security_number VARCHAR(10) PRIMARY KEY UNIQUE NOT NULL,
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
    max_students INT NOT NULL,
    FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS university.waitlist (
    id SERIAL PRIMARY KEY,
    student_social_security_number VARCHAR(10),
    FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
    course_code VARCHAR(5),
    FOREIGN KEY (course_code) REFERENCES university.limited_courses (course_code) ON DELETE CASCADE,
    registration_date DATE DEFAULT CURRENT_DATE,
    UNIQUE (course_code, student_social_security_number)
);

DROP TABLE university.student_course_registrations CASCADE;
CREATE TABLE IF NOT EXISTS university.student_course_registrations (
    id SERIAL PRIMARY KEY,
    student_social_security_number VARCHAR(10) NOT NULL,
    FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
    course_code VARCHAR(6),
    FOREIGN KEY (course_code) REFERENCES university.courses (code),
    registration_date DATE DEFAULT CURRENT_DATE,
    UNIQUE (student_social_security_number, course_code)
);

CREATE TABLE IF NOT EXISTS university.study_administrators (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS university.override_logs (
    id SERIAL PRIMARY KEY,
    administrator_id INT,
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

CREATE TABLE IF NOT EXISTS university.waitlist (
    id SERIAL PRIMARY KEY,
    course_code VARCHAR(6) NOT NULL,
    FOREIGN KEY (course_code) REFERENCES university.limited_courses (course_code) ON DELETE CASCADE,
    student_social_security_number VARCHAR(10) NOT NULL,
    FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS university.student_completed_courses (
  student_social_security_number VARCHAR(10),
  FOREIGN KEY (student_social_security_number) REFERENCES university.students (social_security_number) ON DELETE CASCADE,
  course_code VARCHAR(6),
  FOREIGN KEY (course_code) REFERENCES university.courses (code) ON DELETE CASCADE,
  PRIMARY KEY (student_social_security_number, course_code),
  grade VARCHAR,
  FOREIGN KEY (grade) REFERENCES university.grades (symbol) ON DELETE CASCADE,
  completed_date DATE DEFAULT CURRENT_DATE
);

