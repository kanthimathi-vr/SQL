-- day25 mini projects
use day24;
-- project1:
-- ✅ 1. Employee Access Control System
-- Domain: Human Resources
-- Goal: Secure and simplify employee data access
-- Requirements:
-- Create a view PublicEmployeeView to hide salaries and show only emp_id, emp_name, department.
CREATE OR REPLACE VIEW PublicEmployeeView AS
SELECT 
    e.emp_id,
    e.emp_name,
    d.dept_name AS department
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;

-- Create a stored procedure to get employees by department.
DELIMITER $$

CREATE PROCEDURE GetEmployeesByDepartment(IN deptName VARCHAR(50))
BEGIN
    SELECT 
        e.emp_id,
        e.emp_name,
        d.dept_name,
        e.status
    FROM Employees e
    JOIN Departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name = deptName;
END $$

DELIMITER ;

-- Create a trigger to log new employee insertions into an EmployeeAudit table.
CREATE TABLE EmployeeAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    action VARCHAR(50),
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELIMITER $$

CREATE TRIGGER AfterEmployeeInsert
AFTER INSERT ON Employees
FOR EACH ROW
BEGIN
    INSERT INTO EmployeeAudit (emp_id, action)
    VALUES (NEW.emp_id, 'INSERT');
END $$

DELIMITER ;
INSERT INTO Employees (emp_id,emp_name, dept_id, salary, status)
VALUES (51,'Ravi Kumar', 102, 52000, 'Active');

-- Create a function to count employees in a department.
DELIMITER $$

CREATE FUNCTION EmployeeCount(deptName VARCHAR(50)) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Employees e
    JOIN Departments d ON e.dept_id = d.dept_id
    WHERE d.dept_name = deptName;
    RETURN total;
END $$

DELIMITER ;
SELECT EmployeeCount('IT');

-- Use CREATE OR REPLACE VIEW when department info changes.
CREATE OR REPLACE VIEW PublicEmployeeView AS
SELECT 
    e.emp_id,
    e.emp_name,
    d.dept_name AS department
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;
-- project2:
-- 2. Sales Reporting & Summary System
-- Domain: Retail
-- Goal: Generate custom sales reports
-- Requirements:
CREATE TABLE Sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    amount DECIMAL(10,2),
    sale_date DATE
);
INSERT INTO Sales (product_id, customer_id, amount, sale_date) VALUES
(101, 1, 2500.00, '2025-01-15'),
(102, 2, 1800.50, '2025-01-20'),
(103, 3, 3200.00, '2025-02-05'),
(101, 2, 1500.00, '2025-02-18'),
(104, 4, 2750.75, '2025-03-10'),
(102, 1, 1100.00, '2025-03-12'),
(105, 5, 3000.00, '2025-04-01'),
(101, 3, 2000.00, '2025-04-15'),
(103, 2, 2200.00, '2025-05-05'),
(104, 1, 1700.00, '2025-05-20'),
(105, 4, 2900.00, '2025-06-03'),
(101, 5, 3100.00, '2025-06-15'),
(102, 3, 1950.00, '2025-07-01'),
(103, 1, 2100.00, '2025-07-05');

-- Create a view MonthlySalesSummary with total sales grouped by month.
CREATE OR REPLACE VIEW MonthlySalesSummary AS
SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') AS month,
    SUM(amount) AS total_sales
FROM Sales
GROUP BY month
ORDER BY month;

-- Create a function to return total sales for a specific product.
DELIMITER $$

CREATE FUNCTION TotalSalesByProduct(prod_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(amount) INTO total
    FROM Sales
    WHERE product_id = prod_id;
    RETURN IFNULL(total, 0);
END $$

DELIMITER ;
SELECT TotalSalesByProduct(101);

-- Create a stored procedure to show top 10 customers by order value.
DELIMITER $$

CREATE PROCEDURE TopCustomersByValue()
BEGIN
    SELECT 
        c.customer_id,
        c.customer_name,
        SUM(s.amount) AS total_spent
    FROM Sales s
    JOIN Customers c ON s.customer_id = c.customer_id
    GROUP BY c.customer_id
    ORDER BY total_spent DESC
    LIMIT 10;
END $$

DELIMITER ;

-- Add a trigger that inserts log entries after each new sale is made.
CREATE TABLE SalesLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT,
    
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(50)
);
DELIMITER $$

CREATE TRIGGER AfterSaleInsert
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
    INSERT INTO SalesLog (sale_id, action)
    VALUES (NEW.sale_id, 'New Sale');
END $$

DELIMITER ;

INSERT INTO SalesLog (sale_id, action) VALUES
(1, 'New Sale'),
(2, 'New Sale'),
(3, 'New Sale'),
(4, 'New Sale'),
(5, 'New Sale'),
(6, 'New Sale'),
(7, 'New Sale'),
(8, 'New Sale'),
(9, 'New Sale'),
(10, 'New Sale');

-- Allow role-based access using views for different user types (manager vs clerk).
CREATE OR REPLACE VIEW ManagerSalesView AS
SELECT 
    s.sale_id,
    s.product_id,
    s.customer_id,
    s.amount,
    s.sale_date
FROM Sales s;
CREATE OR REPLACE VIEW ClerkSalesView AS
SELECT 
    s.sale_id,
    s.product_id,
    DATE(s.sale_date) AS sale_date
FROM Sales s;
-- project3:
-- 3. Student Information Portal
-- Domain: Education
-- Goal: Provide read-only and detailed access based on role
-- Requirements:
create database education;
use education;
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    batch_year INT,
    cgpa DECIMAL(3,2),
    total_fees DECIMAL(10,2),
    paid_fees DECIMAL(10,2)
);
CREATE TABLE Grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    subject VARCHAR(50),
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);
CREATE TABLE StudentLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    action VARCHAR(50),
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Students (first_name, last_name, batch_year, cgpa, total_fees, paid_fees) VALUES
('Alice', 'Sharma', 2023, 8.4, 100000, 80000),
('Bob', 'Verma', 2022, 7.9, 95000, 95000),
('Charlie', 'Patel', 2023, 9.1, 105000, 105000),
('Diana', 'Singh', 2024, 8.7, 99000, 50000),
('Ethan', 'Rao', 2022, 6.8, 94000, 94000);
INSERT INTO Grades (student_id, subject, grade) VALUES
(1, 'Math', 'A'),
(1, 'Physics', 'B'),
(2, 'Math', 'B+'),
(2, 'Chemistry', 'A'),
(3, 'Math', 'A+'),
(4, 'Physics', 'A'),
(5, 'Biology', 'C');


-- Use views to expose different fields (students see grades; admins see fees).
CREATE OR REPLACE VIEW StudentView AS
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    s.batch_year,
    s.cgpa,
    g.subject,
    g.grade
FROM Students s
JOIN Grades g ON s.student_id = g.student_id;
CREATE OR REPLACE VIEW AdminView AS
SELECT 
    student_id,
    first_name,
    last_name,
    batch_year,
    total_fees,
    paid_fees,
    (total_fees - paid_fees) AS pending_fees
FROM Students;

-- Create a stored procedure to fetch student records by batch year.
DELIMITER $$

CREATE PROCEDURE GetStudentsByBatch(IN year INT)
BEGIN
    SELECT * FROM Students
    WHERE batch_year = year;
END $$

DELIMITER ;
CALL GetStudentsByBatch(2023);

-- Create a function to return CGPA for a student.
DELIMITER $$

CREATE FUNCTION GetCGPA(studentID INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE result DECIMAL(3,2);
    SELECT cgpa INTO result
    FROM Students
    WHERE student_id = studentID;
    RETURN result;
END $$

DELIMITER ;
SELECT GetCGPA(3);

-- Create a trigger to insert a log record when a new student is added.
DELIMITER $$

CREATE TRIGGER AfterStudentInsert
AFTER INSERT ON Students
FOR EACH ROW
BEGIN
    INSERT INTO StudentLog (student_id, action)
    VALUES (NEW.student_id, 'INSERT');
END $$

DELIMITER ;
INSERT INTO Students (first_name, last_name, batch_year, cgpa, total_fees, paid_fees)
VALUES ('Ravi', 'Kumar', 2024, 8.3, 98000, 50000);
SELECT * FROM StudentLog ORDER BY action_time DESC;

-- Use DROP VIEW to remove outdated views after semester ends.
DROP VIEW IF EXISTS StudentView;
DROP VIEW IF EXISTS AdminView;

-- project4:
-- 4. Product Stock and Audit Logger
-- Domain: Inventory
-- Goal: Track product inserts and maintain inventory audit
-- Requirements:
create database inventory;
use inventory;
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    stock INT,
    supplier_price DECIMAL(10,2),
    retail_price DECIMAL(10,2)
);
CREATE TABLE StockAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    action VARCHAR(20),
    stock INT,
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Products (product_name, category, stock, supplier_price, retail_price) VALUES
('Laptop', 'Electronics', 45, 50000.00, 60000.00),
('Mouse', 'Electronics', 120, 200.00, 400.00),
('Keyboard', 'Electronics', 30, 500.00, 800.00),
('Notebook', 'Stationery', 80, 20.00, 40.00),
('Pen', 'Stationery', 25, 5.00, 10.00),
('Desk Chair', 'Furniture', 15, 1500.00, 2500.00),
('Monitor', 'Electronics', 70, 6000.00, 8000.00);

-- Create a view LowStockItems for products with stock < 50.
CREATE OR REPLACE VIEW LowStockItems AS
SELECT product_id, product_name, category, stock
FROM Products
WHERE stock < 50;

-- Create a stored procedure to add new product entries.
DELIMITER $$

CREATE PROCEDURE AddProduct(
    IN pname VARCHAR(100),
    IN pcat VARCHAR(50),
    IN pstock INT,
    IN supp_price DECIMAL(10,2),
    IN retail_price DECIMAL(10,2)
)
BEGIN
    INSERT INTO Products (product_name, category, stock, supplier_price, retail_price)
    VALUES (pname, pcat, pstock, supp_price, retail_price);
END $$

DELIMITER ;
CALL AddProduct('Whiteboard', 'Furniture', 40, 1200.00, 1800.00);

-- Create a trigger to log every insert/update into a StockAudit table.
DELIMITER $$

CREATE TRIGGER LogStockInsert
AFTER INSERT ON Products
FOR EACH ROW
BEGIN
    INSERT INTO StockAudit (product_id, action, stock)
    VALUES (NEW.product_id, 'INSERT', NEW.stock);
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER LogStockUpdate
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO StockAudit (product_id, action, stock)
    VALUES (NEW.product_id, 'UPDATE', NEW.stock);
END $$

DELIMITER ;

-- Create a function to return total stock per product category.
DELIMITER $$

CREATE FUNCTION TotalStockByCategory(cat VARCHAR(50))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT SUM(stock) INTO total
    FROM Products
    WHERE category = cat;
    RETURN IFNULL(total, 0);
END $$

DELIMITER ;
SELECT TotalStockByCategory('Electronics');

-- Secure views to prevent access to supplier pricing.
CREATE OR REPLACE VIEW PublicProductView AS
SELECT 
    product_id,
    product_name,
    category,
    stock,
    retail_price
FROM Products;
-- project5:
-- 5. Leave Management System
-- Domain: HR / Attendance
-- Goal: Automate leave tracking and approval
-- Requirements:
create database hr;
use hr;
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    manager_id INT
);
CREATE TABLE LeaveRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    leave_date DATE,
    leave_type VARCHAR(20),
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);
CREATE TABLE LeaveBalance (
    emp_id INT PRIMARY KEY,
    remaining_leaves INT
);
INSERT INTO Employees VALUES
(1, 'Alice', NULL),         -- Manager
(2, 'Bob', 1),
(3, 'Charlie', 1),
(4, 'Diana', 1);
INSERT INTO LeaveBalance VALUES
(1, 10),
(2, 12),
(3, 8),
(4, 5);

-- Use a trigger to auto-update LeaveBalance after insert into LeaveRequests.
DELIMITER $$

CREATE TRIGGER AfterLeaveRequestInsert
AFTER INSERT ON LeaveRequests
FOR EACH ROW
BEGIN
    UPDATE LeaveBalance
    SET remaining_leaves = remaining_leaves - 1
    WHERE emp_id = NEW.emp_id;
END $$

DELIMITER ;

-- Create a view for team leads to see only their team’s requests.
CREATE OR REPLACE VIEW TeamLeaveRequests AS
SELECT r.request_id, r.emp_id, e.emp_name, r.leave_date, r.leave_type, r.status
FROM LeaveRequests r
JOIN Employees e ON r.emp_id = e.emp_id
WHERE e.manager_id = 1; -- Example: only show team members under manager_id 1

-- Create a stored procedure to approve/reject leave.
DELIMITER $$

CREATE PROCEDURE ApproveRejectLeave(
    IN req_id INT,
    IN new_status VARCHAR(20)
)
BEGIN
    UPDATE LeaveRequests
    SET status = new_status
    WHERE request_id = req_id;
END $$

DELIMITER ;
CALL ApproveRejectLeave(2, 'Approved');
-- Create a function to check remaining leave for a given employee.
DELIMITER $$

CREATE FUNCTION GetRemainingLeave(emp INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE balance INT;
    SELECT remaining_leaves INTO balance FROM LeaveBalance WHERE emp_id = emp;
    RETURN balance;
END $$

DELIMITER ;
SELECT GetRemainingLeave(3);

-- Use DROP TRIGGER and recreate when logic changes.
DROP TRIGGER IF EXISTS AfterLeaveRequestInsert;
DELIMITER $$

CREATE TRIGGER AfterLeaveRequestInsert
AFTER INSERT ON LeaveRequests
FOR EACH ROW
BEGIN
    DECLARE leave_days INT DEFAULT 1;

    IF NEW.leave_type = 'Sick' THEN
        SET leave_days = 2;
    END IF;

    UPDATE LeaveBalance
    SET remaining_leaves = remaining_leaves - leave_days
    WHERE emp_id = NEW.emp_id;
END $$

DELIMITER ;
-- project6:
-- 6. Payroll Processing and Monitoring
-- Domain: Finance
-- Goal: Secure and automate payroll records
-- Requirements:
create database finance;
use finance;
CREATE TABLE Payroll (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    base_salary DECIMAL(10,2),
    bonus DECIMAL(10,2),
    net_salary DECIMAL(10,2)
);
CREATE TABLE SalaryAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_on DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Payroll (emp_id, emp_name, department, base_salary, bonus, net_salary) VALUES
(1, 'Alice', 'Finance', 50000.00, 5000.00, 55000.00),
(2, 'Bob', 'IT', 60000.00, 7000.00, 67000.00),
(3, 'Charlie', 'HR', 45000.00, 4000.00, 49000.00),
(4, 'Diana', 'Finance', 70000.00, 8000.00, 78000.00);

-- Use views to separate HR view (with salary) and Employee view (without salary).
CREATE OR REPLACE VIEW HRPayrollView AS
SELECT emp_id, emp_name, department, base_salary, bonus, net_salary
FROM Payroll;
CREATE OR REPLACE VIEW EmployeePayrollView AS
SELECT emp_id, emp_name, department
FROM Payroll;

-- Create a stored procedure to generate monthly payroll report.
DELIMITER $$

CREATE PROCEDURE GeneratePayrollReport()
BEGIN
    SELECT emp_id, emp_name, department, base_salary, bonus, net_salary
    FROM Payroll;
END $$

DELIMITER ;
CALL GeneratePayrollReport();

-- Create a function to calculate tax deduction for an employee.
DELIMITER $$

CREATE FUNCTION CalculateTax(salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE tax_rate DECIMAL(5,2);
    IF salary <= 50000 THEN
        SET tax_rate = 0.10;
    ELSEIF salary <= 70000 THEN
        SET tax_rate = 0.15;
    ELSE
        SET tax_rate = 0.20;
    END IF;

    RETURN salary * tax_rate;
END $$

DELIMITER ;
SELECT CalculateTax(78000);

-- Add a trigger that logs changes in salary records.
DELIMITER $$

CREATE TRIGGER LogSalaryUpdate
BEFORE UPDATE ON Payroll
FOR EACH ROW
BEGIN
    IF OLD.base_salary != NEW.base_salary THEN
        INSERT INTO SalaryAudit (emp_id, old_salary, new_salary)
        VALUES (OLD.emp_id, OLD.base_salary, NEW.base_salary);
    END IF;
END $$

DELIMITER ;

-- Use CREATE OR REPLACE VIEW for payroll summary updates.
CREATE OR REPLACE VIEW PayrollSummary AS
SELECT 
    emp_name,
    department,
    base_salary + bonus AS gross_salary,
    net_salary - CalculateTax(net_salary) AS take_home
FROM Payroll;

-- project 7:
-- 7. Online Exam Result Generator
-- Domain: Education / LMS
-- Goal: Auto-calculate and present results securely
-- Requirements:
use education;
CREATE TABLE ExamResults (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    exam_id INT,
    marks INT,
    score_published BOOLEAN DEFAULT FALSE,
    internal_remarks VARCHAR(255),
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO ExamResults (student_id, exam_id, marks, score_published, internal_remarks)
VALUES
(1, 101, 95, FALSE, NULL),
(2, 101, 82, TRUE, NULL),
(3, 101, 76, FALSE, NULL),
(4, 102, 65, TRUE, NULL),
(5, 102, 58, FALSE, NULL),
(6, 103, 45, FALSE, NULL),
(7, 103, 88, TRUE, NULL),
(8, 104, 92, TRUE, NULL),
(9, 104, 70, FALSE, NULL),
(10, 105, 55, FALSE, NULL);

CREATE TABLE ScoreAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    result_id INT,
    old_marks INT,
    new_marks INT,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_by VARCHAR(100) -- Optional: username or system info
);
INSERT INTO ScoreAudit (result_id, old_marks, new_marks, modified_at, modified_by)
VALUES
(2, 80, 82, NOW(), 'admin'),
(4, 60, 65, NOW(), 'teacher1'),
(7, 85, 88, NOW(), 'teacher2');

-- Use a view to present result summaries (without answers or internal remarks).
CREATE OR REPLACE VIEW ResultSummary AS
SELECT
    result_id,
    student_id,
    exam_id,
    marks,
    score_published
FROM ExamResults;

-- Create a stored procedure to assign grades based on marks.
DELIMITER $$

CREATE FUNCTION GetGrade(score INT) RETURNS CHAR(2)
DETERMINISTIC
BEGIN
    DECLARE grade CHAR(2);

    IF score >= 90 THEN
        SET grade = 'A+';
    ELSEIF score >= 80 THEN
        SET grade = 'A';
    ELSEIF score >= 70 THEN
        SET grade = 'B';
    ELSEIF score >= 60 THEN
        SET grade = 'C';
    ELSEIF score >= 50 THEN
        SET grade = 'D';
    ELSE
        SET grade = 'F';
    END IF;

    RETURN grade;
END $$

DELIMITER ;

-- Create a function that returns grade for a score.
DELIMITER $$

CREATE PROCEDURE AssignGrades()
BEGIN
    UPDATE ExamResults
    SET internal_remarks = GetGrade(marks);
END $$

DELIMITER ;
CALL AssignGrades();

-- Use a trigger to prevent score updates after publishing.
DELIMITER $$

CREATE TRIGGER PreventScoreUpdateAfterPublish
BEFORE UPDATE ON ExamResults
FOR EACH ROW
BEGIN
    IF OLD.score_published = TRUE AND NEW.marks != OLD.marks THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Score cannot be updated after publishing';
    END IF;
END $$

DELIMITER ;

-- Log all score modifications in an audit table.
DELIMITER $$

CREATE TRIGGER LogScoreModification
AFTER UPDATE ON ExamResults
FOR EACH ROW
BEGIN
    IF OLD.marks != NEW.marks THEN
        INSERT INTO ScoreAudit (result_id, old_marks, new_marks)
        VALUES (OLD.result_id, OLD.marks, NEW.marks);
    END IF;
END $$

DELIMITER ;

-- project8:
-- 8. Customer Loyalty Program
-- Domain: Retail
-- Goal: Manage points, access, and auto-updates
-- Requirements:
create database cusloyalty;
use cusloyalty;
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    loyalty_points INT DEFAULT 0,
    loyalty_level VARCHAR(20)
);
INSERT INTO Customers (customer_name, email, loyalty_points, loyalty_level)
VALUES
('Alice Johnson', 'alice.johnson@example.com', 150, 'Bronze'),
('Bob Smith', 'bob.smith@example.com', 520, 'Gold'),
('Charlie Brown', 'charlie.brown@example.com', 1100, 'Platinum'),
('Diana Prince', 'diana.prince@example.com', 300, 'Silver'),
('Ethan Hunt', 'ethan.hunt@example.com', 50, 'Bronze');

CREATE TABLE LoyaltyLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    old_points INT,
    new_points INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO LoyaltyLog (customer_id, old_points, new_points, updated_at)
VALUES
(1, 100, 150, '2025-05-01 10:15:00'),
(2, 400, 520, '2025-05-03 11:30:00'),
(3, 900, 1100, '2025-05-05 09:45:00'),
(4, 250, 300, '2025-05-07 14:20:00'),
(5, 20, 50, '2025-05-10 16:00:00');
-- Use a view to show customer points and levels.
-- Create a function to calculate loyalty level based on points.
DELIMITER $$

CREATE FUNCTION CalculateLoyaltyLevel(points INT) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE level VARCHAR(20);

    IF points >= 1000 THEN
        SET level = 'Platinum';
    ELSEIF points >= 500 THEN
        SET level = 'Gold';
    ELSEIF points >= 200 THEN
        SET level = 'Silver';
    ELSE
        SET level = 'Bronze';
    END IF;

    RETURN level;
END $$

DELIMITER ;

-- Create a stored procedure to update loyalty points after each purchase.
DELIMITER $$

CREATE PROCEDURE UpdateLoyaltyPoints(
    IN cust_id INT,
    IN points_earned INT
)
BEGIN
    DECLARE old_points INT;
    DECLARE new_points INT;
    DECLARE new_level VARCHAR(20);

    -- Get old points
    SELECT loyalty_points INTO old_points FROM Customers WHERE customer_id = cust_id;

    -- Calculate new points
    SET new_points = old_points + points_earned;

    -- Calculate new loyalty level
    SET new_level = CalculateLoyaltyLevel(new_points);

    -- Update Customers table
    UPDATE Customers
    SET loyalty_points = new_points, loyalty_level = new_level
    WHERE customer_id = cust_id;

    -- Log the update
    INSERT INTO LoyaltyLog(customer_id, old_points, new_points)
    VALUES (cust_id, old_points, new_points);
END $$

DELIMITER ;
CREATE OR REPLACE VIEW CustomerLoyaltyView AS
SELECT customer_id, customer_name, loyalty_points, loyalty_level
FROM Customers;

-- Use a trigger to log every loyalty update.
DELIMITER $$

CREATE TRIGGER LoyaltyPointsUpdateLog
AFTER UPDATE ON Customers
FOR EACH ROW
BEGIN
    IF OLD.loyalty_points != NEW.loyalty_points THEN
        INSERT INTO LoyaltyLog(customer_id, old_points, new_points)
        VALUES (NEW.customer_id, OLD.loyalty_points, NEW.loyalty_points);
    END IF;
END $$

DELIMITER ;
CALL UpdateLoyaltyPoints(3, 150);  -- Adds 150 points to customer with ID=3
SELECT * FROM CustomerLoyaltyView;
CREATE OR REPLACE VIEW CustomerLoyaltyView AS
SELECT customer_id, customer_name, loyalty_points, loyalty_level
FROM Customers;

-- Drop and recreate views after new level rules are introduced.
DROP VIEW IF EXISTS CustomerLoyaltyView;
CREATE VIEW CustomerLoyaltyView AS
SELECT customer_id, customer_name, loyalty_points, loyalty_level
FROM Customers;

-- project9:
-- 9. User Registration and Role Manager
-- Domain: Security / Identity Management
-- Goal: Manage users, assign roles, and restrict views
-- Requirements:
create database securi;
use securi;
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Users (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('charlie', 'charlie@example.com'),
('dave', 'dave@example.com'),
('eve', 'eve@example.com');

CREATE TABLE Roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE UserRoles (
    user_id INT,
    role_id INT,
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

CREATE TABLE RoleAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    role_id INT,
    action VARCHAR(20),
    action_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE UserSettings (
    user_id INT PRIMARY KEY,
    setting_key VARCHAR(100),
    setting_value VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Roles (role_name) VALUES ('admin'), ('manager'), ('employee');


-- Create views for each role (admin, manager, employee) with filtered columns.
CREATE OR REPLACE VIEW AdminView AS
SELECT user_id, username, email, created_at FROM Users;

CREATE OR REPLACE VIEW ManagerView AS
SELECT user_id, username FROM Users;

CREATE OR REPLACE VIEW EmployeeView AS
SELECT user_id, username FROM Users;

-- Create a stored procedure to assign a role.
DELIMITER //
CREATE PROCEDURE AssignUserRole(IN p_user_id INT, IN p_role_name VARCHAR(50))
BEGIN
    DECLARE v_role_id INT;

    SELECT role_id INTO v_role_id FROM Roles WHERE role_name = p_role_name;

    IF v_role_id IS NOT NULL THEN
        INSERT IGNORE INTO UserRoles(user_id, role_id) VALUES (p_user_id, v_role_id);
        
        -- Log the role assignment
        INSERT INTO RoleAudit(user_id, role_id, action) VALUES (p_user_id, v_role_id, 'Assigned');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role does not exist';
    END IF;
END //
DELIMITER ;

-- Create a function to check if a user is admin.
DELIMITER //
CREATE FUNCTION IsUserAdmin(p_user_id INT) RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN

    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count
    FROM UserRoles ur
    JOIN Roles r ON ur.role_id = r.role_id
    WHERE ur.user_id = p_user_id AND r.role_name = 'admin';

    RETURN v_count > 0;
END //
DELIMITER ;

-- Use a trigger to automatically insert default settings after user creation.
DELIMITER //
CREATE TRIGGER AfterUserInsert
AFTER INSERT ON Users
FOR EACH ROW
BEGIN
    INSERT INTO UserSettings(user_id, setting_key, setting_value)
    VALUES (NEW.user_id, 'theme', 'light');
END //
DELIMITER ;
-- Insert a new user
INSERT INTO Users (username, email) VALUES ('johndoe', 'john@example.com');

-- Assign 'admin' role
CALL AssignUserRole(1, 'admin');

-- Check if user is admin
SELECT IsUserAdmin(1); -- Returns 1 (true)

-- Query the AdminView
SELECT * FROM AdminView;

-- Use audit table to log all role changes.

-- project 10:
-- ✅ 10. E-Commerce Product Search & Filter Engine
-- Domain: E-commerce
-- Goal: Fast, secure product access
-- Requirements:
create database ecommerce;
use ecommerce;
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock INT,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO Products (product_name, category, price, stock, discount_percent) VALUES
('Smartphone A', 'Electronics', 500, 10, 5),
('Smartphone B', 'Electronics', 700, 0, 10),
('Laptop A', 'Computers', 1200, 5, 15),
('Headphones', 'Accessories', 150, 25, 0),
('Camera', 'Electronics', 800, 8, 20),
('Mouse', 'Computers', 40, 0, 0);

-- Create a view AvailableProductsView that filters out out-of-stock items.
CREATE OR REPLACE VIEW AvailableProductsView AS
SELECT product_id, product_name, category, price, stock, discount_percent
FROM Products
WHERE stock > 0;

-- Create a function to return price after discount.
DELIMITER //

CREATE FUNCTION PriceAfterDiscount(p_price DECIMAL(10,2), p_discount DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN ROUND(p_price * (1 - p_discount / 100), 2);
END //

DELIMITER ;

-- Create a stored procedure to retrieve products by category and price range.
DELIMITER //

CREATE PROCEDURE GetProductsByCategoryPrice(
    IN p_category VARCHAR(50),
    IN p_min_price DECIMAL(10,2),
    IN p_max_price DECIMAL(10,2)
)
BEGIN
    SELECT product_id, product_name, category, price, stock, discount_percent,
           PriceAfterDiscount(price, discount_percent) AS final_price
    FROM Products
    WHERE category = p_category
      AND PriceAfterDiscount(price, discount_percent) BETWEEN p_min_price AND p_max_price
      AND stock > 0;
END //

DELIMITER ;

-- Add a trigger to log product updates.
CREATE TABLE ProductUpdateLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    old_stock INT,
    new_stock INT,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //
-- Use CREATE OR REPLACE VIEW when discount logic changes.
CREATE TRIGGER trg_after_product_update
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductUpdateLog(product_id, old_price, new_price, old_stock, new_stock)
    VALUES (OLD.product_id, OLD.price, NEW.price, OLD.stock, NEW.stock);
END //

DELIMITER ;

-- project11:
-- 11. Doctor Appointment and Notification Tracker
-- Domain: Healthcare
-- Goal: Automate and monitor appointments
-- Requirements:
create database doctor;
use doctor;
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_name VARCHAR(100),
    specialty VARCHAR(100),
    schedule VARCHAR(255) -- e.g. "Mon-Fri 9AM-5PM"
);

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_name VARCHAR(100),
    contact_info VARCHAR(255)
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT,
    patient_id INT,
    appointment_date DATE,
    appointment_time TIME,
    status VARCHAR(20) DEFAULT 'Booked',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

CREATE TABLE NotificationsLog (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT,
    appointment_id INT,
    notification_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    message VARCHAR(255),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

CREATE TABLE MedicalHistory (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    record TEXT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

-- Insert sample doctors
INSERT INTO Doctors (doctor_name, specialty, schedule) VALUES
('Dr. Alice Smith', 'Cardiology', 'Mon-Fri 9AM-5PM'),
('Dr. Bob Johnson', 'Dermatology', 'Tue-Sat 10AM-6PM'),
('Dr. Carol Lee', 'Pediatrics', 'Mon-Fri 8AM-4PM');

-- Insert sample patients
INSERT INTO Patients (patient_name, contact_info) VALUES
('John Doe', 'john.doe@example.com'),
('Jane Roe', 'jane.roe@example.com'),
('Mark Twain', 'mark.twain@example.com');

-- Insert sample medical history
INSERT INTO MedicalHistory (patient_id, record) VALUES
(1, 'No known allergies. Past surgery in 2018.'),
(2, 'Allergic to penicillin.'),
(3, 'Diabetic patient. Regular insulin shots.');

-- Insert sample appointments
INSERT INTO Appointments (doctor_id, patient_id, appointment_date, appointment_time, status) VALUES
(1, 1, '2025-07-15', '10:00:00', 'Booked'),
(2, 2, '2025-07-16', '11:00:00', 'Booked'),
(3, 3, '2025-07-17', '09:00:00', 'Booked');

-- Use a view to show doctor schedules to patients.
CREATE OR REPLACE VIEW DoctorSchedulesView AS
SELECT doctor_id, doctor_name, specialty, schedule
FROM Doctors;

-- Create a stored procedure to book appointments.
DELIMITER //

CREATE PROCEDURE BookAppointment(
    IN p_doctor_id INT,
    IN p_patient_id INT,
    IN p_appointment_date DATE,
    IN p_appointment_time TIME
)
BEGIN
    INSERT INTO Appointments (doctor_id, patient_id, appointment_date, appointment_time)
    VALUES (p_doctor_id, p_patient_id, p_appointment_date, p_appointment_time);
END //

DELIMITER ;

-- Create a function to return next available slot.
DELIMITER //

CREATE FUNCTION NextAvailableSlot(p_doctor_id INT, p_date DATE)
RETURNS TIME
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE slot TIME DEFAULT '09:00:00';
    DECLARE done INT DEFAULT 0;

    WHILE slot <= '17:00:00' AND done = 0 DO
        IF NOT EXISTS (
            SELECT 1 FROM Appointments
            WHERE doctor_id = p_doctor_id
              AND appointment_date = p_date
              AND appointment_time = slot
              AND status = 'Booked'
        ) THEN
            SET done = 1;
        ELSE
            SET slot = ADDTIME(slot, '01:00:00');
        END IF;
    END WHILE;

    IF done = 1 THEN
        RETURN slot;
    ELSE
        RETURN NULL; -- No slots available
    END IF;
END //

DELIMITER ;

-- Create a trigger to notify doctor upon appointment booking (log entry).
DELIMITER //

CREATE TRIGGER trg_after_appointment_insert
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    INSERT INTO NotificationsLog (doctor_id, appointment_id, message)
    VALUES (NEW.doctor_id, NEW.appointment_id, CONCAT('New appointment booked for ', NEW.appointment_date, ' at ', NEW.appointment_time));
END //

DELIMITER ;

-- Restrict medical history access using secured views.
CREATE OR REPLACE VIEW PatientMedicalHistoryView AS
SELECT patient_id, record
FROM MedicalHistory;

-- project12:
-- 12. NGO Donation and Campaign Summary
-- Domain: Nonprofit
-- Goal: Manage and audit donations
-- Requirements:
use ngodonation;
CREATE TABLE DonationAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    donation_id INT,
    action VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donation_id) REFERENCES Donations(donation_id)
);
-- Create a view to show public donation totals per campaign.
CREATE OR REPLACE VIEW PublicDonationSummary AS
SELECT 
    c.campaign_name,
    SUM(d.donation_amount) AS total_donations
FROM Donations d
JOIN Campaigns c ON d.campaign_id = c.campaign_id
GROUP BY c.campaign_name;

-- Create a stored procedure to register donations.
DELIMITER $$

CREATE PROCEDURE RegisterDonation(
    IN p_donor_id INT,
    IN p_campaign_id INT,
    IN p_amount DECIMAL(10,2),
    IN p_date DATE
)
BEGIN
    INSERT INTO Donations (donor_id, campaign_id, amount, donation_date)
    VALUES (p_donor_id, p_campaign_id, p_amount, p_date);

    -- Log insertion in DonationAudit
    INSERT INTO DonationAudit (donation_id, action)
    VALUES (LAST_INSERT_ID(), 'Donation Registered');
END $$

DELIMITER ;

-- Create a function to calculate total donation per donor.
DELIMITER $$

CREATE FUNCTION TotalDonationByDonor(p_donor_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT IFNULL(SUM(donation_amount), 0) INTO total
    FROM Donations
    WHERE donor_id = p_donor_id;
    RETURN total;
END $$

DELIMITER ;

-- Add a trigger to log every donation to an audit table.
DELIMITER $$

CREATE TRIGGER trg_AfterDonationInsert
AFTER INSERT ON Donations
FOR EACH ROW
BEGIN
    INSERT INTO DonationAudit (donation_id, action)
    VALUES (NEW.donation_id, 'Donation Inserted');
END $$

DELIMITER ;

-- Secure donor personal info via filtered views.
CREATE OR REPLACE VIEW PublicDonorInfo AS
SELECT donor_id, donor_name
FROM Donors;

-- project13:
-- 13. Restaurant Table Reservation System
-- Domain: Hospitality
-- Goal: Auto-block tables and log changes
-- Requirements:
create database hospitality;
use hospitality;
-- Tables in the restaurant
CREATE TABLE Tables (
    table_id INT PRIMARY KEY AUTO_INCREMENT,
    capacity INT,
    status VARCHAR(20) DEFAULT 'Available'  -- Available / Reserved / Blocked
);

-- Customer reservations
CREATE TABLE Reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    table_id INT,
    customer_name VARCHAR(100),
    reservation_date DATE,
    reservation_time TIME,
    status VARCHAR(20) DEFAULT 'Reserved', -- Reserved / Cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (table_id) REFERENCES Tables(table_id)
);

-- Audit log for reservation cancellations
CREATE TABLE Reservation_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_id INT,
    action VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
);
INSERT INTO Tables (capacity) VALUES
(2), (4), (4), (6), (8);

-- Use a view to show available tables by time slot.
CREATE OR REPLACE VIEW AvailableTablesView AS
SELECT t.table_id, t.capacity
FROM Tables t
WHERE t.status = 'Available';

-- Create a stored procedure to reserve a table.
DELIMITER $$

CREATE PROCEDURE ReserveTable(
    IN p_table_id INT,
    IN p_customer_name VARCHAR(100),
    IN p_date DATE,
    IN p_time TIME
)
BEGIN
    -- Insert reservation
    INSERT INTO Reservations (table_id, customer_name, reservation_date, reservation_time)
    VALUES (p_table_id, p_customer_name, p_date, p_time);

    -- Update table status
    UPDATE Tables
    SET status = 'Reserved'
    WHERE table_id = p_table_id;
END $$

DELIMITER ;

-- Create a function to check reservation availability.
DELIMITER $$

CREATE FUNCTION IsTableAvailable(p_table_id INT, p_date DATE, p_time TIME)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE count_existing INT;
    SELECT COUNT(*) INTO count_existing
    FROM Reservations
    WHERE table_id = p_table_id
      AND reservation_date = p_date
      AND reservation_time = p_time
      AND status = 'Reserved';

    RETURN count_existing = 0;
END $$

DELIMITER ;

-- Add a trigger to update table status on reservation.
DELIMITER $$

CREATE TRIGGER trg_AfterReservationInsert
AFTER INSERT ON Reservations
FOR EACH ROW
BEGIN
    UPDATE Tables
    SET status = 'Reserved'
    WHERE table_id = NEW.table_id;
END $$

DELIMITER ;

-- Log reservation cancelations in Reservation_Audit.

DELIMITER $$

CREATE TRIGGER trg_AfterReservationCancel
AFTER UPDATE ON Reservations
FOR EACH ROW
BEGIN
    IF NEW.status = 'Cancelled' AND OLD.status <> 'Cancelled' THEN
        INSERT INTO Reservation_Audit (reservation_id, action)
        VALUES (NEW.reservation_id, 'Reservation Cancelled');

        -- Optional: Free the table
        UPDATE Tables
        SET status = 'Available'
        WHERE table_id = NEW.table_id;
    END IF;
END $$

DELIMITER ;

CALL ReserveTable(2, 'John Doe', '2025-07-15', '19:00:00');
SELECT IsTableAvailable(2, '2025-07-15', '19:00:00') AS is_available;
UPDATE Reservations
SET status = 'Cancelled'
WHERE reservation_id = 1;
SELECT * FROM AvailableTablesView;
SELECT * FROM Reservation_Audit;

-- project14:
-- 14. Service Center Workflow Automation
-- Domain: Automobile / IT Services
-- Goal: Track service requests and updates
-- Requirements:
create database servicecenter;
use servicecenter;
-- Table of customers
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Table of technicians
CREATE TABLE Technicians (
    technician_id INT PRIMARY KEY AUTO_INCREMENT,
    tech_name VARCHAR(100),
    specialty VARCHAR(100)
);

-- Table of service requests
CREATE TABLE ServiceRequests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    technician_id INT,
    issue_description TEXT,
    status VARCHAR(20) DEFAULT 'Open', -- Open, In Progress, Closed
    request_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    completion_time DATETIME,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (technician_id) REFERENCES Technicians(technician_id)
);

-- Audit table
CREATE TABLE Service_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    request_id INT,
    action VARCHAR(100),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES ServiceRequests(request_id)
);
-- Customers
INSERT INTO Customers (name, email) VALUES
('Alice Smith', 'alice@example.com'),
('Bob Brown', 'bob@example.com');

-- Technicians
INSERT INTO Technicians (tech_name, specialty) VALUES
('Charlie Tech', 'Electrical'),
('Dana Fixit', 'Mechanical');

-- Service Requests
INSERT INTO ServiceRequests (customer_id, issue_description)
VALUES
(1, 'Car not starting'),
(2, 'Oil leak in engine');

-- Create a view for open vs closed service requests.
CREATE OR REPLACE VIEW RequestStatusView AS
SELECT
    sr.request_id,
    c.name AS customer_name,
    sr.issue_description,
    sr.status,
    sr.request_time,
    sr.completion_time
FROM ServiceRequests sr
JOIN Customers c ON sr.customer_id = c.customer_id
WHERE sr.status IN ('Open', 'Closed');

-- Create a stored procedure to assign a technician.
DELIMITER $$

CREATE PROCEDURE AssignTechnician(
    IN p_request_id INT,
    IN p_technician_id INT
)
BEGIN
    UPDATE ServiceRequests
    SET technician_id = p_technician_id,
        status = 'In Progress'
    WHERE request_id = p_request_id;
END $$

DELIMITER ;
CALL AssignTechnician(1, 1);

-- Create a function to calculate time since request logged.
DELIMITER $$

CREATE FUNCTION TimeSinceRequest(p_request_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE hours_elapsed INT;
    SELECT TIMESTAMPDIFF(HOUR, request_time, NOW())
    INTO hours_elapsed
    FROM ServiceRequests
    WHERE request_id = p_request_id;
    RETURN hours_elapsed;
END $$

DELIMITER ;
SELECT TimeSinceRequest(1);

-- Add a trigger to log completion in Service_Audit.
DELIMITER $$

CREATE TRIGGER trg_AfterServiceCompletion
AFTER UPDATE ON ServiceRequests
FOR EACH ROW
BEGIN
    IF NEW.status = 'Closed' AND OLD.status <> 'Closed' THEN
        INSERT INTO Service_Audit (request_id, action)
        VALUES (NEW.request_id, 'Service Request Closed');
    END IF;
END $$

DELIMITER ;
UPDATE ServiceRequests
SET status = 'Closed', completion_time = NOW()
WHERE request_id = 1;

-- Restrict customers from accessing internal logs via views.
CREATE OR REPLACE VIEW CustomerServiceView AS
SELECT
    sr.request_id,
    sr.issue_description,
    sr.status,
    sr.request_time,
    sr.completion_time
FROM ServiceRequests sr;

-- project15:
-- 15. Event Management System
-- Domain: Corporate / Cultural
-- Goal: Automate participant entry and reports
-- Requirements:
use eventmanagement;
-- Events table
CREATE TABLE Events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    event_name VARCHAR(100),
    event_date DATE,
    event_time TIME,
    location VARCHAR(100),
    internal_notes TEXT
);

-- Participants table
CREATE TABLE Participants (
    participant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    event_id INT,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES Events(event_id)
);

-- Audit table to track participant registrations
CREATE TABLE Registration_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    participant_id INT,
    event_id INT,
    action VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Events (event_name, event_date, event_time, location, internal_notes) VALUES
('Tech Conference', '2025-08-10', '10:00:00', 'Main Hall', 'Internal keynote planning at 9 AM'),
('Art Workshop', '2025-08-12', '14:00:00', 'Room B', 'Supplies delivery check');

-- Use a view to list event schedules (no internal planning).
CREATE OR REPLACE VIEW PublicEventSchedule AS
SELECT event_id, event_name, event_date, event_time, location
FROM Events;

-- Create a stored procedure to register participants.
DELIMITER $$

CREATE PROCEDURE RegisterParticipant(
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_event_id INT
)
BEGIN
    INSERT INTO Participants (name, email, event_id)
    VALUES (p_name, p_email, p_event_id);
END $$

DELIMITER ;
CALL RegisterParticipant('Alice Johnson', 'alice@example.com', 1);

-- Create a function to return total attendees for an event.
DELIMITER $$

CREATE FUNCTION TotalAttendees(p_event_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Participants
    WHERE event_id = p_event_id;
    RETURN total;
END $$

DELIMITER ;
SELECT TotalAttendees(1) AS AttendeeCount;

-- Add a trigger to insert audit records when a user registers.
DELIMITER $$

CREATE TRIGGER trg_AfterParticipantInsert
AFTER INSERT ON Participants
FOR EACH ROW
BEGIN
    INSERT INTO Registration_Audit (participant_id, event_id, action)
    VALUES (NEW.participant_id, NEW.event_id, 'Participant Registered');
END $$

DELIMITER ;
CALL RegisterParticipant('Bob Lee', 'bob@example.com', 1);

-- Use secure views to expose only public event info.
CREATE OR REPLACE VIEW EventPublicInfo AS
SELECT event_id, event_name, event_date, location
FROM Events;

-- project16:
-- 16. Help Desk and Ticket Logger
-- Domain: IT / Customer Support
-- Goal: Manage ticket lifecycle and logs
-- Requirements:
create database helpdesk;
use helpdesk;
-- Agents table
CREATE TABLE Agents (
    agent_id INT PRIMARY KEY AUTO_INCREMENT,
    agent_name VARCHAR(100),
    email VARCHAR(100)
);

-- Tickets table
CREATE TABLE Tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(255),
    description TEXT,
    customer_email VARCHAR(100),
    status VARCHAR(50) DEFAULT 'Open', -- Open, In Progress, Resolved, Closed
    assigned_agent INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    FOREIGN KEY (assigned_agent) REFERENCES Agents(agent_id)
);

-- Ticket status log table
CREATE TABLE Ticket_Status_Log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);
-- Insert agents
INSERT INTO Agents (agent_name, email) VALUES
('Alice Johnson', 'alice@support.com'),
('Bob Smith', 'bob@support.com');

-- Insert tickets
INSERT INTO Tickets (subject, description, customer_email)
VALUES
('Login Issue', 'Cannot log into the account.', 'user1@example.com'),
('Printer Not Working', 'Printer shows paper jam.', 'user2@example.com');

-- Use a view to show open tickets per agent.
CREATE OR REPLACE VIEW OpenTicketsPerAgent AS
SELECT
    a.agent_name,
    t.ticket_id,
    t.subject,
    t.status,
    t.created_at
FROM Tickets t
JOIN Agents a ON t.assigned_agent = a.agent_id
WHERE t.status = 'Open';

-- Create a stored procedure to assign tickets.
DELIMITER $$

CREATE PROCEDURE AssignTicket(
    IN p_ticket_id INT,
    IN p_agent_id INT
)
BEGIN
    UPDATE Tickets
    SET assigned_agent = p_agent_id,
        status = 'In Progress'
    WHERE ticket_id = p_ticket_id;
END $$

DELIMITER ;

-- Create a function to return average resolution time.
DELIMITER $$

CREATE FUNCTION AvgResolutionTime()
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_time DECIMAL(10,2);
    SELECT AVG(TIMESTAMPDIFF(HOUR, created_at, resolved_at))
    INTO avg_time
    FROM Tickets
    WHERE resolved_at IS NOT NULL;
    RETURN avg_time;
END $$

DELIMITER ;
SELECT AvgResolutionTime() AS Avg_Hours_To_Resolve;

-- Add a trigger to log ticket status changes.
DELIMITER $$

CREATE TRIGGER LogTicketStatusChange
BEFORE UPDATE ON Tickets
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO Ticket_Status_Log (ticket_id, old_status, new_status)
        VALUES (OLD.ticket_id, OLD.status, NEW.status);
    END IF;
END $$

DELIMITER ;
UPDATE Tickets
SET status = 'Resolved', resolved_at = NOW()
WHERE ticket_id = 1;

-- Limit data exposure to agents using filtered views.
CREATE OR REPLACE VIEW AgentTicketView AS
SELECT
    ticket_id,
    subject,
    status,
    assigned_agent,
    created_at
FROM Tickets;
-- project17:
-- 17. Transport Booking and Route Manager
-- Domain: Travel / Transport
-- Goal: Automate bookings and route visibility
-- Requirements:
create database transbooking;
use transbooking;
-- Routes Table
CREATE TABLE Routes (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    origin VARCHAR(100),
    destination VARCHAR(100),
    departure_time DATETIME,
    total_seats INT,
    internal_notes TEXT
);

-- Bookings Table
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    route_id INT,
    seats_booked INT,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);

-- Seat Status Table (for tracking available seats)
CREATE TABLE SeatStatus (
    route_id INT PRIMARY KEY,
    available_seats INT,
    FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);
-- Insert routes
INSERT INTO Routes (origin, destination, departure_time, total_seats, internal_notes)
VALUES
('Delhi', 'Mumbai', '2025-07-15 08:00:00', 40, 'Route A-Optimized for speed'),
('Chennai', 'Bangalore', '2025-07-15 10:00:00', 30, 'Alternate via Hosur');

-- Initialize SeatStatus (assuming full availability)
INSERT INTO SeatStatus (route_id, available_seats)
SELECT route_id, total_seats FROM Routes;

-- Use views for customers to view available routes.
CREATE OR REPLACE VIEW AvailableRoutes AS
SELECT 
    route_id,
    origin,
    destination,
    departure_time,
    available_seats
FROM Routes
JOIN SeatStatus USING (route_id);

-- Create a stored procedure to book seats.
DELIMITER $$

CREATE PROCEDURE BookSeats(
    IN p_customer_name VARCHAR(100),
    IN p_route_id INT,
    IN p_seats INT
)
BEGIN
    DECLARE current_avail INT;

    -- Check available seats
    SELECT available_seats INTO current_avail
    FROM SeatStatus WHERE route_id = p_route_id;

    IF current_avail >= p_seats THEN
        -- Insert booking
        INSERT INTO Bookings (customer_name, route_id, seats_booked)
        VALUES (p_customer_name, p_route_id, p_seats);

        -- Update seat availability
        UPDATE SeatStatus
        SET available_seats = available_seats - p_seats
        WHERE route_id = p_route_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough seats available';
    END IF;
END $$

DELIMITER ;
CALL BookSeats('Raj Mehra', 1, 2);

-- Create a function to return seat availability.
DELIMITER $$

CREATE FUNCTION GetSeatAvailability(p_route_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avail INT;
    SELECT available_seats INTO avail
    FROM SeatStatus WHERE route_id = p_route_id;
    RETURN avail;
END $$

DELIMITER ;
SELECT GetSeatAvailability(1) AS Available;

-- Use a trigger to auto-update seat status on booking.
DELIMITER $$

CREATE TRIGGER UpdateSeatStatusAfterBooking
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE SeatStatus
    SET available_seats = available_seats - NEW.seats_booked
    WHERE route_id = NEW.route_id;
END $$

DELIMITER ;

-- Hide internal route optimization using abstraction via views.
CREATE OR REPLACE VIEW RouteSummaryForCustomers AS
SELECT 
    route_id,
    origin,
    destination,
    departure_time
FROM Routes;

-- project18:
-- 18. Online Assessment Tracker
-- Domain: E-learning
-- Goal: Auto-grade and control assessments
-- Requirements:
create database onlineassess;
use onlineassess;
-- Students Table
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100)
);

-- Assessments Table
CREATE TABLE Assessments (
    assessment_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100),
    deadline DATETIME
);

-- AssessmentResults Table
CREATE TABLE AssessmentResults (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    assessment_id INT,
    score INT,
    answer_text TEXT,
    instructor_remarks TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (assessment_id) REFERENCES Assessments(assessment_id)
);
-- Students
INSERT INTO Students (student_name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Assessments
INSERT INTO Assessments (title, deadline) VALUES
('Math Quiz', '2025-07-15 23:59:59'),
('Science Quiz', '2025-07-16 23:59:59');

-- Create a view for students to see scores only (no answers).
CREATE OR REPLACE VIEW StudentScoresView AS
SELECT
    s.student_name,
    a.title AS assessment,
    ar.score
FROM AssessmentResults ar
JOIN Students s ON ar.student_id = s.student_id
JOIN Assessments a ON ar.assessment_id = a.assessment_id;

-- Create a function to calculate grade from score.
DELIMITER $$

CREATE FUNCTION CalculateGrade(score INT)
RETURNS VARCHAR(2)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN score >= 90 THEN 'A'
        WHEN score >= 80 THEN 'B'
        WHEN score >= 70 THEN 'C'
        WHEN score >= 60 THEN 'D'
        ELSE 'F'
    END;
END $$

DELIMITER ;
SELECT CalculateGrade(85);  -- Output: B

-- Create a stored procedure to insert assessment records.
DELIMITER $$

CREATE PROCEDURE SubmitAssessment(
    IN p_student_id INT,
    IN p_assessment_id INT,
    IN p_score INT,
    IN p_answer TEXT
)
BEGIN
    INSERT INTO AssessmentResults (student_id, assessment_id, score, answer_text)
    VALUES (p_student_id, p_assessment_id, p_score, p_answer);
END $$

DELIMITER ;
CALL SubmitAssessment(1, 1, 88, 'Answer content here...');

-- Add a trigger to block changes post grading deadline.
DELIMITER $$

CREATE TRIGGER BlockChangesAfterDeadline
BEFORE UPDATE ON AssessmentResults
FOR EACH ROW
BEGIN
    DECLARE assess_deadline DATETIME;
    SELECT deadline INTO assess_deadline
    FROM Assessments
    WHERE assessment_id = OLD.assessment_id;

    IF NOW() > assess_deadline THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot modify record after grading deadline.';
    END IF;
END $$

DELIMITER ;

-- Secure instructor-only views for answers and remarks.
CREATE OR REPLACE VIEW InstructorAssessmentView AS
SELECT
    s.student_name,
    a.title AS assessment,
    ar.score,
    ar.answer_text,
    ar.instructor_remarks
FROM AssessmentResults ar
JOIN Students s ON ar.student_id = s.student_id
JOIN Assessments a ON ar.assessment_id = a.assessment_id;

-- project19:
-- 19. Insurance Policy Issuance System
-- Domain: Finance / Insurance
-- Goal: Track policy activity and changes
-- Requirements:
create database insystem;
use insystem;
-- Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100)
);

-- Policies table
CREATE TABLE Policies (
    policy_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    policy_type VARCHAR(50),
    coverage_amount DECIMAL(12,2),
    status ENUM('Active', 'Inactive', 'Expired'),
    start_date DATE,
    end_date DATE,
    terms TEXT,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- PolicyAudit table
CREATE TABLE PolicyAudit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    policy_id INT,
    changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_terms TEXT,
    new_terms TEXT
);
INSERT INTO Customers (name, email) VALUES
('John Doe', 'john@example.com'),
('Alice Smith', 'alice@example.com');

-- Create a view to display customer policy status.
CREATE OR REPLACE VIEW CustomerPolicyStatus AS
SELECT
    c.name AS customer_name,
    p.policy_type,
    p.status,
    p.start_date,
    p.end_date
FROM Policies p
JOIN Customers c ON p.customer_id = c.customer_id;

-- Create a stored procedure to issue a new policy.
DELIMITER $$

CREATE PROCEDURE IssuePolicy(
    IN p_customer_id INT,
    IN p_type VARCHAR(50),
    IN p_coverage DECIMAL(12,2),
    IN p_start DATE,
    IN p_end DATE,
    IN p_terms TEXT
)
BEGIN
    INSERT INTO Policies (customer_id, policy_type, coverage_amount, status, start_date, end_date, terms)
    VALUES (p_customer_id, p_type, p_coverage, 'Active', p_start, p_end, p_terms);
END $$

DELIMITER ;
CALL IssuePolicy(1, 'Health', 500000, '2025-07-15', '2030-07-15', 'Basic coverage terms apply...');

-- Create a function to check active policies per customer.
DELIMITER $$

CREATE FUNCTION ActivePolicyCount(p_customer_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE count_active INT;
    SELECT COUNT(*) INTO count_active
    FROM Policies
    WHERE customer_id = p_customer_id AND status = 'Active';
    RETURN count_active;
END $$

DELIMITER ;
SELECT ActivePolicyCount(1);

-- Add a trigger to log modifications to policy terms.
DELIMITER $$

CREATE TRIGGER LogPolicyTermChange
BEFORE UPDATE ON Policies
FOR EACH ROW
BEGIN
    IF OLD.terms <> NEW.terms THEN
        INSERT INTO PolicyAudit (policy_id, old_terms, new_terms)
        VALUES (OLD.policy_id, OLD.terms, NEW.terms);
    END IF;
END $$

DELIMITER ;

-- Use views to expose only allowed details to different roles.
-- View for customers (no terms or internal fields)
CREATE OR REPLACE VIEW PublicPolicyView AS
SELECT
    c.name,
    p.policy_type,
    p.status,
    p.start_date,
    p.end_date
FROM Policies p
JOIN Customers c ON p.customer_id = c.customer_id;

-- View for admins (full access)
CREATE OR REPLACE VIEW AdminPolicyView AS
SELECT
    c.name,
    p.policy_type,
    p.coverage_amount,
    p.status,
    p.start_date,
    p.end_date,
    p.terms,
    p.last_modified
FROM Policies p
JOIN Customers c ON p.customer_id = c.customer_id;

-- project20:
-- ✅ 20. Real Estate Property Listing Portal
-- Domain: Property Tech
-- Goal: Filtered, optimized listing access
-- Requirements:
create database realestate1;
use realestate1;
-- Owners Table
CREATE TABLE Owners (
    owner_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Properties Table
CREATE TABLE Properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT,
    address VARCHAR(255),
    location VARCHAR(100),
    price DECIMAL(12,2),
    status ENUM('Available', 'Sold', 'Pending'),
    listed_on DATE,
    FOREIGN KEY (owner_id) REFERENCES Owners(owner_id)
);

-- Visits Table
CREATE TABLE PropertyVisits (
    visit_id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT,
    visitor_name VARCHAR(100),
    visit_date DATE,
    contact_info VARCHAR(100),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id)
);

-- ListingAudit Table
CREATE TABLE ListingAudit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT,
    change_type VARCHAR(50),
    old_value TEXT,
    new_value TEXT,
    changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Owners (name, phone, email) VALUES
('Alice Kumar', '9876543210', 'alice@domain.com'),
('Bob Mehta', '9988776655', 'bob@domain.com');

INSERT INTO Properties (owner_id, address, location, price, status, listed_on) VALUES
(1, '12 MG Road, Bangalore', 'Bangalore', 9500000, 'Available', '2025-07-01'),
(2, '77 Park Street, Kolkata', 'Kolkata', 7500000, 'Sold', '2025-06-15');

-- Use a view to show only available properties to clients.
CREATE OR REPLACE VIEW AvailablePropertiesView AS
SELECT 
    p.property_id,
    p.address,
    p.location,
    p.price,
    p.status
FROM Properties p
WHERE p.status = 'Available';

-- Create a stored procedure to schedule property visits.
DELIMITER $$

CREATE PROCEDURE ScheduleVisit (
    IN p_property_id INT,
    IN p_visitor_name VARCHAR(100),
    IN p_visit_date DATE,
    IN p_contact_info VARCHAR(100)
)
BEGIN
    INSERT INTO PropertyVisits (property_id, visitor_name, visit_date, contact_info)
    VALUES (p_property_id, p_visitor_name, p_visit_date, p_contact_info);
END $$

DELIMITER ;
CALL ScheduleVisit(1, 'John Client', '2025-07-12', 'john@example.com');

-- Create a function to return count of listings by location.
DELIMITER $$

CREATE FUNCTION ListingsByLocation(p_location VARCHAR(100))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE listing_count INT;
    SELECT COUNT(*) INTO listing_count
    FROM Properties
    WHERE location = p_location;
    RETURN listing_count;
END $$

DELIMITER ;
SELECT ListingsByLocation('Bangalore');

-- Add a trigger to log listing changes (price, status).
DELIMITER $$

CREATE TRIGGER LogListingChanges
BEFORE UPDATE ON Properties
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO ListingAudit (property_id, change_type, old_value, new_value)
        VALUES (OLD.property_id, 'Price Change', OLD.price, NEW.price);
    END IF;

    IF OLD.status <> NEW.status THEN
        INSERT INTO ListingAudit (property_id, change_type, old_value, new_value)
        VALUES (OLD.property_id, 'Status Change', OLD.status, NEW.status);
    END IF;
END $$

DELIMITER ;

-- Filter sensitive owner info in public-facing views.
 CREATE OR REPLACE VIEW PublicPropertyView AS
SELECT 
    p.property_id,
    p.address,
    p.location,
    p.price,
    p.status
FROM Properties p
WHERE p.status = 'Available';




























