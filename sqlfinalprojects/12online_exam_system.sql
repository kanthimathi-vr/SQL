-- 12. Online Exam System 
-- Objective: Store exams, questions, and student answers.
create database onlineexam;
use onlineexam;
 
-- Entities: 
-- • Exams 
-- • Questions 
-- • Student Answers 

-- Tables: 
-- • exams (id, course_id, date) 
CREATE TABLE exams (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL
);
INSERT INTO exams (course_id, date) VALUES
(1, '2025-07-10');  -- Course 1: Database Systems

-- • questions (id, exam_id, text, correct_option) 
CREATE TABLE questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    exam_id BIGINT UNSIGNED NOT NULL,
    text TEXT NOT NULL,
    correct_option CHAR(1) NOT NULL CHECK (correct_option IN ('A', 'B', 'C', 'D')),
    FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
);
INSERT INTO questions (exam_id, text, correct_option) VALUES
(1, 'What does SQL stand for?', 'A'),
(1, 'Which command is used to remove a table?', 'B'),
(1, 'What is a PRIMARY KEY?', 'C');


CREATE TABLE students (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);
INSERT INTO students (name, email) VALUES
('Alice Johnson', 'alice.johnson@example.com'),
('Bob Smith', 'bob.smith@example.com'),
('Charlie Lee', 'charlie.lee@example.com'),
('Diana Patel', 'diana.patel@example.com'),
('Ethan Kim', 'ethan.kim@example.com');

-- • student_answers (student_id, question_id, selected_option) 
CREATE TABLE student_answers (
    student_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,
    selected_option CHAR(1) NOT NULL CHECK (selected_option IN ('A', 'B', 'C', 'D')),
    PRIMARY KEY (student_id, question_id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);
-- Alice (student_id = 1)
INSERT INTO student_answers (student_id, question_id, selected_option) VALUES
(1, 1, 'A'),  -- correct
(1, 2, 'C'),  -- incorrect
(1, 3, 'C');  -- correct

-- Bob (student_id = 2)
INSERT INTO student_answers (student_id, question_id, selected_option) VALUES
(2, 1, 'B'),  -- incorrect
(2, 2, 'B'),  -- correct
(2, 3, 'D');  -- incorrect

-- Charlie (student_id = 3)
INSERT INTO student_answers (student_id, question_id, selected_option) VALUES
(3, 1, 'A'),  -- correct
(3, 2, 'B'),  -- correct
(3, 3, 'C');  -- correct

SELECT * FROM student_answers;


-- SQL Skills: 
-- • Join exam with answers 
-- • Calculate scores with correct answers 
SELECT 
    sa.student_id,
    s.name AS student_name,
    q.text AS question,
    sa.selected_option,
    q.correct_option,
    CASE 
        WHEN sa.selected_option = q.correct_option THEN 1 
        ELSE 0 
    END AS is_correct
FROM student_answers sa
JOIN students s ON sa.student_id = s.id
JOIN questions q ON sa.question_id = q.id
ORDER BY sa.student_id, sa.question_id;
--  Calculate Total Score Per Student
SELECT 
    sa.student_id,
    s.name AS student_name,
    COUNT(*) AS total_questions,
    SUM(CASE WHEN sa.selected_option = q.correct_option THEN 1 ELSE 0 END) AS correct_answers,
    ROUND(SUM(CASE WHEN sa.selected_option = q.correct_option THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS percentage_score
FROM student_answers sa
JOIN students s ON sa.student_id = s.id
JOIN questions q ON sa.question_id = q.id
GROUP BY sa.student_id;
--  Questions Not Yet Answered by a Student (e.g., Charlie = student_id 3)
SELECT q.id, q.text
FROM questions q
WHERE q.id NOT IN (
    SELECT question_id
    FROM student_answers
    WHERE student_id = 3
);

