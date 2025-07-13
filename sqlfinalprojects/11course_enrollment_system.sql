-- 11. Course Enrollment System 
-- Objective: Manage courses, students, and enrollments. 
create database course;
use course;
-- Entities: 
-- • Courses 
-- • Students 
-- • Enrollments 

-- Tables: 
-- • courses (id, title, instructor) 
CREATE TABLE courses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    instructor VARCHAR(100) NOT NULL
);
INSERT INTO courses (title, instructor) VALUES
('Database Systems', 'Dr. Smith'),
('Web Development', 'Prof. Adams'),
('AI Fundamentals', 'Dr. Johnson');

-- • students (id, name, email) 
CREATE TABLE students (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);
INSERT INTO students (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');

-- • enrollments (course_id, student_id, enroll_date) 
CREATE TABLE enrollments (
    course_id BIGINT UNSIGNED NOT NULL,
    student_id BIGINT UNSIGNED NOT NULL,
    enroll_date timestamp NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (course_id, student_id),
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);
INSERT INTO enrollments (course_id, student_id, enroll_date) VALUES
(1, 1, '2025-07-01'),
(1, 2, '2025-07-02'),
(2, 1, '2025-07-03'),
(3, 3, '2025-07-04');

-- SQL Skills: 
-- • Many-to-many relationships 
-- • Queries for students per course 
--  List All Students Enrolled in Each Course
SELECT 
    c.title AS course,
    s.name AS student,
    s.email,
    e.enroll_date
FROM enrollments e
JOIN courses c ON e.course_id = c.id
JOIN students s ON e.student_id = s.id
ORDER BY c.title, s.name;

-- • Count enrolled students 
-- Count of Students Per Course
SELECT 
    c.title AS course,
    COUNT(e.student_id) AS enrolled_students
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id;
--  Courses a Specific Student Is Enrolled In (e.g., Bob)
SELECT 
    s.name AS student,
    c.title AS course,
    c.instructor,
    e.enroll_date
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
WHERE s.name = 'Bob';
--  Students Not Enrolled in Any Course
SELECT 
    s.name,
    s.email
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
WHERE e.course_id IS NULL;


