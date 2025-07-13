-- 20. Salary Management System 
-- Objective: Calculate monthly salaries with deductions. 
create database salary;
use salary;

-- Entities: 
-- • Employees 
-- • Salaries 
-- • Deductions 
-- SQL Skills: 
-- • Monthly aggregation 
-- • Conditional bonus 
-- Tables: 
-- • employees (id, name) 
-- • salaries (emp_id, month, base, bonus) 
-- • deductions (emp_id, month, reason, amount)

-- Employees table
CREATE TABLE employees (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Salaries table
CREATE TABLE salaries (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT UNSIGNED NOT NULL,
    month DATE NOT NULL,  -- first day of month (e.g., '2025-07-01')
    base DECIMAL(10, 2) NOT NULL,
    bonus DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (emp_id) REFERENCES employees(id) ON DELETE CASCADE
);

-- Deductions table
CREATE TABLE deductions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    emp_id BIGINT UNSIGNED NOT NULL,
    month DATE NOT NULL,
    reason VARCHAR(100),
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    FOREIGN KEY (emp_id) REFERENCES employees(id) ON DELETE CASCADE
);

-- Employees
INSERT INTO employees (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Salaries (assume salary always posted on first of the month)
INSERT INTO salaries (emp_id, month, base, bonus) VALUES
(1, '2025-07-01', 5000.00, 500.00),
(2, '2025-07-01', 4500.00, 0.00),
(3, '2025-07-01', 6000.00, 800.00),
(1, '2025-06-01', 5000.00, 300.00);

-- Deductions
INSERT INTO deductions (emp_id, month, reason, amount) VALUES
(1, '2025-07-01', 'Late', 150.00),
(2, '2025-07-01', 'Tax', 300.00),
(2, '2025-07-01', 'Leave', 100.00),
(3, '2025-07-01', 'Other', 200.00),
(1, '2025-06-01', 'Late', 100.00);
-- Monthly Net Salary Calculation Per Employee
SELECT 
    e.name AS employee,
    s.month,
    s.base,
    s.bonus,
    IFNULL(SUM(d.amount), 0) AS total_deductions,
    (s.base + s.bonus - IFNULL(SUM(d.amount), 0)) AS net_salary
FROM salaries s
JOIN employees e ON s.emp_id = e.id
LEFT JOIN deductions d ON s.emp_id = d.emp_id AND s.month = d.month
GROUP BY s.emp_id, s.month
ORDER BY s.month, e.name;
-- Total Payroll Summary for a Given Month
SELECT 
    s.month,
    SUM(s.base) AS total_base,
    SUM(s.bonus) AS total_bonus,
    SUM(IFNULL(d.amount, 0)) AS total_deductions,
    SUM(s.base + s.bonus - IFNULL(d.amount, 0)) AS total_net_payroll
FROM salaries s
LEFT JOIN deductions d ON s.emp_id = d.emp_id AND s.month = d.month
GROUP BY s.month
ORDER BY s.month DESC;
-- . Employees With Bonus Greater Than 500 in July 2025
SELECT 
    e.name,
    s.month,
    s.base,
    s.bonus
FROM salaries s
JOIN employees e ON s.emp_id = e.id
WHERE s.month = '2025-07-01' AND s.bonus > 500;







