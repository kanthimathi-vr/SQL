-- 35. Survey Collection System 
-- Objective: Store responses for surveys and analyze results. 
create database survey;
use survey;
-- Entities: 
-- • Surveys 
-- • Questions 
-- • Responses 
-- SQL Skills: 
-- • COUNT and GROUP BY 
-- • Pivot-style summaries 
-- Tables: 
-- • surveys (id, title) 
-- • questions (id, survey_id, question_text) 
-- • responses (user_id, question_id, answer_text)


CREATE TABLE surveys (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    survey_id BIGINT UNSIGNED NOT NULL,
    question_text TEXT NOT NULL,
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE
);

CREATE TABLE responses (
    user_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,
    answer_text TEXT NOT NULL,
    PRIMARY KEY (user_id, question_id),
    FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);
-- Insert Surveys
INSERT INTO surveys (title) VALUES 
('Customer Satisfaction Survey'),
('Product Feedback Survey');

-- Insert Questions for Survey 1 (survey_id = 1)
INSERT INTO questions (survey_id, question_text) VALUES
(1, 'How satisfied are you with our service?'),
(1, 'Would you recommend us to others?');

-- Insert Questions for Survey 2 (survey_id = 2)
INSERT INTO questions (survey_id, question_text) VALUES
(2, 'How do you rate the product quality?'),
(2, 'What features would you like to see?');
SELECT * FROM questions;

-- Insert responses from users (assuming user_id = 101 to 104)
INSERT INTO responses (user_id, question_id, answer_text) VALUES
(101, 1, 'Very satisfied'),
(101, 2, 'Yes'),
(102, 1, 'Satisfied'),
(102, 2, 'Maybe'),
(103, 3, 'Excellent'),
(103, 4, 'More colors'),
(104, 3, 'Good'),
(104, 4, 'Better battery life');
--  Count of responses per question
SELECT 
    q.id AS question_id,
    q.question_text,
    COUNT(r.user_id) AS total_responses
FROM questions q
LEFT JOIN responses r ON q.id = r.question_id
GROUP BY q.id, q.question_text
ORDER BY q.id;
-- Summary of answers (pivot-like) for a question
SELECT 
    answer_text, 
    COUNT(*) AS total 
FROM responses 
WHERE question_id = 1 
GROUP BY answer_text 
ORDER BY total DESC;
-- View all responses for a given survey (e.g., survey_id = 1)
SELECT 
    r.user_id,
    q.question_text,
    r.answer_text
FROM responses r
JOIN questions q ON r.question_id = q.id
WHERE q.survey_id = 1
ORDER BY r.user_id, q.id;

