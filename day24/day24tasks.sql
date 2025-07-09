-- day24
create database day24;
use day24;
-- A. Indexing in SQL (Tasks 1–15)
-- Create a table Employees with emp_id, emp_name, dept_id, salary.
-- Insert 15 employee records into the Employees table.

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10, 2)
);

-- Create an index on emp_name to speed up name-based searches.
CREATE INDEX idx_emp_name ON Employees(emp_name);

-- Run a SELECT query with WHERE emp_name = 'John' and observe performance.
SELECT * FROM Employees WHERE emp_name = 'John';

-- Use EXPLAIN to check if the index is used on emp_name.
EXPLAIN SELECT * FROM Employees WHERE emp_name = 'John';

-- Create a compound index on (dept_id, salary). Test a WHERE query using both.
CREATE INDEX idx_dept_salary ON Employees(dept_id, salary);

EXPLAIN
SELECT * FROM Employees WHERE dept_id = 101 AND salary > 50000;

-- Drop the index on emp_name.
DROP INDEX idx_emp_name ON Employees;

-- Create a new table Departments with dept_id, dept_name.
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100)
);

-- Create a PRIMARY KEY on dept_id (clustered index).
-- Create a non-clustered index on dept_name.
CREATE INDEX idx_dept_name ON Departments(dept_name);

-- Create a JOIN query between Employees and Departments using indexed columns.
SELECT e.emp_name, d.dept_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;

-- Compare performance of JOIN queries with and without indexes using EXPLAIN.
EXPLAIN SELECT e.emp_name, d.dept_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;

-- Write a SELECT query using ORDER BY emp_name — test with and without index.
SELECT * FROM Employees ORDER BY emp_name;

SELECT * FROM Employees WHERE emp_name = 'JOHN';
EXPLAIN SELECT * FROM Employees WHERE emp_name = 'JOHN';

-- Insert 1,000+ dummy records and measure SELECT query performance with/without indexing.
EXPLAIN SELECT * FROM Employees WHERE emp_name = 'paul';

-- Identify columns where indexing should be avoided (e.g., high-update frequency or rarely queried).
-- aNSWER: salary (alone) — unless used frequently in range filters or sorting
-- emp_name — if not often searched (but in your case it is searched)

-- B. Query Optimization (Tasks 16–25)
-- Use EXPLAIN to analyze a full table scan and optimize it with indexing.
EXPLAIN SELECT * FROM Employees WHERE emp_name = 'John';

-- Write a SELECT * query and optimize it by specifying only required columns.
SELECT emp_id, dept_id FROM Employees WHERE emp_name = 'John';

-- Create a table Orders with columns order_id, customer_id, order_date.
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE
);

-- Insert 20+ sample orders and analyze a query using EXPLAIN SELECT * FROM Orders.
INSERT INTO Orders (order_id, customer_id, order_date) VALUES
(1, 101, CURDATE() - INTERVAL 1 DAY),
(2, 102, CURDATE() - INTERVAL 2 DAY),
(3, 103, CURDATE() - INTERVAL 3 DAY),
(4, 104, CURDATE() - INTERVAL 4 DAY),
(5, 105, CURDATE() - INTERVAL 5 DAY),
(6, 106, CURDATE() - INTERVAL 6 DAY),
(7, 107, CURDATE() - INTERVAL 7 DAY),
(8, 108, CURDATE() - INTERVAL 8 DAY),
(9, 109, CURDATE() - INTERVAL 9 DAY),
(10, 110, CURDATE() - INTERVAL 10 DAY),
(11, 101, CURDATE() - INTERVAL 11 DAY),
(12, 102, CURDATE() - INTERVAL 12 DAY),
(13, 103, CURDATE() - INTERVAL 13 DAY),
(14, 104, CURDATE() - INTERVAL 14 DAY),
(15, 105, CURDATE() - INTERVAL 15 DAY),
(16, 106, CURDATE() - INTERVAL 16 DAY),
(17, 107, CURDATE() - INTERVAL 17 DAY),
(18, 108, CURDATE() - INTERVAL 18 DAY),
(19, 109, CURDATE() - INTERVAL 19 DAY),
(20, 110, CURDATE() - INTERVAL 20 DAY);

-- Create an index on order_date and rerun the EXPLAIN analysis.
CREATE INDEX idx_order_date ON Orders(order_date);

EXPLAIN SELECT * FROM Orders WHERE order_date = CURDATE() - INTERVAL 5 DAY;

-- Write a query to retrieve all orders in the last 7 days using WHERE order_date BETWEEN.
SELECT * FROM Orders
WHERE order_date BETWEEN CURDATE() - INTERVAL 7 DAY AND CURDATE();

-- Replace a subquery with a JOIN and compare performance using EXPLAIN.
SELECT emp_id FROM Employees
WHERE dept_id IN (SELECT dept_id FROM Departments WHERE dept_name = 'IT');
-- optimised with join
SELECT e.emp_id
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'IT';

EXPLAIN SELECT emp_id FROM Employees;


-- Write a complex SELECT query using 3–4 columns and optimize it by reducing columns.
SELECT * FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Finance';
-- better one:
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Finance';

-- Create a view using an optimized query with indexed columns.
CREATE VIEW v_employee_finance AS
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Finance';

-- Test query performance difference with/without LIMIT clause.
-- Without LIMIT
EXPLAIN SELECT * FROM v_employee_finance;

-- With LIMIT
EXPLAIN SELECT * FROM v_employee_finance LIMIT 5;
-- C. Using LIMIT to Optimize Retrieval (Tasks 26–30)
-- Write a query to retrieve the first 5 customers from a Customers table using LIMIT.
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100)
);
INSERT INTO Customers (customer_id, customer_name, city) VALUES
(1, 'Alice', 'New York'),
(2, 'Bob', 'Los Angeles'),
(3, 'Charlie', 'Chicago'),
(4, 'David', 'Houston'),
(5, 'Eve', 'Phoenix'),
(6, 'Frank', 'Philadelphia'),
(7, 'Grace', 'San Antonio'),
(8, 'Hank', 'San Diego'),
(9, 'Ivy', 'Dallas'),
(10, 'Jack', 'San Jose'),
(11, 'Karen', 'Austin'),
(12, 'Leo', 'Jacksonville'),
(13, 'Mona', 'Fort Worth'),
(14, 'Nina', 'Columbus'),
(15, 'Oscar', 'Charlotte'),
(16, 'Paul', 'San Francisco'),
(17, 'Quincy', 'Indianapolis'),
(18, 'Rachel', 'Seattle'),
(19, 'Steve', 'Denver'),
(20, 'Tina', 'Washington'),
(21, 'Uma', 'Boston'),
(22, 'Victor', 'El Paso'),
(23, 'Wendy', 'Detroit'),
(24, 'Xander', 'Nashville'),
(25, 'Yara', 'Memphis'),
(26, 'Zane', 'Portland'),
(27, 'Amy', 'Oklahoma City'),
(28, 'Ben', 'Las Vegas'),
(29, 'Cathy', 'Louisville'),
(30, 'Dan', 'Baltimore'),
(31, 'Ella', 'Milwaukee'),
(32, 'Fred', 'Albuquerque'),
(33, 'Gina', 'Tucson'),
(34, 'Harry', 'Fresno'),
(35, 'Isla', 'Sacramento'),
(36, 'Jonas', 'Mesa'),
(37, 'Kara', 'Kansas City'),
(38, 'Liam', 'Atlanta'),
(39, 'Mira', 'Omaha'),
(40, 'Noah', 'Colorado Springs'),
(41, 'Olga', 'Raleigh'),
(42, 'Pete', 'Miami'),
(43, 'Queen', 'Virginia Beach'),
(44, 'Ron', 'Oakland'),
(45, 'Sophia', 'Minneapolis'),
(46, 'Tom', 'Tulsa'),
(47, 'Una', 'Arlington'),
(48, 'Vince', 'New Orleans'),
(49, 'Willa', 'Wichita'),
(50, 'Xena', 'Cleveland'),
(51, 'Yusuf', 'Bakersfield'),
(52, 'Zoey', 'Tampa');

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(100),
    price DECIMAL(10, 2)
);
INSERT INTO Products (product_id, product_name, category, price) VALUES
(1, 'Laptop', 'Electronics', 999.99),
(2, 'Smartphone', 'Electronics', 699.99),
(3, 'Tablet', 'Electronics', 499.99),
(4, 'Monitor', 'Electronics', 199.99),
(5, 'Keyboard', 'Electronics', 49.99),
(6, 'Mouse', 'Electronics', 29.99),
(7, 'Printer', 'Electronics', 159.99),
(8, 'Desk Lamp', 'Home', 39.99),
(9, 'Chair', 'Furniture', 129.99),
(10, 'Sofa', 'Furniture', 899.99),
(11, 'Bed Frame', 'Furniture', 499.99),
(12, 'Mattress', 'Furniture', 799.99),
(13, 'Bookshelf', 'Furniture', 149.99),
(14, 'Coffee Table', 'Furniture', 199.99),
(15, 'Dining Table', 'Furniture', 599.99),
(16, 'Toaster', 'Appliances', 39.99),
(17, 'Microwave', 'Appliances', 89.99),
(18, 'Refrigerator', 'Appliances', 1199.99),
(19, 'Oven', 'Appliances', 999.99),
(20, 'Blender', 'Appliances', 49.99),
(21, 'Mixer', 'Appliances', 79.99),
(22, 'Kettle', 'Appliances', 24.99),
(23, 'Fan', 'Appliances', 44.99),
(24, 'Heater', 'Appliances', 89.99),
(25, 'TV', 'Electronics', 699.99),
(26, 'Camera', 'Electronics', 349.99),
(27, 'Speakers', 'Electronics', 149.99),
(28, 'Headphones', 'Electronics', 89.99),
(29, 'Smartwatch', 'Electronics', 199.99),
(30, 'Router', 'Electronics', 59.99),
(31, 'Modem', 'Electronics', 49.99),
(32, 'Drill', 'Tools', 99.99),
(33, 'Hammer', 'Tools', 19.99),
(34, 'Wrench Set', 'Tools', 39.99),
(35, 'Screwdriver Set', 'Tools', 29.99),
(36, 'Vacuum Cleaner', 'Appliances', 199.99),
(37, 'Iron', 'Appliances', 59.99),
(38, 'Laundry Basket', 'Home', 19.99),
(39, 'Curtains', 'Home', 49.99),
(40, 'Wall Clock', 'Home', 29.99),
(41, 'Mirror', 'Home', 89.99),
(42, 'Vase', 'Home', 24.99),
(43, 'Rug', 'Home', 199.99),
(44, 'Pillow Set', 'Home', 59.99),
(45, 'Blanket', 'Home', 79.99),
(46, 'Wardrobe', 'Furniture', 699.99),
(47, 'Nightstand', 'Furniture', 99.99),
(48, 'Lawn Mower', 'Garden', 399.99),
(49, 'Garden Hose', 'Garden', 34.99),
(50, 'Grill', 'Garden', 249.99),
(51, 'Patio Set', 'Garden', 899.99),
(52, 'Planter', 'Garden', 19.99);

-- Retrieve top 10 products sorted by price DESC using ORDER BY and LIMIT.
SELECT * FROM Customers LIMIT 5;
SELECT * FROM Products ORDER BY price DESC LIMIT 10;

-- Combine WHERE, ORDER BY, and LIMIT in one optimized query.
SELECT product_id, product_name, price
FROM Products
WHERE category = 'Electronics'
ORDER BY price DESC
LIMIT 5;

-- Test performance of SELECT * FROM large_table LIMIT 5 vs full query.
select * from orders;
EXPLAIN SELECT * FROM Orders;
EXPLAIN SELECT * FROM Orders LIMIT 5;

-- Use LIMIT with OFFSET to implement pagination (e.g., records 11–20).
SELECT * FROM Customers
ORDER BY customer_id
LIMIT 10 OFFSET 10;

-- D. Clustered vs. Non-Clustered Index Tasks (Tasks 31–35)
-- Create a table Products with product_id as PRIMARY KEY (clustered).
select * from products;

-- Add a non-clustered index on product_name.
CREATE INDEX idx_product_name ON Products(product_name);

-- Insert 10 sample products and query them using WHERE product_name LIKE '%lap%'.
SELECT * FROM Products
WHERE product_name LIKE '%lap%';
EXPLAIN SELECT * FROM Products
WHERE product_name LIKE '%lap%';


-- Explain the difference in execution between clustered and non-clustered index using EXPLAIN.
-- 🧠 Difference Between Clustered & Non-Clustered Index in MySQL
-- Feature	| Clustered Index (PRIMARY KEY)|	Non-Clustered Index
-- Data storage|	Actual table data stored in the index	|Stores only index key + pointer to row (PK)
-- Ordering|	Physically ordered by primary key	|Logical, not physical
-- Access speed |	Faster when queried by PK|	One extra lookup to find full row
-- Index Name	|PRIMARY	|e.g., idx_product_name

-- Drop the non-clustered index and test impact on query performance.
DROP INDEX idx_product_name ON Products;
EXPLAIN SELECT * FROM Products
WHERE product_name LIKE '%lap%';

-- E. Normalization Tasks (1NF, 2NF, 3NF) (Tasks 36–40)
-- Design an unnormalized table SalesData with repeated columns for multiple products per order.
CREATE TABLE SalesData (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    product1_name VARCHAR(100),
    product1_qty INT,
    product2_name VARCHAR(100),
    product2_qty INT,
    order_date DATE
);

INSERT INTO SalesData VALUES
(1, 'Alice', 'New York', 'Laptop', 1, 'Mouse', 2, '2025-07-01'),
(2, 'Bob', 'Chicago', 'Tablet', 1, NULL, NULL, '2025-07-02'),
(3, 'Alice', 'New York', 'Laptop', 1, 'Keyboard', 1, '2025-07-03');

-- Apply 1NF: Remove repeating groups by creating individual rows for each product.
CREATE TABLE SalesData_1NF (
    order_id INT,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    product_name VARCHAR(100),
    product_qty INT,
    order_date DATE
);

-- Insert one row per product per order
INSERT INTO SalesData_1NF VALUES
(1, 'Alice', 'New York', 'Laptop', 1, '2025-07-01'),
(1, 'Alice', 'New York', 'Mouse', 2, '2025-07-01'),
(2, 'Bob', 'Chicago', 'Tablet', 1, '2025-07-02'),
(3, 'Alice', 'New York', 'Laptop', 1, '2025-07-03'),
(3, 'Alice', 'New York', 'Keyboard', 1, '2025-07-03');

-- Apply 2NF: Remove partial dependency by creating a Products table.
CREATE TABLE Products1 (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) UNIQUE
);

-- Insert distinct products
INSERT INTO Products1 (product_name) VALUES ('Laptop'), ('Mouse'), ('Tablet'), ('Keyboard');

CREATE TABLE SalesData_2NF (
    order_id INT,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    product_id INT,
    product_qty INT,
    order_date DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Insert using product_id references
INSERT INTO SalesData_2NF (order_id, customer_name, customer_city, product_id, product_qty, order_date)
SELECT
    sd.order_id,
    sd.customer_name,
    sd.customer_city,
    p.product_id,
    sd.product_qty,
    sd.order_date
FROM
    SalesData_1NF sd
JOIN
    Products1 p ON sd.product_name = p.product_name;

-- Apply 3NF: Remove transitive dependency by separating customer info into a Customers table.
CREATE TABLE Customers1 (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) UNIQUE,
    customer_city VARCHAR(100)
);

-- Insert distinct customers
INSERT INTO Customers1 (customer_name, customer_city)
SELECT DISTINCT customer_name, customer_city FROM SalesData_2NF;

-- Create Orders, Customers, and OrderItems tables with proper foreign keys and normalize data.
CREATE TABLE Orders1 (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
TRUNCATE TABLE Orders1;
INSERT  INTO Orders1 (order_id, customer_id, order_date)
SELECT DISTINCT
    sd.order_id,
    c.customer_id,
    sd.order_date
FROM
    SalesData_2NF sd
JOIN
    Customers1 c ON sd.customer_name = c.customer_name;

-- F. Denormalization Tasks (Tasks 41–45)
-- Create a denormalized table combining Orders, Customers, and OrderItems.
use day24;
CREATE TABLE Orders_Denormalized (
    order_id INT,
    customer_name VARCHAR(100),
    customer_city VARCHAR(100),
    order_date DATE,
    product_name VARCHAR(100),
    product_qty INT
);

-- Insert sample records with duplicated customer names and product info.
INSERT INTO Orders_Denormalized VALUES
(1, 'Alice', 'New York', '2025-07-01', 'Laptop', 1),
(1, 'Alice', 'New York', '2025-07-01', 'Mouse', 2),
(2, 'Bob', 'Chicago', '2025-07-02', 'Tablet', 1),
(3, 'Alice', 'New York', '2025-07-03', 'Laptop', 1),
(3, 'Alice', 'New York', '2025-07-03', 'Keyboard', 1);

-- Write a query that retrieves full order info without joins (denormalized benefit).
SELECT * FROM Orders_Denormalized WHERE order_id = 1;

-- Compare performance of normalized vs denormalized query for data retrieval.
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    product_qty INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
INSERT INTO OrderItems (order_id, product_id, product_qty) VALUES
(1, 1, 1),  -- Order 1, Product 1 (e.g., Laptop), qty 1
(1, 2, 2),  -- Order 1, Product 2 (e.g., Mouse), qty 2
(2, 3, 1),  -- Order 2, Product 3 (e.g., Tablet), qty 1
(3, 1, 1),  -- Order 3, Product 1 (Laptop), qty 1
(3, 4, 1);  -- Order 3, Product 4 (Keyboard), qty 1

SELECT o.order_id, c.customer_name, c.customer_city, o.order_date, p.product_name, oi.product_qty
FROM Orders1 o
JOIN Customers1 c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products1 p ON oi.product_id = p.product_id
WHERE o.order_id = 1;

SELECT * FROM Orders_Denormalized WHERE order_id = 1;

-- Discuss and document trade-offs: update anomalies vs query performance.
-- Aspect|	Normalized Schema	|Denormalized Schema
-- Update Anomalies	|Avoided (data stored once)|	Prone to anomalies (duplicate data to update)
-- Data Redundancy|	Minimal |	High (data repeated in many rows)
-- Storage|	Efficient|	More storage required
-- Read Performance|	Slower due to joins|	Faster for reads without joins
-- Write Performance|	More efficient updates	|Updates may be slower or complex due to duplication
-- Complex Queries|	More complex due to joins|	Simpler queries

-- 📊 G. Real-world Performance Scenarios (Tasks 46–50)
-- Run a JOIN between Customers and Orders without index — measure execution time.
SHOW INDEX FROM Customers;
-- Enable timing
SET profiling = 1;

SELECT o.order_id, c.customer_name, o.order_date
FROM Orders1 o
JOIN Customers1 c ON o.customer_id = c.customer_id;

SHOW PROFILES;


-- Add indexes on customer_id in both tables and rerun JOIN — measure again.
CREATE INDEX idx_customers_customer_id ON Customers1(customer_id);
CREATE INDEX idx_orders_customer_id ON Orders1(customer_id);
SET profiling = 1;

SELECT o.order_id, c.customer_name, o.order_date
FROM Orders1 o
JOIN Customers1 c ON o.customer_id = c.customer_id;

SHOW PROFILES;

-- Write a query using a subquery in WHERE clause and compare it to an equivalent JOIN.
SELECT order_id, order_date, customer_id
FROM Orders1
WHERE customer_id IN (SELECT customer_id FROM Customers1 WHERE customer_name LIKE 'A%');

SELECT o.order_id, o.order_date, o.customer_id
FROM Orders1 o
JOIN Customers1 c ON o.customer_id = c.customer_id
WHERE c.customer_name LIKE 'A%';

EXPLAIN SELECT order_id, order_date, customer_id
FROM Orders1
WHERE customer_id IN (SELECT customer_id FROM Customers1 WHERE customer_name LIKE 'A%');

EXPLAIN
SELECT o.order_id, o.order_date, o.customer_id
FROM Orders1 o
JOIN Customers1 c ON o.customer_id = c.customer_id
WHERE c.customer_name LIKE 'A%';

-- Analyze performance of a filtered GROUP BY query with and without an index on the grouping column.
-- without index
EXPLAIN
SELECT customer_id, COUNT(*) AS total_orders
FROM Orders1
WHERE order_date >= '2025-01-01'
GROUP BY customer_id;
-- with index
EXPLAIN
SELECT customer_id, COUNT(*) AS total_orders
FROM Orders1
WHERE order_date >= '2025-01-01'
GROUP BY customer_id;

-- Combine multiple techniques (LIMIT, SELECT columns, WHERE filter, indexed JOIN) into a highly optimized report query.
SELECT o.order_id, c.customer_name, o.order_date, COUNT(oi.product_id) AS product_count
FROM Orders1 o
JOIN Customers1 c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
WHERE o.order_date BETWEEN '2025-01-01' AND '2025-06-30'
GROUP BY o.order_id, c.customer_name, o.order_date
ORDER BY o.order_date DESC
LIMIT 1;

SELECT COUNT(*) FROM Orders1 WHERE order_date BETWEEN '2025-01-01' AND '2025-06-30';







