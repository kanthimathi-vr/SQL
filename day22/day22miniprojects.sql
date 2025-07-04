-- day22 mini projects
-- 1. Employee Salary Insight Dashboard
-- Domain: HR
-- Objective: Create insights comparing each employee’s salary to various benchmarks.
-- Requirements:
-- Show each employee’s salary alongside company-wide max, avg, and min salary (subqueries in SELECT).
use company;
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    (SELECT MAX(amount) FROM salary) AS company_max_salary,
    (SELECT round(AVG(amount),2) FROM salary) AS company_avg_salary,
    (SELECT MIN(amount) FROM salary) AS company_min_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id;
-- Classify salary as High, Medium, or Low using CASE WHEN.
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    CASE
        WHEN s.amount > (SELECT AVG(amount) FROM salary) THEN 'High'
        WHEN s.amount > (SELECT MIN(amount) FROM salary) THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees e
JOIN salary s ON e.id = s.emp_id;

-- Use correlated subquery to compare salary to department average.
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    d.name AS department_name,
    CASE 
        WHEN s.amount > (
            SELECT AVG(s2.amount) 
            FROM salary s2
            JOIN employees e2 ON s2.emp_id = e2.id
            WHERE e2.department_id = e.department_id
        ) THEN 'Above Department Average'
        ELSE 'Below Department Average'
    END AS salary_vs_department_avg
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id;

-- Display department-wise salary summary with JOIN and GROUP BY
SELECT 
    d.name AS department_name,
    COUNT(e.id) AS employee_count,
    SUM(s.amount) AS total_salary,
    AVG(s.amount) AS avg_salary,
    MIN(s.amount) AS min_salary,
    MAX(s.amount) AS max_salary
FROM department d
LEFT JOIN employees e ON d.id = e.department_id
LEFT JOIN salary s ON e.id = s.emp_id
GROUP BY d.name
ORDER BY total_salary DESC;

-- 2. Department Budget Analyzer
-- Domain: Corporate Finance
-- Objective: Analyze departmental salary expenses.
-- Requirements:
-- Use subquery in FROM clause to calculate average salary by department.
SELECT 
    dept_avg.department_name,
    dept_avg.avg_salary
FROM (
    SELECT 
        d.name AS department_name,
        round(AVG(s.amount),2) AS avg_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    JOIN department d ON e.department_id = d.id
    GROUP BY d.name
) AS dept_avg;

-- Filter only those departments with average salary > ₹50,000.
SELECT 
    dept_avg.department_name,
    dept_avg.avg_salary
FROM (
    SELECT 
        d.name AS department_name,
        AVG(s.amount) AS avg_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    JOIN department d ON e.department_id = d.id
    GROUP BY d.name
) AS dept_avg
WHERE dept_avg.avg_salary > 50000;

-- Show total salary paid by each department.
SELECT 
    d.name AS department_name,
    SUM(s.amount) AS total_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name
ORDER BY total_salary DESC;

-- Show which department has the highest total salary using subquery comparison.
SELECT 
    d.name AS department_name,
    SUM(s.amount) AS total_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name
HAVING SUM(s.amount) = (
    SELECT MAX(dept_total)
    FROM (
        SELECT SUM(s2.amount) AS dept_total
        FROM employees e2
        JOIN salary s2 ON e2.id = s2.emp_id
        GROUP BY e2.department_id
    ) AS totals
);
-- 3. Employee Transfer Tracker
-- Domain: HR / Operations
-- Objective: Track employees who worked in multiple departments.
-- Requirements:
-- Use INTERSECT to find employees in both IT and Finance.
CREATE TABLE employee_department_history (
    emp_id INT,
    department_id INT,
    transfer_date DATE
);
-- Create the table (if not already created)
CREATE TABLE employee_department_history (
    emp_id INT,
    department_id INT,
    transfer_date DATE
);

-- Insert transfer history for employees
INSERT INTO employee_department_history (emp_id, department_id, transfer_date) VALUES
(1, 1, '2019-04-10'),  -- Alice in HR
(1, 2, '2023-12-15'),  -- Alice transferred to IT recently

(2, 2, '2021-07-01'),  -- Bob in IT
(2, 4, '2024-06-10'),  -- Bob transferred to Finance (within 6 months)

(3, 2, '2022-01-15'),  -- Charlie in IT
(3, 4, '2024-11-20'),  -- Charlie to Finance

(4, 3, '2020-09-20'),  -- David in Marketing
(4, 2, '2024-08-01'),  -- David to IT

(5, 3, '2018-03-05'),  -- Eve in Marketing

(6, 4, '2023-05-01'),  -- Frank in Finance
(6, 1, '2025-01-20'),  -- Frank to HR

(7, 1, '2024-02-10'),  -- Grace in HR

(8, 5, '2021-11-11'),  -- Heidi in Operations
(8, 2, '2025-02-01'),  -- Heidi to IT

(9, 5, '2020-08-18'),  -- Ivan in Operations

(10, 1, '2019-12-30'); -- Judy in HR

SELECT emp_id 
FROM employee_department_history 
WHERE department_id = 2  -- IT

INTERSECT

SELECT emp_id 
FROM employee_department_history 
WHERE department_id = 4; -- Finance

-- Use EXCEPT to find employees in one dept but not in another.
SELECT emp_id 
FROM employee_department_history 
WHERE department_id = 2  -- IT

EXCEPT

SELECT emp_id 
FROM employee_department_history 
WHERE department_id = 1; -- HR


-- Use subqueries to find employees who transferred in the last 6 months.
SELECT DISTINCT emp_id
FROM employee_department_history
WHERE transfer_date >= CURDATE() - INTERVAL 1 YEAR;

-- Track unique department count per employee using subquery.
SELECT 
    emp_id,
    COUNT(DISTINCT department_id) AS total_departments_worked
FROM employee_department_history
GROUP BY emp_id
ORDER BY total_departments_worked DESC;

-- 4. Product Category Merger Report
-- Domain: E-Commerce
-- Objective: Analyze merged product data from multiple categories.
-- Requirements:
-- Use UNION to combine products from electronics, clothing, and furniture.
-- Use UNION ALL to check duplicate products.
-- Show max price, min price using subqueries.
-- Classify products by price using CASE

CREATE TABLE electronics (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2)
);

CREATE TABLE clothing (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2)
);

CREATE TABLE furniture (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10, 2)
);
-- Electronics
INSERT INTO electronics VALUES
(1, 'Laptop', 65000.00),
(2, 'Smartphone', 40000.00),
(3, 'Headphones', 2500.00);

-- Clothing
INSERT INTO clothing VALUES
(4, 'Jeans', 2000.00),
(5, 'T-Shirt', 800.00),
(6, 'Smartwatch', 40000.00);  -- Duplicate price with Smartphone

-- Furniture
INSERT INTO furniture VALUES
(7, 'Sofa', 55000.00),
(8, 'Dining Table', 35000.00),
(9, 'Chair', 2500.00);  -- Duplicate price with Headphones

SELECT product_name, price FROM electronics
UNION
SELECT product_name, price FROM clothing
UNION
SELECT product_name, price FROM furniture;

SELECT product_name, price FROM electronics
UNION ALL
SELECT product_name, price FROM clothing
UNION ALL
SELECT product_name, price FROM furniture;

SELECT
    (SELECT MAX(price) FROM (
        SELECT price FROM electronics
        UNION ALL
        SELECT price FROM clothing
        UNION ALL
        SELECT price FROM furniture
    ) AS all_products) AS max_price,

    (SELECT MIN(price) FROM (
        SELECT price FROM electronics
        UNION ALL
        SELECT price FROM clothing
        UNION ALL
        SELECT price FROM furniture
    ) AS all_products) AS min_price;

SELECT 
    product_name,
    price,
    CASE 
        WHEN price >= 50000 THEN 'Premium'
        WHEN price >= 2000 THEN 'Mid-Range'
        ELSE 'Budget'
    END AS price_category
FROM (
    SELECT product_name, price FROM electronics
    UNION ALL
    SELECT product_name, price FROM clothing
    UNION ALL
    SELECT product_name, price FROM furniture
) AS merged_products;

-- 5. Customer Purchase Comparison Tool
-- Domain: Retail
-- Objective: Compare online and offline customer purchases.
-- Requirements:
-- Use UNION and UNION ALL to merge customer data from two sources.
-- Use INTERSECT to find customers active on both platforms.
-- Use subqueries to find customers who bought more than the average.
-- Classify customers based on purchase frequency.
create database purchase;
USE purchase;
CREATE TABLE online_orders (
    customer_id INT,
    customer_name VARCHAR(100),
    purchase_date DATE
);

CREATE TABLE store_orders (
    customer_id INT,
    customer_name VARCHAR(100),
    purchase_date DATE
);
-- Online Orders
INSERT INTO online_orders VALUES
(1, 'Alice', '2024-12-01'),
(2, 'Bob', '2025-01-05'),
(3, 'Charlie', '2025-02-15'),
(4, 'David', '2025-01-10');

-- Store Orders
INSERT INTO store_orders VALUES
(2, 'Bob', '2025-01-15'),
(3, 'Charlie', '2025-02-20'),
(5, 'Eve', '2025-01-25'),
(6, 'Frank', '2025-03-05');

-- Use UNION and UNION ALL to merge customer data from two sources.
SELECT customer_name FROM online_orders
UNION
SELECT customer_name FROM store_orders;

SELECT customer_name FROM online_orders
UNION ALL
SELECT customer_name FROM store_orders;


-- Use INTERSECT to find customers active on both platforms.
SELECT customer_name FROM online_orders
INTERSECT
SELECT customer_name FROM store_orders;

-- Use subqueries to find customers who bought more than the average.
SELECT customer_name
FROM (
    SELECT customer_name, COUNT(*) AS total_orders
    FROM (
        SELECT customer_name FROM online_orders
        UNION ALL
        SELECT customer_name FROM store_orders
    ) AS all_orders
    GROUP BY customer_name
) AS customer_totals
WHERE total_orders > (
    SELECT AVG(order_count)
    FROM (
        SELECT customer_name, COUNT(*) AS order_count
        FROM (
            SELECT customer_name FROM online_orders
            UNION ALL
            SELECT customer_name FROM store_orders
        ) AS all_orders
        GROUP BY customer_name
    ) AS avg_data
);

-- Classify customers based on purchase frequency.
SELECT 
    customer_name,
    COUNT(*) AS total_orders,
    CASE
        WHEN COUNT(*) >= 3 THEN 'Frequent Buyer'
        WHEN COUNT(*) = 2 THEN 'Occasional Buyer'
        ELSE 'One-time Buyer'
    END AS purchase_category
FROM (
    SELECT customer_name FROM online_orders
    UNION ALL
    SELECT customer_name FROM store_orders
) AS combined_orders
GROUP BY customer_name
ORDER BY total_orders DESC;

-- 6. High Performer Identification System
-- Domain: HR
-- Objective: Find top-performing employees.
USE company;

-- Requirements:
-- Use a correlated subquery to get employees with salary > dept average.
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
WHERE s.amount > (
    SELECT AVG(s2.amount)
    FROM salary s2
    JOIN employees e2 ON s2.emp_id = e2.id
    WHERE e2.department_id = e.department_id
);

-- Highlight top 5 earners using subquery with ORDER BY LIMIT.
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    s.amount AS salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
ORDER BY s.amount DESC
LIMIT 5;

-- Show department-level performance summary using JOIN + GROUP BY.
SELECT 
    d.name AS department_name,
    COUNT(e.id) AS employee_count,
    AVG(s.amount) AS avg_salary,
    MAX(s.amount) AS max_salary,
    MIN(s.amount) AS min_salary,
    SUM(s.amount) AS total_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
JOIN department d ON e.department_id = d.id
GROUP BY d.name
ORDER BY total_salary DESC;

-- Use CASE WHEN to classify employee performance level.
SELECT 
    e.name AS employee_name,
    s.amount AS salary,
    CASE
        WHEN s.amount >= 70000 THEN 'Top Performer'
        WHEN s.amount >= 50000 THEN 'Mid Performer'
        ELSE 'Needs Improvement'
    END AS performance_level
FROM employees e
JOIN salary s ON e.id = s.emp_id;

-- 7. Inventory Stock Checker
-- Domain: Warehouse Management
-- Objective: Check stock levels across categories.
CREATE TABLE electronics_inventory (
    item_id INT,
    item_name VARCHAR(100),
    stock INT,
    warehouse VARCHAR(50)
);

CREATE TABLE clothing_inventory (
    item_id INT,
    item_name VARCHAR(100),
    stock INT,
    warehouse VARCHAR(50)
);

CREATE TABLE furniture_inventory (
    item_id INT,
    item_name VARCHAR(100),
    stock INT,
    warehouse VARCHAR(50)
);
-- Electronics
INSERT INTO electronics_inventory VALUES
(1, 'Laptop', 40, 'Warehouse A'),
(2, 'Tablet', 25, 'Warehouse B'),
(3, 'Smartphone', 70, 'Warehouse A');

-- Clothing
INSERT INTO clothing_inventory VALUES
(4, 'T-Shirt', 150, 'Warehouse A'),
(5, 'Jeans', 80, 'Warehouse B'),
(6, 'Jacket', 40, 'Warehouse B');

-- Furniture
INSERT INTO furniture_inventory VALUES
(7, 'Chair', 20, 'Warehouse A'),
(8, 'Table', 10, 'Warehouse C'),
(9, 'Sofa', 5, 'Warehouse B');

-- Requirements:
-- Merge items using UNION from different category tables.
SELECT item_name, stock, warehouse FROM electronics_inventory
UNION
SELECT item_name, stock, warehouse FROM clothing_inventory
UNION
SELECT item_name, stock, warehouse FROM furniture_inventory;

-- Use subquery to find average stock.
SELECT AVG(stock) AS avg_stock FROM (
    SELECT stock FROM electronics_inventory
    UNION ALL
    SELECT stock FROM clothing_inventory
    UNION ALL
    SELECT stock FROM furniture_inventory
) AS all_stock;

-- Use CASE to tag stock as High, Moderate, Low.
SELECT 
    item_name,
    stock,
    warehouse,
    CASE
        WHEN stock >= 100 THEN 'High'
        WHEN stock >= 50 THEN 'Moderate'
        ELSE 'Low'
    END AS stock_level
FROM (
    SELECT item_name, stock, warehouse FROM electronics_inventory
    UNION ALL
    SELECT item_name, stock, warehouse FROM clothing_inventory
    UNION ALL
    SELECT item_name, stock, warehouse FROM furniture_inventory
) AS all_items;

-- Use EXCEPT to find items available in one warehouse but not in another.
SELECT item_name FROM (
    SELECT item_name FROM electronics_inventory WHERE warehouse = 'Warehouse A'
    UNION
    SELECT item_name FROM clothing_inventory WHERE warehouse = 'Warehouse A'
    UNION
    SELECT item_name FROM furniture_inventory WHERE warehouse = 'Warehouse A'
)
EXCEPT
SELECT item_name FROM (
    SELECT item_name FROM electronics_inventory WHERE warehouse = 'Warehouse B'
    UNION
    SELECT item_name FROM clothing_inventory WHERE warehouse = 'Warehouse B'
    UNION
    SELECT item_name FROM furniture_inventory WHERE warehouse = 'Warehouse B'
);

-- 8. Employee Joiner Trend Report
-- Domain: HR Analytics
-- Objective: Analyze hiring patterns over time.
-- Requirements:
-- Use DATE_SUB to get employees who joined in the last 6 months.
SELECT 
    id, name, hire_date
FROM 
    employees
WHERE 
    hire_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
    

-- Use subqueries to find employees who joined before and after company average join date.
-- Average hire date of the company
SELECT ROUND(AVG(hire_date)) AS avg_hire_date FROM employees;
-- Joined **before** average
SELECT id, name, hire_date
FROM employees
WHERE hire_date < (SELECT AVG(hire_date) FROM employees);

-- Joined **after** average
SELECT id, name, hire_date
FROM employees
WHERE hire_date > (SELECT AVG(hire_date) FROM employees);

-- Aggregate joiners per month using GROUP BY.
SELECT  DATE_FORMAT(hire_date, '%Y-%m') AS join_month,
    COUNT(*) AS total_joiners
FROM 
    employees
GROUP BY 
    DATE_FORMAT(hire_date, '%Y-%m')
ORDER BY 
    join_month;

-- Use CASE WHEN for year-wise hiring classification.
SELECT 
    name,
    hire_date,
    CASE 
        WHEN YEAR(hire_date) < 2020 THEN 'Old Joiner'
        WHEN YEAR(hire_date) BETWEEN 2020 AND 2023 THEN 'Mid Joiner'
        ELSE 'New Joiner'
    END AS joiner_category
FROM 
    employees;

-- 9. Department Performance Ranker
-- Domain: Management
-- Objective: Rank departments by performance.
-- Requirements:
-- Use subqueries to calculate total, average salary per department.
SELECT 
    e.department_id,
    SUM(s.amount) AS total_salary,
    ROUND(AVG(s.amount),2) AS avg_salary
FROM employees e
JOIN salary s ON e.id = s.emp_id
GROUP BY e.department_id;

-- Use JOIN to get department names.
SELECT 
    d.name AS department_name,
    dept_stats.total_salary,
    dept_stats.avg_salary
FROM (
    SELECT 
        e.department_id,
        SUM(s.amount) AS total_salary,
        ROUND(AVG(s.amount),2) AS avg_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    GROUP BY e.department_id
) AS dept_stats
JOIN department d ON dept_stats.department_id = d.id;

-- Use CASE WHEN to assign performance tags.
SELECT 
    d.name AS department_name,
    dept_stats.total_salary,
    dept_stats.avg_salary,
    CASE 
        WHEN dept_stats.total_salary > 150000 THEN 'High Performer'
        WHEN dept_stats.total_salary >= 100000 THEN 'Average Performer'
        ELSE 'Needs Review'
    END AS performance_tag
FROM (
    SELECT 
        e.department_id,
        SUM(s.amount) AS total_salary,
        ROUND(AVG(s.amount),2) AS avg_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    GROUP BY e.department_id
) AS dept_stats
JOIN department d ON dept_stats.department_id = d.id;

-- Filter departments above average salary expense.
SELECT 
    d.name AS department_name,
    dept_stats.total_salary,
    dept_stats.avg_salary
FROM (
    SELECT 
        e.department_id,
        SUM(s.amount) AS total_salary,
        ROUND(AVG(s.amount),2) AS avg_salary
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
    GROUP BY e.department_id
) AS dept_stats
JOIN department d ON dept_stats.department_id = d.id
WHERE dept_stats.total_salary > (
    SELECT ROUND(AVG(total),2)
    FROM (
        SELECT 
            SUM(s.amount) AS total
        FROM employees e
        JOIN salary s ON e.id = s.emp_id
        GROUP BY e.department_id
    ) AS dept_totals
);
-- 10. Cross-Sell Opportunity Finder
-- Domain: Sales Analytics
-- Objective: Identify common customers across categories.
-- Category-specific purchase tables
CREATE TABLE electronics_orders (
    customer_id INT,
    amount DECIMAL(10,2)
);
CREATE TABLE clothing_orders (
    customer_id INT,
    amount DECIMAL(10,2)
);

CREATE TABLE furniture_orders (
    customer_id INT,
    amount DECIMAL(10,2)
);
INSERT INTO electronics_orders (customer_id, amount) VALUES
(1, 15000.00),
(2, 8000.00),
(3, 12000.00),
(4, 20000.00),
(5, 5000.00),
(6, 10000.00);
INSERT INTO clothing_orders (customer_id, amount) VALUES
(2, 3000.00),
(3, 4500.00),
(5, 2500.00),
(6, 4000.00),
(7, 6000.00);

INSERT INTO furniture_orders (customer_id, amount) VALUES
(1, 18000.00),
(4, 12000.00),
(6, 9000.00),
(7, 11000.00),
(8, 15000.00);


-- Requirements:
-- Use INTERSECT to find customers who purchased from multiple categories.
SELECT customer_id FROM electronics_orders
INTERSECT
SELECT customer_id FROM clothing_orders;

SELECT customer_id FROM electronics_orders
INTERSECT
SELECT customer_id FROM clothing_orders
INTERSECT
SELECT customer_id FROM furniture_orders;

-- Use EXCEPT to find customers loyal to only one.
SELECT customer_id FROM electronics_orders
EXCEPT
SELECT customer_id FROM clothing_orders;

-- Use subqueries to find customers who spend above average.
-- Get average spend across all orders
SELECT ROUND(AVG(amount),2) AS AVG_SPEND FROM (
    SELECT amount FROM electronics_orders
    UNION ALL
    SELECT amount FROM clothing_orders
    UNION ALL
    SELECT amount FROM furniture_orders
) AS all_orders;

SELECT customer_id, SUM(amount) AS total_spent
FROM (
    SELECT customer_id, amount FROM electronics_orders
    UNION ALL
    SELECT customer_id, amount FROM clothing_orders
    UNION ALL
    SELECT customer_id, amount FROM furniture_orders
) AS all_orders
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(amount) FROM (
        SELECT amount FROM electronics_orders
        UNION ALL
        SELECT amount FROM clothing_orders
        UNION ALL
        SELECT amount FROM furniture_orders
    ) AS combined
);

-- Merge customer lists with UNION.
SELECT DISTINCT customer_id FROM electronics_orders
UNION
SELECT DISTINCT customer_id FROM clothing_orders
UNION
SELECT DISTINCT customer_id FROM furniture_orders;

## 11. Salary Band Distribution Analyzer
## Domain: HR
## Objective: Categorize employees based on salary bands.
-- Requirements:
-- Use subqueries to get company and department averages.
-- Company average salary
SELECT AVG(amount) AS company_avg FROM salary;

-- Department average salary
SELECT 
    e.department_id, 
    round(AVG(s.amount),2) AS dept_avg
FROM employees e
JOIN salary s ON e.id = s.emp_id
GROUP BY e.department_id;

-- Use CASE to tag salaries as Band A, B, C.
SELECT 
    e.id,
    e.name,
    e.department_id,
    s.amount,
    CASE 
        WHEN s.amount > (
            SELECT AVG(s2.amount)
            FROM employees e2
            JOIN salary s2 ON e2.id = s2.emp_id
            WHERE e2.department_id = e.department_id
        ) THEN 'Band A'
        WHEN s.amount = (
            SELECT AVG(s2.amount)
            FROM employees e2
            JOIN salary s2 ON e2.id = s2.emp_id
            WHERE e2.department_id = e.department_id
        ) THEN 'Band B'
        ELSE 'Band C'
    END AS salary_band
FROM employees e
JOIN salary s ON e.id = s.emp_id;

SELECT 
    department_id,
    band,
    COUNT(*) AS employee_count
FROM (
    SELECT 
        e.department_id,
        CASE 
            WHEN s.amount > (
                SELECT AVG(s2.amount)
                FROM employees e2
                JOIN salary s2 ON e2.id = s2.emp_id
                WHERE e2.department_id = e.department_id
            ) THEN 'Band A'
            WHEN s.amount = (
                SELECT AVG(s2.amount)
                FROM employees e2
                JOIN salary s2 ON e2.id = s2.emp_id
                WHERE e2.department_id = e.department_id
            ) THEN 'Band B'
            ELSE 'Band C'
        END AS band
    FROM employees e
    JOIN salary s ON e.id = s.emp_id
) AS classified
GROUP BY department_id, band
ORDER BY department_id, band;

-- ✅ 12. Product Launch Impact Report
-- Domain: Marketing
-- Objective: Analyze the success of new product launches.
ALTER TABLE products ADD COLUMN launch_date DATE;
UPDATE products SET launch_date = '2025-04-01' WHERE id = 1;  -- Laptop
UPDATE products SET launch_date = '2025-05-15' WHERE id = 2;  -- Mouse
UPDATE products SET launch_date = '2025-02-20' WHERE id = 3;  -- Keyboard
UPDATE products SET launch_date = '2024-12-10' WHERE id = 4;  -- Monitor
UPDATE products SET launch_date = '2023-11-05' WHERE id = 5;  -- Chair
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    sale_amount DECIMAL(10, 2),
    sale_date DATE
);
INSERT INTO sales (sale_id, product_id, sale_amount, sale_date) VALUES
-- Sales for Laptop (launched 2025-04-01)
(1, 1, 85000.00, '2025-04-05'),
(2, 1, 84000.00, '2025-04-20'),

-- Sales for Mouse (launched 2025-05-15)
(3, 2, 1500.00, '2025-05-18'),
(4, 2, 1600.00, '2025-06-01'),

-- Sales for Keyboard (launched 2025-02-20)
(5, 3, 3200.00, '2025-03-10'),
(6, 3, 3100.00, '2025-03-25'),

-- Sales for Monitor (launched 2024-12-10)
(7, 4, 12500.00, '2025-01-15'),
(8, 4, 11500.00, '2025-02-20'),

-- Sales for Chair (launched 2023-11-05)
(9, 5, 6800.00, '2024-01-10'),
(10, 5, 7000.00, '2024-05-12');


-- Requirements:
-- Use DATE functions to get products launched in the last 3 months.
SELECT *
FROM products
WHERE launch_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH);

-- Compare sales of new vs existing products using UNION.
-- Sales for new products
SELECT 
    p.id,
    p.product_name,
    'New' AS product_type,
    SUM(s.sale_amount) AS total_sales
FROM products p
JOIN sales s ON p.id = s.product_id
WHERE p.launch_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY p.id, p.product_name

UNION ALL

-- Sales for existing products
SELECT 
    p.id,
    p.product_name,
    'Existing' AS product_type,
    SUM(s.sale_amount) AS total_sales
FROM products p
JOIN sales s ON p.id = s.product_id
WHERE p.launch_date < DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY p.id, p.product_name;

-- Use subqueries to find average sales.
SELECT 
    product_type,
    round(AVG(total_sales),2) AS avg_sales
FROM (
    SELECT 
        p.id,
        p.product_name,
        CASE 
            WHEN p.launch_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH) THEN 'New'
            ELSE 'Existing'
        END AS product_type,
        COALESCE(SUM(s.sale_amount), 0) AS total_sales
    FROM products p
    LEFT JOIN sales s ON p.id = s.product_id
    GROUP BY p.id, p.product_name, product_type
) AS product_sales
GROUP BY product_type;

-- Classify launch as Successful/Neutral/Fail using CASE.
SELECT 
    p.id,
    p.product_name,
    p.launch_date,
    COALESCE(SUM(s.sale_amount), 0) AS total_sales,
    avg_sales_table.avg_sales,
    CASE
        WHEN COALESCE(SUM(s.sale_amount), 0) > avg_sales_table.avg_sales THEN 'Successful'
        WHEN COALESCE(SUM(s.sale_amount), 0) = avg_sales_table.avg_sales THEN 'Neutral'
        ELSE 'Fail'
    END AS launch_status
FROM products p
LEFT JOIN sales s ON p.id = s.product_id
CROSS JOIN (
    SELECT AVG(total_sales) AS avg_sales
    FROM (
        SELECT product_id, COALESCE(SUM(sale_amount), 0) AS total_sales
        FROM sales
        GROUP BY product_id
    ) AS sales_totals
) AS avg_sales_table
GROUP BY p.id, p.product_name, p.launch_date, avg_sales_table.avg_sales
ORDER BY launch_status DESC, total_sales DESC;

-- 13. Supplier Consistency Checker
-- Domain: Supply Chain
-- Objective: Evaluate supplier consistency.
-- Requirements:
-- Use INTERSECT to find suppliers present in both Q1 and Q2.
-- Use EXCEPT to find suppliers missing in Q2.
-- Use subquery to compare average delivery time.
-- Tag supplier status using CASE.
-- Suppliers Table
CREATE TABLE suppliers1 (
supplier_id INT PRIMARY KEY,
supplier_name VARCHAR(100));

INSERT INTO suppliers1 (supplier_id, supplier_name) VALUES
(1, 'Global Supply Co'),
(2, 'Alpha Traders'),
(3, 'QuickMove Inc'),
(4, 'LogiMax'),
(5, 'PrimeTrans');

-- deliveries Table
CREATE TABLE deliveries (
delivery_id INT PRIMARY KEY,
supplier_id INT,
delivery_date DATE,
delivery_time_days INT,
FOREIGN KEY (supplier_id) REFERENCES suppliers1(supplier_id));

INSERT INTO deliveries (delivery_id, supplier_id, delivery_date, delivery_time_days) VALUES
(1, 1, '2025-01-15', 5),  
(2, 2, '2025-01-20', 6),  
(3, 3, '2025-03-05', 4),  
(4, 1, '2025-04-10', 5),  
(5, 2, '2025-04-15', 8),  
(6, 4, '2025-04-20', 7),  
(7, 5, '2025-05-01', 6);

-- Use INTERSECT to find suppliers present in both Q1 and Q2.
SELECT DISTINCT s.supplier_id, s.supplier_name
FROM suppliers1 s
JOIN deliveries d1 ON s.supplier_id = d1.supplier_id
WHERE QUARTER(d1.delivery_date) = 1
AND s.supplier_id IN (
SELECT supplier_id
FROM deliveries
WHERE QUARTER(delivery_date) = 2);

-- Use EXCEPT to find suppliers missing in Q2.
SELECT DISTINCT s.supplier_id, s.supplier_name
FROM suppliers1 s
JOIN deliveries d1 ON s.supplier_id = d1.supplier_id
WHERE QUARTER(d1.delivery_date) = 1
AND s.supplier_id NOT IN (
SELECT supplier_id
FROM deliveries
WHERE QUARTER(delivery_date) = 2);

-- Use subquery to compare average delivery time.
SELECT s.supplier_id, s.supplier_name,
AVG(d.delivery_time_days) AS supplier_avg_time,
(SELECT AVG(delivery_time_days) FROM deliveries) AS company_avg_time
FROM suppliers1 s
JOIN deliveries d ON s.supplier_id = d.supplier_id
GROUP BY s.supplier_id, s.supplier_name;

-- Tag supplier status using CASE.
SELECT s.supplier_id, s.supplier_name,
AVG(d.delivery_time_days) AS avg_delivery_time,
CASE WHEN AVG(d.delivery_time_days) < (
SELECT AVG(delivery_time_days) FROM deliveries) THEN 'Consistent'
WHEN AVG(d.delivery_time_days) = (
SELECT AVG(delivery_time_days) FROM deliveries) THEN 'Average'
ELSE 'Inconsistent'
END AS supplier_status
FROM suppliers1 s
JOIN deliveries d ON s.supplier_id = d.supplier_id
GROUP BY s.supplier_id, s.supplier_name;


## 14. Student Performance Dashboard
## Domain: Education
## Objective: Analyze academic scores.
-- Requirements:
CREATE DATABASE StudentPerformance;
USE StudentPerformance;

-- Student Table
CREATE TABLE students (
student_id INT PRIMARY KEY,
student_name VARCHAR(100));

INSERT INTO students (student_id, student_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Courses Table
CREATE TABLE courses (
course_id INT PRIMARY KEY,
course_name VARCHAR(100));

INSERT INTO courses (course_id, course_name) VALUES
(101, 'Math'),
(102, 'Science'),
(103, 'English');

-- Scores Table
CREATE TABLE scores (
score_id INT PRIMARY KEY,
student_id INT,
course_id INT,
marks INT,
FOREIGN KEY (student_id) REFERENCES students(student_id),
FOREIGN KEY (course_id) REFERENCES courses(course_id));

INSERT INTO scores (score_id, student_id, course_id, marks) VALUES
(1, 1, 101, 85),
(2, 1, 102, 78),
(3, 1, 103, 92),
(4, 2, 101, 70),
(5, 2, 102, 68),
(6, 2, 103, 65),
(7, 3, 101, 95),
(8, 3, 102, 88),
(9, 3, 103, 91),
(10, 4, 101, 55),
(11, 4, 102, 60),
(12, 4, 103, 58);

-- Use subqueries to calculate subject-wise and overall average marks.
-- Subject-wise marks
SELECT c.course_name,
AVG(s.marks) AS average_marks
FROM scores s
JOIN courses c ON s.course_id = c.course_id
GROUP BY c.course_name;

-- Overall Marks
SELECT AVG(marks) AS overall_average
FROM scores;

-- Use CASE to tag students as Pass, Merit, Distinction.
SELECT st.student_id, st.student_name,
AVG(sc.marks) AS average_marks,
CASE WHEN AVG(sc.marks) >= 85 THEN 'Distinction'
WHEN AVG(sc.marks) >= 70 THEN 'Merit'
WHEN AVG(sc.marks) >= 50 THEN 'Pass'
ELSE 'Fail'
END AS result_status
FROM students st
JOIN scores sc ON st.student_id = sc.student_id
GROUP BY st.student_id, st.student_name;

-- Use JOIN to combine student and course tables.
SELECT s.student_name, c.course_name, sc.marks
FROM scores sc
JOIN students s ON sc.student_id = s.student_id
JOIN courses c ON sc.course_id = c.course_id;

-- Filter students above average using WHERE with subquery.
SELECT st.student_id, st.student_name, AVG(sc.marks) AS avg_score
FROM students st
JOIN scores sc ON st.student_id = sc.student_id
GROUP BY st.student_id, st.student_name
HAVING AVG(sc.marks) > (
SELECT AVG(marks) FROM scores);

## 15. Revenue Comparison Engine
## Domain: Finance
## Objective: Compare monthly revenue across years.
-- Requirements:
CREATE DATABASE RevenueComparison;
USE RevenueComparison;

-- Revenue Table
CREATE TABLE revenue (
revenue_id INT PRIMARY KEY,
revenue_date DATE,
amount DECIMAL(10,2));

INSERT INTO revenue (revenue_id, revenue_date, amount) VALUES
(1, '2024-01-15', 12000.00),
(2, '2024-02-10', 15000.00),
(3, '2024-03-20', 18000.00),
(4, '2024-04-05', 10000.00),
(5, '2024-05-25', 16000.00),
(6, '2024-06-12', 17000.00),
(7, '2025-01-17', 14000.00),
(8, '2025-02-14', 12500.00),
(9, '2025-03-21', 13500.00),
(10, '2025-04-18', 11000.00),
(11, '2025-05-09', 14500.00),
(12, '2025-06-28', 15500.00);

-- Use DATE functions to group revenue by year/month.
SELECT YEAR(revenue_date) AS revenue_year,
MONTH(revenue_date) AS revenue_month,
SUM(amount) AS monthly_revenue
FROM revenue
GROUP BY YEAR(revenue_date), MONTH(revenue_date)
ORDER BY revenue_year, revenue_month;

-- Use subquery to calculate year-wise average revenue.
SELECT revenue_year,
AVG(monthly_revenue) AS avg_yearly_revenue
FROM (SELECT
YEAR(revenue_date) AS revenue_year,
MONTH(revenue_date) AS revenue_month,
SUM(amount) AS monthly_revenue
FROM revenue
GROUP BY YEAR(revenue_date), MONTH(revenue_date)) AS monthly_data
GROUP BY revenue_year;

-- Highlight months where revenue was higher than average.
SELECT revenue_year, revenue_month, monthly_revenue
FROM (
SELECT YEAR(revenue_date) AS revenue_year,
MONTH(revenue_date) AS revenue_month,
SUM(amount) AS monthly_revenue
FROM revenue
GROUP BY YEAR(revenue_date), MONTH(revenue_date)) AS m
WHERE monthly_revenue > (SELECT AVG(monthly_revenue)
FROM (
SELECT YEAR(revenue_date) AS revenue_year,
MONTH(revenue_date) AS revenue_month,
SUM(amount) AS monthly_revenue
FROM revenue
GROUP BY YEAR(revenue_date), MONTH(revenue_date)) AS sub
WHERE sub.revenue_year = m.revenue_year);

-- Use CASE to classify month as High/Low revenue.
SELECT revenue_year, revenue_month, monthly_revenue,
CASE WHEN monthly_revenue > (
SELECT AVG(monthly_revenue)
FROM (SELECT
YEAR(revenue_date) AS revenue_year,
MONTH(revenue_date) AS revenue_month,
SUM(amount) AS monthly_revenue
FROM revenue
GROUP BY YEAR(revenue_date), MONTH(revenue_date)) AS sub
WHERE sub.revenue_year = main.revenue_year) THEN 'High Revenue'
ELSE 'Low Revenue'
END AS revenue_status
FROM (SELECT
YEAR(revenue_date) AS revenue_year,
MONTH(revenue_date) AS revenue_month,
SUM(amount) AS monthly_revenue FROM revenue
GROUP BY YEAR(revenue_date), MONTH(revenue_date)) AS main
ORDER BY revenue_year, revenue_month;


## 16. Resignation & Replacement Audit
## Domain: HR
## Objective: Audit resigned and hired employees.
-- Requirements:
CREATE DATABASE ResignationAudit;
USE ResignationAudit;

-- employees_resigned Table
CREATE TABLE employees_resigned (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100),
department_id INT,
designation VARCHAR(50),
resignation_date DATE);

INSERT INTO employees_resigned (emp_id, emp_name, department_id, designation, resignation_date) VALUES
(1, 'Alice', 101, 'Developer', '2024-12-15'),
(2, 'Bob', 102, 'Analyst', '2025-01-10'),
(3, 'Charlie', 101, 'Developer', '2025-01-20'),
(4, 'David', 103, 'Manager', '2025-02-05'),
(5, 'Eve', 104, 'Tester', '2025-03-01');

-- employees_hired Table
CREATE TABLE employees_hired (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100),
department_id INT,
designation VARCHAR(50),
hire_date DATE);

INSERT INTO employees_hired (emp_id, emp_name, department_id, designation, hire_date) VALUES
(101, 'Frank', 101, 'Developer', '2025-01-25'),
(102, 'Grace', 102, 'Data Analyst', '2025-02-01'),
(103, 'Hank', 103, 'Manager', '2025-02-15'),
(104, 'Ivy', 105, 'Developer', '2025-03-10');

-- department Table
CREATE TABLE departments (
department_id INT PRIMARY KEY,
department_name VARCHAR(100));

INSERT INTO departments (department_id, department_name) VALUES
(101, 'IT'),
(102, 'Finance'),
(103, 'HR'),
(104, 'QA'),
(105, 'Support');

-- Use EXCEPT to list resigned employees not replaced.
SELECT DISTINCT designation
FROM employees_resigned
WHERE designation NOT IN (
SELECT DISTINCT designation
FROM employees_hired);

-- Use INTERSECT to identify overlapping designations.
SELECT DISTINCT designation
FROM employees_resigned
WHERE designation IN (
SELECT DISTINCT designation
FROM employees_hired);

-- Use subqueries to find departments with highest attrition.
SELECT department_id, COUNT(*) AS resignation_count
FROM employees_resigned
GROUP BY department_id
HAVING COUNT(*) = (
SELECT MAX(res_count) FROM (
SELECT department_id, COUNT(*) AS res_count
FROM employees_resigned
GROUP BY department_id) AS dept_counts);

-- Use JOIN and GROUP BY for department-level resignation count.
SELECT d.department_name,
COUNT(er.emp_id) AS resignation_count
FROM employees_resigned er
JOIN departments d ON er.department_id = d.department_id
GROUP BY d.department_name;



## 17. Product Return & Complaint Analyzer
## Domain: Customer Support
## Objective: Track product return behavior.
-- Requirements:
CREATE DATABASE ProductAnalyzer;
USE ProductAnalyzer;

-- Products Table
CREATE TABLE products (
product_id INT PRIMARY KEY,
product_name VARCHAR(100));

INSERT INTO products (product_id, product_name) VALUES
(1, 'Laptop'),
(2, 'Headphones'),
(3, 'Keyboard'),
(4, 'Smartphone');

-- orders Table
CREATE TABLE orders (
order_id INT PRIMARY KEY,
product_id INT,
customer_id INT,
order_date DATE,
FOREIGN KEY (product_id) REFERENCES products(product_id));

INSERT INTO orders (order_id, product_id, customer_id, order_date) VALUES
(101, 1, 1001, '2025-05-10'),
(102, 2, 1002, '2025-05-12'),
(103, 3, 1003, '2025-05-13'),
(104, 1, 1004, '2025-05-14'),
(105, 4, 1005, '2025-05-15'),
(106, 2, 1006, '2025-05-16'),
(107, 1, 1007, '2025-05-17');

-- returns Table
CREATE TABLE returns (
return_id INT PRIMARY KEY,
order_id INT,
return_date DATE,
return_reason VARCHAR(50),
FOREIGN KEY (order_id) REFERENCES orders(order_id));

INSERT INTO returns (return_id, order_id, return_date, return_reason) VALUES
(1, 101, '2025-05-20', 'damaged'),
(2, 102, '2025-05-22', 'late_delivery'),
(3, 104, '2025-05-25', 'not_as_described'),
(4, 106, '2025-05-28', 'damaged');

-- Use subqueries to find most returned products.
SELECT p.product_id, p.product_name,
COUNT(r.return_id) AS return_count
FROM products p
JOIN orders o ON p.product_id = o.product_id
JOIN returns r ON o.order_id = r.order_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(r.return_id) = (
SELECT MAX(return_total) FROM (
SELECT COUNT(r2.return_id) AS return_total
FROM orders o2
JOIN returns r2 ON o2.order_id = r2.order_id
GROUP BY o2.product_id) AS return_counts);

-- Use CASE to classify return reason (Damaged, Late, Not as Described).
SELECT r.return_id, r.order_id, r.return_reason,
CASE
WHEN r.return_reason = 'damaged' THEN 'Damaged'
WHEN r.return_reason = 'late_delivery' THEN 'Late'
WHEN r.return_reason = 'not_as_described' THEN 'Not as Described'
ELSE 'Other'
END AS reason_category
FROM returns r;

-- Use JOIN to link orders and returns.
SELECT o.order_id, p.product_name,
r.return_date, r.return_reason
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN returns r ON o.order_id = r.order_id;

-- Filter products with return rate above average.
SELECT p.product_id, p.product_name,
COUNT(r.return_id) / COUNT(DISTINCT o.order_id) AS return_rate
FROM products p
JOIN orders o ON p.product_id = o.product_id
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY p.product_id, p.product_name
HAVING return_rate > (
SELECT AVG(product_return_rate)
FROM (SELECT
COUNT(r2.return_id) / COUNT(DISTINCT o2.order_id) AS product_return_rate
FROM products p2
JOIN orders o2 ON p2.product_id = o2.product_id
LEFT JOIN returns r2 ON o2.order_id = r2.order_id
GROUP BY p2.product_id) AS avg_rates);

## 18. Freelancer Project Tracker
## Domain: Freelance Portal
## Objective: Analyze freelancer earnings and projects.
-- Requirements:
CREATE DATABASE FreelancerTracker;
USE FreelancerTracker;

-- freelancers Table
CREATE TABLE freelancers (
freelancer_id INT PRIMARY KEY,
freelancer_name VARCHAR(100));

INSERT INTO freelancers (freelancer_id, freelancer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Projects Table
CREATE TABLE projects (
project_id INT PRIMARY KEY,
freelancer_id INT,
project_name VARCHAR(100),
earning DECIMAL(10,2),
FOREIGN KEY (freelancer_id) REFERENCES freelancers(freelancer_id));

INSERT INTO projects (project_id, freelancer_id, project_name, earning) VALUES
(101, 1, 'Website Development', 1200.00),
(102, 1, 'SEO Optimization', 800.00),
(103, 2, 'Mobile App', 2000.00),
(104, 2, 'Bug Fixes', 600.00),
(105, 3, 'Logo Design', 300.00),
(106, 3, 'Marketing Campaign', 500.00),
(107, 4, 'Backend API', 1500.00);

-- Use subquery to calculate average earnings.
SELECT AVG(earning) AS average_earning
FROM projects;

-- Use correlated subquery to compare project earnings to user average.
SELECT p.project_id, f.freelancer_name, p.project_name, p.earning,(
SELECT AVG(p2.earning)
FROM projects p2
WHERE p2.freelancer_id = p.freelancer_id) AS freelancer_avg_earning,
CASE WHEN p.earning > (
SELECT AVG(p2.earning)
FROM projects p2
WHERE p2.freelancer_id = p.freelancer_id) THEN 'Above Average'
ELSE 'Below or Equal'
END AS performance
FROM projects p
JOIN freelancers f ON p.freelancer_id = f.freelancer_id;

-- Use CASE to classify freelancers by earnings.
SELECT f.freelancer_id, f.freelancer_name,
AVG(p.earning) AS avg_earning,
CASE WHEN AVG(p.earning) >= 1500 THEN 'High Earner'
WHEN AVG(p.earning) >= 800 THEN 'Medium Earner'
ELSE 'Low Earner'
END AS earning_category
FROM freelancers f
JOIN projects p ON f.freelancer_id = p.freelancer_id
GROUP BY f.freelancer_id, f.freelancer_name;

-- Use GROUP BY to show projects completed per freelancer.
SELECT f.freelancer_name,
COUNT(p.project_id) AS project_count
FROM freelancers f
JOIN projects p ON f.freelancer_id = p.freelancer_id
GROUP BY f.freelancer_name;

## 19. Course Enrollment Optimizer
## Domain: E-Learning
## Objective: Analyze course popularity.
-- Requirements:
CREATE DATABASE CourseOptimizer;
USE CourseOptimizer;

-- courses Table
CREATE TABLE courses (
course_id INT PRIMARY KEY,
course_name VARCHAR(100),
category_id INT);

INSERT INTO courses (course_id, course_name, category_id) VALUES
(101, 'Web Development', 1),
(102, 'Project Management', 2),
(103, 'Graphic Design', 3),
(104, 'Data Science', 1);

-- Categories Table
CREATE TABLE categories (
category_id INT PRIMARY KEY,
category_name VARCHAR(100));

INSERT INTO categories (category_id, category_name) VALUES
(1, 'Technology'),
(2, 'Business'),
(3, 'Design');

-- free_enrollments Table
CREATE TABLE free_enrollments (
enroll_id INT PRIMARY KEY,
course_id INT,
user_id INT,
enroll_date DATE,
FOREIGN KEY (course_id) REFERENCES courses(course_id));

INSERT INTO free_enrollments (enroll_id, course_id, user_id, enroll_date) VALUES
(1, 101, 201, '2025-06-01'),
(2, 101, 202, '2025-06-02'),
(3, 102, 203, '2025-06-03'),
(4, 103, 204, '2025-06-04');

-- Paid_enrollments Table
CREATE TABLE paid_enrollments (
enroll_id INT PRIMARY KEY,
course_id INT,
user_id INT,
enroll_date DATE,
FOREIGN KEY (course_id) REFERENCES courses(course_id));

INSERT INTO paid_enrollments (enroll_id, course_id, user_id, enroll_date) VALUES
(101, 101, 301, '2025-06-01'),
(102, 104, 302, '2025-06-02'),
(103, 104, 303, '2025-06-03'),
(104, 104, 304, '2025-06-04'),
(105, 103, 305, '2025-06-05');

-- Use UNION to combine enrollments from free and paid platforms.
SELECT course_id, user_id, enroll_date FROM free_enrollments
UNION
SELECT course_id, user_id, enroll_date FROM paid_enrollments;

-- Use subquery to find average enrollment per course.
SELECT course_id,
COUNT(*) AS total_enrollments
FROM (
SELECT course_id FROM free_enrollments
UNION ALL
SELECT course_id FROM paid_enrollments) AS all_enrollments
GROUP BY course_id;

-- Use JOIN to connect courses and categories.
SELECT c.course_name, cat.category_name
FROM courses c
JOIN categories cat ON c.category_id = cat.category_id;

-- Classify courses as Popular/Regular based on average.
SELECT c.course_id, c.course_name,
COUNT(*) AS total_enrollments,
CASE
WHEN COUNT(*) >= (SELECT AVG(course_enrolls) FROM (
SELECT course_id, COUNT(*) AS course_enrolls
FROM (SELECT course_id FROM free_enrollments
UNION ALL
SELECT course_id FROM paid_enrollments) AS all_enrolls
GROUP BY course_id) AS avg_table) THEN 'Popular'
ELSE 'Regular'
END AS popularity
FROM courses c
LEFT JOIN (
SELECT course_id FROM free_enrollments
UNION ALL
SELECT course_id FROM paid_enrollments) AS combined_enrollments ON c.course_id = combined_enrollments.course_id
GROUP BY c.course_id, c.course_name;


## 20. Vehicle Maintenance Tracker
## Domain: Transportation
## Objective: Track vehicle maintenance schedules.
-- Requirements:
CREATE DATABASE VehicleTracker;
USE VehicleTracker;

-- vehicle Table
CREATE TABLE vehicles (
vehicle_id INT PRIMARY KEY,
vehicle_type VARCHAR(50),
model VARCHAR(100),
last_service_date DATE,
next_service_date DATE);

INSERT INTO vehicles (vehicle_id, vehicle_type, model, last_service_date, next_service_date) VALUES
(1, 'Truck', 'Volvo FH16', '2025-05-01', '2025-07-20'),
(2, 'Bus', 'Mercedes Tourismo', '2025-06-10', '2025-07-15'),
(3, 'Van', 'Ford Transit', '2025-06-01', '2025-07-03'),
(4, 'Car', 'Toyota Corolla', '2025-05-15', '2025-08-10');

-- Maintainence Table
CREATE TABLE maintenance (
maintenance_id INT PRIMARY KEY,
vehicle_id INT,
service_date DATE,
cost DECIMAL(10,2),
description VARCHAR(200),
FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id));

INSERT INTO maintenance (maintenance_id, vehicle_id, service_date, cost, description) VALUES
(101, 1, '2025-05-01', 1200.00, 'Engine oil & brake check'),
(102, 2, '2025-06-10', 800.00, 'AC servicing'),
(103, 3, '2025-06-01', 950.00, 'Tyre rotation'),
(104, 4, '2025-05-15', 600.00, 'Battery replacement');

-- Use DATE_SUB to list vehicles due for service in the next 30 days.
SELECT vehicle_id, model, next_service_date
FROM vehicles
WHERE next_service_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- Use subqueries to find vehicles with highest service cost.
SELECT v.vehicle_id, v.model, m.cost
FROM vehicles v
JOIN maintenance m ON v.vehicle_id = m.vehicle_id
WHERE m.cost = (
SELECT MAX(cost)
FROM maintenance);

-- Use CASE to label urgency (High, Medium, Low).
SELECT vehicle_id, model, next_service_date,
CASE
WHEN DATEDIFF(next_service_date, CURDATE()) <= 7 THEN 'High'
WHEN DATEDIFF(next_service_date, CURDATE()) <= 15 THEN 'Medium'
ELSE 'Low'
END AS urgency_level
FROM vehicles;

-- Use GROUP BY to get total cost per vehicle type.
SELECT v.vehicle_type,
SUM(m.cost) AS total_maintenance_cost
FROM vehicles v
JOIN maintenance m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_type;
 

