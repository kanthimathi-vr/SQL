-- 47. Complaint Management System 
-- Objective: Track public complaints and resolutions. 
create database complaint;
use complaint;

-- Entities: 
-- • Complaints 
-- • Departments 
-- • Responses 
-- SQL Skills: 
-- • Status summary 
-- • Department workload 
-- Tables: 
-- • complaints (id, title, department_id, status) 
-- • departments (id, name) 
-- • responses (complaint_id, responder_id, message)

CREATE TABLE departments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE complaints (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    department_id BIGINT UNSIGNED NOT NULL,
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
);

CREATE TABLE responses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    complaint_id BIGINT UNSIGNED NOT NULL,
    responder_id BIGINT UNSIGNED NOT NULL,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE
    -- Assuming responder_id relates to an employee or user table; if not, you can omit FK constraint
);
INSERT INTO departments (name) VALUES 
('Customer Service'),
('Technical Support'),
('Billing');

INSERT INTO complaints (title, department_id, status) VALUES
('Internet not working', 2, 'open'),
('Wrong billing amount', 3, 'in_progress'),
('Late delivery of product', 1, 'resolved'),
('App crashes on launch', 2, 'open');

INSERT INTO responses (complaint_id, responder_id, message) VALUES
(1, 101, 'We are looking into the internet outage.'),
(2, 102, 'Billing team is verifying your charges.'),
(3, 103, 'Product was delivered late due to courier delay.'),
(3, 104, 'Customer has been compensated.'),
(4, 105, 'Please reinstall the app and try again.');
-- Summary of complaints by status
SELECT 
    status, 
    COUNT(*) AS total_complaints
FROM complaints
GROUP BY status;
--  Number of complaints handled per department
SELECT 
    d.name AS department_name,
    COUNT(c.id) AS complaint_count
FROM departments d
LEFT JOIN complaints c ON d.id = c.department_id
GROUP BY d.id, d.name;
-- Get all complaints with their latest response message
SELECT 
    c.id AS complaint_id,
    c.title,
    c.status,
    d.name AS department_name,
    r.message,
    r.created_at
FROM complaints c
JOIN departments d ON c.department_id = d.id
LEFT JOIN responses r ON r.complaint_id = c.id
WHERE r.created_at = (
    SELECT MAX(created_at) FROM responses WHERE complaint_id = c.id
)
ORDER BY c.id;
--  List all responses for a specific complaint (e.g., complaint_id = 3)
SELECT 
    responder_id, 
    message, 
    created_at
FROM responses
WHERE complaint_id = 3
ORDER BY created_at ASC;
