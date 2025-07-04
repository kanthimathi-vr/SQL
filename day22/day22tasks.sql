-- 1–5: Subqueries in SELECT Clause
CREATE DATABASE COMPANY;
USE COMPANY;
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    join_date DATE,
    department_id INT,
    manager_id INT
);
CREATE TABLE salary (
    id INT PRIMARY KEY,
    emp_id INT,
    amount DECIMAL(10,2),
    valid_upto DATE
);
CREATE TABLE department (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);
INSERT INTO employees (id, name, join_date, department_id, manager_id) VALUES
(1, 'Alice', '2019-04-10', 1, NULL),
(2, 'Bob', '2021-07-01', 2, 1),
(3, 'Charlie', '2022-01-15', 2, 1),
(4, 'David', '2020-09-20', 3, 2),
(5, 'Eve', '2018-03-05', 3, 2),
(6, 'Frank', '2023-05-01', 4, 1),
(7, 'Grace', '2024-02-10', NULL, 1),
(8, 'Heidi', '2021-11-11', 5, 3),
(9, 'Ivan', '2020-08-18', 5, 3),
(10, 'Judy', '2019-12-30', 1, NULL);

INSERT INTO salary (id, emp_id, amount, valid_upto) VALUES
(1, 1, 60000.00, '2024-12-31'),
(2, 2, 55000.00, '2024-12-31'),
(3, 3, 75000.00, '2024-12-31'),
(4, 4, 50000.00, '2024-12-31'),
(5, 5, 62000.00, '2024-12-31'),
(6, 6, 48000.00, '2024-12-31'),
(7, 8, 59000.00, '2024-12-31'),
(8, 9, 72000.00, '2024-12-31'),
(9, 10, 58000.00, '2024-12-31');
INSERT INTO department (id, name) VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Marketing'),
(4, 'Finance'),
(5, 'Operations'),
(6, NULL);

INSERT INTO products (id, product_name, price) VALUES
(1, 'Laptop', 85000.00),
(2, 'Mouse', 1500.00),
(3, 'Keyboard', 3000.00),
(4, 'Monitor', 12000.00),
(5, 'Chair', 7000.00);

-- 1 Retrieve each employee’s name and compare their salary to the highest salary in the company.
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    (SELECT MAX(amount) FROM salary) AS highest_salary,
    s.amount - (SELECT MAX(amount) FROM salary) AS salary_difference
FROM employees e
JOIN salary s ON e.id = s.emp_id;

-- 2 Show each employee’s salary and the total number of employees (using subquery).
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    (SELECT COUNT(*) FROM employees) AS total_employees
FROM employees e
JOIN salary s ON e.id = s.emp_id;

-- 3 List employees with their salaries and the minimum salary in their department.
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    s.amount AS salary,
    (
        SELECT MIN(s2.amount)
        FROM employees e2
        JOIN salary s2 ON e2.id = s2.emp_id
        WHERE e2.department_id = e.department_id
    ) AS min_salary_in_dept
FROM employees e
JOIN salary s ON e.id = s.emp_id
LEFT JOIN department d ON e.department_id = d.id;

-- 4.Display each product with its price and the highest price in the product table.
SELECT 
    product_name,
    price,
    (SELECT MAX(price) FROM products) AS highest_price
FROM products;

-- 5.Show each employee’s bonus as 10% of the max salary (use subquery in SELECT).
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    0.10 * (SELECT MAX(amount) FROM salary) AS bonus
FROM employees e
JOIN salary s ON e.id = s.emp_id;

-- 6-10.    Subqueries in FROM Clause
-- 6. Display departments where average salary is more than ₹10,000 using a subquery in the FROM clause.
SELECT dept_name, avg_salary
FROM (
    SELECT 
        d.name AS dept_name,
        AVG(s.amount) AS avg_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    JOIN department d ON e.department_id = d.id
    GROUP BY d.name
) AS dept_avg
WHERE avg_salary > 10000;

-- 7.Get department-wise average salaries and sort only those greater than the company-wide average salary.
SELECT dept_name, avg_salary
FROM (
    SELECT 
        d.name AS dept_name,
        AVG(s.amount) AS avg_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    JOIN department d ON e.department_id = d.id
    GROUP BY d.name
) AS dept_avg
WHERE avg_salary > (
    SELECT AVG(amount) FROM salary
);

-- 8.From a subquery table of top 3 salaried employees, list employee names and departments.
SELECT t.name AS employee_name, d.name AS department_name, t.salary
FROM (
    SELECT 
        e.name, e.department_id, s.amount AS salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    ORDER BY s.amount DESC
    LIMIT 3
) AS t
LEFT JOIN department d ON t.department_id = d.id;

--  9.Calculate total salary by department, only for departments that have more than 5 employees.
SELECT dept_name, total_salary
FROM (
    SELECT 
        d.name AS dept_name,
        COUNT(e.id) AS emp_count,
        SUM(s.amount) AS total_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    JOIN department d ON e.department_id = d.id
    GROUP BY d.name
) AS dept_summary
WHERE emp_count > 1;

-- 10. Create a temporary table using subquery to calculate salary ranges (min, max, avg) per department.
CREATE TEMPORARY TABLE dept_salary_ranges AS
SELECT 
    d.name AS department_name,
    MIN(s.amount) AS min_salary,
    MAX(s.amount) AS max_salary,
    AVG(s.amount) AS avg_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name;

-- ✅ 11–15: Subqueries in WHERE Clause
-- 11 Show employees who earn more than the average salary.
SELECT 
    e.name AS employee_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
WHERE s.amount > (
    SELECT AVG(amount) FROM salary
);

-- 12 List products whose price is higher than the average price.
SELECT 
    product_name,
    price
FROM products
WHERE price > (
    SELECT AVG(price) FROM products
);

-- 13 Find employees whose department has more than 3 employees (using COUNT subquery).
SELECT 
    e.name AS employee_name,
    d.name AS department_name
FROM employees e
JOIN department d ON e.department_id = d.id
WHERE e.department_id IN (
    SELECT department_id
    FROM employees
    WHERE department_id IS NOT NULL
    GROUP BY department_id
    HAVING COUNT(*) > 1
);

-- 14 Get customers who have placed more orders than the average number of orders per customer.
CREATE TABLE customers (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE
);
INSERT INTO customers (id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana'),
(5, 'Eve');
INSERT INTO orders (id, customer_id, order_date) VALUES
(1, 1, '2024-01-01'),
(2, 1, '2024-01-15'),
(3, 1, '2024-02-20'),
(4, 2, '2024-02-25'),
(5, 2, '2024-03-10'),
(6, 3, '2024-04-01'),
(7, 4, '2024-05-05'),
(8, 4, '2024-05-10'),
(9, 4, '2024-06-12'),
(10, 4, '2024-06-30');

SELECT 
    c.name,
    COUNT(o.id) AS total_orders
FROM customers c
JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING COUNT(o.id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT customer_id, COUNT(*) AS order_count
        FROM orders
        GROUP BY customer_id
    ) AS customer_orders
);



-- 15 Display products whose quantity is below the minimum quantity across all products.

SELECT 
    product_name,
    quantity
FROM products
WHERE quantity < (
    SELECT MIN(quantity) FROM products
);

-- ✅ 16–20: Correlated vs. Non-Correlated Subqueries
-- 16 Find employees who earn more than the average salary in their department.
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
WHERE s.amount > (
    SELECT AVG(s2.amount)
    FROM employees e2
    JOIN salary s2 ON e2.id = s2.emp_id
    WHERE e2.department_id = e.department_id
);

-- 17 List employees who are the highest paid in their department.
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
WHERE s.amount = (
    SELECT MAX(s2.amount)
    FROM employees e2
    JOIN salary s2 ON e2.id = s2.emp_id
    WHERE e2.department_id = e.department_id
);

-- 18 Show departments that have at least one employee earning more than ₹50,000.
SELECT DISTINCT d.name AS department_name
FROM department d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    WHERE e.department_id = d.id AND s.amount > 50000
);

-- 19 List employees whose salaries are higher than all their team members (correlated).
SELECT 
    e.name AS employee_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
WHERE s.amount > ALL (
    SELECT s2.amount
    FROM employees e2
    JOIN salary s2 ON e2.id = s2.emp_id
    WHERE e2.manager_id = e.manager_id AND e2.id <> e.id
);

-- 20 Identify employees who earn less than the maximum salary of any department (non-correlated).
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
WHERE s.amount < (
    SELECT MAX(s2.amount)
    FROM employees e2
    JOIN salary s2 ON e2.id = s2.emp_id
    WHERE e2.department_id IS NOT NULL
);
-- B. UNION, UNION ALL, INTERSECT, EXCEPT (10 Tasks)
-- ✅ 21–25: UNION & UNION ALL
CREATE TABLE online_orders (
    id INT,
    customer_name VARCHAR(100)
);

CREATE TABLE store_orders (
    id INT,
    customer_name VARCHAR(100)
);

INSERT INTO online_orders (id, customer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO store_orders (id, customer_name) VALUES
(1, 'Alice'),
(2, 'Diana'),
(3, 'Eve');

-- List all unique customer names from two tables: online_orders and store_orders (use UNION).
SELECT customer_name FROM online_orders
UNION
SELECT customer_name FROM store_orders;

-- List all customer names (including duplicates) from online_orders and store_orders (UNION ALL).
SELECT customer_name FROM online_orders
UNION ALL
SELECT customer_name FROM store_orders;

-- Combine employee names from full_time_employees and contract_employees.
CREATE TABLE full_time_employees (
    id INT,
    name VARCHAR(100)
);

CREATE TABLE contract_employees (
    id INT,
    name VARCHAR(100)
);

INSERT INTO full_time_employees (id, name) VALUES
(1, 'Frank'),
(2, 'Grace');

INSERT INTO contract_employees (id, name) VALUES
(1, 'Hannah'),
(2, 'Grace');

SELECT name FROM full_time_employees
UNION
SELECT name FROM contract_employees;

-- Combine all product names from electronics and furniture tables.
CREATE TABLE electronics (
    id INT,
    product_name VARCHAR(100)
);

CREATE TABLE furniture (
    id INT,
    product_name VARCHAR(100)
);

INSERT INTO electronics (id, product_name) VALUES
(1, 'Laptop'),
(2, 'Monitor');

INSERT INTO furniture (id, product_name) VALUES
(1, 'Chair'),
(2, 'Desk'),
(3, 'Monitor');
SELECT product_name FROM electronics
UNION
SELECT product_name FROM furniture;

-- Display all city names from customers and suppliers (with and without duplicates).
CREATE TABLE customers1 (
    id INT,
    name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE suppliers (
    id INT,
    name VARCHAR(100),
    city VARCHAR(100)
);

INSERT INTO customers1 (id, name, city) VALUES
(1, 'Alice', 'Delhi'),
(2, 'Bob', 'Mumbai'),
(3, 'Charlie', 'Bangalore');

INSERT INTO suppliers (id, name, city) VALUES
(1, 'Vendor1', 'Mumbai'),
(2, 'Vendor2', 'Chennai'),
(3, 'Vendor3', 'Delhi');
SELECT city FROM customers1
UNION
SELECT city FROM suppliers;

SELECT city FROM customers1
UNION ALL
SELECT city FROM suppliers;

-- 26–30: INTERSECT & EXCEPT
-- 26 Find employees who work in both department 101 (IT) and 102 (Finance) – INTERSECT.
CREATE TABLE employee_department (
    emp_id INT,
    department_id INT
);

INSERT INTO employee_department (emp_id, department_id) VALUES
(1, 101), -- Alice
(2, 101), -- Bob
(2, 102), -- Bob
(3, 102), -- Charlie
(4, 101),
(4, 102); -- David

SELECT emp_id FROM employee_department WHERE department_id = 101
INTERSECT
SELECT emp_id FROM employee_department WHERE department_id = 102;

-- 27 List employees in IT but not in HR – use EXCEPT or MINUS.
SELECT id, name FROM employees WHERE department_id = 2
EXCEPT
SELECT id, name FROM employees WHERE department_id = 1;

-- 28 Get product IDs available in both wholesale and retail tables.
CREATE TABLE wholesale (
    product_id INT
);

CREATE TABLE retail (
    product_id INT
);

INSERT INTO wholesale (product_id) VALUES (1), (2), (3), (4);
INSERT INTO retail (product_id) VALUES (3), (4), (5), (6);

SELECT product_id FROM wholesale
INTERSECT
SELECT product_id FROM retail;

-- 29 Find customers who only ordered from the website, not from stores.
SELECT customer_name FROM online_orders
EXCEPT
SELECT customer_name FROM store_orders;

-- 30 List employee IDs that exist in current_employees but not in resigned_employees.
CREATE TABLE current_employees (
    emp_id INT
);

CREATE TABLE resigned_employees (
    emp_id INT
);

INSERT INTO current_employees VALUES (1), (2), (3), (4), (5);
INSERT INTO resigned_employees VALUES (3), (4);

SELECT emp_id FROM current_employees
EXCEPT
SELECT emp_id FROM resigned_employees;

-- C. Complex Queries with JOIN, GROUP BY, Aggregation (10 Tasks)
-- ✅ 31–35: JOIN + GROUP BY + Aggregation
-- Show total salary paid per department (join with department table).
SELECT 
    d.name AS department_name,
    SUM(s.amount) AS total_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name;

-- Find number of employees in each department.
SELECT 
    d.name AS department_name,
    COUNT(e.id) AS employee_count
FROM department d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name;

-- Get department names and average salary of employees working in them.
SELECT 
    d.name AS department_name,
    ROUND(AVG(s.amount),2) AS avg_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name;

-- Display departments with a total salary bill above ₹1,00,000.
SELECT 
    d.name AS department_name,
    SUM(s.amount) AS total_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name
HAVING SUM(s.amount) > 100000;

-- Show number of employees hired per year.
SELECT 
    YEAR(hire_date) AS hire_year,
    COUNT(*) AS employee_count
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year;

-- ✅ 36–40: JOIN + Subquery + Aggregation
-- Find departments where the average salary is higher than the company's average salary.
SELECT 
    d.name AS department_name,
    AVG(s.amount) AS dept_avg_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name
HAVING AVG(s.amount) > (
    SELECT AVG(amount) FROM salary
);

-- Display departments and the name of the highest-paid employee in each.
SELECT 
    d.name AS department_name,
    e.name AS employee_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
WHERE s.amount = (
    SELECT MAX(s2.amount)
    FROM employees e2
    JOIN salary s2 ON e2.id = s2.emp_id
    WHERE e2.department_id = e.department_id
);

-- Get names of departments where the employee count is below the average department size.
SELECT 
    d.name AS department_name,
    COUNT(e.id) AS emp_count
FROM department d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name
HAVING COUNT(e.id) < (
    SELECT AVG(emp_count) FROM (
        SELECT department_id, COUNT(*) AS emp_count
        FROM employees
        WHERE department_id IS NOT NULL
        GROUP BY department_id
    ) AS dept_counts
);

-- Show all departments and count of employees earning more than ₹50,000.
SELECT 
    d.name AS department_name,
    COUNT(e.id) AS high_earners
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
WHERE s.amount > 50000
GROUP BY d.name;

-- List employees whose salary is more than their department’s average salary.
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
WHERE s.amount > (
    SELECT AVG(s2.amount)
    FROM employees e2
    JOIN salary s2 ON e2.id = s2.emp_id
    WHERE e2.department_id = e.department_id
);

-- D. Conditional Logic & Date Functions (10 Tasks)
-- ✅ 41–45: CASE WHEN – Conditional Aggregation
-- Classify employees as High, Medium, or Low salary using CASE WHEN.
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    CASE 
        WHEN s.amount > 65000 THEN 'High'
        WHEN s.amount > 50000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees e
JOIN salary s ON e.id = s.emp_id;

-- Display product stock status as Low, Moderate, or High based on quantity.
CREATE TABLE products1 (
    id INT,
    product_name VARCHAR(100),
    quantity INT
);

INSERT INTO products1 (id, product_name, quantity) VALUES
(1, 'Laptop', 10),
(2, 'Mouse', 50),
(3, 'Chair', 5),
(4, 'Monitor', 30),
(5, 'Keyboard', 70);
SELECT 
    product_name,
    quantity,
    CASE 
        WHEN quantity < 10 THEN 'Low'
        WHEN quantity BETWEEN 10 AND 40 THEN 'Moderate'
        ELSE 'High'
    END AS stock_status
FROM products1;


-- Show department-wise count of employees in each salary category (using CASE inside SUM).
SELECT 
    d.name AS department_name,
    SUM(CASE WHEN s.amount > 65000 THEN 1 ELSE 0 END) AS high_salary,
    SUM(CASE WHEN s.amount BETWEEN 50001 AND 65000 THEN 1 ELSE 0 END) AS medium_salary,
    SUM(CASE WHEN s.amount <= 50000 THEN 1 ELSE 0 END) AS low_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name;

-- Show employees with remarks: New Joiner, Mid-Level, or Senior based on their joining year.
SELECT 
    name AS employee_name,
    hire_date,
    CASE 
        WHEN YEAR(hire_date) < 2020 THEN 'Senior'
        WHEN YEAR(hire_date) BETWEEN 2020 AND 2022 THEN 'Mid-Level'
        ELSE 'New Joiner'
    END AS remarks
FROM employees;

-- For each employee, display salary grade using CASE WHEN with 3 conditions.

SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    CASE 
        WHEN s.amount > 70000 THEN 'Grade A'
        WHEN s.amount BETWEEN 55000 AND 70000 THEN 'Grade B'
        ELSE 'Grade C'
    END AS salary_grade
FROM employees e
JOIN salary s ON e.id = s.emp_id;

-- 46–50: Working with Date Functions
-- List employees who joined in the last 6 months using DATE_SUB.
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2019-04-10' WHERE id = 1; -- Alice
UPDATE employees SET hire_date = '2021-07-01' WHERE id = 2; -- Bob
UPDATE employees SET hire_date = '2022-01-15' WHERE id = 3; -- Charlie
UPDATE employees SET hire_date = '2020-09-20' WHERE id = 4; -- David
UPDATE employees SET hire_date = '2018-03-05' WHERE id = 5; -- Eve
UPDATE employees SET hire_date = '2023-05-01' WHERE id = 6; -- Frank
UPDATE employees SET hire_date = '2024-02-10' WHERE id = 7; -- Grace
UPDATE employees SET hire_date = '2021-11-11' WHERE id = 8; -- Heidi
UPDATE employees SET hire_date = '2020-08-18' WHERE id = 9; -- Ivan
UPDATE employees SET hire_date = '2019-12-30' WHERE id = 10; -- Judy

SELECT 
    name AS employee_name,
    hire_date
FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR);

-- Show employees whose tenure is more than 2 years using DATEDIFF or TIMESTAMPDIFF.

-- Display employees' names and months since their joining.
SELECT 
    name AS employee_name,
    hire_date,
    TIMESTAMPDIFF(MONTH, hire_date, CURDATE()) AS months_since_joining
FROM employees;

-- Count how many employees joined in each year using YEAR(hire_date).
SELECT 
    YEAR(hire_date) AS join_year,
    COUNT(*) AS employee_count
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY join_year;

-- List all employees whose birthday is in the current month.
ALTER TABLE employees ADD COLUMN  birth_date DATE;
UPDATE employees SET birth_date = '1990-07-10' WHERE id = 1;  -- Alice
UPDATE employees SET birth_date = '1985-12-05' WHERE id = 2;  -- Bob
UPDATE employees SET birth_date = '1993-07-02' WHERE id = 3;  -- Charlie
UPDATE employees SET birth_date = '1992-08-20' WHERE id = 4;  -- David
UPDATE employees SET birth_date = '1988-03-15' WHERE id = 5;  -- Eve
UPDATE employees SET birth_date = '1995-05-22' WHERE id = 6;  -- Frank
UPDATE employees SET birth_date = '1991-07-09' WHERE id = 7;  -- Grace
UPDATE employees SET birth_date = '1986-01-17' WHERE id = 8;  -- Heidi
UPDATE employees SET birth_date = '1990-07-30' WHERE id = 9;  -- Ivan
UPDATE employees SET birth_date = '1987-11-11' WHERE id = 10; -- Judy

SELECT 
    name AS employee_name,
    birth_date
FROM employees
WHERE MONTH(birth_date) = MONTH(CURDATE());


