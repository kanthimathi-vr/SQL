-- 45. Job Scheduling System 
-- Objective: Store and track scheduled background jobs. 
create database job;
use job;
-- Entities: 
-- • Jobs 
-- • Schedules 
-- • Status Logs 
-- SQL Skills: 
-- • Last run, next run 
-- • Status count by job 
-- Tables: 
-- • jobs (id, name, frequency) 
-- • job_logs (id, job_id, run_time, status)


CREATE TABLE jobs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    frequency VARCHAR(50) NOT NULL  -- e.g. 'daily', 'hourly', 'weekly'
);

CREATE TABLE job_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    job_id BIGINT UNSIGNED NOT NULL,
    run_time DATETIME NOT NULL,
    status ENUM('success', 'failure', 'running') NOT NULL,
    FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
);
INSERT INTO jobs (name, frequency) VALUES
('Data Backup', 'daily'),
('Report Generation', 'hourly'),
('Email Notification', 'weekly');

INSERT INTO job_logs (job_id, run_time, status) VALUES
(1, '2025-07-10 01:00:00', 'success'),
(1, '2025-07-11 01:00:00', 'failure'),
(1, '2025-07-12 01:00:00', 'success'),
(2, '2025-07-12 08:00:00', 'success'),
(2, '2025-07-12 09:00:00', 'running'),
(3, '2025-07-07 12:00:00', 'success');
-- Get last run and next scheduled run per job (assuming frequency translates to interval)
SELECT
    j.id,
    j.name,
    MAX(l.run_time) AS last_run,
    CASE j.frequency
        WHEN 'hourly' THEN DATE_ADD(MAX(l.run_time), INTERVAL 1 HOUR)
        WHEN 'daily' THEN DATE_ADD(MAX(l.run_time), INTERVAL 1 DAY)
        WHEN 'weekly' THEN DATE_ADD(MAX(l.run_time), INTERVAL 1 WEEK)
        ELSE NULL
    END AS next_run
FROM jobs j
LEFT JOIN job_logs l ON j.id = l.job_id
GROUP BY j.id, j.name, j.frequency;
-- Count of job statuses per job
SELECT 
    j.id,
    j.name,
    SUM(CASE WHEN l.status = 'success' THEN 1 ELSE 0 END) AS success_count,
    SUM(CASE WHEN l.status = 'failure' THEN 1 ELSE 0 END) AS failure_count,
    SUM(CASE WHEN l.status = 'running' THEN 1 ELSE 0 END) AS running_count
FROM jobs j
LEFT JOIN job_logs l ON j.id = l.job_id
GROUP BY j.id, j.name;
-- All logs for a specific job (e.g., job_id = 1)
SELECT run_time, status
FROM job_logs
WHERE job_id = 1
ORDER BY run_time DESC;
