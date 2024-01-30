--      1. Step Create DB with user

CREATE DATABASE UniversityDB;

CREATE USER master WITH password 'qwerty1234';

GRANT ALL ON DATABASE UniversityDB TO master;

--      2. Step Create tables for Db "UniversityDB"

\c UniversityDB

CREATE TABLE Faculty (
    faculty_id SERIAL PRIMARY KEY,
    faculty_name VARCHAR(255) NOT NULL
);
 CREATE TABLE Student (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(255) NOT NULL,
    faculty_id INT REFERENCES Faculty(faculty_id)
);
CREATE TABLE Dean (
    dean_id SERIAL PRIMARY KEY,
    dean_name VARCHAR(255) NOT NULL,
    faculty_id INT REFERENCES Faculty(faculty_id)
);
CREATE TABLE Lecturer (
    lecturer_id SERIAL PRIMARY KEY,
    lecturer_name VARCHAR(255) NOT NULL
);CREATE TABLE Program (
    program_id SERIAL PRIMARY KEY,
    program_name VARCHAR(255) NOT NULL
);
CREATE TABLE Subject (
    subject_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(255) NOT NULL,
    subject_cost DECIMAL(10, 2) NOT NULL
);
CREATE TABLE Course (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    program_id INT REFERENCES Program(program_id),
    semester INT NOT NULL
);
--This is bridge table (many-to-many)
CREATE TABLE StudentCourse (
    student_id INT REFERENCES Student(student_id),
    course_id INT REFERENCES Course(course_id),
    PRIMARY KEY (student_id, course_id)
);

--This is bridge table (many-to-many)
CREATE TABLE LecturerCourse (
    lecturer_id INT REFERENCES Lecturer(lecturer_id),
    course_id INT REFERENCES Course(course_id),
    PRIMARY KEY (lecturer_id, course_id)
);
--This is bridge table (many-to-many)
CREATE TABLE SubjectCourse (
    subject_id INT REFERENCES Subject(subject_id),
    course_id INT REFERENCES Course(course_id),
    PRIMARY KEY (subject_id, course_id)
);

CREATE TABLE StudyPlan (
    study_plan_id SERIAL PRIMARY KEY,
    course_id INT REFERENCES Course(course_id),
    subject_id INT REFERENCES Subject(subject_id),
    lecturer_id INT REFERENCES Lecturer(lecturer_id),
    lessons_count INT NOT NULL
);
CREATE TABLE TuitionCost (
    tuition_cost_id SERIAL PRIMARY KEY,
    subject_id INT REFERENCES Subject(subject_id),
    course_id INT REFERENCES Course(course_id),
    lessons_count INT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
);
CREATE TABLE CourseParticipation (
    participation_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES Student(student_id),
    course_id INT REFERENCES Course(course_id),
    semesters_count INT NOT NULL
);
CREATE TABLE Exam (
    exam_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES Student(student_id),
    subject_id INT REFERENCES Subject(subject_id),
    grade INT NOT NULL
);

--      3. step insert data in tables

INSERT INTO Faculty (faculty_name)
    VALUES ('Faculty of Science'),
            ('Faculty of Arts'),
            ('Faculty of Science'),
            ('Faculty of Arts');

INSERT INTO Dean (dean_name, faculty_id)
    VALUES ('Prof. David', 1),
            ('Dr. Art', 2),
            ('Ms. Anna', 3),
            ('Anush', 4);

INSERT INTO Student (student_name, faculty_id)
    VALUES ('Poxos Poxosyan', 1),
            ('Valod Valodyan', 2),
            ('Art Jan', 3),
            ('Davo Noroyan', 4);

INSERT INTO Lecturer (lecturer_name)
    VALUES ('Husikyan'),
            ('Babayan'),
            ('Poghosyan'),
            ('Simonyan');

INSERT INTO Subject (subject_name, subject_cost)
    VALUES ('Mathematics', 400000),
            ('Litetrature',600000),
            ('Programming', 800000),
            ('Esiminch', 1000000);

INSERT INTO Program (program_name)
    VALUES ('Computer Science'),
            ('History'),('Bio'),
            ('Herahaxordakcutyun');

INSERT INTO  Course (course_name,program_id, semester)
    VALUES ('HH001', 1,1),
            ('HR360',2,1),
            ('HR300',3,2),
            ('AM007',3,3);

INSERT INTO StudentCourse (student_id, course_id)
     VALUES (1,1),
             (2,2),
             (3,2),
             (4,1);

INSERT INTO LecturerCourse (lecturer_id, course_id)
    VALUES (1,4),
            (3,2),
            (4,4),
            (2,3);

INSERT INTO  SubjectCourse (subject_id, course_id)
    VALUES (1,1),
            (2,2),
            (3,3),
            (4,4);

INSERT INTO StudyPlan (course_id, subject_id, lecturer_id, lessons_count)
    VALUES (1, 1, 1, 20),
            (2,2,2,15),
            (3,3,3,10),
            (4,4,4,8);

INSERT INTO TuitionCost (subject_id, course_id, lessons_count, cost)
    VALUES (1, 1, 20, 50000),
            (2,2,5,30000),
            (3,3,12,25000),
            (4,1,30,52400);

INSERT INTO CourseParticipation (student_id, course_id, semesters_count)
    VALUES (1, 1, 2),
            (2,2,1),
            (3,3,4),
            (4,1,2);

INSERT INTO Exam (student_id, subject_id, grade)
    VALUES (1, 1, 90),
            (2,3,30),
            (3,2,75),
            (4,3,95);


--      4. step SELECT queries

--Q1

SELECT
    f.faculty_name,
    c.course_name,
    SUM(tc.cost * sp.lessons_count) AS yearly_fee
FROM
    Faculty f
JOIN Dean d ON f.faculty_id = d.faculty_id
JOIN Student s ON f.faculty_id = s.faculty_id
JOIN StudentCourse sc ON s.student_id = sc.student_id
JOIN Course c ON sc.course_id = c.course_id
JOIN StudyPlan sp ON c.course_id = sp.course_id
JOIN TuitionCost tc ON sp.subject_id = tc.subject_id AND sp.course_id = tc.course_id
GROUP BY
    f.faculty_name,
    c.course_name;

--Q2

SELECT
    SUM(tc.cost * sp.lessons_count * cp.semesters_count) AS total_yearly_income
FROM
    TuitionCost tc
JOIN StudyPlan sp ON tc.subject_id = sp.subject_id AND tc.course_id = sp.course_id
JOIN CourseParticipation cp ON tc.course_id = cp.course_id
WHERE
    cp.semesters_count > 0;

--Q3
SELECT
    s.student_name,
    c.course_name,
    f.faculty_name,
    sub.subject_name,
    e.grade,
    CASE
        WHEN e.grade > 70 THEN 'Good'
        ELSE 'Bad'
    END AS comment
FROM
    Exam e
JOIN Student s ON e.student_id = s.student_id
JOIN Subject sub ON e.subject_id = sub.subject_id
JOIN StudentCourse sc ON s.student_id = sc.student_id
JOIN Course c ON sc.course_id = c.course_id
JOIN Faculty f ON s.faculty_id = f.faculty_id;

--Q4
SELECT
    s.student_name,
    c.course_name,
    f.faculty_name,
    AVG(e.grade) AS average_grade,
    CASE
        WHEN AVG(e.grade) >= 70 THEN 'Finished'
        ELSE 'Forwarded next course'
    END AS comment
FROM
    Exam e
JOIN Student s ON e.student_id = s.student_id
JOIN StudentCourse sc ON s.student_id = sc.student_id
JOIN Course c ON sc.course_id = c.course_id
JOIN Faculty f ON s.faculty_id = f.faculty_id
GROUP BY
    s.student_name,
    c.course_name,
    f.faculty_name;

--Q5
WITH StudentAverages AS (
    SELECT
        s.student_name,
        c.course_name,
        f.faculty_name,
        AVG(e.grade) AS average_grade,
        RANK() OVER (PARTITION BY c.course_name ORDER BY AVG(e.grade) DESC) AS rank_desc,
        RANK() OVER (PARTITION BY c.course_name ORDER BY AVG(e.grade) ASC) AS rank_asc
    FROM
        Exam e
    JOIN Student s ON e.student_id = s.student_id
    JOIN StudentCourse sc ON s.student_id = sc.student_id
    JOIN Course c ON sc.course_id = c.course_id
    JOIN Faculty f ON s.faculty_id = f.faculty_id
    GROUP BY
        s.student_name,
        c.course_name,
        f.faculty_name
)

SELECT
    student_name,
    course_name,
    faculty_name,
    CASE WHEN average_grade > 70 THEN average_grade END AS best_student_grade,
    CASE WHEN average_grade < 70 THEN average_grade END AS worst_student_grade
FROM
    StudentAverages
WHERE
    rank_asc = 1 OR rank_desc = 1
ORDER BY
    course_name, faculty_name, rank_desc;

--Q6
SELECT
    s.student_name,
    f.faculty_name,
    c.course_name,
    tc.cost AS tuition_cost_per_hour,
    p.program_name,
    tc.cost * sp.lessons_count AS program_cost,
    tc.cost * sp.lessons_count * cp.semesters_count AS total_cost
FROM
    Student s
JOIN Faculty f ON s.faculty_id = f.faculty_id
JOIN StudentCourse sc ON s.student_id = sc.student_id
JOIN Course c ON sc.course_id = c.course_id
JOIN StudyPlan sp ON c.course_id = sp.course_id
JOIN TuitionCost tc ON sp.subject_id = tc.subject_id AND sp.course_id = tc.course_id
JOIN CourseParticipation cp ON s.student_id = cp.student_id AND c.course_id = cp.course_id
JOIN Program p ON c.program_id = p.program_id;
