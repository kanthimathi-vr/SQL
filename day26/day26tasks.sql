-- day 26 tasks

-- A. Hierarchical Data Tasks (1–15)
-- Create a self-referencing Employees table with emp_id, emp_name, and manager_id.
create database day26;
use day26;
CREATE TABLE Employees (
    emp_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    manager_id BIGINT UNSIGNED,
    position VARCHAR(50),
    department VARCHAR(50),
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES Employees(emp_id)
);

-- Insert at least 7 records to simulate an organizational hierarchy (CEO → Managers → Staff).
INSERT INTO Employees (emp_name, manager_id, position, department) VALUES
('Alice', NULL, 'CEO', 'Executive'),        -- Level 0
('Bob', 1, 'CTO', 'Tech'),                  -- Level 1
('Carol', 1, 'CFO', 'Finance'),            -- Level 1
('Dave', 2, 'Engineering Manager', 'Tech'),-- Level 2
('Eve', 2, 'DevOps Engineer', 'Tech'),     -- Level 2
('Frank', 4, 'Software Engineer', 'Tech'), -- Level 3
('Grace', 3, 'Accountant', 'Finance');     -- Level 2

-- Write a query using WITH RECURSIVE to show full employee hierarchy (emp_id, name, manager_id, level).
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT emp_id, emp_name, manager_id, position, department, 0 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.manager_id, e.position, e.department, eh.level + 1
    FROM Employees e
    JOIN EmployeeHierarchy eh ON e.manager_id = eh.emp_id
)
SELECT * FROM EmployeeHierarchy;

-- Modify the above query to return hierarchy sorted by level.
SELECT * FROM EmployeeHierarchy
ORDER BY level, emp_id;
-- this is cte (virtual temporay dat set)
-- alternative
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT emp_id, emp_name, manager_id, position, department, 0 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.manager_id, e.position, e.department, eh.level + 1
    FROM Employees e
    JOIN EmployeeHierarchy eh ON e.manager_id = eh.emp_id
)
SELECT * FROM EmployeeHierarchy
ORDER BY level, emp_id;

-- Add a column position and include it in the recursive query output.

-- Write a query to find all subordinates of a specific manager (e.g., manager_id = 2).
WITH RECURSIVE Subordinates AS (
    SELECT emp_id, emp_name, manager_id, 0 AS level
    FROM Employees
    WHERE emp_id = 2

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.manager_id, s.level + 1
    FROM Employees e
    JOIN Subordinates s ON e.manager_id = s.emp_id
)
SELECT * FROM Subordinates WHERE emp_id != 2;

-- Add a constraint to ensure no cyclic relationships (manager cannot be their own subordinate).
-- This must be enforced in application logic or via triggers in most RDBMS.
-- PostgreSQL-specific example using a function and trigger:

-- You could write a BEFORE INSERT or BEFORE UPDATE trigger to prevent
-- a new manager_id from being a subordinate of the current employee
-- See implementation if required.

-- Create a view EmployeeHierarchyView using the recursive CTE.
CREATE VIEW EmployeeHierarchyView AS
WITH RECURSIVE EmployeeHierarchy AS (
    SELECT emp_id, emp_name, manager_id, position, department, 0 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.manager_id, e.position, e.department, eh.level + 1
    FROM Employees e
    JOIN EmployeeHierarchy eh ON e.manager_id = eh.emp_id
)
SELECT * FROM EmployeeHierarchy;

-- Filter only level 3 employees (deepest hierarchy).
SELECT * FROM EmployeeHierarchyView WHERE level = 3;

-- Find the maximum level in the hierarchy using the recursive CTE.
SELECT MAX(level) AS max_depth FROM EmployeeHierarchyView;

-- Show manager and their immediate team (manager_id and team count).
SELECT manager_id, COUNT(*) AS team_count
FROM Employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id;

-- Count how many direct and indirect reports each manager has.
WITH RECURSIVE Reports AS (
    SELECT emp_id, manager_id, emp_id AS top_manager
    FROM Employees
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT e.emp_id, e.manager_id, r.top_manager
    FROM Employees e
    JOIN Reports r ON e.manager_id = r.emp_id
)
SELECT manager_id, COUNT(emp_id) AS total_reports
FROM Reports
GROUP BY manager_id;

-- Modify the recursive query to return a “path” from CEO to each employee.
WITH RECURSIVE EmployeePaths AS (
    SELECT emp_id, emp_name, manager_id, position, department,
           0 AS level,
           emp_name AS path
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.manager_id, e.position, e.department,
           ep.level + 1,
           CONCAT(ep.path, ' → ', e.emp_name)
    FROM Employees e
    JOIN EmployeePaths ep ON e.manager_id = ep.emp_id
)
SELECT * FROM EmployeePaths;

-- Add a department and list hierarchy within each department.
WITH RECURSIVE DeptHierarchy AS (
    SELECT emp_id, emp_name, manager_id, position, department, 0 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.manager_id, e.position, e.department, dh.level + 1
    FROM Employees e
    JOIN DeptHierarchy dh ON e.manager_id = dh.emp_id
)
SELECT * FROM DeptHierarchy
ORDER BY department, level;

-- Find the depth of a given employee in the organization tree.
WITH RECURSIVE EmpDepth AS (
    SELECT emp_id, manager_id, 0 AS depth
    FROM Employees
    WHERE emp_id = 6

    UNION ALL

    SELECT e.emp_id, e.manager_id, ed.depth + 1
    FROM Employees e
    JOIN EmpDepth ed ON e.emp_id = ed.manager_id
)
SELECT MAX(depth) AS depth_from_ceo
FROM EmpDepth;

-- B. Window Function Tasks (16–35)
-- Create a table Salaries with emp_id, emp_name, department, salary.
CREATE TABLE Salaries (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

-- Insert sample data for 10 employees across 3 departments.
INSERT INTO Salaries (emp_id, emp_name, department, salary) VALUES
(1, 'Alice', 'HR', 60000),
(2, 'Bob', 'Tech', 90000),
(3, 'Carol', 'Tech', 85000),
(4, 'Dave', 'HR', 62000),
(5, 'Eve', 'Finance', 75000),
(6, 'Frank', 'Finance', 80000),
(7, 'Grace', 'Tech', 85000),
(8, 'Heidi', 'Finance', 78000),
(9, 'Ivan', 'HR', 59000),
(10, 'Judy', 'Tech', 95000);

-- Use ROW_NUMBER() to rank employees based on salary (descending).
SELECT *, ROW_NUMBER() OVER (ORDER BY salary DESC) AS salary_rank
FROM Salaries;

-- Use RANK() to rank employees with salary ties.
SELECT *, RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM Salaries;

-- Use DENSE_RANK() and compare the output with RANK().
SELECT *, 
    RANK() OVER (ORDER BY salary DESC) AS rank_val,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_val
FROM Salaries;

-- Partition the ranking by department (use PARTITION BY).
SELECT *, 
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM Salaries;

-- Use LAG() to get previous employee's salary based on salary order.
SELECT emp_id, emp_name, salary,
       LAG(salary) OVER (ORDER BY salary DESC) AS prev_salary
FROM Salaries;

-- Use LEAD() to get next employee’s salary.
SELECT emp_id, emp_name, salary,
       LEAD(salary) OVER (ORDER BY salary DESC) AS next_salary
FROM Salaries;

-- Combine ROW_NUMBER() and LAG() to show employee progression.
SELECT emp_id, emp_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,
       LAG(salary) OVER (ORDER BY salary DESC) AS prev_salary
FROM Salaries;

-- Find employees whose salary increased compared to the previous one in order.
WITH SalaryLag AS (
    SELECT emp_id, emp_name, salary,
           LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM Salaries
)
SELECT *
FROM SalaryLag
WHERE salary > prev_salary;

-- Use NTILE(3) to divide employees into 3 salary tiers.
SELECT emp_id, emp_name, salary,
       NTILE(3) OVER (ORDER BY salary DESC) AS salary_tier
FROM Salaries;

-- Use FIRST_VALUE() and LAST_VALUE() to find salary extremes per department.
SELECT emp_id, emp_name, department, salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department ORDER BY salary DESC) AS highest_salary,
       LAST_VALUE(salary) OVER (
           PARTITION BY department ORDER BY salary DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS lowest_salary
FROM Salaries;

-- Use CUME_DIST() and PERCENT_RANK() to analyze salary distribution.
SELECT 
    emp_id,
    emp_name,
    salary,
    ((RANK() OVER (ORDER BY salary DESC) - 1) * 1.0) /
    (COUNT(*) OVER () - 1) AS percent1_rank
FROM Salaries;
-- Calculate moving average salary using AVG() with window frame.
SELECT emp_id, emp_name, salary,
       AVG(salary) OVER (
           ORDER BY emp_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS moving_avg
FROM Salaries;

-- Create a view that shows employee salary ranking in real-time using window functions.
CREATE VIEW SalaryRankView AS
SELECT emp_id, emp_name, department, salary,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_salary_rank
FROM Salaries;

-- Display each employee's salary as a percentage of the department total.
SELECT emp_id, emp_name, department, salary,
       ROUND((salary * 100) / SUM(salary) OVER (PARTITION BY department), 2) AS pct_of_dept
FROM Salaries;

-- Calculate salary difference from the highest salary in each department.
SELECT emp_id, emp_name, department, salary,
       MAX(salary) OVER (PARTITION BY department) - salary AS diff_from_top
FROM Salaries;

-- Write a report showing each employee and how they compare with their peers.
SELECT emp_id, emp_name, department, salary,
       AVG(salary) OVER (PARTITION BY department) AS dept_avg_salary,
       salary - AVG(salary) OVER (PARTITION BY department) AS diff_from_avg
FROM Salaries;

-- Identify employees whose salary is less than their department average.
WITH DeptAvg AS (
    SELECT *, 
           AVG(salary) OVER (PARTITION BY department) AS dept_avg
    FROM Salaries
)
SELECT * FROM DeptAvg
WHERE salary < dept_avg;

-- Group employees by department and rank their salaries within that group.
SELECT emp_id, emp_name, department, salary,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM Salaries
ORDER BY department, dept_rank;
-- C. CTE (Common Table Expression) Tasks (36–50)
-- Create a table Orders with order_id, customer_id, amount, order_date.
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    amount DECIMAL(10, 2),
    order_date DATE
);

-- Insert at least 20 orders across 5 customers.
INSERT INTO Orders (customer_id, amount, order_date) VALUES
(1, 15000, '2025-07-01'),
(2,  8000, '2025-07-01'),
(3, 12000, '2025-07-02'),
(1, 13000, '2025-07-02'),
(4,  9500, '2025-07-02'),
(5, 20000, '2025-07-03'),
(2, 18000, '2025-07-03'),
(3, 11000, '2025-07-03'),
(1,  5000, '2025-07-04'),
(4, 17000, '2025-07-04'),
(5,  7000, '2025-07-04'),
(1, 11500, '2025-07-05'),
(2, 12500, '2025-07-05'),
(3,  4500, '2025-07-06'),
(4,  9800, '2025-07-06'),
(5, 16000, '2025-07-07'),
(1, 10500, '2025-07-07'),
(2, 22000, '2025-07-08'),
(3, 14500, '2025-07-08'),
(5, 15000, '2025-07-09');

-- Use a CTE to filter and return orders above ₹10,000.
WITH HighValueOrders AS (
    SELECT * FROM Orders WHERE amount > 10000
)
SELECT * FROM HighValueOrders;

-- Use a CTE to calculate total order amount per customer.
WITH CustomerTotals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM Orders
    GROUP BY customer_id
)
SELECT * FROM CustomerTotals;

-- Use a CTE to count orders per customer, and return only those with > 3 orders.
WITH OrderCounts AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM Orders
    GROUP BY customer_id
)
SELECT * FROM OrderCounts
WHERE order_count > 3;

-- Write a query using two CTEs: one for top spending customers, another for frequent buyers.
WITH TopSpenders AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM Orders
    GROUP BY customer_id
    HAVING total_spent > 40000
),
FrequentBuyers AS (
    SELECT customer_id, COUNT(*) AS orders_made
    FROM Orders
    GROUP BY customer_id
    HAVING orders_made > 3
)
SELECT ts.customer_id, ts.total_spent, fb.orders_made
FROM TopSpenders ts
JOIN FrequentBuyers fb ON ts.customer_id = fb.customer_id;

-- Use a recursive CTE to simulate a tree structure of product categories.
-- Table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    parent_id INT
);

-- Sample hierarchy
INSERT INTO Categories VALUES
(1, 'Electronics', NULL),
(2, 'Phones', 1),
(3, 'Laptops', 1),
(4, 'Smartphones', 2),
(5, 'Gaming Laptops', 3);

-- Recursive CTE
WITH RECURSIVE CategoryTree AS (
    SELECT category_id, category_name, parent_id, 0 AS level
    FROM Categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT c.category_id, c.category_name, c.parent_id, ct.level + 1
    FROM Categories c
    JOIN CategoryTree ct ON c.parent_id = ct.category_id
)
SELECT * FROM CategoryTree;

-- Create a recursive CTE to calculate the factorial of a number.
WITH RECURSIVE Factorial(n, fact) AS (
    SELECT 1, 1
    UNION ALL
    SELECT n + 1, fact * (n + 1)
    FROM Factorial
    WHERE n < 5
)
SELECT * FROM Factorial;

-- Use a CTE to calculate running totals over daily sales (with date filter).
WITH DailySales AS (
    SELECT order_date, SUM(amount) AS daily_total
    FROM Orders
    GROUP BY order_date
),
RunningTotal AS (
    SELECT order_date, daily_total,
           SUM(daily_total) OVER (ORDER BY order_date) AS running_total
    FROM DailySales
)
SELECT * FROM RunningTotal;

-- Use CTE inside a view to simplify reporting.
CREATE VIEW CustomerSpendingReport AS
WITH CustomerTotals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM Orders
    GROUP BY customer_id
)
SELECT * FROM CustomerTotals;

-- Chain multiple CTEs together and use them in a final SELECT.
WITH DailyTotals AS (
    SELECT order_date, SUM(amount) AS total
    FROM Orders
    GROUP BY order_date
),
Running AS (
    SELECT order_date, total,
           SUM(total) OVER (ORDER BY order_date) AS running_total
    FROM DailyTotals
),
TopDays AS (
    SELECT * FROM Running WHERE total > 20000
)
SELECT * FROM TopDays;

WITH DailyTotals AS (
    SELECT 
        order_date, 
        SUM(amount) AS total,
        COUNT(*) AS orders_count,
        AVG(amount) AS avg_order_amount
    FROM Orders
    GROUP BY order_date
),
Running AS (
    SELECT 
        order_date, 
        total,
        orders_count,
        avg_order_amount,
        SUM(total) OVER (ORDER BY order_date) AS running_total
    FROM DailyTotals
),
TopDays AS (
    SELECT * FROM Running WHERE total > 20000
)
SELECT * FROM TopDays;


-- Compare performance of a long nested query vs. using CTE for readability.
SELECT order_date, SUM(total) OVER (ORDER BY order_date) AS running_total
FROM (
    SELECT order_date, SUM(amount) AS total
    FROM Orders
    GROUP BY order_date
) AS sub;

-- Use a recursive CTE to list all levels of reporting managers for a given employee.
WITH RECURSIVE ReportingChain AS (
    SELECT emp_id, emp_name, manager_id, 0 AS level
    FROM Employees
    WHERE emp_id = 6  -- target employee

    UNION ALL

    SELECT e.emp_id, e.emp_name, e.manager_id, rc.level + 1
    FROM Employees e
    JOIN ReportingChain rc ON e.emp_id = rc.manager_id
)
SELECT * FROM ReportingChain;

-- Create a temporary table using a CTE for top 5 customers per region.
-- Assume Orders has region info
ALTER TABLE Orders ADD COLUMN region VARCHAR(50);
-- Then populate it accordingly...
ALTER TABLE Orders ADD COLUMN region VARCHAR(50);
-- Example: randomly assign regions (you can customize this)
UPDATE Orders SET region = CASE 
    WHEN customer_id IN (1, 2) THEN 'North'
    WHEN customer_id IN (3) THEN 'South'
    WHEN customer_id IN (4) THEN 'East'
    ELSE 'West'
END
where order_id > 0;

WITH RankedCustomers AS (
    SELECT customer_id, region, SUM(amount) AS total_spent,
           RANK() OVER (PARTITION BY region ORDER BY SUM(amount) DESC) AS rnk
    FROM Orders
    GROUP BY customer_id, region
)
SELECT * FROM RankedCustomers WHERE rnk <= 5;

-- Write a final query combining CTE + window function to get rank of customers by order total.
WITH CustomerTotals AS (
    SELECT customer_id, SUM(amount) AS total_spent
    FROM Orders
    GROUP BY customer_id
)
SELECT customer_id, total_spent,
       RANK() OVER (ORDER BY total_spent DESC) AS customer_rank
FROM CustomerTotals;




























































