-- 6. Employee Timesheet Tracker 
-- Objective: Store and calculate employee work logs on projects. 
create database timesheet;
use timesheet;

-- Entities: 
-- • Employees 
-- • Projects 
-- • Timesheets 
 
-- Tables: 
-- • employees (id, name, dept) 
CREATE TABLE employees (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dept VARCHAR(100)
);
INSERT INTO employees (name, dept) VALUES
('Alice', 'Engineering'),
('Bob', 'Marketing'),
('Charlie', 'Design');

-- • projects (id, name) 
CREATE TABLE projects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL
);
INSERT INTO projects (name) VALUES
('Website Redesign'),
('Product Launch'),
('CRM Integration');

-- • timesheets (id, emp_id, project_id, hours, date) 
CREATE TABLE timesheets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NOT NULL,
    hours DECIMAL(5,2) NOT NULL CHECK (hours >= 0),
    date DATE NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES employees(id),
    FOREIGN KEY (project_id) REFERENCES projects(id)
);
INSERT INTO timesheets (emp_id, project_id, hours, date) VALUES
(1, 1, 4.0, '2025-07-08'),
(1, 2, 3.5, '2025-07-09'),
(2, 2, 5.0, '2025-07-10'),
(3, 1, 6.0, '2025-07-11'),
(1, 1, 4.5, '2025-07-12'),
(2, 3, 2.5, '2025-07-13');

-- SQL Skills: 
-- • JOINs to fetch timesheet per project 
SELECT 
    t.date,
    e.name AS employee,
    p.name AS project,
    t.hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
JOIN projects p ON t.project_id = p.id
ORDER BY t.date DESC;
SELECT 
    e.name AS employee,
    p.name AS project,
    SUM(t.hours) AS total_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
JOIN projects p ON t.project_id = p.id
GROUP BY e.id, p.id
ORDER BY employee, project;

-- • GROUP BY employee/project 
-- • Date filters for weekly/monthly hours
SELECT 
    e.name AS employee,
    SUM(t.hours) AS total_week_hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
WHERE t.date >= CURDATE() - INTERVAL 7 DAY
GROUP BY e.id;

SELECT 
    p.name AS project,
    MONTH(t.date) AS month,
    SUM(t.hours) AS total_hours
FROM timesheets t
JOIN projects p ON t.project_id = p.id
WHERE YEAR(t.date) = YEAR(CURDATE()) AND MONTH(t.date) = MONTH(CURDATE())
GROUP BY p.id, MONTH(t.date);

SELECT 
    t.date,
    p.name AS project,
    t.hours
FROM timesheets t
JOIN employees e ON t.emp_id = e.id
JOIN projects p ON t.project_id = p.id
WHERE e.name = 'Alice'
ORDER BY t.date;




