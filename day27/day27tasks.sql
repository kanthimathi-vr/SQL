-- day 27 tasks

-- Section 1: Data Warehousing Concepts
-- ✅ Basics of Data Warehousing
-- Define what a data warehouse is and list its key components.
-- A data warehouse is a centralized repository that stores integrated data 
-- from multiple sources, optimized for querying and analysis rather than
--  transaction processing. It supports decision-making processes by 
-- allowing efficient reporting and data mining.
-- key components
-- | Component                  | Description                                                                                             |
-- | -------------------------- | ------------------------------------------------------------------------------------------------------- |
-- | **Data Sources**           | External/internal systems like CRM, ERP, OLTP databases, etc.                                           |
-- | **ETL Process**            | Extract, Transform, Load – responsible for data cleansing, integration, and loading into the warehouse. |
-- | **Data Staging Area**      | Temporary storage for processing before data is moved to the warehouse.                                 |
-- | **Data Warehouse Storage** | Central repository where transformed data is stored.                                                    |
-- | **Metadata**               | Data about data – defines source, usage, format, and other properties.                                  |
-- | **Query Tools**            | Tools for querying and reporting like SQL, BI tools (Power BI, Tableau).                                |

-- Differentiate between OLTP and OLAP with real-time examples.
-- | Feature        | OLTP (Online Transaction Processing) | OLAP (Online Analytical Processing)  |
-- | -------------- | ------------------------------------ | ------------------------------------ |
-- | **Purpose**    | Day-to-day transaction processing    | Data analysis and decision support   |
-- | **Data**       | Current, detailed, normalized        | Historical, summarized, denormalized |
-- | **Operations** | INSERT, UPDATE, DELETE               | SELECT (complex queries, aggregates) |
-- | **Speed**      | Optimized for fast write operations  | Optimized for fast read operations   |
-- | **Example**    | Banking system, E-commerce orders    | Sales dashboard, trend analysis      |

-- Create a table that simulates a basic OLTP system for order management.
create database day27;
use day27;
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2)
);

-- Create a separate table for OLAP queries (e.g., monthly sales summary).
CREATE TABLE MonthlySalesSummary (
    Month VARCHAR(10),
    Year INT,
    ProductID INT,
    TotalSalesAmount DECIMAL(15, 2),
    TotalUnitsSold INT
);
-- Write a SQL query to simulate a transactional OLTP insert.
INSERT INTO Orders (OrderID, CustomerID, OrderDate, ProductID, Quantity, Price)
VALUES (1001, 501, '2025-07-11', 301, 2, 49.99);

-- Star Schema Design
-- Design a Star Schema for a retail store with:
-- Fact_Sales
-- Dim_Product, Dim_Customer, Dim_Time, Dim_Location
CREATE TABLE Dim_Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50),
    Category VARCHAR(30),
    Price DECIMAL(10, 2)
);
CREATE TABLE Dim_Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    Gender CHAR(1),
    Age INT
);
CREATE TABLE Dim_Time (
    TimeID INT PRIMARY KEY,
    Date DATE,
    Month VARCHAR(10),
    Year INT
);
CREATE TABLE Dim_Location (
    LocationID INT PRIMARY KEY,
    City VARCHAR(50),
    Region VARCHAR(50)
);
CREATE TABLE Fact_Sales (
    SalesID INT PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    TimeID INT,
    LocationID INT,
    Quantity INT,
    TotalRevenue DECIMAL(12, 2),
    FOREIGN KEY (ProductID) REFERENCES Dim_Product(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Dim_Customer(CustomerID),
    FOREIGN KEY (TimeID) REFERENCES Dim_Time(TimeID),
    FOREIGN KEY (LocationID) REFERENCES Dim_Location(LocationID)
);

-- Insert sample data into each dimension and fact table (minimum 5 records).
INSERT INTO Dim_Product VALUES
(1, 'Laptop', 'Electronics', 1200.00),
(2, 'Headphones', 'Electronics', 150.00),
(3, 'Chair', 'Furniture', 85.00),
(4, 'Desk Lamp', 'Home Decor', 40.00),
(5, 'Water Bottle', 'Fitness', 20.00);
INSERT INTO Dim_Customer VALUES
(101, 'Alice Smith', 'F', 28),
(102, 'Bob Johnson', 'M', 35),
(103, 'Charlie Lee', 'M', 42),
(104, 'Diana King', 'F', 22),
(105, 'Eva Brown', 'F', 30);
INSERT INTO Dim_Time VALUES
(201, '2025-07-01', 'July', 2025),
(202, '2025-07-02', 'July', 2025),
(203, '2025-07-03', 'July', 2025),
(204, '2025-07-04', 'July', 2025),
(205, '2025-07-05', 'July', 2025);
INSERT INTO Dim_Location VALUES
(301, 'New York', 'East Coast'),
(302, 'Los Angeles', 'West Coast'),
(303, 'Chicago', 'Midwest'),
(304, 'Houston', 'South'),
(305, 'Seattle', 'Northwest');
INSERT INTO Fact_Sales VALUES
(1001, 1, 101, 201, 301, 1, 1200.00),
(1002, 2, 102, 202, 302, 2, 300.00),
(1003, 3, 103, 203, 303, 1, 85.00),
(1004, 4, 104, 204, 304, 3, 120.00),
(1005, 5, 105, 205, 305, 5, 100.00);

-- Write a query to calculate total revenue by product category using star schema.
SELECT 
    P.Category,
    SUM(F.TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Product P ON F.ProductID = P.ProductID
GROUP BY 
    P.Category;

-- Create a report that shows sales by region (from Dim_Location).
SELECT 
    L.Region,
    SUM(F.TotalRevenue) AS TotalSales
FROM 
    Fact_Sales F
JOIN 
    Dim_Location L ON F.LocationID = L.LocationID
GROUP BY 
    L.Region;

-- Write a query that joins all dimension tables with the fact table.
SELECT 
    F.SalesID,
    P.ProductName,
    P.Category,
    C.CustomerName,
    C.Gender,
    T.Date,
    L.City,
    L.Region,
    F.Quantity,
    F.TotalRevenue
FROM 
    Fact_Sales F
JOIN Dim_Product P ON F.ProductID = P.ProductID
JOIN Dim_Customer C ON F.CustomerID = C.CustomerID
JOIN Dim_Time T ON F.TimeID = T.TimeID
JOIN Dim_Location L ON F.LocationID = L.LocationID;

-- Snowflake Schema Design
-- Normalize Dim_Product by creating a Category_Details sub-table.
CREATE TABLE Category_Details (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(30)
);
CREATE TABLE Dim_Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50),
    CategoryID INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (CategoryID) REFERENCES Category_Details(CategoryID)
);

-- Create a Snowflake Schema and insert sample data.
INSERT INTO Category_Details VALUES
(1, 'Electronics'),
(2, 'Furniture'),
(3, 'Home Decor'),
(4, 'Fitness');
INSERT INTO Dim_Product VALUES
(1, 'Laptop', 1, 1200.00),
(2, 'Headphones', 1, 150.00),
(3, 'Chair', 2, 85.00),
(4, 'Desk Lamp', 3, 40.00),
(5, 'Water Bottle', 4, 20.00);

-- Write a SQL query to show total revenue per product category using snowflake schema.
SELECT 
    C.CategoryName,
    SUM(F.TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Product P ON F.ProductID = P.ProductID
JOIN 
    Category_Details C ON P.CategoryID = C.CategoryID
GROUP BY 
    C.CategoryName;

-- Compare performance difference (execution time) between star and snowflake queries.
-- | Aspect                 | Star Schema           | Snowflake Schema                        |
-- | ---------------------- | --------------------- | --------------------------------------- |
-- | **Joins**              | Fewer (fewer tables)  | More (normalized, deeper hierarchy)     |
-- | **Query Performance**  | Faster (denormalized) | Slower (more joins required)            |
-- | **Storage Efficiency** | Less efficient        | More efficient                          |
-- | **Use Case Fit**       | Reporting, dashboards | Analytical accuracy, normalized control |

-- Write a SQL query to count the number of sales per customer location.
SELECT 
    L.City,
    L.Region,
    COUNT(F.SalesID) AS NumberOfSales
FROM 
    Fact_Sales F
JOIN 
    Dim_Location L ON F.LocationID = L.LocationID
GROUP BY 
    L.City, L.Region;

-- Section 2: Data Aggregation and Reporting
-- ✅ Grouping and Aggregating
-- Write a query to group total sales by month and year.
SELECT 
    T.Month,
    T.Year,
    SUM(F.TotalRevenue) AS TotalMonthlySales
FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    T.Month, T.Year
ORDER BY 
    T.Year, FIELD(T.Month, 'January','February','March','April','May','June','July','August','September','October','November','December');

-- Use HAVING to filter results where monthly sales > ₹10,000.
SELECT 
    T.Month,
    T.Year,
    SUM(F.TotalRevenue) AS TotalMonthlySales
FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    T.Month, T.Year
HAVING 
    SUM(F.TotalRevenue) > 1000
ORDER BY 
    T.Year, T.Month;

-- Generate a report showing number of orders per product.
SELECT 
    P.ProductName,
    COUNT(F.SalesID) AS NumberOfOrders
FROM 
    Fact_Sales F
JOIN 
    Dim_Product P ON F.ProductID = P.ProductID
GROUP BY 
    P.ProductName;

-- Show average sale amount per customer.
SELECT 
    C.CustomerName,
    AVG(F.TotalRevenue) AS AvgSaleAmount
FROM 
    Fact_Sales F
JOIN 
    Dim_Customer C ON F.CustomerID = C.CustomerID
GROUP BY 
    C.CustomerName;

-- Display the maximum, minimum, and average order total per product category.
SELECT 
    CD.CategoryName,
    MAX(F.TotalRevenue) AS MaxOrder,
    MIN(F.TotalRevenue) AS MinOrder,
    AVG(F.TotalRevenue) AS AvgOrder
FROM 
    Fact_Sales F
JOIN 
    Dim_Product P ON F.ProductID = P.ProductID
JOIN 
    Category_Details CD ON P.CategoryID = CD.CategoryID
GROUP BY 
    CD.CategoryName;

-- Business Reporting Tasks
-- Generate a monthly performance report with:
-- Year, Month, Total Orders, Total Revenue
SELECT 
    T.Year,
    T.Month,
    COUNT(F.SalesID) AS TotalOrders,
    SUM(F.TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    T.Year, T.Month
ORDER BY 
    T.Year, FIELD(T.Month, 'January','February','March','April','May','June','July','August','September','October','November','December');

-- Generate a customer spending report (Top 5 customers by total spend).
SELECT 
    C.CustomerName,
    SUM(F.TotalRevenue) AS TotalSpend
FROM 
    Fact_Sales F
JOIN 
    Dim_Customer C ON F.CustomerID = C.CustomerID
GROUP BY 
    C.CustomerName
ORDER BY 
    TotalSpend DESC
LIMIT 5;

-- Identify months with decline in revenue using comparison (e.g., LEAD or LAG).
WITH MonthlyRevenue AS (
    SELECT 
        T.Year,
        T.Month,
        SUM(F.TotalRevenue) AS Revenue
    FROM 
        Fact_Sales F
    JOIN 
        Dim_Time T ON F.TimeID = T.TimeID
    GROUP BY 
        T.Year, T.Month
)

SELECT 
    Year,
    Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year, FIELD(Month, 'January','February','March','April','May','June','July','August','September','October','November','December')) AS PrevRevenue,
    CASE 
        WHEN Revenue < LAG(Revenue) OVER (ORDER BY Year, FIELD(Month, 'January','February','March','April','May','June','July','August','September','October','November','December'))
        THEN 'Decline'
        ELSE 'Increase/Stable'
    END AS RevenueTrend
FROM 
    MonthlyRevenue;

-- Show customer retention trend by month (using COUNT(DISTINCT customer_id)).
SELECT 
    T.Year,
    T.Month,
    COUNT(DISTINCT F.CustomerID) AS ActiveCustomers
FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    T.Year, T.Month
ORDER BY 
    T.Year, FIELD(T.Month, 'January','February','March','April','May','June','July','August','September','October','November','December');

-- Write a query to analyze seasonal trends in product category sales.
SELECT 
    T.Month,
    CD.CategoryName,
    SUM(F.TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Product P ON F.ProductID = P.ProductID
JOIN 
    Category_Details CD ON P.CategoryID = CD.CategoryID
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    T.Month, CD.CategoryName
ORDER BY 
    FIELD(T.Month, 'January','February','March','April','May','June','July','August','September','October','November','December'),
    CD.CategoryName;

-- Section 3: ETL (Extract, Transform, Load)
-- ✅ Extract Phase
-- Extract active customer data from customers table where status = 'Active'.
ALTER TABLE Dim_Customer ADD status VARCHAR(10);
-- Then update:
UPDATE Dim_Customer SET status = 'Active' WHERE CustomerID IN (101, 103, 105);
UPDATE Dim_Customer SET status = 'Inactive' WHERE CustomerID IN (102, 104);
SELECT * 
FROM Dim_Customer 
WHERE status = 'Active';

-- Write a query to extract all orders made in the last 6 months.
SELECT F.*
FROM Fact_Sales F
JOIN Dim_Time T ON F.TimeID = T.TimeID
WHERE T.Date >= CURDATE() - INTERVAL 6 MONTH;

-- Export results of extracted data to CSV (via CLI or tool like MySQL Workbench).
-- Extract high-value customers who spent > ₹20,000 in total.
SELECT 
    C.CustomerID,
    C.CustomerName,
    SUM(F.TotalRevenue) AS TotalSpent
FROM 
    Fact_Sales F
JOIN 
    Dim_Customer C ON F.CustomerID = C.CustomerID
GROUP BY 
    C.CustomerID, C.CustomerName
HAVING 
    SUM(F.TotalRevenue) > 20000;
-- 30-34: Transform Phase
-- Transform all customer names to uppercase in the customers table.
UPDATE Dim_Customer
SET CustomerName = UPPER(CustomerName)
where customerid > 0;

-- Replace null values in the email column with a default email.
UPDATE Dim_Customer
SET email = 'noemail@default.com'
WHERE email IS NULL;

-- Create a derived column in query: full_name = CONCAT(first_name, ' ', last_name).
SELECT 
    CustomerID,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM 
    Dim_Customer;

-- Standardize product category names to lowercase.
UPDATE Category_Details
SET CategoryName = LOWER(CategoryName)
where categoryid >0;

-- Calculate tax column as 18% of total_amount using SQL.
ALTER TABLE Fact_Sales ADD TaxAmount DECIMAL(12,2);

UPDATE Fact_Sales
SET TaxAmount = ROUND(TotalRevenue * 0.18, 2);
SELECT 
    SalesID,
    TotalRevenue,
    ROUND(TotalRevenue * 0.18, 2) AS TaxAmount
FROM 
    Fact_Sales;
-- 35-39 load phase:
-- Create a dw_sales_summary table for storing aggregated data.
CREATE TABLE dw_sales_summary (
    CustomerID INT,
    TotalOrders INT,
    TotalRevenue DECIMAL(12, 2),
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Write an INSERT INTO ... SELECT ... to load total purchases per customer.
INSERT INTO dw_sales_summary (CustomerID, TotalOrders, TotalRevenue)
SELECT 
    CustomerID,
    COUNT(*) AS TotalOrders,
    SUM(TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales
GROUP BY 
    CustomerID;

-- Load product-level monthly summary into dw_monthly_product_sales.
CREATE TABLE dw_monthly_product_sales (
    ProductID INT,
    Month VARCHAR(10),
    Year INT,
    TotalUnitsSold INT,
    TotalRevenue DECIMAL(12, 2),
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO dw_monthly_product_sales (ProductID, Month, Year, TotalUnitsSold, TotalRevenue)
SELECT 
    P.ProductID,
    T.Month,
    T.Year,
    SUM(F.Quantity) AS TotalUnits,
    SUM(F.TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Product P ON F.ProductID = P.ProductID
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    P.ProductID, T.Month, T.Year;

-- Build an ETL simulation script to perform extract, transform, and load steps in sequence.
-- STEP 1: Extract
CREATE TEMPORARY TABLE temp_active_customers AS
SELECT * FROM Dim_Customer WHERE status = 'Active';

-- STEP 2: Transform
UPDATE temp_active_customers
SET CustomerName = UPPER(CustomerName)
WHERE status = 'Active';

-- STEP 3: Load into dw_sales_summary
INSERT INTO dw_sales_summary (CustomerID, TotalOrders, TotalRevenue)
SELECT 
    F.CustomerID,
    COUNT(*) AS TotalOrders,
    SUM(F.TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales F
JOIN 
    temp_active_customers C ON F.CustomerID = C.CustomerID
GROUP BY 
    F.CustomerID;

-- Create a transaction log table and populate ETL step success/failure logs.
CREATE TABLE etl_transaction_log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    StepName VARCHAR(100),
    Status VARCHAR(10),     -- 'Success' or 'Failure'
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ErrorMessage TEXT
);
INSERT INTO etl_transaction_log (StepName, Status)
VALUES ('Load dw_sales_summary', 'Success');

-- Section 4: OLAP Query Practice
-- Use EXTRACT(MONTH FROM order_date) to group by month in reports.
SELECT 
    EXTRACT(MONTH FROM T.Date) AS MonthNumber,
    COUNT(F.SalesID) AS TotalOrders,
    SUM(F.TotalRevenue) AS TotalRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    EXTRACT(MONTH FROM T.Date)
ORDER BY 
    MonthNumber;

-- Calculate quarterly revenue using SQL query logic.
SELECT 
    T.Year,
    CEIL(MONTH(T.Date) / 3) AS Quarter,
    SUM(F.TotalRevenue) AS QuarterlyRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    T.Year, Quarter
ORDER BY 
    T.Year, Quarter;

-- Write a query to show average order size by product.
SELECT 
    P.ProductName,
    AVG(F.TotalRevenue) AS AvgOrderValue
FROM 
    Fact_Sales F
JOIN 
    Dim_Product P ON F.ProductID = P.ProductID
GROUP BY 
    P.ProductName;

-- Build a time series report using EXTRACT(YEAR), EXTRACT(MONTH).
SELECT 
    EXTRACT(YEAR FROM T.Date) AS Year,
    EXTRACT(MONTH FROM T.Date) AS Month,
    SUM(F.TotalRevenue) AS MonthlyRevenue
FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    EXTRACT(YEAR FROM T.Date), EXTRACT(MONTH FROM T.Date)
ORDER BY 
    Year, Month;

-- Compare this month vs. last month total revenue using window functions.
WITH MonthlyRevenue AS (
    SELECT 
        EXTRACT(YEAR FROM T.Date) AS Year,
        EXTRACT(MONTH FROM T.Date) AS Month,
        SUM(F.TotalRevenue) AS Revenue
    FROM 
        Fact_Sales F
    JOIN 
        Dim_Time T ON F.TimeID = T.TimeID
    GROUP BY 
        EXTRACT(YEAR FROM T.Date), EXTRACT(MONTH FROM T.Date)
)

SELECT 
    Year,
    Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year, Month) AS LastMonthRevenue,
    (Revenue - LAG(Revenue) OVER (ORDER BY Year, Month)) AS RevenueChange
FROM 
    MonthlyRevenue;

-- Section 5: Advanced BI Use Cases
-- Create a dashboard view using SQL VIEW that shows:
-- Monthly sales
-- Top 3 products
-- Region with highest revenue
CREATE VIEW vw_dashboard_summary AS
SELECT
    -- Monthly Sales Summary
    T.Month,
    T.Year,
    SUM(F.TotalRevenue) AS MonthlyRevenue,

    -- Top 3 Products This Month (simplified, use separate query or temp table in practice)
    (SELECT P.ProductName
     FROM Fact_Sales FS
     JOIN Dim_Product P ON FS.ProductID = P.ProductID
     JOIN Dim_Time DT ON FS.TimeID = DT.TimeID
     WHERE DT.Month = T.Month AND DT.Year = T.Year
     GROUP BY P.ProductName
     ORDER BY SUM(FS.TotalRevenue) DESC
     LIMIT 1) AS TopProduct1,

    -- Highest Revenue Region This Month
    (SELECT L.Region
     FROM Fact_Sales FS
     JOIN Dim_Location L ON FS.LocationID = L.LocationID
     JOIN Dim_Time DT ON FS.TimeID = DT.TimeID
     WHERE DT.Month = T.Month AND DT.Year = T.Year
     GROUP BY L.Region
     ORDER BY SUM(FS.TotalRevenue) DESC
     LIMIT 1) AS TopRegion

FROM 
    Fact_Sales F
JOIN 
    Dim_Time T ON F.TimeID = T.TimeID
GROUP BY 
    T.Year, T.Month;

-- Create a materialized view (if supported) for high-cost aggregation results.
CREATE TABLE mv_high_cost_customers AS
SELECT 
    C.CustomerID,
    SUM(F.TotalRevenue) AS TotalSpent
FROM 
    Fact_Sales F
JOIN 
    Dim_Customer C ON F.CustomerID = C.CustomerID
GROUP BY 
    C.CustomerID
HAVING 
    SUM(F.TotalRevenue) > 20000;
TRUNCATE TABLE mv_high_cost_customers;

INSERT INTO mv_high_cost_customers
SELECT 
    C.CustomerID,
    SUM(F.TotalRevenue)
FROM 
    Fact_Sales F
JOIN 
    Dim_Customer C ON F.CustomerID = C.CustomerID
GROUP BY 
    C.CustomerID
HAVING 
    SUM(F.TotalRevenue) > 20000;

-- Perform rolling 3-month average revenue using window functions.
WITH MonthlyRevenue AS (
    SELECT 
        T.Year,
        T.Month,
        SUM(F.TotalRevenue) AS Revenue
    FROM 
        Fact_Sales F
    JOIN 
        Dim_Time T ON F.TimeID = T.TimeID
    GROUP BY 
        T.Year, T.Month
)

SELECT 
    Year,
    Month,
    Revenue,
    ROUND(AVG(Revenue) OVER (
        ORDER BY Year, Month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling3MonthAvg
FROM 
    MonthlyRevenue;

-- Write a report to analyze customer churn (inactive in last 90 days).
SELECT 
    C.CustomerID,
    C.CustomerName
FROM 
    Dim_Customer C
WHERE 
    C.CustomerID NOT IN (
        SELECT DISTINCT F.CustomerID
        FROM Fact_Sales F
        JOIN Dim_Time T ON F.TimeID = T.TimeID
        WHERE T.Date >= CURDATE() - INTERVAL 90 DAY
    );

-- Identify top 5 product categories that consistently appear in top sales monthly.
WITH MonthlyCategoryRank AS (
    SELECT 
        T.Month,
        T.Year,
        CD.CategoryName,
        SUM(F.TotalRevenue) AS Revenue,
        RANK() OVER (PARTITION BY T.Month, T.Year ORDER BY SUM(F.TotalRevenue) DESC) AS CategoryRank
    FROM 
        Fact_Sales F
    JOIN Dim_Product P ON F.ProductID = P.ProductID
    JOIN Category_Details CD ON P.CategoryID = CD.CategoryID
    JOIN Dim_Time T ON F.TimeID = T.TimeID
    GROUP BY 
        T.Month, T.Year, CD.CategoryName
)

SELECT 
    CategoryName,
    COUNT(*) AS MonthsInTop5
FROM 
    MonthlyCategoryRank
WHERE 
    CategoryRank <= 5
GROUP BY 
    CategoryName
ORDER BY 
    MonthsInTop5 DESC
LIMIT 5;

-- Optimize a heavy sales summary query using indexing and EXPLAIN.
SELECT 
    T.Month,
    T.Year,
    SUM(F.TotalRevenue)
FROM 
    Fact_Sales F
JOIN Dim_Time T ON F.TimeID = T.TimeID
GROUP BY T.Year, T.Month;
CREATE INDEX idx_factsales_timeid ON Fact_Sales(TimeID);
CREATE INDEX idx_dimtime_date ON Dim_Time(Date, Year, Month);
EXPLAIN
SELECT 
    T.Month,
    T.Year,
    SUM(F.TotalRevenue)
FROM 
    Fact_Sales F
JOIN Dim_Time T ON F.TimeID = T.TimeID
GROUP BY T.Year, T.Month;




































































































