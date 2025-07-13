-- 7. Leave Management System 
-- Objective: Track employee leave requests, approvals, and balances. 
create database leavemanagement;
use leavemanagement;
-- Entities: 
-- • Employees 
-- • Leave Types 
-- • Leave Requests 

-- Tables: 
-- • employees (id, name) 
CREATE TABLE employees (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO employees (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- • leave_types (id, type_name) 
CREATE TABLE leave_types (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL
);
INSERT INTO leave_types (type_name) VALUES
('Sick Leave'),
('Vacation'),
('Maternity Leave');

-- • leave_requests (id, emp_id, leave_type_id, from_date, to_date, 
-- status)
CREATE TABLE leave_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT UNSIGNED NOT NULL,
    leave_type_id BIGINT UNSIGNED NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (emp_id) REFERENCES employees(id),
    FOREIGN KEY (leave_type_id) REFERENCES leave_types(id),
    CHECK (from_date <= to_date)
);
INSERT INTO leave_requests (emp_id, leave_type_id, from_date, to_date, status) VALUES
(1, 1, '2025-07-01', '2025-07-03', 'approved'),
(1, 2, '2025-07-15', '2025-07-20', 'pending'),
(2, 1, '2025-07-10', '2025-07-11', 'approved'),
(3, 3, '2025-07-01', '2025-09-30', 'approved');

-- SQL Skills: 
-- • Constraints on overlapping dates 
SELECT 
    lr.id,
    e.name AS employee,
    lt.type_name,
    lr.from_date,
    lr.to_date,
    lr.status
FROM leave_requests lr
JOIN employees e ON lr.emp_id = e.id
JOIN leave_types lt ON lr.leave_type_id = lt.id
ORDER BY lr.from_date DESC;
--  Total Leave Days Taken by Each Employee (Approved Only)
SELECT 
    e.name AS employee,
    SUM(DATEDIFF(lr.to_date, lr.from_date) + 1) AS total_days
FROM leave_requests lr
JOIN employees e ON lr.emp_id = e.id
WHERE lr.status = 'approved'
GROUP BY e.id;
-- Check Overlapping Leave Requests (for a new request)
SELECT *
FROM leave_requests
WHERE emp_id = 1
  AND status = 'approved'
  AND (
        from_date <= '2025-07-04'
        AND to_date >= '2025-07-02'
      );

-- • Aggregate leaves by employee 
-- Show Current Pending Requests
SELECT 
    e.name,
    lt.type_name,
    lr.from_date,
    lr.to_date
FROM leave_requests lr
JOIN employees e ON lr.emp_id = e.id
JOIN leave_types lt ON lr.leave_type_id = lt.id
WHERE lr.status = 'pending';
-- Update Leave Request Status (e.g., approve Alice’s vacation)
UPDATE leave_requests
SET status = 'approved'
WHERE id = 2;







