-- 24. Attendance Tracker 
-- Objective: Record daily student attendance. 
create database attendance;
use attendance;

-- Entities: 
-- • Students 
-- • Courses 
-- • Attendance 
-- SQL Skills: 
-- • Date logic 
-- • Summary per student/course 
-- Tables: 
-- • students (id, name) 
-- • courses (id, name) 
-- • attendance (student_id, course_id, date, status)


-- Students table
CREATE TABLE students (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Courses table
CREATE TABLE courses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Attendance table
CREATE TABLE attendance (
    student_id BIGINT UNSIGNED NOT NULL,
    course_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late') NOT NULL,
    PRIMARY KEY (student_id, course_id, date),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);
-- Students
INSERT INTO students (name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Courses
INSERT INTO courses (name) VALUES
('Mathematics'), ('Science');

-- Attendance records
INSERT INTO attendance (student_id, course_id, date, status) VALUES
(1, 1, '2025-07-12', 'Present'),
(2, 1, '2025-07-12', 'Absent'),
(3, 1, '2025-07-12', 'Late'),
(1, 2, '2025-07-12', 'Present'),
(2, 2, '2025-07-12', 'Present'),
(3, 2, '2025-07-12', 'Absent'),
(1, 1, '2025-07-13', 'Absent'),
(2, 1, '2025-07-13', 'Present'),
(3, 1, '2025-07-13', 'Present');
-- Attendance Summary Per Student Per Course
SELECT 
    s.name AS student,
    c.name AS course,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_days,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late_days,
    COUNT(*) AS total_days
FROM attendance a
JOIN students s ON a.student_id = s.id
JOIN courses c ON a.course_id = c.id
GROUP BY s.id, c.id
ORDER BY student, course;
-- Get Attendance for a Specific Date
SELECT 
    s.name AS student,
    c.name AS course,
    a.status
FROM attendance a
JOIN students s ON a.student_id = s.id
JOIN courses c ON a.course_id = c.id
WHERE a.date = '2025-07-12'
ORDER BY course, student;
-- Student's Attendance Over Time (e.g., Alice)
SELECT 
    a.date,
    c.name AS course,
    a.status
FROM attendance a
JOIN courses c ON a.course_id = c.id
WHERE a.student_id = 1
ORDER BY a.date, course;
