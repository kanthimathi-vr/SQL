-- 44. Course Feedback System 
-- Objective: Collect and analyze course feedback. 
create database feedback;
use feedback;

-- Entities: 
-- • Courses 
-- • Feedback 
-- SQL Skills: 
-- • Sentiment tracking 
-- • AVG rating per course 
-- Tables: 
-- • courses (id, title) 
-- • feedback (id, course_id, user_id, rating, comments) 


CREATE TABLE courses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL
);

CREATE TABLE feedback (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);
INSERT INTO courses (title) VALUES
('Introduction to SQL'),
('Advanced Python Programming'),
('Web Development Basics');

INSERT INTO feedback (course_id, user_id, rating, comments) VALUES
(1, 101, 5, 'Excellent course, very clear explanations.'),
(1, 102, 4, 'Good content but could use more examples.'),
(2, 103, 3, 'Average, some topics were confusing.'),
(2, 104, 5, 'Loved the projects and assignments!'),
(3, 105, 2, 'Too basic for me.'),
(3, 106, 4, 'Well structured and easy to follow.');
-- Average rating per course
SELECT 
    c.id,
    c.title,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    COUNT(f.id) AS feedback_count
FROM courses c
LEFT JOIN feedback f ON c.id = f.course_id
GROUP BY c.id, c.title;
-- Sentiment tracking by keyword in comments (simple example)
SELECT 
    course_id,
    COUNT(*) AS total_feedback,
    SUM(CASE WHEN comments LIKE '%excellent%' OR comments LIKE '%loved%' THEN 1 ELSE 0 END) AS positive_feedback,
    SUM(CASE WHEN comments LIKE '%confusing%' OR comments LIKE '%too basic%' THEN 1 ELSE 0 END) AS negative_feedback
FROM feedback
GROUP BY course_id;
-- Get all feedback for a specific course (e.g., course_id = 1)
SELECT 
    user_id,
    rating,
    comments
FROM feedback
WHERE course_id = 1
ORDER BY rating DESC;
