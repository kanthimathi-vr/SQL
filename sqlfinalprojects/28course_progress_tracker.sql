-- 28. Course Progress Tracker 
-- Objective: Monitor lesson completion per student. 
create database cprogress;
use cprogress;

-- Entities: 
-- • Courses 
-- • Lessons 
-- • Progress 
-- SQL Skills: 
-- • Completion % calculation 
-- • JOINs and GROUP BY 
-- Tables: 
-- • courses (id, name) 
-- • lessons (id, course_id, title) 
-- • progress (student_id, lesson_id, completed_at)

-- Students table
CREATE TABLE students (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Courses table
CREATE TABLE courses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL
);

-- Lessons table
CREATE TABLE lessons (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);

-- Progress table
CREATE TABLE progress (
    student_id BIGINT UNSIGNED NOT NULL,
    lesson_id BIGINT UNSIGNED NOT NULL,
    completed_at DATETIME NOT NULL,
    PRIMARY KEY (student_id, lesson_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);
-- Students
INSERT INTO students (name) VALUES
('Alice'), ('Bob');

-- Courses
INSERT INTO courses (name) VALUES
('MySQL Basics'), ('Web Development');

-- Lessons
INSERT INTO lessons (course_id, title) VALUES
(1, 'Introduction to SQL'),
(1, 'SELECT Statements'),
(1, 'Filtering and Sorting'),
(2, 'HTML Basics'),
(2, 'CSS Fundamentals');

-- Progress (student_id, lesson_id, completed_at)
-- Alice completed 2 lessons from MySQL Basics
INSERT INTO progress (student_id, lesson_id, completed_at) VALUES
(1, 1, '2025-07-10 10:00:00'),
(1, 2, '2025-07-11 11:00:00'),
(2, 4, '2025-07-12 09:30:00');  -- Bob completed one lesson from Web Dev
-- Course Completion % per Student per Course
SELECT 
    s.name AS student,
    c.name AS course,
    COUNT(DISTINCT p.lesson_id) AS lessons_completed,
    COUNT(DISTINCT l.id) AS total_lessons,
    ROUND(COUNT(DISTINCT p.lesson_id) / COUNT(DISTINCT l.id) * 100, 2) AS completion_percentage
FROM courses c
JOIN lessons l ON c.id = l.course_id
JOIN students s ON 1=1
LEFT JOIN progress p ON p.lesson_id = l.id AND p.student_id = s.id
GROUP BY s.id, c.id
ORDER BY s.name, c.name;
--  List Lessons Completed by a Student (e.g., Alice)
SELECT 
    l.title AS lesson,
    c.name AS course,
    p.completed_at
FROM progress p
JOIN lessons l ON p.lesson_id = l.id
JOIN courses c ON l.course_id = c.id
WHERE p.student_id = 1
ORDER BY p.completed_at;
-- List Incomplete Lessons for a Student (e.g., Bob)
SELECT 
    s.name AS student,
    c.name AS course,
    l.title AS lesson
FROM students s
JOIN lessons l ON 1=1
JOIN courses c ON c.id = l.course_id
LEFT JOIN progress p ON p.lesson_id = l.id AND p.student_id = s.id
WHERE s.id = 2 AND p.lesson_id IS NULL
ORDER BY c.name, l.title;








