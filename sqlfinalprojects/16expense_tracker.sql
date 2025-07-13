-- 16. Expense Tracker 
-- Objective: Log and categorize expenses.
create database expense;
use expense;
-- Entities: 
-- • Users 
-- • Categories 
-- • Expenses 
-- SQL Skills: 
-- • Aggregations by category/month 
-- • Filters by amount range 
-- Tables: 
-- • users (id, name) 
-- • categories (id, name) 
-- • expenses (id, user_id, category_id, amount, date) 


-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Categories table
CREATE TABLE categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Expenses table
CREATE TABLE expenses (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob');

-- Categories
INSERT INTO categories (name) VALUES
('Food'),
('Travel'),
('Utilities'),
('Entertainment');

-- Expenses
INSERT INTO expenses (user_id, category_id, amount, date) VALUES
(1, 1, 50.75, '2025-07-01'),  -- Alice - Food
(1, 2, 120.00, '2025-07-02'), -- Alice - Travel
(1, 3, 80.00, '2025-07-10'),  -- Alice - Utilities
(2, 1, 40.50, '2025-07-03'),  -- Bob - Food
(2, 4, 25.00, '2025-07-04'),  -- Bob - Entertainment
(1, 1, 30.00, '2025-08-01'),  -- Alice - Food in August
(2, 2, 200.00, '2025-08-02'); -- Bob - Travel in August
--  Total Expense Per Category Per User
SELECT 
    u.name AS user,
    c.name AS category,
    SUM(e.amount) AS total_spent
FROM expenses e
JOIN users u ON e.user_id = u.id
JOIN categories c ON e.category_id = c.id
GROUP BY u.id, c.id
ORDER BY user, total_spent DESC;
--  Monthly Expense Summary (Grouped by User and Month)
SELECT 
    u.name AS user,
    DATE_FORMAT(e.date, '%Y-%m') AS month,
    SUM(e.amount) AS total_spent
FROM expenses e
JOIN users u ON e.user_id = u.id
GROUP BY u.id, DATE_FORMAT(e.date, '%Y-%m')
ORDER BY user, month;
--  Filter Expenses by Amount Range (e.g. Between $50 and $150)
SELECT 
    u.name AS user,
    c.name AS category,
    e.amount,
    e.date
FROM expenses e
JOIN users u ON e.user_id = u.id
JOIN categories c ON e.category_id = c.id
WHERE e.amount BETWEEN 50 AND 150
ORDER BY e.amount DESC;
--- List All Expenses for a Specific User (e.g. Alice)
SELECT 
    e.date,
    c.name AS category,
    e.amount
FROM expenses e
JOIN users u ON e.user_id = u.id
JOIN categories c ON e.category_id = c.id
WHERE u.name = 'Alice'
ORDER BY e.date;



