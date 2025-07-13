-- 10. Project Management Tracker 
-- Objective: Track projects, tasks, and assignment status. 
-- Entities: 
-- • Projects 
-- • Tasks 
CREATE TABLE task_assignments (
    task_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (task_id, user_id),
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
INSERT INTO task_assignments (task_id, user_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 1),
(5, 2);

-- • Users 
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

create database tracker;
use tracker;

-- Tables: 
-- • projects (id, name) 
CREATE TABLE projects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL
);
INSERT INTO projects (name) VALUES
('Website Redesign'),
('Mobile App Development');

-- • tasks (id, project_id, name, status) 
CREATE TABLE tasks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    project_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(200) NOT NULL,
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    FOREIGN KEY (project_id) REFERENCES projects(id)
);
INSERT INTO tasks (project_id, name, status) VALUES
(1, 'Design homepage', 'completed'),
(1, 'Implement homepage', 'in_progress'),
(1, 'QA Testing', 'pending'),
(2, 'Login Screen', 'completed'),
(2, 'Payment Integration', 'pending');

-- • task_assignments (task_id, user_id)
-- SQL Skills: 
-- • JOINs 
-- • Status tracking and counts 
-- • User-task associations 
--  List All Tasks with Project Name and Assigned Users
SELECT 
    t.id AS task_id,
    t.name AS task_name,
    t.status,
    p.name AS project,
    u.name AS assigned_user
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN task_assignments ta ON t.id = ta.task_id
JOIN users u ON ta.user_id = u.id
ORDER BY p.name, t.name;
-- Tasks Assigned to a Specific User (e.g. Bob)
SELECT 
    t.name AS task,
    p.name AS project,
    t.status
FROM tasks t
JOIN task_assignments ta ON t.id = ta.task_id
JOIN users u ON ta.user_id = u.id
JOIN projects p ON t.project_id = p.id
WHERE u.name = 'Bob';
--  Count of Completed Tasks per User
SELECT 
    u.name AS user,
    COUNT(*) AS completed_tasks
FROM users u
JOIN task_assignments ta ON u.id = ta.user_id
JOIN tasks t ON ta.task_id = t.id
WHERE t.status = 'completed'
GROUP BY u.id;
-- Task Completion Summary by Project
SELECT 
    p.name AS project,
    SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completed,
    COUNT(t.id) AS total,
    ROUND(SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) / COUNT(t.id) * 100, 1) AS percent_complete
FROM tasks t
JOIN projects p ON t.project_id = p.id
GROUP BY p.id;
