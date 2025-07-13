-- 29. Recruitment Portal Database 
-- Objective: Track job applications and candidate status. 
create database recruit;
use recruit;

-- Entities: 
-- • Jobs 
-- • Candidates 
-- • Applications 
-- SQL Skills: 
-- • Filter candidates by status 
-- • Job-wise applicant count 
-- Tables: 
-- • jobs (id, title, company) 
-- • candidates (id, name) 
-- • applications (job_id, candidate_id, status, applied_at) 


CREATE TABLE jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    company VARCHAR(150) NOT NULL
);

CREATE TABLE candidates (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE applications (
    job_id BIGINT UNSIGNED NOT NULL,
    candidate_id BIGINT UNSIGNED NOT NULL,
    status ENUM('applied', 'interview', 'offered', 'rejected', 'hired') NOT NULL DEFAULT 'applied',
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (job_id, candidate_id),
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE
);
-- Jobs
INSERT INTO jobs (title, company) VALUES
('Software Engineer', 'TechCorp'),
('Data Analyst', 'DataWorks'),
('Product Manager', 'Innovate Inc');

-- Candidates
INSERT INTO candidates (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Lee');

-- Applications
INSERT INTO applications (job_id, candidate_id, status, applied_at) VALUES
(1, 1, 'applied', '2025-07-01 09:00:00'),
(1, 2, 'interview', '2025-07-02 10:30:00'),
(2, 3, 'offered', '2025-07-03 11:00:00'),
(3, 1, 'rejected', '2025-07-04 12:00:00');
--  Filter Candidates by Application Status (e.g., 'interview')
SELECT 
    c.id AS candidate_id,
    c.name AS candidate_name,
    j.title AS job_title,
    j.company,
    a.status,
    a.applied_at
FROM applications a
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
WHERE a.status = 'interview'
ORDER BY a.applied_at DESC;
-- Count Applicants per Job
SELECT 
    j.id AS job_id,
    j.title,
    j.company,
    COUNT(a.candidate_id) AS total_applicants
FROM jobs j
LEFT JOIN applications a ON j.id = a.job_id
GROUP BY j.id, j.title, j.company
ORDER BY total_applicants DESC;
-- List All Applications of a Candidate (e.g., candidate_id = 1)
SELECT 
    j.title AS job_title,
    j.company,
    a.status,
    a.applied_at
FROM applications a
JOIN jobs j ON a.job_id = j.id
WHERE a.candidate_id = 1
ORDER BY a.applied_at DESC;






