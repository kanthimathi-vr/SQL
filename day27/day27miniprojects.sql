-- day27 mini projects
-- project1:
-- 1. Retail Sales Data Warehouse
-- Goal: Build a data warehouse to analyze product sales trends.
-- Features:
create database day27mp;
use day27mp;
CREATE TABLE Dim_Product (
    Product_ID SERIAL PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Brand VARCHAR(50),
    Price DECIMAL(10,2)
);
CREATE TABLE Dim_Customer (
    Customer_ID SERIAL PRIMARY KEY,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Gender CHAR(1),
    Age_Group VARCHAR(20),
    Email VARCHAR(100)
);
CREATE TABLE Dim_Time (
    Time_ID SERIAL PRIMARY KEY,
    Date DATE,
    Month INT,
    Quarter INT,
    Year INT
);
CREATE TABLE Dim_Location (
    Location_ID SERIAL PRIMARY KEY,
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50)
);
CREATE TABLE Fact_Sales (
    Sales_ID SERIAL PRIMARY KEY,
    Product_ID INT REFERENCES Dim_Product(Product_ID),
    Customer_ID INT REFERENCES Dim_Customer(Customer_ID),
    Time_ID INT REFERENCES Dim_Time(Time_ID),
    Location_ID INT REFERENCES Dim_Location(Location_ID),
    Quantity_Sold INT,
    Unit_Price DECIMAL(10,2),
    Total_Amount DECIMAL(12,2)
);

-- Create Fact_Sales, Dim_Product, Dim_Customer, Dim_Time, Dim_Location
-- Load data via ETL: Extract from orders, clean names, load into Fact_Sales
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date DATE,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    quantity INT,
    customer_first_name VARCHAR(50),
    customer_last_name VARCHAR(50),
    gender CHAR(1),
    age INT,
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);
INSERT INTO orders (
    order_date, product_name, category, brand, unit_price, quantity,
    customer_first_name, customer_last_name, gender, age, email,
    city, state, country
) VALUES
-- Order 1
('2025-07-01', 'Laptop X200', 'Electronics', 'TechBrand', 899.99, 2,
 'Alice', 'Johnson', 'F', 28, 'alice.j@example.com',
 'New York', 'NY', 'USA'),

-- Order 2
('2025-07-01', 'Smartphone S10', 'Electronics', 'PhoneCorp', 599.99, 1,
 'Bob', 'Smith', 'M', 38, 'bob.smith@example.com',
 'San Francisco', 'CA', 'USA'),

-- Order 3
('2025-07-02', 'Bluetooth Speaker', 'Audio', 'SoundMax', 149.99, 3,
 'Carol', 'Lee', 'F', 24, 'carol.lee@example.com',
 'Toronto', 'ON', 'Canada'),

-- Order 4
('2025-07-03', 'Laptop X200', 'Electronics', 'TechBrand', 899.99, 1,
 'David', 'Brown', 'M', 45, 'david.b@example.com',
 'Chicago', 'IL', 'USA'),

-- Order 5
('2025-07-03', 'Smartphone S10', 'Electronics', 'PhoneCorp', 599.99, 2,
 'Eva', 'Green', 'F', 33, 'eva.green@example.com',
 'Los Angeles', 'CA', 'USA');

-- Generate reports: top-selling products, monthly revenue, customer segments
SELECT 
    dp.Product_Name,
    SUM(fs.Quantity_Sold) AS Total_Units_Sold
FROM Fact_Sales fs
JOIN Dim_Product dp ON fs.Product_ID = dp.Product_ID
GROUP BY dp.Product_Name
ORDER BY Total_Units_Sold DESC
LIMIT 10;
SELECT 
    dt.Year,
    dt.Month,
    SUM(fs.Total_Amount) AS Monthly_Revenue
FROM Fact_Sales fs
JOIN Dim_Time dt ON fs.Time_ID = dt.Time_ID
GROUP BY dt.Year, dt.Month
ORDER BY dt.Year, dt.Month;
SELECT 
    dc.Age_Group,
    COUNT(DISTINCT fs.Customer_ID) AS Customer_Count,
    SUM(fs.Total_Amount) AS Total_Revenue
FROM Fact_Sales fs
JOIN Dim_Customer dc ON fs.Customer_ID = dc.Customer_ID
GROUP BY dc.Age_Group
ORDER BY Total_Revenue DESC;
-- 2. Online Orders Dashboard (OLTP vs OLAP)
-- Goal: Compare OLTP and OLAP behavior for the same business.
-- | Feature        | OLTP                              | OLAP                                                     |
-- | -------------- | --------------------------------- | -------------------------------------------------------- |
-- | Use Case       | Real-time transaction processing  | Analytical reporting and summarization                   |
-- | Tables         | `orders`, `customers`, `products` | `fact_orders`, `dim_time`, `dim_customer`, `dim_product` |
-- | Operation Type | Frequent INSERT/UPDATE/DELETE     | Batch inserts and aggregations                           |
-- | Query Type     | Detailed row-level reads          | Aggregate, group by, trends                              |

create database day27mp2;
use day27mp2;

-- Features:
-- OLTP: orders, customers, products tables with frequent updates
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    gender CHAR(1),
    age INT
);
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    price DECIMAL(10,2)
);
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    order_date DATE
);
INSERT INTO customers (first_name, last_name, email, gender, age) VALUES
('Alice', 'Smith', 'alice@example.com', 'F', 29),
('Bob', 'Jones', 'bob@example.com', 'M', 35),
('Charlie', 'Brown', 'charlie@example.com', 'M', 42);
INSERT INTO products (product_name, category, brand, price) VALUES
('Laptop X200', 'Electronics', 'TechBrand', 900.00),
('Smartphone S10', 'Electronics', 'PhoneCorp', 600.00),
('Headphones Z', 'Audio', 'SoundMax', 120.00);
INSERT INTO orders (customer_id, product_id, quantity, order_date) VALUES
(1, 1, 1, '2025-07-01'),
(2, 2, 2, '2025-07-02'),
(3, 3, 1, '2025-07-03'),
(1, 2, 1, '2025-07-03'),
(2, 3, 3, '2025-07-05');

-- OLAP: summarize orders monthly for analytics
CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    gender CHAR(1),
    age_group VARCHAR(20)
);
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50)
);
CREATE TABLE dim_time (
    date DATE PRIMARY KEY,
    month INT,
    quarter INT,
    year INT
);
CREATE TABLE fact_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    revenue DECIMAL(10,2)
);
INSERT INTO dim_customer (customer_id, full_name, gender, age_group)
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    gender,
    CASE
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        ELSE '45+'
    END AS age_group
FROM customers;
INSERT INTO dim_product (product_id, product_name, category, brand)
SELECT product_id, product_name, category, brand
FROM products;
INSERT INTO dim_time (date, month, quarter, year)
SELECT DISTINCT
    order_date,
    EXTRACT(MONTH FROM order_date),
    EXTRACT(QUARTER FROM order_date),
    EXTRACT(YEAR FROM order_date)
FROM orders;
INSERT INTO fact_orders (order_id, customer_id, product_id, order_date, quantity, revenue)
SELECT 
    o.order_id,
    o.customer_id,
    o.product_id,
    o.order_date,
    o.quantity,
    o.quantity * p.price AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id;

-- Create SQL queries for transactional vs analytical reporting
--  OLTP Query 1 – Get Recent Orders
SELECT 
    o.order_id, 
    c.first_name || ' ' || c.last_name AS customer,
    p.product_name,
    o.quantity,
    o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
ORDER BY o.order_date DESC;
--  OLAP Query 1 – Total Monthly Revenue
SELECT 
    t.year,
    t.month,
    SUM(f.revenue) AS monthly_revenue
FROM fact_orders f
JOIN dim_time t ON f.order_date = t.date
GROUP BY t.year, t.month
ORDER BY t.year, t.month;
--  OLAP Query 2 – Revenue by Product Category
SELECT 
    dp.category,
    SUM(f.revenue) AS total_revenue
FROM fact_orders f
JOIN dim_product dp ON f.product_id = dp.product_id
GROUP BY dp.category
ORDER BY total_revenue DESC;
--  OLAP Query 3 – Customer Segments (Age Group)
SELECT 
    dc.age_group,
    SUM(f.revenue) AS revenue,
    COUNT(DISTINCT f.customer_id) AS customers
FROM fact_orders f
JOIN dim_customer dc ON f.customer_id = dc.customer_id
GROUP BY dc.age_group
ORDER BY revenue DESC;

-- 3. Monthly Sales Summary Report
-- Goal: Build a reporting system for monthly sales tracking.
-- Features:
create database day27mp3;
use day27mp3;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    order_date DATE
);
-- July 2025 (High Revenue Month)
INSERT INTO orders VALUES
(1, 1, 1, 5, 10000.00, '2025-07-01'),  -- ₹50,000
(2, 2, 2, 3, 12000.00, '2025-07-05'),  -- ₹36,000
(3, 3, 3, 4, 5000.00, '2025-07-10');   -- ₹20,000

-- August 2025 (Below Threshold)
INSERT INTO orders VALUES
(4, 1, 1, 1, 10000.00, '2025-08-01'),  -- ₹10,000
(5, 2, 2, 2, 5000.00, '2025-08-08');   -- ₹10,000

-- September 2025 (High Revenue Month)
INSERT INTO orders VALUES
(6, 1, 1, 10, 7000.00, '2025-09-01'),  -- ₹70,000
(7, 3, 3, 5, 3000.00, '2025-09-15');   -- ₹15,000

-- October 2025 (Medium Revenue)
INSERT INTO orders VALUES
(8, 2, 2, 3, 9000.00, '2025-10-01'),   -- ₹27,000
(9, 1, 1, 2, 5000.00, '2025-10-20');   -- ₹10,000

-- Group orders by MONTH(order_date) and YEAR(order_date)
-- Count total orders and total revenue
-- Filter months with revenue > ₹50,000
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(quantity * unit_price) AS total_revenue
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
HAVING total_revenue > 50000
ORDER BY order_year, order_month;

-- 4. Customer Segmentation for Marketing
-- Goal: Categorize customers based on purchase behavior.
-- Features:
create database day27mp4;
use day27mp4;
CREATE TABLE customer_segments (
    customer_id INT PRIMARY KEY,
    total_purchase DECIMAL(12,2),
    segment VARCHAR(10)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    order_date DATE
);
-- July 2025 (High Revenue Month)
INSERT INTO orders VALUES
(1, 1, 1, 5, 10000.00, '2025-07-01'),  -- ₹50,000
(2, 2, 2, 3, 12000.00, '2025-07-05'),  -- ₹36,000
(3, 3, 3, 4, 5000.00, '2025-07-10');   -- ₹20,000

-- August 2025 (Below Threshold)
INSERT INTO orders VALUES
(4, 1, 1, 1, 10000.00, '2025-08-01'),  -- ₹10,000
(5, 2, 2, 2, 5000.00, '2025-08-08');   -- ₹10,000

-- September 2025 (High Revenue Month)
INSERT INTO orders VALUES
(6, 1, 1, 10, 7000.00, '2025-09-01'),  -- ₹70,000
(7, 3, 3, 5, 3000.00, '2025-09-15');   -- ₹15,000

-- October 2025 (Medium Revenue)
INSERT INTO orders VALUES
(8, 2, 2, 3, 9000.00, '2025-10-01'),   -- ₹27,000
(9, 1, 1, 2, 5000.00, '2025-10-20');   -- ₹10,000

INSERT INTO customer_segments (customer_id, total_purchase, segment)
SELECT
    customer_id,
    SUM(quantity * unit_price) AS total_purchase,
    CASE
        WHEN SUM(quantity * unit_price) > 30000 THEN 'Gold'
        WHEN SUM(quantity * unit_price) BETWEEN 15000 AND 30000 THEN 'Silver'
        ELSE 'Bronze'
    END AS segment
FROM orders
GROUP BY customer_id;
select * from  customer_segments;
-- ETL to calculate total purchase value per customer
-- Segment: Gold (>₹30k), Silver (₹15k–₹30k), Bronze (<₹15k)
-- Store in customer_segments table
-- project5:
-- Product Category Performance (Star vs Snowflake)
-- Goal: Compare query performance between star and snowflake schemas.
-- Features:
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE fact_sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    sale_date DATE,
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);
INSERT INTO dim_product VALUES
(1, 'Laptop X200', 'Electronics'),
(2, 'Smartphone S10', 'Electronics'),
(3, 'Headphones Z', 'Audio');

INSERT INTO fact_sales VALUES
(1, 1, 2, 900.00, '2025-07-01'),
(2, 2, 1, 600.00, '2025-07-02'),
(3, 3, 5, 100.00, '2025-07-03');

CREATE TABLE dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

CREATE TABLE dim_product1 (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id)
);

CREATE TABLE fact_sales1 (
    sale_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    sale_date DATE,
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);
INSERT INTO dim_category VALUES
(1, 'Electronics'),
(2, 'Audio');

INSERT INTO dim_product1 VALUES
(1, 'Laptop X200', 1),
(2, 'Smartphone S10', 1),
(3, 'Headphones Z', 2);

INSERT INTO fact_sales1 VALUES
(1, 1, 2, 900.00, '2025-07-01'),
(2, 2, 1, 600.00, '2025-07-02'),
(3, 3, 5, 100.00, '2025-07-03');

-- Build both schemas from sales, product, and category
-- Run same query on both and compare efficiency
-- Star Schema Query
SELECT
    category,
    SUM(quantity * unit_price) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY category
ORDER BY total_revenue DESC;
-- Snowflake Schema Query
SELECT
    c.category_name,
    SUM(f.quantity * f.unit_price) AS total_revenue
FROM fact_sales1 f
JOIN dim_product1 p ON f.product_id = p.product_id
JOIN dim_category c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- Visualize execution plan with EXPLAIN
EXPLAIN
SELECT
    category,
    SUM(quantity * unit_price) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY category
ORDER BY total_revenue DESC;

EXPLAIN
SELECT
    c.category_name,
    SUM(f.quantity * f.unit_price) AS total_revenue
FROM fact_sales1 f
JOIN dim_product1 p ON f.product_id = p.product_id
JOIN dim_category c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- | Step              | Star Schema                             | Snowflake Schema                  |
-- | ----------------- | --------------------------------------- | --------------------------------- |
-- | Schema Complexity | Simpler, fewer tables                   | More normalized, more joins       |
-- | Query Simplicity  | Simpler queries                         | Queries require extra joins       |
-- | Performance       | Typically faster for read-heavy queries | Can be slower due to joins        |
-- | Data Redundancy   | Some redundancy (category repeated)     | Minimal redundancy                |
-- | Maintenance       | Easier                                  | More complex due to normalization |

-- 6. Regional Revenue Tracker
-- Goal: Analyze revenue per customer region.
-- Features:
create database regionrevenue;
use regionrevenue;
CREATE TABLE dim_location (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50)
);

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    region_id INT,
    FOREIGN KEY (region_id) REFERENCES dim_location(region_id)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);
-- Regions
INSERT INTO dim_location VALUES
(1, 'North'),
(2, 'South'),
(3, 'East'),
(4, 'West');

-- Customers
INSERT INTO dim_customer VALUES
(1, 'Alice Smith', 1),
(2, 'Bob Johnson', 2),
(3, 'Carol White', 3),
(4, 'David Black', 4);

-- Products
INSERT INTO dim_product VALUES
(1, 'Laptop X200', 'Electronics'),
(2, 'Smartphone S10', 'Electronics'),
(3, 'Coffee Maker', 'Home Appliances');

-- Orders
INSERT INTO orders VALUES
(1, 1, 1, 2, 900.00, '2025-07-01'),   -- North, Electronics
(2, 2, 2, 1, 600.00, '2025-07-02'),   -- South, Electronics
(3, 3, 3, 5, 150.00, '2025-07-03'),   -- East, Home Appliances
(4, 4, 3, 1, 150.00, '2025-07-04');   -- West, Home Appliances

-- Link orders with Dim_Location via customer
-- Aggregate revenue by region and product category
-- Use HAVING clause to filter low-performing regions
SELECT
    loc.region_name,
    prod.category,
    SUM(ord.quantity * ord.unit_price) AS total_revenue
FROM orders ord
JOIN dim_customer cust ON ord.customer_id = cust.customer_id
JOIN dim_location loc ON cust.region_id = loc.region_id
JOIN dim_product prod ON ord.product_id = prod.product_id
GROUP BY loc.region_name, prod.category
HAVING total_revenue >= 200
ORDER BY total_revenue DESC;

-- 7. Time-Based Revenue Analysis
-- Goal: Analyze trends by day, week, month, quarter, and year.
-- Features:
create database timereven;
use timereven;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    order_date DATE
);
INSERT INTO orders (order_id, customer_id, product_id, quantity, unit_price, order_date) VALUES
(1, 1, 1, 2, 900.00, '2025-01-05'),   -- Q1, Week 1, Day 5
(2, 2, 2, 1, 600.00, '2025-01-15'),   -- Q1, Week 3, Day 15
(3, 3, 3, 5, 150.00, '2025-02-20'),   -- Q1, Week 8, Day 20
(4, 1, 1, 1, 900.00, '2025-03-30'),   -- Q1, Week 13, Day 30
(5, 2, 2, 3, 600.00, '2025-04-10'),   -- Q2, Week 15, Day 10
(6, 3, 3, 2, 150.00, '2025-05-05'),   -- Q2, Week 18, Day 5
(7, 1, 1, 4, 900.00, '2025-06-25'),   -- Q2, Week 26, Day 25
(8, 2, 2, 1, 600.00, '2025-07-01'),   -- Q3, Week 27, Day 1
(9, 3, 3, 3, 150.00, '2025-08-15'),   -- Q3, Week 33, Day 15
(10, 1, 1, 2, 900.00, '2025-09-10'),  -- Q3, Week 37, Day 10
(11, 2, 2, 5, 600.00, '2025-10-20'),  -- Q4, Week 43, Day 20
(12, 3, 3, 1, 150.00, '2025-11-11'),  -- Q4, Week 46, Day 11
(13, 1, 1, 3, 900.00, '2025-12-05');  -- Q4, Week 49, Day 5

-- Use EXTRACT() on order_date
-- Compare revenue quarterly
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    EXTRACT(MONTH FROM order_date) AS month,
    EXTRACT(WEEK FROM order_date) AS week,
    EXTRACT(DAY FROM order_date) AS day,
    SUM(quantity * unit_price) AS total_revenue
FROM orders
GROUP BY year, quarter, month, week, day
ORDER BY year, quarter, month, week, day;
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    SUM(quantity * unit_price) AS total_revenue
FROM orders
GROUP BY year, quarter
ORDER BY year, quarter;

-- Determine best and worst performing periods
-- best
-- Best performing quarter
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    SUM(quantity * unit_price) AS total_revenue
FROM orders
GROUP BY year, quarter
ORDER BY total_revenue DESC
LIMIT 1;
-- worst performance
-- Worst performing quarter
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    SUM(quantity * unit_price) AS total_revenue
FROM orders
GROUP BY year, quarter
ORDER BY total_revenue ASC
LIMIT 1;

-- 8. Sales Funnel Analysis
-- Goal: Build a BI model to simulate a marketing sales funnel.
-- Features:
create database salesfunnel;
use salesfunnel;
CREATE TABLE leads (
    lead_id INT PRIMARY KEY,
    customer_email VARCHAR(100),
    lead_date DATE
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_email VARCHAR(100),
    signup_date DATE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
-- Leads
INSERT INTO leads VALUES
(1, 'alice@example.com', '2025-01-01'),
(2, 'bob@example.com', '2025-01-05'),
(3, 'carol@example.com', '2025-01-10'),
(4, 'david@example.com', '2025-01-15');

-- Customers (converted leads)
INSERT INTO customers VALUES
(1, 'alice@example.com', '2025-01-03'),
(2, 'bob@example.com', '2025-01-07');

-- Orders
INSERT INTO orders VALUES
(1, 1, '2025-01-05', 500.00),
(2, 1, '2025-02-01', 200.00),
(3, 2, '2025-01-10', 300.00);

-- Track leads, converted customers, repeat customers
-- Use aggregation and CTEs for funnel stages
-- Analyze conversion rates
WITH
-- Total Leads
total_leads AS (
    SELECT COUNT(DISTINCT customer_email) AS leads_count FROM leads
),

-- Converted Customers (leads who became customers)
converted_customers AS (
    SELECT COUNT(DISTINCT c.customer_id) AS converted_count
    FROM customers c
    JOIN leads l ON c.customer_email = l.customer_email
),

-- Repeat Customers (customers with more than 1 order)
repeat_customers AS (
    SELECT COUNT(DISTINCT o.customer_id) AS repeat_count
    FROM orders o
    GROUP BY o.customer_id
    HAVING COUNT(o.order_id) > 1
)

SELECT
    tl.leads_count,
    cc.converted_count,
    rc.repeat_count,
    ROUND(cc.converted_count * 100.0 / tl.leads_count, 2) AS conversion_rate_pct,
    ROUND(rc.repeat_count * 100.0 / cc.converted_count, 2) AS repeat_conversion_rate_pct
FROM total_leads tl
CROSS JOIN converted_customers cc
CROSS JOIN repeat_customers rc;

-- 9. Product Stock Analysis
-- Goal: Monitor inventory and stockouts.
-- Features:
create database stock;
use stock;
CREATE TABLE warehouse_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    alert_date DATE,
    alert_message VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    initial_stock INT NOT NULL,
    category VARCHAR(50),
    supplier VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

INSERT INTO dim_product (product_id, product_name, initial_stock) VALUES
(1, 'Laptop X200', 150),
(2, 'Smartphone S10', 200),
(3, 'Coffee Maker', 100),
(4, 'Wireless Headphones', 80),
(5, 'Gaming Keyboard', 120);
INSERT INTO orders (order_id, product_id, quantity, unit_price, order_date) VALUES
(1, 1, 20, 900.00, '2025-07-01'),
(2, 2, 50, 600.00, '2025-07-02'),
(3, 3, 30, 150.00, '2025-07-03'),
(4, 1, 10, 900.00, '2025-07-04'),
(5, 4, 40, 120.00, '2025-07-05'),
(6, 5, 100, 80.00, '2025-07-06'),
(7, 2, 15, 600.00, '2025-07-07'),
(8, 3, 5, 150.00, '2025-07-08'),
(9, 4, 10, 120.00, '2025-07-09'),
(10, 1, 8, 900.00, '2025-07-10');


-- ETL process: calculate stock left after sales
WITH total_sold AS (
    SELECT
        product_id,
        COALESCE(SUM(quantity), 0) AS total_quantity_sold
    FROM orders
    GROUP BY product_id
),
stock_status AS (
    SELECT
        p.product_id,
        p.product_name,
        p.initial_stock,
        COALESCE(ts.total_quantity_sold, 0) AS total_sold,
        p.initial_stock - COALESCE(ts.total_quantity_sold, 0) AS stock_left
    FROM dim_product p
    LEFT JOIN total_sold ts ON p.product_id = ts.product_id
)
SELECT * FROM stock_status;

-- Highlight products with stock < threshold
-- Load stock alerts to warehouse_alerts
INSERT INTO warehouse_alerts (product_id, alert_date, alert_message)
SELECT
    stock_left.product_id,
    CURRENT_DATE,
    CONCAT('Low stock alert: Only ', stock_left.stock_left, ' units left')
FROM (
    SELECT
        p.product_id,
        p.product_name,
        p.initial_stock,
        COALESCE(SUM(o.quantity), 0) AS total_sold,
        p.initial_stock - COALESCE(SUM(o.quantity), 0) AS stock_left
    FROM dim_product p
    LEFT JOIN orders o ON p.product_id = o.product_id
    GROUP BY p.product_id, p.product_name, p.initial_stock
) stock_left
WHERE stock_left.stock_left < 50;
select * from warehouse_alerts;

-- 10. Customer Churn Prediction Report
-- Goal: Identify customers likely to churn.
-- Features:
create database churn;
use churn;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);
INSERT INTO customers (customer_id, customer_name, email) VALUES
(1, 'Alice Smith', 'alice@example.com'),
(2, 'Bob Johnson', 'bob@example.com'),
(3, 'Carol White', 'carol@example.com'),
(4, 'David Black', 'david@example.com'),
(5, 'Eve Green', 'eve@example.com');
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO orders (order_id, customer_id, product_id, quantity, unit_price, order_date) VALUES
(1, 1, 101, 1, 500.00, '2025-07-01'),   -- recent
(2, 2, 102, 2, 250.00, '2025-03-15'),   -- over 90 days ago
(3, 3, 103, 1, 300.00, '2025-02-10'),   -- over 90 days ago
(4, 4, 104, 3, 100.00, '2025-07-10'),   -- recent
(5, 5, 105, 1, 450.00, '2024-12-01');   -- very old

CREATE TABLE churn_candidates (
    customer_id INT PRIMARY KEY,
    last_purchase_date DATE,
    days_inactive INT
);
-- Use CURRENT_DATE or '2025-07-12' for fixed date testing
INSERT INTO churn_candidates (customer_id, last_purchase_date, days_inactive)
SELECT
    customer_id,
    last_purchase_date,
    DATEDIFF(CURRENT_DATE, last_purchase_date) AS days_inactive
FROM (
    SELECT
        customer_id,
        MAX(order_date) AS last_purchase_date
    FROM orders
    GROUP BY customer_id
) AS last_orders
WHERE DATEDIFF(CURRENT_DATE, last_purchase_date) >= 90;
SELECT c.customer_id, cu.customer_name, cu.email, c.last_purchase_date, c.days_inactive
FROM churn_candidates c
JOIN customers cu ON c.customer_id = cu.customer_id
ORDER BY c.days_inactive DESC;

-- Use last purchase date
-- Store in churn_candidates table for marketing reactivation
-- Filter customers inactive for 90+ days
WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_purchase_date
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    last_purchase_date,
    DATEDIFF('2025-07-12', last_purchase_date) AS days_inactive
FROM last_purchase
WHERE DATEDIFF('2025-07-12', last_purchase_date) >= 90;

-- 11. Financial Year Revenue Dashboard
-- Goal: Create a dashboard by Indian financial year (Apr–Mar).
-- Features:
create database revendashboard;
use revendashboard;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);
INSERT INTO customers (customer_id, customer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Carol');

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO orders (order_id, customer_id, order_date, amount) VALUES
-- FY 2024-2025 (Apr 2024 - Mar 2025)
(1, 1, '2024-04-15', 10000.00),
(2, 1, '2024-06-01', 15000.00),
(3, 2, '2024-07-20', 5000.00),
(4, 3, '2024-10-12', 8000.00),
(5, 2, '2025-01-25', 20000.00),
(6, 1, '2025-03-10', 12000.00),

-- FY 2025-2026
(7, 1, '2025-04-05', 11000.00),
(8, 3, '2025-05-15', 9000.00),
(9, 2, '2025-07-01', 13000.00),
(10, 1, '2025-12-31', 17000.00);

-- ETL extracts revenue based on FY split
SELECT
    CASE 
        WHEN MONTH(order_date) >= 4 THEN CONCAT(YEAR(order_date), '-', YEAR(order_date) + 1)
        ELSE CONCAT(YEAR(order_date) - 1, '-', YEAR(order_date))
    END AS financial_year,
    MONTH(order_date) AS month,
    SUM(amount) AS monthly_revenue
FROM orders
GROUP BY financial_year, month
ORDER BY financial_year, month;

-- Group by fiscal year and month
SELECT
    CASE 
        WHEN MONTH(order_date) >= 4 THEN CONCAT(YEAR(order_date), '-', YEAR(order_date) + 1)
        ELSE CONCAT(YEAR(order_date) - 1, '-', YEAR(order_date))
    END AS financial_year,
    SUM(amount) AS total_revenue
FROM orders
GROUP BY financial_year
ORDER BY financial_year;

-- Highlight trends and dips
SELECT
    CASE 
        WHEN MONTH(order_date) >= 4 THEN CONCAT(YEAR(order_date), '-', YEAR(order_date) + 1)
        ELSE CONCAT(YEAR(order_date) - 1, '-', YEAR(order_date))
    END AS financial_year,
    MONTH(order_date) AS month,
    SUM(amount) AS monthly_revenue,
    CASE
        WHEN SUM(amount) < 10000 THEN 'Revenue Dip'
        ELSE 'Stable/High'
    END AS performance_flag
FROM orders
GROUP BY financial_year, month
ORDER BY financial_year, month;

-- 12. Daily ETL Pipeline Simulation
-- Goal: Simulate automated ETL processing daily.
-- Features:
create database pipeline;
use pipeline;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    order_date DATE,
    amount DECIMAL(10, 2)
);
CREATE TABLE dw_orders (
    dw_order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    order_date DATE,
    amount_rounded DECIMAL(10, 0)
);
CREATE TABLE etl_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    job_date DATE,
    status VARCHAR(50),
    records_processed INT,
    message VARCHAR(255)
);
INSERT INTO orders (order_id, customer_id, customer_name, order_date, amount) VALUES
(1, 101, 'alice smith', '2025-07-11', 1249.75),
(2, 102, 'Bob Johnson', '2025-07-11', 999.49),
(3, 103, 'carol white', '2025-07-12', 1850.25),
(4, 104, 'David Black', '2025-07-12', 2100.99);

-- Extract orders, clean data (UPPER names, round totals)
-- Optional: Delete if rerunning ETL
DELETE FROM dw_orders WHERE order_date = '2025-07-12';

-- Transform and Load
INSERT INTO dw_orders (dw_order_id, customer_id, customer_name, order_date, amount_rounded)
SELECT
    order_id,
    customer_id,
    UPPER(customer_name),
    order_date,
    ROUND(amount)
FROM orders
WHERE order_date = '2025-07-12';

-- Load into dw_orders
-- Log ETL job status into etl_logs
INSERT INTO etl_logs (job_date, status, records_processed, message)
SELECT
    CURRENT_DATE,
    'SUCCESS',
    COUNT(*),
    CONCAT('ETL completed for ', CURRENT_DATE)
FROM orders
WHERE order_date = CURRENT_DATE;
SELECT * FROM dw_orders WHERE order_date = '2025-07-12';
SELECT * FROM etl_logs ORDER BY log_id DESC;

-- 13. Category-wise Profit Margin Report
-- Goal: Compare revenue vs cost to calculate profit per category.
-- Features:
create database mp13;
use mp13;
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    cost_price DECIMAL(10, 2)
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    order_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE profit_report (
    category VARCHAR(50),
    total_revenue DECIMAL(12, 2),
    total_cost DECIMAL(12, 2),
    profit DECIMAL(12, 2)
);
INSERT INTO products (product_id, product_name, category, cost_price) VALUES
(1, 'Laptop X200', 'Electronics', 600.00),
(2, 'Smartphone S10', 'Electronics', 350.00),
(3, 'Office Chair', 'Furniture', 120.00),
(4, 'Coffee Table', 'Furniture', 90.00),
(5, 'Running Shoes', 'Apparel', 40.00);
INSERT INTO orders (order_id, product_id, quantity, unit_price, order_date) VALUES
(1, 1, 10, 900.00, '2025-07-01'),
(2, 2, 15, 600.00, '2025-07-02'),
(3, 3, 20, 200.00, '2025-07-03'),
(4, 4, 10, 150.00, '2025-07-04'),
(5, 5, 50, 80.00, '2025-07-05'),
(6, 1, 5, 900.00, '2025-07-06'),
(7, 3, 10, 200.00, '2025-07-07');
-- Optional cleanup before rerun
DELETE FROM profit_report;

-- ETL: Insert into profit_report
INSERT INTO profit_report (category, total_revenue, total_cost, profit)
SELECT
    p.category,
    SUM(o.unit_price * o.quantity) AS total_revenue,
    SUM(p.cost_price * o.quantity) AS total_cost,
    SUM(o.unit_price * o.quantity) - SUM(p.cost_price * o.quantity) AS profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category;

-- ETL: calculate cost from products, revenue from orders
-- Store in profit_report
-- Use HAVING to filter profit > ₹10,000
SELECT *
FROM profit_report
HAVING profit > 1000;

-- 14. Geo-Sales Heatmap Database
-- Goal: Prepare backend for a location-wise sales heatmap.
-- Features:
create database heatmap;
use heatmap;
CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50)
);
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    location_id INT,
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE dw_sales_by_region (
    state VARCHAR(50),
    city VARCHAR(50),
    total_revenue DECIMAL(12, 2)
);
INSERT INTO locations (location_id, city, state) VALUES
(1, 'Mumbai', 'Maharashtra'),
(2, 'Pune', 'Maharashtra'),
(3, 'Bangalore', 'Karnataka'),
(4, 'Chennai', 'Tamil Nadu');
INSERT INTO customers (customer_id, customer_name, location_id) VALUES
(101, 'Alice', 1),
(102, 'Bob', 2),
(103, 'Carol', 3),
(104, 'David', 4),
(105, 'Eve', 1);
INSERT INTO orders (order_id, customer_id, order_date, amount) VALUES
(1, 101, '2025-07-01', 1200.00),
(2, 102, '2025-07-02', 2200.00),
(3, 103, '2025-07-03', 3100.00),
(4, 104, '2025-07-04', 1800.00),
(5, 105, '2025-07-05', 2500.00),
(6, 101, '2025-07-06', 3000.00);

-- Group revenue by state or city
-- Use aggregate data in dw_sales_by_region
-- Optional: clear existing data
DELETE FROM dw_sales_by_region;

-- Aggregate and insert
INSERT INTO dw_sales_by_region (state, city, total_revenue)
SELECT
    l.state,
    l.city,
    SUM(o.amount) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN locations l ON c.location_id = l.location_id
GROUP BY l.state, l.city;

-- Format data for frontend API/reporting tools
SELECT
    state,
    city,
    total_revenue
FROM dw_sales_by_region
ORDER BY total_revenue DESC;

-- 15. Payment Method Effectiveness Report
-- Goal: Analyze how payment method affects total sales.
-- Features:
create database report;
use report;
CREATE TABLE payment_methods (
    method_id INT PRIMARY KEY,
    method_name VARCHAR(50)
);
INSERT INTO payment_methods (method_id, method_name) VALUES
(1, 'Credit Card'),
(2, 'UPI'),
(3, 'Cash'),
(4, 'Net Banking'),
(5, 'Wallet');

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2),
    payment_method VARCHAR(50)
);
INSERT INTO orders (order_id, customer_id, order_date, amount, payment_method) VALUES
(1, 101, '2025-07-01', 1200.00, 'Credit Card'),
(2, 102, '2025-07-02', 800.00, 'UPI'),
(3, 103, '2025-07-03', 1500.00, 'Cash'),
(4, 104, '2025-07-04', 900.00, 'Credit Card'),
(5, 105, '2025-07-05', 2200.00, 'Net Banking'),
(6, 106, '2025-07-06', 450.00, 'Wallet'),
(7, 107, '2025-07-07', 700.00, 'UPI'),
(8, 108, '2025-07-08', 1300.00, 'Credit Card'),
(9, 109, '2025-07-09', 300.00, 'Wallet'),
(10, 110, '2025-07-10', 1800.00, 'Cash');

-- Group orders by payment_method
-- Compare average order value
-- Show total orders per method

SELECT
    payment_method,
    COUNT(*) AS total_orders,
    SUM(amount) AS total_sales,
    ROUND(AVG(amount), 2) AS avg_order_value
FROM orders
GROUP BY payment_method
ORDER BY total_sales DESC;

-- 16. Seasonal Demand Forecasting Prep
-- Goal: Identify seasonally trending products.
-- Features:
create database demand;
use demand;
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100)
);INSERT INTO products (product_id, product_name) VALUES
(1, 'Running Shoes'),
(2, 'Bluetooth Speaker'),
(3, 'Desk Lamp'),
(4, 'Fitness Band');

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO orders (order_id, product_id, quantity, order_date) VALUES
(1, 1, 20, '2025-04-05'),
(2, 1, 25, '2025-05-06'),
(3, 1, 40, '2025-06-07'),
(4, 2, 15, '2025-04-12'),
(5, 2, 10, '2025-05-20'),
(6, 2, 30, '2025-06-18'),
(7, 3, 10, '2025-06-01'),
(8, 4, 5, '2025-04-22'),
(9, 4, 8, '2025-05-22'),
(10, 4, 18, '2025-06-22');

CREATE TABLE trending_products (
    product_id INT,
    product_name VARCHAR(100),
    month INT,
    year INT,
    total_quantity INT,
    prev_month_quantity INT,
    growth INT
);

-- Extract monthly demand for each product
-- Use window functions or CTEs for month-on-month change
WITH monthly_sales AS (
  SELECT
    p.product_id,
    p.product_name,
    YEAR(o.order_date) AS year,
    MONTH(o.order_date) AS month,
    SUM(o.quantity) AS total_quantity
  FROM orders o
  JOIN products p ON o.product_id = p.product_id
  GROUP BY p.product_id, p.product_name, YEAR(o.order_date), MONTH(o.order_date)
),
sales_with_growth AS (
  SELECT
    product_id,
    product_name,
    year,
    month,
    total_quantity,
    LAG(total_quantity) OVER (PARTITION BY product_id ORDER BY year, month) AS prev_month_quantity,
    total_quantity - LAG(total_quantity) OVER (PARTITION BY product_id ORDER BY year, month) AS growth
  FROM monthly_sales
)
-- Optional: filter for trending only
SELECT *
FROM sales_with_growth
WHERE growth > 0;

-- Store top trending products in trending_products
INSERT INTO trending_products (product_id, product_name, year, month, total_quantity, prev_month_quantity, growth)
SELECT
    product_id,
    product_name,
    year,
    month,
    total_quantity,
    prev_month_quantity,
    growth
FROM (
    WITH monthly_sales AS (
      SELECT
        p.product_id,
        p.product_name,
        YEAR(o.order_date) AS year,
        MONTH(o.order_date) AS month,
        SUM(o.quantity) AS total_quantity
      FROM orders o
      JOIN products p ON o.product_id = p.product_id
      GROUP BY p.product_id, p.product_name, YEAR(o.order_date), MONTH(o.order_date)
    ),
    sales_with_growth AS (
      SELECT
        product_id,
        product_name,
        year,
        month,
        total_quantity,
        LAG(total_quantity) OVER (PARTITION BY product_id ORDER BY year, month) AS prev_month_quantity,
        total_quantity - LAG(total_quantity) OVER (PARTITION BY product_id ORDER BY year, month) AS growth
      FROM monthly_sales
    )
    SELECT *
    FROM sales_with_growth
    WHERE growth > 10
) AS trending;
select * from trending_products;

-- 17. Sales Representative Performance Analytics
-- Goal: Track employee performance based on assigned sales.
-- Features:
create database analysis;
use analysis;
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100)
);
INSERT INTO employees (employee_id, employee_name) VALUES
(1, 'Amit Kumar'),
(2, 'Bhavna Shah'),
(3, 'Carlos Singh'),
(4, 'Divya Menon');

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date DATE,
    amount DECIMAL(10, 2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
INSERT INTO orders (order_id, customer_id, employee_id, order_date, amount) VALUES
(1, 101, 1, '2025-07-01', 1200.00),
(2, 102, 2, '2025-07-02', 800.00),
(3, 103, 1, '2025-07-03', 1500.00),
(4, 104, 3, '2025-07-04', 900.00),
(5, 105, 2, '2025-07-05', 2200.00),
(6, 106, 1, '2025-07-06', 450.00),
(7, 107, 4, '2025-07-07', 1300.00),
(8, 108, 4, '2025-07-08', 1800.00);

CREATE TABLE rep_performance (
    employee_id INT,
    employee_name VARCHAR(100),
    total_sales DECIMAL(12, 2),
    order_count INT,
    rnk INT
);

-- Group sales by employee
-- Use ranking (ROW_NUMBER) to assign top performers
-- Store in rep_performance table
INSERT INTO rep_performance (employee_id, employee_name, total_sales, order_count, rnk)
SELECT *
FROM (
    WITH rep_sales AS (
        SELECT
            e.employee_id,
            e.employee_name,
            COUNT(o.order_id) AS order_count,
            SUM(o.amount) AS total_sales
        FROM employees e
        LEFT JOIN orders o ON e.employee_id = o.employee_id
        GROUP BY e.employee_id, e.employee_name
    ),
    ranked_reps AS (
        SELECT *,
            ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS rnk
        FROM rep_sales
    )
    SELECT employee_id, employee_name, total_sales, order_count, rnk
    FROM ranked_reps
) AS ranked_result;
select * from rep_performance;

-- 18. Flash Sales Impact Report
-- Goal: Measure the revenue impact during limited-time offers.
-- Features:
create database flash;
use flash;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2)
);
INSERT INTO orders (order_id, product_id, customer_id, order_date, amount) VALUES
(1, 101, 201, '2025-06-20', 500.00),  -- before flash sale
(2, 102, 202, '2025-06-22', 700.00),
(3, 101, 203, '2025-06-25', 1200.00), -- during flash sale
(4, 103, 204, '2025-06-26', 1500.00),
(5, 104, 205, '2025-06-27', 1100.00),
(6, 101, 206, '2025-07-01', 600.00),  -- after flash sale
(7, 102, 207, '2025-07-02', 900.00);

CREATE TABLE flash_sale_summary (
    period VARCHAR(20),         -- 'before', 'during', 'after'
    total_orders INT,
    total_revenue DECIMAL(12,2)
);

-- Compare sales before, during, and after a campaign
INSERT INTO flash_sale_summary (period, total_orders, total_revenue)
SELECT period, total_orders, total_revenue
FROM (
  SELECT
    CASE
      WHEN order_date < '2025-06-24' THEN 'before'
      WHEN order_date BETWEEN '2025-06-24' AND '2025-06-27' THEN 'during'
      ELSE 'after'
    END AS period,
    COUNT(order_id) AS total_orders,
    SUM(amount) AS total_revenue
  FROM orders
  GROUP BY period
) AS agg_sales;

-- Use order_date range filter and CTEs
-- Store in flash_sale_summary

SELECT * FROM flash_sale_summary;

-- 19. Return and Refund Analytics
-- Goal: Analyze return rate and refund impact on revenue.
-- Features:
create database refund;
use refund;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10, 2)
);

CREATE TABLE returns (
    return_id INT PRIMARY KEY,
    order_id INT,
    return_date DATE,
    refund_amount DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics'),
(102, 'Headphones', 'Electronics'),
(103, 'Coffee Mug', 'Kitchen'),
(104, 'T-shirt', 'Apparel');

INSERT INTO orders VALUES
(1, 101, 201, '2025-06-20', 50000.00),
(2, 102, 202, '2025-06-22', 1500.00),
(3, 103, 203, '2025-06-25', 300.00),
(4, 104, 204, '2025-06-26', 800.00),
(5, 101, 205, '2025-06-27', 50000.00);

INSERT INTO returns VALUES
(1, 2, '2025-06-29', 1500.00), -- Headphones returned
(2, 5, '2025-07-01', 50000.00); -- Laptop returned
CREATE TABLE return_refund_report (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    total_orders INT,
    total_returns INT,
    total_revenue DECIMAL(12,2),
    total_refund DECIMAL(12,2),
    return_rate DECIMAL(5,2) -- percentage
);

-- Join orders with returns table
-- Aggregate return counts and refund amounts
INSERT INTO return_refund_report
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(o.order_id) AS total_orders,
    COUNT(r.return_id) AS total_returns,
    SUM(o.amount) AS total_revenue,
    COALESCE(SUM(r.refund_amount), 0) AS total_refund,
    ROUND(
      (COUNT(r.return_id) / COUNT(o.order_id)) * 100, 2
    ) AS return_rate
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
LEFT JOIN returns r ON o.order_id = r.order_id
GROUP BY p.product_id, p.product_name, p.category
HAVING return_rate > 0;  -- highlight only products with returns

-- Highlight high-return products or categories
SELECT * FROM return_refund_report ORDER BY return_rate DESC;

-- 20. Multi-Source ETL Integration Project
-- Goal: Build an ETL pipeline that merges multiple data sources.
-- Features:
create database multisrc;
use multisrc;

CREATE TABLE stg_customers (
    customer_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100)
);
DESC stg_customers;
select * from stg_customers;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    amount DECIMAL(10, 2)
);
INSERT INTO orders VALUES
(1001, 201, 301, '2025-07-01', 2, 1500.00),
(1002, 202, 302, '2025-07-02', 1, 700.00);


CREATE TABLE stg_products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50)
);
CREATE TABLE stg_products_json (
    raw_json JSON
);
INSERT INTO stg_products_json (raw_json)
VALUES (
'[
  { "product_id": 301, "product_name": "Gaming Mouse", "category": "Electronics" },
  { "product_id": 302, "product_name": "Mechanical Keyboard", "category": "Electronics" }
]'
);
INSERT INTO stg_products (product_id, product_name, category)
SELECT 
  jt.product_id,
  jt.product_name,
  jt.category
FROM (
  SELECT raw_json
  FROM stg_products_json
  LIMIT 1
) AS src,
JSON_TABLE(
  src.raw_json,
  '$[*]'
  COLUMNS (
    product_id INT PATH '$.product_id',
    product_name VARCHAR(100) PATH '$.product_name',
    category VARCHAR(50) PATH '$.category'
  )
) AS jt;



CREATE TABLE dw_combined_data (
    customer_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    product_id INT,
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    order_id INT,
    order_date DATE,
    order_quantity INT,
    order_amount DECIMAL(12, 2)
);

-- ETL merge logic
INSERT INTO dw_combined_data (
    customer_id, customer_name, customer_email,
    product_id, product_name, product_category,
    order_id, order_date, order_quantity, order_amount
)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS customer_email,
    p.product_id,
    p.product_name,
    p.category AS product_category,
    o.order_id,
    o.order_date,
    o.quantity AS order_quantity,
    o.amount AS order_amount
FROM orders o
JOIN stg_customers c ON o.customer_id = c.customer_id
JOIN stg_products p ON o.product_id = p.product_id;

-- verify loaded warehouse
SELECT * FROM dw_combined_data;


















