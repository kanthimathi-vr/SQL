-- day 26 mini projects
-- project1:

-- 1. Organizational Chart Reporting System
-- Goal: Show the company hierarchy with employee levels
-- Requirements:
-- Create Employees table with self-referencing manager_id
create database day26mp;
use day26mp;
CREATE TABLE Employees (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    FOREIGN KEY (manager_id) REFERENCES Employees(id)
);
INSERT INTO Employees (id, name, manager_id) VALUES
(1, 'Alice', NULL),       -- CEO
(2, 'Bob', 1),
(3, 'Charlie', 1),
(4, 'Diana', 2),
(5, 'Eve', 2),
(6, 'Frank', 3),
(7, 'Grace', 4);

-- Use a recursive CTE to list all employees with level of hierarchy
WITH RECURSIVE OrgHierarchy AS (
    SELECT 
        id,
        name,
        manager_id,
        0 AS level
    FROM Employees
    WHERE manager_id IS NULL  -- Start from the top (CEO)

    UNION ALL

    SELECT 
        e.id,
        e.name,
        e.manager_id,
        oh.level + 1
    FROM Employees e
    INNER JOIN OrgHierarchy oh ON e.manager_id = oh.id
)
SELECT * FROM OrgHierarchy;

-- Create a view OrgHierarchyView to abstract the logic
CREATE VIEW OrgHierarchyView AS
WITH RECURSIVE OrgHierarchy AS (
    SELECT 
        id,
        name,
        manager_id,
        0 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT 
        e.id,
        e.name,
        e.manager_id,
        oh.level + 1
    FROM Employees e
    INNER JOIN OrgHierarchy oh ON e.manager_id = oh.id
)
SELECT * FROM OrgHierarchy;

-- Report: Show each employee's name, manager name, and depth
SELECT 
    o.name AS employee_name,
    m.name AS manager_name,
    o.level AS hierarchy_depth
FROM OrgHierarchyView o
LEFT JOIN Employees m ON o.manager_id = m.id
ORDER BY o.level, o.name;

-- project2:
-- 2. Salary Ranking Dashboard
-- Goal: Rank employees by salary for performance review
-- Requirements:
CREATE TABLE Employees1 (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10, 2)
);
INSERT INTO Employees1 (id, name, department, salary) VALUES
(1, 'Alice', 'Engineering', 120000),
(2, 'Bob', 'Engineering', 115000),
(3, 'Charlie', 'Engineering', 120000),
(4, 'Diana', 'HR', 90000),
(5, 'Eve', 'HR', 85000),
(6, 'Frank', 'HR', 85000),
(7, 'Grace', 'Sales', 95000),
(8, 'Heidi', 'Sales', 90000);

-- Use window functions: ROW_NUMBER(), RANK(), DENSE_RANK()
SELECT
    id,
    name,
    department,
    salary,

    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num,
    RANK()       OVER (PARTITION BY department ORDER BY salary DESC) AS rnk,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dens_rank,

    LAG(salary)  OVER (PARTITION BY department ORDER BY salary DESC) AS previous_salary,
    LEAD(salary) OVER (PARTITION BY department ORDER BY salary DESC) AS next_salary,

    salary - LAG(salary)  OVER (PARTITION BY department ORDER BY salary DESC) AS diff_from_previous,
    LEAD(salary) OVER (PARTITION BY department ORDER BY salary DESC) - salary AS diff_to_next
FROM Employees1
ORDER BY department, salary DESC;

-- Partition by department
-- Include LEAD() and LAG() to show previous and next salaries
-- Build a report with ranking columns and movement insights
CREATE VIEW SalaryRankingDashboard AS
SELECT
    id,
    name,
    department,
    salary,

    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS row_num,
    RANK()       OVER (PARTITION BY department ORDER BY salary DESC) AS rnk,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dens_rank,

    LAG(salary)  OVER (PARTITION BY department ORDER BY salary DESC) AS previous_salary,
    LEAD(salary) OVER (PARTITION BY department ORDER BY salary DESC) AS next_salary,

    salary - LAG(salary)  OVER (PARTITION BY department ORDER BY salary DESC) AS diff_from_previous,
    LEAD(salary) OVER (PARTITION BY department ORDER BY salary DESC) - salary AS diff_to_next
FROM Employees1;

-- project3:
-- 3. Customer Order Recency Report
-- Goal: Analyze customer orders chronologically
-- Requirements:
-- Create Orders table with customer_id, order_date, amount
CREATE TABLE Orders (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2)
);
INSERT INTO Orders (id, customer_id, order_date, amount) VALUES
(1, 101, '2025-01-01', 100.00),
(2, 101, '2025-01-15', 150.00),
(3, 101, '2025-03-01', 200.00),
(4, 102, '2025-02-01', 120.00),
(5, 102, '2025-02-10', 130.00),
(6, 102, '2025-04-20', 140.00),
(7, 103, '2025-01-10', 90.00);

-- Use LAG() and LEAD() to compare previous and next orders
WITH OrderGaps AS (
    SELECT
        id,
        customer_id,
        order_date,
        amount,

        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
        LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_date,

        DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_previous,
        DATEDIFF(LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date), order_date) AS days_to_next
    FROM Orders
)
SELECT * FROM OrderGaps;
-- Calculate time difference between orders using DATEDIFF()
-- Use a CTE to filter customers with gaps > 30 days between orders
WITH OrderGaps AS (
    SELECT
        id,
        customer_id,
        order_date,
        amount,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
        DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_previous
    FROM Orders
)
SELECT *
FROM OrderGaps
WHERE days_since_previous > 30;

-- project4:
-- 4. Product Category Tree Visualizer
-- Goal: Represent products in parent-child categories
-- Requirements:
-- Create ProductCategories with self-referencing parent_id
CREATE TABLE ProductCategories (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT NULL,
    FOREIGN KEY (parent_id) REFERENCES ProductCategories(id)
);
INSERT INTO ProductCategories (id, name, parent_id) VALUES
(1, 'Electronics', NULL),
(2, 'Computers', 1),
(3, 'Laptops', 2),
(4, 'Desktops', 2),
(5, 'Smartphones', 1),
(6, 'Clothing', NULL),
(7, 'Men', 6),
(8, 'Women', 6),
(9, 'Shirts', 7),
(10, 'Dresses', 8);

-- Use recursive CTE to retrieve category hierarchy with level
WITH RECURSIVE CategoryTree AS (
    SELECT
        id,
        name,
        parent_id,
        0 AS level,
        name AS path
    FROM ProductCategories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.id,
        c.name,
        c.parent_id,
        ct.level + 1,
        CONCAT(ct.path, ' > ', c.name) AS path
    FROM ProductCategories c
    JOIN CategoryTree ct ON c.parent_id = ct.id
)
SELECT *
FROM CategoryTree
ORDER BY path;

-- Add path column using string concatenation to trace full path
WITH RECURSIVE CategoryTree AS (
    SELECT
        id,
        name,
        parent_id,
        0 AS level,
        name AS path
    FROM ProductCategories
    WHERE parent_id IS NULL  -- Start from root categories

    UNION ALL

    SELECT
        c.id,
        c.name,
        c.parent_id,
        ct.level + 1,
        CONCAT(ct.path, ' > ', c.name) AS path
    FROM ProductCategories c
    JOIN CategoryTree ct ON c.parent_id = ct.id
)
SELECT 
    id,
    name AS category_name,
    parent_id,
    level,
    path
FROM CategoryTree
ORDER BY path;

-- Display top-level to sub-category tree in a report

-- project5:
-- 5. Employee Promotion Tracker
-- Goal: Track employee growth and salary progression
-- Requirements:
CREATE TABLE EmployeeSalaries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    salary DECIMAL(10, 2),
    effective_date DATE
);
INSERT INTO EmployeeSalaries (employee_id, salary, effective_date) VALUES
(1, 50000, '2023-01-01'),
(1, 55000, '2024-06-01'),
(1, 60000, '2025-05-15'),
(2, 60000, '2023-03-01'),
(2, 60000, '2024-07-01'),
(3, 45000, '2024-12-15'),
(3, 50000, '2025-01-15');

-- Store multiple salary records over time
-- Use LAG() to compare current vs. previous salary
WITH SalaryChanges AS (
    SELECT
        employee_id,
        salary,
        effective_date,
        LAG(salary) OVER (PARTITION BY employee_id ORDER BY effective_date) AS previous_salary,
        salary - LAG(salary) OVER (PARTITION BY employee_id ORDER BY effective_date) AS salary_diff
    FROM EmployeeSalaries
)
SELECT *
FROM SalaryChanges
WHERE 
    salary_diff IS NOT NULL 
    AND salary_diff > 0
    AND YEAR(effective_date) = YEAR(CURDATE());
-- Highlight employees promoted or raised in last year
WITH SalaryChanges AS (
    SELECT
        employee_id,
        salary,
        effective_date,
        LAG(salary) OVER (PARTITION BY employee_id ORDER BY effective_date) AS previous_salary,
        salary - LAG(salary) OVER (PARTITION BY employee_id ORDER BY effective_date) AS salary_diff
    FROM EmployeeSalaries
)
SELECT *
FROM SalaryChanges
WHERE 
    salary_diff IS NOT NULL
    AND salary_diff > 0
    AND YEAR(effective_date) = YEAR(CURDATE()) - 1;

-- Use CTE for current year promotions only
WITH SalaryChanges AS (
    SELECT
        employee_id,
        salary,
        effective_date,
        LAG(salary) OVER (PARTITION BY employee_id ORDER BY effective_date) AS previous_salary,
        salary - LAG(salary) OVER (PARTITION BY employee_id ORDER BY effective_date) AS salary_diff
    FROM EmployeeSalaries
)
SELECT *
FROM SalaryChanges
WHERE 
    salary_diff IS NOT NULL
    AND salary_diff > 0
    AND YEAR(effective_date) = YEAR(CURDATE());
-- project6:
-- 6. Customer Segmentation System
-- Goal: Classify customers based on order volume
-- Requirements:
CREATE TABLE Customers (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE Orders1 (
    id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(id)
);
INSERT INTO Customers (id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Eva'),
(6, 'Frank'),
(7, 'Grace'),
(8, 'Helen'),
(9, 'Ivan'),
(10, 'Julia');

INSERT INTO Orders1 (id, customer_id, order_date, amount) VALUES
(1, 1, '2024-01-10', 250.00),
(2, 1, '2024-02-15', 300.00),
(3, 2, '2024-01-20', 150.00),
(4, 3, '2024-03-10', 500.00),
(5, 3, '2024-04-10', 700.00),
(6, 4, '2024-02-01', 200.00),
(7, 5, '2024-01-15', 50.00),
(8, 6, '2024-03-22', 900.00),
(9, 7, '2024-04-18', 400.00),
(10, 8, '2024-05-05', 1200.00),
(11, 9, '2024-04-25', 100.00),
(12, 10, '2024-05-20', 300.00),
(13, 10, '2024-06-01', 400.00);

-- Use window function NTILE() to divide customers into 4 quartiles
WITH CustomerSpend AS (
    SELECT 
        customer_id, 
        SUM(amount) AS total_spend
    FROM Orders
    GROUP BY customer_id
),
CustomerQuartiles AS (
    SELECT 
        customer_id,
        total_spend,
        NTILE(4) OVER (ORDER BY total_spend DESC) AS quartile_rank
    FROM CustomerSpend
)
SELECT * FROM CustomerQuartiles;

-- Calculate total spend per customer using aggregation + CTE
WITH CustomerSpend AS (
    SELECT 
        customer_id, 
        SUM(amount) AS total_spend
    FROM Orders1
    GROUP BY customer_id
)
SELECT * FROM CustomerSpend;

-- Assign segment: Platinum, Gold, Silver, Bronze
WITH CustomerSpend AS (
    SELECT 
        customer_id, 
        SUM(amount) AS total_spend
    FROM Orders
    GROUP BY customer_id
),
CustomerQuartiles AS (
    SELECT 
        customer_id,
        total_spend,
        NTILE(4) OVER (ORDER BY total_spend DESC) AS quartile_rank
    FROM CustomerSpend
)
SELECT
    customer_id,
    total_spend,
    quartile_rank,
    CASE quartile_rank
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
    END AS segment
FROM CustomerQuartiles;

-- Create a view for reporting by segment
CREATE VIEW CustomerSegmentation AS
WITH CustomerSpend AS (
    SELECT 
        customer_id, 
        SUM(amount) AS total_spend
    FROM Orders
    GROUP BY customer_id
),
CustomerQuartiles AS (
    SELECT 
        customer_id,
        total_spend,
        NTILE(4) OVER (ORDER BY total_spend DESC) AS quartile_rank
    FROM CustomerSpend
)
SELECT
    customer_id,
    total_spend,
    quartile_rank,
    CASE quartile_rank
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
    END AS segment
FROM CustomerQuartiles;
-- final report joining customer names
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM CustomerSegmentation;
WITH CustomerSpend AS (
    SELECT 
        customer_id, 
        SUM(amount) AS total_spend
    FROM Orders
    GROUP BY customer_id
)
SELECT * FROM CustomerSpend;

SELECT
    c.name,
    cs.total_spend,
    cs.segment
FROM CustomerSegmentation cs
JOIN Customers c ON cs.customer_id = c.id
ORDER BY cs.total_spend DESC;

-- project7:
-- 7. Salesperson Hierarchy and Performance Tracker
-- Goal: Visualize team structure and sales performance
-- Requirements:
CREATE TABLE Salespersons (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT NULL,
    FOREIGN KEY (manager_id) REFERENCES Salespersons(id)
);
INSERT INTO Salespersons (id, name, manager_id) VALUES
(1, 'Alice', NULL),       -- Top-level manager (CEO)
(2, 'Bob', 1),
(3, 'Charlie', 1),
(4, 'David', 2),
(5, 'Eva', 2),
(6, 'Frank', 3),
(7, 'Grace', 3),
(8, 'Helen', 4);

-- Salespersons table with self-referencing manager_id
CREATE TABLE Sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    salesperson_id INT,
    sales_amount DECIMAL(10,2),
    sale_date DATE,
    FOREIGN KEY (salesperson_id) REFERENCES Salespersons(id)
);
INSERT INTO Sales (salesperson_id, sales_amount, sale_date) VALUES
(2, 1000, '2024-06-01'),
(3, 1500, '2024-06-01'),
(4, 700, '2024-06-01'),
(5, 900, '2024-06-01'),
(6, 1200, '2024-06-01'),
(7, 1300, '2024-06-01'),
(8, 600, '2024-06-01');

-- Use recursive CTE to build the hierarchy
WITH RECURSIVE Hierarchy AS (
    SELECT
        id,
        name,
        manager_id,
        1 AS level,
        CAST(name AS CHAR(1000)) AS path -- keep track of path for clarity
    FROM Salespersons
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        s.id,
        s.name,
        s.manager_id,
        h.level + 1,
        CONCAT(h.path, ' > ', s.name)
    FROM Salespersons s
    INNER JOIN Hierarchy h ON s.manager_id = h.id
)
SELECT * FROM Hierarchy ORDER BY path;

-- Use SUM(sales_amount) over window to track team performance
SELECT
    salesperson_id,
    SUM(sales_amount) AS total_sales
FROM Sales
GROUP BY salesperson_id;
WITH RECURSIVE Hierarchy AS (
    SELECT
        id,
        name,
        manager_id
    FROM Salespersons
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        s.id,
        s.name,
        s.manager_id
    FROM Salespersons s
    INNER JOIN Hierarchy h ON s.manager_id = h.id
),
TeamMembers AS (
    SELECT
        h1.id AS manager_id,
        h2.id AS team_member_id
    FROM Hierarchy h1
    JOIN Hierarchy h2 ON h2.path LIKE CONCAT(h1.path, '%') -- this approach requires a path column; if not available, alternative approach below
),
-- Alternative approach without path:
Team AS (
    -- Start with each manager
    SELECT id AS manager_id, id AS team_member_id
    FROM Salespersons

    UNION ALL

    SELECT t.manager_id, s.id
    FROM Team t
    JOIN Salespersons s ON s.manager_id = t.team_member_id
),
SalesSum AS (
    SELECT
        t.manager_id,
        SUM(COALESCE(s.sales_amount, 0)) AS team_sales
    FROM Team t
    LEFT JOIN Sales s ON s.salesperson_id = t.team_member_id
    GROUP BY t.manager_id
)
SELECT
    sp.id,
    sp.name,
    ss.team_sales
FROM Salespersons sp
LEFT JOIN SalesSum ss ON sp.id = ss.manager_id
ORDER BY ss.team_sales DESC;

-- Add ranking using RANK() by sales within team
WITH RECURSIVE Team AS (
    SELECT id AS manager_id, id AS team_member_id
    FROM Salespersons

    UNION ALL

    SELECT t.manager_id, s.id
    FROM Team t
    JOIN Salespersons s ON s.manager_id = t.team_member_id
),
SalesSum AS (
    SELECT
        t.manager_id,
        t.team_member_id,
        COALESCE(SUM(s.sales_amount), 0) AS member_sales
    FROM Team t
    LEFT JOIN Sales s ON s.salesperson_id = t.team_member_id
    GROUP BY t.manager_id, t.team_member_id
)
SELECT
    manager_id,
    team_member_id,
    member_sales,
    RANK() OVER (PARTITION BY manager_id ORDER BY member_sales DESC) AS sales_rank
FROM SalesSum
ORDER BY manager_id, sales_rank;

-- project8:
-- 8. Finance Department Budget Tracker
-- Goal: Analyze departmental expenses and ranks
-- Requirements:
CREATE TABLE Departments (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE DepartmentBudgets (
    id INT PRIMARY KEY,
    department_id INT,
    budget_amount DECIMAL(15,2),
    budget_year INT,
    FOREIGN KEY (department_id) REFERENCES Departments(id)
);

-- Sample data
INSERT INTO Departments (id, name) VALUES
(1, 'Finance'),
(2, 'HR'),
(3, 'Engineering'),
(4, 'Marketing'),
(5, 'Sales');

INSERT INTO DepartmentBudgets (id, department_id, budget_amount, budget_year) VALUES
(1, 1, 500000, 2024),
(2, 2, 200000, 2024),
(3, 3, 750000, 2024),
(4, 4, 300000, 2024),
(5, 5, 450000, 2024);
WITH FilteredBudgets AS (
    SELECT
        d.id AS department_id,
        d.name AS department_name,
        b.budget_amount
    FROM Departments d
    JOIN DepartmentBudgets b ON d.id = b.department_id
    WHERE b.budget_amount > 250000
), RankedBudgets AS (
    SELECT
        department_id,
        department_name,
        budget_amount,
        RANK() OVER (ORDER BY budget_amount DESC) AS spend_rank,
        MAX(budget_amount) OVER () AS max_budget
    FROM FilteredBudgets
)
SELECT
    department_name,
    spend_rank,
    budget_amount,
    max_budget - budget_amount AS spend_delta
FROM RankedBudgets
ORDER BY spend_rank;


-- Use window functions to rank departments by spend
-- Use CTEs to isolate only budgets above a threshold
-- Calculate difference between each department and top spender
-- Present report with department, rank, spend delta

-- project9:
-- 9. Daily Transaction Trend Analyzer
-- Goal: Track trends and moving averages
-- Requirements:
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_date DATE,
    amount DECIMAL(10,2)
);
INSERT INTO Transactions (transaction_date, amount) VALUES
('2025-06-01', 100.00),
('2025-06-01', 150.00),
('2025-06-02', 200.00),
('2025-06-03', 120.00),
('2025-06-03', 180.00),
('2025-06-04', 90.00),
('2025-06-05', 300.00),
('2025-06-06', 250.00),
('2025-06-07', 400.00),
('2025-06-08', 350.00),
('2025-06-09', 500.00),
('2025-06-10', 450.00),
('2025-06-11', 600.00),
('2025-06-12', 700.00),
('2025-06-13', 800.00),
('2025-06-14', 750.00),
('2025-06-15', 650.00),
('2025-06-16', 400.00),
('2025-06-17', 300.00),
('2025-06-18', 350.00),
('2025-06-19', 200.00),
('2025-06-20', 150.00),
('2025-06-21', 100.00),
('2025-06-22', 180.00),
('2025-06-23', 220.00),
('2025-06-24', 270.00),
('2025-06-25', 300.00),
('2025-06-26', 280.00),
('2025-06-27', 260.00),
('2025-06-28', 290.00),
('2025-06-29', 310.00),
('2025-06-30', 330.00),
('2025-07-01', 350.00),
('2025-07-02', 370.00),
('2025-07-03', 390.00),
('2025-07-04', 410.00),
('2025-07-05', 430.00),
('2025-07-06', 450.00),
('2025-07-07', 470.00);

-- Use AVG() with a window frame for rolling 7-day average
-- Highlight days when spending was above average
-- Use a CTE to filter recent 30-day period
-- Graph-ready output with daily metrics
WITH RecentTransactions AS (
    SELECT
        transaction_date,
        SUM(amount) AS daily_total
    FROM Transactions
    WHERE transaction_date >= CURDATE() - INTERVAL 30 DAY
    GROUP BY transaction_date
),
DailyWithAvg AS (
    SELECT
        transaction_date,
        daily_total,
        AVG(daily_total) OVER (
            ORDER BY transaction_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS rolling_7day_avg
    FROM RecentTransactions
)
SELECT
    transaction_date,
    daily_total,
    rolling_7day_avg,
    CASE
        WHEN daily_total > rolling_7day_avg THEN 'Above Average'
        ELSE 'Normal or Below Average'
    END AS trend_indicator
FROM DailyWithAvg
ORDER BY transaction_date;

-- project10:
-- ✅ 10. Online Learning Progress Report
-- Goal: Show student learning progression
-- Requirements:
CREATE TABLE StudentQuizScores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    quiz_date DATE,
    score INT
);

-- Sample data (student_id, quiz_date, score)
INSERT INTO StudentQuizScores (student_id, quiz_date, score) VALUES
(1, '2025-06-01', 70),
(1, '2025-06-05', 75),
(1, '2025-06-10', 72),
(2, '2025-06-02', 80),
(2, '2025-06-07', 85),
(2, '2025-06-12', 90),
(3, '2025-06-01', 60),
(3, '2025-06-05', 60),
(3, '2025-06-10', 60);

-- Use LAG() to compare quiz scores
WITH ScoreComparison AS (
    SELECT
        student_id,
        quiz_date,
        score,
        LAG(score) OVER (PARTITION BY student_id ORDER BY quiz_date) AS previous_score
    FROM StudentQuizScores
)
SELECT
    student_id,
    quiz_date,
    score,
    previous_score,
    CASE
        WHEN previous_score IS NULL THEN 'N/A'
        WHEN score > previous_score THEN 'Improving'
        WHEN score < previous_score THEN 'Declining'
        ELSE 'Stagnant'
    END AS progress_trend
FROM ScoreComparison
ORDER BY student_id, quiz_date;

-- Identify students improving, declining, or stagnant
-- Partition scores by student_id
-- Use CTE to prepare improvement summary for each student
WITH ScoreComparison AS (
    SELECT
        student_id,
        quiz_date,
        score,
        LAG(score) OVER (PARTITION BY student_id ORDER BY quiz_date) AS previous_score
    FROM StudentQuizScores
),
ImprovementSummary AS (
    SELECT
        student_id,
        SUM(CASE WHEN score > previous_score THEN 1 ELSE 0 END) AS improving_count,
        SUM(CASE WHEN score < previous_score THEN 1 ELSE 0 END) AS declining_count,
        SUM(CASE WHEN score = previous_score THEN 1 ELSE 0 END) AS stagnant_count,
        COUNT(*) - 1 AS total_comparisons  -- total comparisons per student (excluding first quiz)
    FROM ScoreComparison
    WHERE previous_score IS NOT NULL
    GROUP BY student_id
)
SELECT
    student_id,
    improving_count,
    declining_count,
    stagnant_count,
    total_comparisons
FROM ImprovementSummary
ORDER BY student_id;

-- project11:
-- 11. E-commerce Purchase Funnel Report
-- Goal: Analyze user journey through funnel stages
-- Requirements:
CREATE TABLE UserFunnelActivities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    activity_date DATETIME,
    stage ENUM('view', 'cart', 'checkout', 'payment')
);

-- Sample data (user_id, activity_date, stage)
INSERT INTO UserFunnelActivities (user_id, activity_date, stage) VALUES
(1, '2025-07-01 10:00', 'view'),
(1, '2025-07-01 10:05', 'cart'),
(1, '2025-07-01 10:10', 'checkout'),
(2, '2025-07-01 11:00', 'view'),
(2, '2025-07-01 11:15', 'cart'),
(3, '2025-07-01 12:00', 'view'),
(3, '2025-07-01 12:20', 'cart'),
(3, '2025-07-01 12:30', 'checkout'),
(3, '2025-07-01 12:45', 'payment'),
(4, '2025-07-01 13:00', 'view');

-- Track stage-wise activity (view → cart → checkout → payment)
WITH StagedActivities AS (
    SELECT
        user_id,
        stage,
        activity_date,
        CASE stage
            WHEN 'view' THEN 1
            WHEN 'cart' THEN 2
            WHEN 'checkout' THEN 3
            WHEN 'payment' THEN 4
        END AS stage_rank
    FROM UserFunnelActivities
),
UserMaxStage AS (
    SELECT
        user_id,
        MAX(stage_rank) AS max_stage
    FROM StagedActivities
    GROUP BY user_id
),
UserActivityDepth AS (
    SELECT
        user_id,
        max_stage,
        RANK() OVER (ORDER BY max_stage DESC) AS depth_rank
    FROM UserMaxStage
)
SELECT
    u.user_id,
    u.max_stage,
    CASE u.max_stage
        WHEN 1 THEN 'view'
        WHEN 2 THEN 'cart'
        WHEN 3 THEN 'checkout'
        WHEN 4 THEN 'payment'
    END AS deepest_stage,
    u.depth_rank
FROM UserActivityDepth u
ORDER BY depth_rank, user_id;

-- Use window functions to find conversion drop-off points
WITH StagedActivities AS (
    SELECT
        user_id,
        stage,
        activity_date,
        CASE stage
            WHEN 'view' THEN 1
            WHEN 'cart' THEN 2
            WHEN 'checkout' THEN 3
            WHEN 'payment' THEN 4
        END AS stage_rank
    FROM UserFunnelActivities
),
StageCounts AS (
    SELECT
        stage_rank,
        COUNT(DISTINCT user_id) AS user_count
    FROM StagedActivities
    GROUP BY stage_rank
),
DropOffs AS (
    SELECT
        sc1.stage_rank AS from_stage,
        sc2.stage_rank AS to_stage,
        sc1.user_count AS from_users,
        sc2.user_count AS to_users,
        (sc1.user_count - sc2.user_count) AS drop_off,
        ROUND(100.0 * (sc1.user_count - sc2.user_count) / sc1.user_count, 2) AS drop_off_percentage
    FROM StageCounts sc1
    LEFT JOIN StageCounts sc2 ON sc2.stage_rank = sc1.stage_rank + 1
    WHERE sc2.stage_rank IS NOT NULL
)
SELECT
    from_stage,
    CASE from_stage
        WHEN 1 THEN 'view'
        WHEN 2 THEN 'cart'
        WHEN 3 THEN 'checkout'
    END AS from_stage_name,
    to_stage,
    CASE to_stage
        WHEN 2 THEN 'cart'
        WHEN 3 THEN 'checkout'
        WHEN 4 THEN 'payment'
    END AS to_stage_name,
    from_users,
    to_users,
    drop_off,
    drop_off_percentage
FROM DropOffs
ORDER BY from_stage;

-- Rank users by activity depth
-- Create a view for marketing dashboard
CREATE OR REPLACE VIEW EcommFunnelSummary AS
WITH StagedActivities AS (
    SELECT
        user_id,
        stage,
        activity_date,
        CASE stage
            WHEN 'view' THEN 1
            WHEN 'cart' THEN 2
            WHEN 'checkout' THEN 3
            WHEN 'payment' THEN 4
        END AS stage_rank
    FROM UserFunnelActivities
),
UserMaxStage AS (
    SELECT
        user_id,
        MAX(stage_rank) AS max_stage
    FROM StagedActivities
    GROUP BY user_id
),
UserActivityDepth AS (
    SELECT
        user_id,
        max_stage,
        RANK() OVER (ORDER BY max_stage DESC) AS depth_rank
    FROM UserMaxStage
),
StageCounts AS (
    SELECT
        stage_rank,
        COUNT(DISTINCT user_id) AS user_count
    FROM StagedActivities
    GROUP BY stage_rank
),
DropOffs AS (
    SELECT
        sc1.stage_rank AS from_stage,
        sc2.stage_rank AS to_stage,
        sc1.user_count AS from_users,
        sc2.user_count AS to_users,
        (sc1.user_count - sc2.user_count) AS drop_off,
        ROUND(100.0 * (sc1.user_count - sc2.user_count) / sc1.user_count, 2) AS drop_off_percentage
    FROM StageCounts sc1
    LEFT JOIN StageCounts sc2 ON sc2.stage_rank = sc1.stage_rank + 1
    WHERE sc2.stage_rank IS NOT NULL
)
SELECT
    u.user_id,
    u.max_stage,
    CASE u.max_stage
        WHEN 1 THEN 'view'
        WHEN 2 THEN 'cart'
        WHEN 3 THEN 'checkout'
        WHEN 4 THEN 'payment'
    END AS deepest_stage,
    u.depth_rank,
    d.from_stage,
    CASE d.from_stage
        WHEN 1 THEN 'view'
        WHEN 2 THEN 'cart'
        WHEN 3 THEN 'checkout'
    END AS from_stage_name,
    d.to_stage,
    CASE d.to_stage
        WHEN 2 THEN 'cart'
        WHEN 3 THEN 'checkout'
        WHEN 4 THEN 'payment'
    END AS to_stage_name,
    d.from_users,
    d.to_users,
    d.drop_off,
    d.drop_off_percentage
FROM UserActivityDepth u
CROSS JOIN DropOffs d
ORDER BY u.depth_rank, u.user_id, d.from_stage;

-- --project12:
-- 12. Warehouse Inventory Snapshot System
-- Goal: Report daily stock changes
-- Requirements:
CREATE TABLE InventorySnapshots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT,
    snapshot_date DATE,
    stock_qty INT
);

-- Sample data: item_id, snapshot_date, stock_qty
INSERT INTO InventorySnapshots (item_id, snapshot_date, stock_qty) VALUES
(1, '2025-07-01', 100),
(1, '2025-07-02', 90),
(1, '2025-07-03', 60),
(1, '2025-07-04', 65),
(2, '2025-07-01', 200),
(2, '2025-07-02', 180),
(2, '2025-07-03', 150),
(2, '2025-07-04', 140),
(3, '2025-07-01', 300),
(3, '2025-07-02', 310),
(3, '2025-07-03', 305),
(3, '2025-07-04', 290),
(4, '2025-07-01', 400),
(4, '2025-07-02', 390),
(4, '2025-07-03', 200),
(4, '2025-07-04', 195),
(5, '2025-07-01', 500),
(5, '2025-07-02', 505),
(5, '2025-07-03', 495),
(5, '2025-07-04', 480);

-- Use LAG() to calculate stock changes day-to-day
WITH StockChanges AS (
    SELECT
        item_id,
        snapshot_date,
        stock_qty,
        LAG(stock_qty) OVER (PARTITION BY item_id ORDER BY snapshot_date) AS previous_stock,
        stock_qty - LAG(stock_qty) OVER (PARTITION BY item_id ORDER BY snapshot_date) AS daily_change
    FROM InventorySnapshots
),
HighMovementItems AS (
    SELECT
        item_id,
        SUM(ABS(daily_change)) AS total_movement
    FROM StockChanges
    WHERE daily_change IS NOT NULL
    GROUP BY item_id
    ORDER BY total_movement DESC
    LIMIT 10
),
FinalReport AS (
    SELECT
        sc.item_id,
        sc.snapshot_date,
        sc.stock_qty,
        sc.daily_change,
        AVG(sc.stock_qty) OVER (PARTITION BY sc.item_id ORDER BY sc.snapshot_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_stock_last_7_days,
        CASE
            WHEN sc.daily_change < -50 THEN 'Sharp Drop'
            ELSE 'Normal'
        END AS movement_flag
    FROM StockChanges sc
    JOIN HighMovementItems hmi ON sc.item_id = hmi.item_id
)
SELECT *
FROM FinalReport
ORDER BY item_id, snapshot_date;

-- Identify items with sharp drops using conditional logic
-- Use CTEs for top 10 high-movement items
-- Include daily average stock via AVG() window

-- project13:
-- 13. Student Class Hierarchy Tracker
-- Goal: Track class levels and mentors in hierarchy
-- Requirements:
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    mentor_id INT NULL,
    FOREIGN KEY (mentor_id) REFERENCES Students(student_id)
);

-- Sample data: (student_id, name, mentor_id)
INSERT INTO Students (student_id, name, mentor_id) VALUES
(1, 'Alice', NULL),        -- Senior mentor, no mentor above
(2, 'Bob', 1),             -- Mentored by Alice
(3, 'Charlie', 1),
(4, 'David', 2),
(5, 'Eva', 2),
(6, 'Frank', 3),
(7, 'Grace', 4);

-- Self-referencing Mentors table (Senior → Junior)
-- Use recursive CTE to build student–mentor hierarchy
WITH RECURSIVE MentorHierarchy AS (
    -- Anchor member: top-level mentors with no mentor_id
    SELECT
        student_id,
        name,
        mentor_id,
        0 AS depth,
        CAST(name AS CHAR(1000)) AS mentor_path
    FROM Students
    WHERE mentor_id IS NULL

    UNION ALL

    -- Recursive member: join mentees to their mentors
    SELECT
        s.student_id,
        s.name,
        s.mentor_id,
        mh.depth + 1 AS depth,
        CONCAT(mh.mentor_path, ' > ', s.name) AS mentor_path
    FROM Students s
    INNER JOIN MentorHierarchy mh ON s.mentor_id = mh.student_id
)
SELECT
    student_id,
    name,
    mentor_id,
    depth,
    mentor_path
FROM MentorHierarchy
ORDER BY mentor_path;

-- Add depth level and mentor paths
-- Highlight mentor teams using views
CREATE OR REPLACE VIEW MentorTeamsView AS
WITH RECURSIVE MentorHierarchy AS (
    SELECT
        student_id,
        name,
        mentor_id,
        0 AS depth,
        CAST(name AS CHAR(1000)) AS mentor_path
    FROM Students
    WHERE mentor_id IS NULL

    UNION ALL

    SELECT
        s.student_id,
        s.name,
        s.mentor_id,
        mh.depth + 1 AS depth,
        CONCAT(mh.mentor_path, ' > ', s.name) AS mentor_path
    FROM Students s
    INNER JOIN MentorHierarchy mh ON s.mentor_id = mh.student_id
)
SELECT
    student_id,
    name,
    mentor_id,
    depth,
    mentor_path
FROM MentorHierarchy;

-- project14:
-- 14. Job Application Status Pipeline
-- Goal: Monitor status transitions for candidates
-- Requirements:
CREATE TABLE ApplicationStatus (
    id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_id INT,
    status_date DATE,
    stage ENUM('Applied', 'HR', 'Tech', 'Offered')
);

-- Sample data (candidate_id, status_date, stage)
INSERT INTO ApplicationStatus (candidate_id, status_date, stage) VALUES
(1, '2025-06-01', 'Applied'),
(1, '2025-06-05', 'HR'),
(1, '2025-06-10', 'Tech'),
(2, '2025-06-02', 'Applied'),
(2, '2025-06-07', 'HR'),
(3, '2025-06-01', 'Applied'),
(3, '2025-06-10', 'HR'),
(3, '2025-06-20', 'Tech'),
(4, '2025-06-01', 'Applied');

-- Store multiple application stages: Applied → HR → Tech → Offered
-- Use LAG() to compare previous stage
-- Use LEAD() to forecast next expected stage
WITH StatusWithLagLead AS (
    SELECT
        candidate_id,
        status_date,
        stage,
        LAG(stage) OVER (PARTITION BY candidate_id ORDER BY status_date) AS previous_stage,
        LEAD(stage) OVER (PARTITION BY candidate_id ORDER BY status_date) AS next_stage
    FROM ApplicationStatus
)
SELECT *
FROM StatusWithLagLead
ORDER BY candidate_id, status_date;

-- Use CTEs to filter stalled applications
WITH StatusWithLagLead AS (
    SELECT
        candidate_id,
        status_date,
        stage,
        LAG(status_date) OVER (PARTITION BY candidate_id ORDER BY status_date) AS previous_date,
        LAG(stage) OVER (PARTITION BY candidate_id ORDER BY status_date) AS previous_stage
    FROM ApplicationStatus
),
StalledApplications AS (
    SELECT
        candidate_id,
        stage,
        status_date,
        previous_date,
        DATEDIFF(status_date, previous_date) AS days_since_last_stage
    FROM StatusWithLagLead
    WHERE previous_date IS NOT NULL
)
SELECT *
FROM StalledApplications
WHERE days_since_last_stage > 10
ORDER BY candidate_id, status_date;

-- project15:
-- 15. IT Support Ticket Resolution Report
-- Goal: Track support SLA compliance
-- Requirements:
CREATE TABLE SupportTickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    support_staff_id INT,
    status VARCHAR(20),  -- 'Open', 'Resolved', etc.
    created_date DATETIME,
    resolved_date DATETIME
);

-- Sample data
INSERT INTO SupportTickets (user_id, support_staff_id, status, created_date, resolved_date) VALUES
(101, 201, 'Resolved', '2025-07-01 08:00:00', '2025-07-01 10:30:00'),
(101, 201, 'Resolved', '2025-07-02 09:00:00', '2025-07-02 15:00:00'),
(102, 202, 'Resolved', '2025-07-01 07:00:00', '2025-07-03 07:00:00'),
(103, 201, 'Resolved', '2025-07-01 11:00:00', '2025-07-01 12:00:00'),
(101, 203, 'Open', '2025-07-04 08:00:00', NULL);

-- Use DATEDIFF() with LEAD() to get resolution times
WITH TicketOrder AS (
    SELECT
        ticket_id,
        user_id,
        support_staff_id,
        status,
        created_date,
        resolved_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_date) AS ticket_seq,
        LEAD(resolved_date) OVER (PARTITION BY user_id ORDER BY created_date) AS next_resolved_date
    FROM SupportTickets
    WHERE status = 'Resolved'
),
ResolutionTimes AS (
    SELECT
        ticket_id,
        user_id,
        support_staff_id,
        created_date,
        resolved_date,
        ticket_seq,                      -- include this!
        TIMESTAMPDIFF(MINUTE, created_date, resolved_date) AS resolution_minutes
    FROM TicketOrder
)
SELECT *
FROM ResolutionTimes
ORDER BY user_id, ticket_seq;
-- Use ROW_NUMBER() to order tickets by user
-- Create a CTE for overdue tickets
WITH TicketOrder AS (
    SELECT
        ticket_id,
        user_id,
        support_staff_id,
        status,
        created_date,
        resolved_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_date) AS ticket_seq
    FROM SupportTickets
    WHERE status = 'Resolved'
),
ResolutionTimes AS (
    SELECT
        ticket_id,
        user_id,
        support_staff_id,
        created_date,
        resolved_date,
        TIMESTAMPDIFF(MINUTE, created_date, resolved_date) AS resolution_minutes
    FROM TicketOrder
),
OverdueTickets AS (
    SELECT *
    FROM ResolutionTimes
    WHERE resolution_minutes > 240
)
SELECT *
FROM OverdueTickets
ORDER BY resolution_minutes DESC;

-- Calculate average resolution time per support staff
WITH ResolutionTimes AS (
    SELECT
        support_staff_id,
        TIMESTAMPDIFF(MINUTE, created_date, resolved_date) AS resolution_minutes
    FROM SupportTickets
    WHERE status = 'Resolved'
)
SELECT
    support_staff_id,
    ROUND(AVG(resolution_minutes), 2) AS avg_resolution_minutes,
    COUNT(*) AS tickets_resolved
FROM ResolutionTimes
GROUP BY support_staff_id
ORDER BY avg_resolution_minutes;

-- project16:
-- 16. Banking Transaction Audit
-- Goal: Compare customer balances over time
-- Requirements:
CREATE TABLE Transactions1 (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT,
    transaction_date DATE,
    balance DECIMAL(15, 2)  -- balance after transaction
);

-- Sample data (account_id, transaction_date, balance)
INSERT INTO Transactions1 (account_id, transaction_date, balance) VALUES
(1001, '2025-06-01', 5000.00),
(1001, '2025-06-10', 4800.00),
(1001, '2025-06-20', 4700.00),
(1001, '2025-07-01', 4000.00),  -- Big dip here
(1002, '2025-06-05', 10000.00),
(1002, '2025-06-15', 9800.00),
(1002, '2025-07-01', 9700.00),
(1003, '2025-06-01', 7000.00),
(1003, '2025-06-20', 7200.00);

-- Use LAG() to get previous balance
WITH BalanceHistory AS (
    SELECT
        account_id,
        transaction_date,
        balance,
        LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date) AS previous_balance,
        -- Calculate percent change from previous balance
        CASE 
            WHEN LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date) IS NULL THEN NULL
            ELSE ROUND(((balance - LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date)) / LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date)) * 100, 2)
        END AS percent_change
    FROM Transactions1
)
SELECT *
FROM BalanceHistory
ORDER BY account_id, transaction_date;

-- Use CTE to find accounts with abnormal dips
WITH BalanceHistory AS (
    SELECT
        account_id,
        transaction_date,
        balance,
        LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date) AS previous_balance,
        CASE 
            WHEN LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date) IS NULL THEN NULL
            ELSE ROUND(((balance - LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date)) / LAG(balance) OVER (PARTITION BY account_id ORDER BY transaction_date)) * 100, 2)
        END AS percent_change
    FROM Transactions1
),
AbnormalDips AS (
    SELECT *
    FROM BalanceHistory
    WHERE percent_change < -10
)
SELECT
    account_id,
    transaction_date,
    balance,
    previous_balance,
    percent_change
FROM AbnormalDips
ORDER BY account_id, transaction_date;

-- Calculate percent change using window math
-- Audit-ready summary for compliance team

-- project17:
-- 17. Call Center Agent Performance Report
-- Goal: Track agent efficiency and activity
-- Requirements:
CREATE TABLE Calls (
    call_id INT PRIMARY KEY AUTO_INCREMENT,
    agent_id INT,
    call_time DATETIME,
    shift VARCHAR(10),      -- e.g., 'Morning', 'Evening'
    location VARCHAR(50)
);

CREATE TABLE Agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100)
);

-- Sample agents
INSERT INTO Agents (agent_id, agent_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Sample calls
INSERT INTO Calls (agent_id, call_time, shift, location) VALUES
(1, '2025-07-10 08:05:00', 'Morning', 'NY'),
(1, '2025-07-10 08:20:00', 'Morning', 'NY'),
(2, '2025-07-10 08:15:00', 'Morning', 'NY'),
(2, '2025-07-10 08:40:00', 'Morning', 'NY'),
(3, '2025-07-10 20:00:00', 'Evening', 'CA'),
(3, '2025-07-10 20:30:00', 'Evening', 'CA'),
(4, '2025-07-10 20:05:00', 'Evening', 'CA'),
(4, '2025-07-10 21:00:00', 'Evening', 'CA'),
(4, '2025-07-10 21:30:00', 'Evening', 'CA');

-- Rank agents by number of calls handled (using RANK())
WITH AgentCallCounts AS (
    SELECT
        agent_id,
        shift,
        location,
        COUNT(*) AS calls_handled
    FROM Calls
    GROUP BY agent_id, shift, location
),
RankedAgents AS (
    SELECT
        agent_id,
        shift,
        location,
        calls_handled,
        RANK() OVER (PARTITION BY shift, location ORDER BY calls_handled DESC) AS call_rank
    FROM AgentCallCounts
)
SELECT
    ra.agent_id,
    a.agent_name,
    ra.shift,
    ra.location,
    ra.calls_handled,
    ra.call_rank
FROM RankedAgents ra
JOIN Agents a ON ra.agent_id = a.agent_id
ORDER BY ra.shift, ra.location, ra.call_rank;

-- Partition by shift or location
-- Use LAG() to detect call gap durations
WITH CallGaps AS (
    SELECT
        agent_id,
        call_time,
        LAG(call_time) OVER (PARTITION BY agent_id ORDER BY call_time) AS previous_call_time,
        TIMESTAMPDIFF(MINUTE, LAG(call_time) OVER (PARTITION BY agent_id ORDER BY call_time), call_time) AS gap_minutes
    FROM Calls
)
SELECT *
FROM CallGaps
ORDER BY agent_id, call_time;

-- Use CTE to list agents with consistently high volume
WITH AgentCallCounts AS (
    SELECT
        agent_id,
        shift,
        COUNT(*) AS calls_handled
    FROM Calls
    GROUP BY agent_id, shift
),
AgentAvgCalls AS (
    SELECT
        agent_id,
        AVG(calls_handled) AS avg_calls_per_shift
    FROM AgentCallCounts
    GROUP BY agent_id
)
SELECT
    a.agent_id,
    ag.agent_name,
    a.avg_calls_per_shift
FROM AgentAvgCalls a
JOIN Agents ag ON a.agent_id = ag.agent_id
WHERE a.avg_calls_per_shift >= 2
ORDER BY a.avg_calls_per_shift DESC;
-- project18:
-- 18. Hospital Departmental Hierarchy & Load
-- Goal: Show hospital staffing structure and patient load
-- Requirements:
CREATE TABLE Departments1 (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

CREATE TABLE Units (
    unit_id INT PRIMARY KEY,
    unit_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments1(dept_id)
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100),
    unit_id INT,
    FOREIGN KEY (unit_id) REFERENCES Units(unit_id)
);

CREATE TABLE PatientCases (
    case_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT,
    case_date DATE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Sample data
INSERT INTO Departments1 VALUES
(1, 'Cardiology'),
(2, 'Neurology');

INSERT INTO Units VALUES
(10, 'Cardio Unit A', 1),
(11, 'Cardio Unit B', 1),
(20, 'Neuro Unit A', 2);

INSERT INTO Doctors VALUES
(100, 'Dr. Smith', 10),
(101, 'Dr. Jones', 10),
(102, 'Dr. Lee', 11),
(200, 'Dr. Patel', 20);

INSERT INTO PatientCases (doctor_id, case_date) VALUES
(100, '2025-07-01'),
(100, '2025-07-02'),
(101, '2025-07-02'),
(102, '2025-07-01'),
(102, '2025-07-03'),
(200, '2025-07-01'),
(200, '2025-07-02'),
(200, '2025-07-03');

-- Build hierarchy of departments → units → doctors
-- Use recursive CTE to build the structure
WITH RECURSIVE DeptHierarchy AS (
    -- Level 1: Departments
    SELECT
        CAST(dept_id AS CHAR(200)) AS hierarchy_path,
        dept_id AS id,
        CAST(NULL AS SIGNED) AS parent_id,  -- explicit cast to int here
        dept_name AS name,
        1 AS level,
        CAST(NULL AS SIGNED) AS doctor_id,
        CAST(NULL AS SIGNED) AS unit_id
    FROM Departments1

    UNION ALL

    -- Level 2: Units under departments
    SELECT
        CONCAT(dh.hierarchy_path, '-', u.unit_id),
        u.unit_id,
        dh.id,
        u.unit_name,
        dh.level + 1,
        CAST(NULL AS SIGNED),
        u.unit_id
    FROM Units u
    JOIN DeptHierarchy dh ON dh.id = u.dept_id AND dh.level = 1

    UNION ALL

    -- Level 3: Doctors under units
    SELECT
        CONCAT(dh.hierarchy_path, '-', doc.doctor_id),
        doc.doctor_id,
        dh.id,
        doc.doctor_name,
        dh.level + 1,
        doc.doctor_id,
        dh.id
    FROM Doctors doc
    JOIN DeptHierarchy dh ON dh.id = doc.unit_id AND dh.level = 2
),
Workload AS (
    SELECT
        doctor_id,
        COUNT(*) AS patient_cases
    FROM PatientCases
    GROUP BY doctor_id
),
DeptWorkload AS (
    SELECT
        dh.hierarchy_path,
        dh.id,
        dh.parent_id,
        dh.name,
        dh.level,
        dh.doctor_id,
        dh.unit_id,
        COALESCE(w.patient_cases, 0) AS doctor_patient_cases
    FROM DeptHierarchy dh
    LEFT JOIN Workload w ON dh.doctor_id = w.doctor_id
)
SELECT
    id,
    parent_id,
    name,
    level,
    doctor_id,
    unit_id,
    doctor_patient_cases
FROM DeptWorkload
ORDER BY hierarchy_path;

-- Use window function to count patient cases per doctor/unit
-- Create view DepartmentalWorkloadView

-- --project19:
-- 19. Flight Connection Lookup System
-- Goal: Find valid flight paths between airports
-- Requirements:
CREATE TABLE Flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    origin VARCHAR(10),
    destination VARCHAR(10),
    duration_minutes INT
);

INSERT INTO Flights (origin, destination, duration_minutes) VALUES
('JFK', 'LAX', 360),
('JFK', 'ORD', 120),
('ORD', 'LAX', 240),
('ORD', 'DFW', 130),
('DFW', 'LAX', 180),
('LAX', 'SFO', 90),
('SFO', 'SEA', 120),
('SEA', 'JFK', 300),
('DFW', 'MIA', 150),
('MIA', 'JFK', 180);

-- Use recursive CTE to simulate connecting flights
-- Limit depth to max 3 connections
-- Output full path of airports
-- Filter valid trips only (no loops, no circular paths)
WITH RECURSIVE FlightPaths AS (
    -- Base case: start from origin airport
    SELECT
        origin,
        destination,
        CAST(origin AS CHAR(1000)) AS path,
        1 AS hops
    FROM Flights
    WHERE origin = 'JFK'  -- Change this to your starting airport

    UNION ALL

    -- Recursive part: connect next flight from last destination if not visited yet
    SELECT
        fp.origin,
        f.destination,
        CONCAT(fp.path, '->', f.destination),
        fp.hops + 1
    FROM FlightPaths fp
    JOIN Flights f ON fp.destination = f.origin
    WHERE fp.hops < 4
      AND FIND_IN_SET(f.destination, REPLACE(fp.path, '->', ',')) = 0 -- prevent loops
)
SELECT
    origin,
    destination,
    path,
    hops
FROM FlightPaths
ORDER BY hops, path;

-- project20:
-- 20. Project Task Dependency Tracker
-- Goal: Show task order based on dependency tree
-- Requirements:
CREATE TABLE Tasks (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    task_name VARCHAR(255) NOT NULL,
    depends_on_task_id INT NULL,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (depends_on_task_id) REFERENCES Tasks(task_id)
);
INSERT INTO Tasks (task_name, depends_on_task_id, start_date, end_date) VALUES
('Project Kickoff', NULL, '2025-07-01', '2025-07-02'),
('Requirement Analysis', 1, '2025-07-03', '2025-07-10'),
('Design', 2, '2025-07-11', '2025-07-20'),
('Development', 3, '2025-07-21', '2025-08-10'),
('Testing', 4, '2025-08-11', '2025-08-20'),
('Deployment', 5, '2025-08-21', '2025-08-22'),
('Documentation', 3, '2025-07-21', '2025-08-05'),
('User Training', 6, '2025-08-23', '2025-08-30');

-- Tasks table with depends_on_task_id (self-referencing)
WITH RECURSIVE TaskOrder AS (
    -- Base tasks: those without dependencies
    SELECT
        task_id,
        task_name,
        depends_on_task_id,
        start_date,
        end_date,
        1 AS level,
        CAST(LPAD(task_id, 5, '0') AS CHAR(100)) AS ordering_priority
    FROM Tasks
    WHERE depends_on_task_id IS NULL

    UNION ALL

    -- Recursive: tasks depending on previous level tasks
    -- Use recursive CTE to build task execution order
	-- Add levels and ordering priority
	-- Create Gantt chart–ready data output
    SELECT
        t.task_id,
        t.task_name,
        t.depends_on_task_id,
        t.start_date,
        t.end_date,
        torder.level + 1 AS level,
        CONCAT(torder.ordering_priority, '-', LPAD(t.task_id, 5, '0')) AS ordering_priority
    FROM Tasks t
    JOIN TaskOrder torder ON t.depends_on_task_id = torder.task_id
)
SELECT
    task_id,
    task_name,
    depends_on_task_id,
    start_date,
    end_date,
    level,
    ordering_priority
FROM TaskOrder
ORDER BY ordering_priority;



