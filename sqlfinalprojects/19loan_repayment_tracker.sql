-- 19. Loan Repayment Tracker 
-- Objective: Manage loans and monthly EMIs. 
create database loan;
use loan;
-- Entities: 
-- • Loans 
-- • Payments 
-- SQL Skills: 
-- • SUM of paid vs total 
-- • Due date logic 
-- Tables: 
-- • loans (id, user_id, principal, interest_rate) 
-- • payments (loan_id, amount, paid_on)

-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Loans table
CREATE TABLE loans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    principal DECIMAL(12, 2) NOT NULL CHECK (principal > 0),
    interest_rate DECIMAL(5, 2) NOT NULL CHECK (interest_rate >= 0), -- % per year
    start_date DATE NOT NULL,
    duration_months INT NOT NULL CHECK (duration_months > 0),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Payments table
CREATE TABLE payments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    loan_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    paid_on DATE NOT NULL,
    FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob');

-- Loans: principal, interest_rate (%), start_date, duration (months)
INSERT INTO loans (user_id, principal, interest_rate, start_date, duration_months) VALUES
(1, 10000.00, 5.00, '2025-01-01', 12), -- Alice
(2, 15000.00, 6.50, '2025-03-01', 10); -- Bob

-- Payments: partial EMI payments
INSERT INTO payments (loan_id, amount, paid_on) VALUES
(1, 1000.00, '2025-02-01'),
(1, 1000.00, '2025-03-01'),
(2, 1500.00, '2025-04-01'),
(2, 1500.00, '2025-05-01');
--  Total Paid and Remaining Balance per Loan
SELECT 
    l.id AS loan_id,
    u.name AS user,
    l.principal,
    l.interest_rate,
    (l.principal + (l.principal * l.interest_rate / 100)) AS total_due,
    IFNULL(SUM(p.amount), 0) AS total_paid,
    (l.principal + (l.principal * l.interest_rate / 100)) - IFNULL(SUM(p.amount), 0) AS remaining_balance
FROM loans l
JOIN users u ON l.user_id = u.id
LEFT JOIN payments p ON l.id = p.loan_id
GROUP BY l.id;
-- Monthly Due Date Logic – Missed or Upcoming Payments
SELECT 
    l.id AS loan_id,
    u.name AS user,
    l.start_date,
    l.duration_months,
    DATE_ADD(l.start_date, INTERVAL TIMESTAMPDIFF(MONTH, l.start_date, CURDATE()) MONTH) AS current_due_date,
    COUNT(p.id) AS payments_made
FROM loans l
JOIN users u ON l.user_id = u.id
LEFT JOIN payments p ON l.id = p.loan_id
    AND MONTH(p.paid_on) = MONTH(CURDATE()) AND YEAR(p.paid_on) = YEAR(CURDATE())
GROUP BY l.id
ORDER BY current_due_date;
--  Full Payment History for a Loan
SELECT 
    l.id AS loan_id,
    u.name AS user,
    p.amount,
    p.paid_on
FROM payments p
JOIN loans l ON p.loan_id = l.id
JOIN users u ON l.user_id = u.id
ORDER BY l.id, p.paid_on;







