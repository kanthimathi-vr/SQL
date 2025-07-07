-- project 1
-- 1. Employee Performance Analyzer
-- Scenario: An HR manager wants to evaluate employee performance.
-- Requirements:
-- Create Employees, Departments, and Salaries tables.
-- Insert employee records using INSERT INTO (single and multiple rows).

create database sql_monday;
use sql_monday;
-- Departments Table
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

-- Employees Table
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    performance_score INT,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Salaries Table
CREATE TABLE Salaries (
    salary_id INT PRIMARY KEY,
    employee_id INT,
    salary DECIMAL(10, 2),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
-- Insert into Departments
INSERT INTO Departments (department_id, department_name)
VALUES
(1, 'Engineering'),
(2, 'Sales'),
(3, 'HR');

-- Insert into Employees (multiple rows)
INSERT INTO Employees (employee_id, name, department_id, performance_score)
VALUES
(101, 'Alice', 1, 92),
(102, 'Bob', 2, 88),
(103, 'Charlie', 1, 75),
(104, 'Diana', 3, 95),
(105, 'Evan', 2, 60);

-- Insert into Salaries (single and multiple)
INSERT INTO Salaries (salary_id, employee_id, salary)
VALUES
(201, 101, 95000.00),
(202, 102, 70000.00),
(203, 103, 80000.00),
(204, 104, 72000.00),
(205, 105, 50000.00);

-- Use SELECT, WHERE, and ORDER BY to retrieve and sort high-performing employees.
-- Get employees with performance > 85, ordered by score
SELECT E.name, D.department_name, E.performance_score
FROM Employees E
JOIN Departments D ON E.department_id = D.department_id
WHERE E.performance_score > 85
ORDER BY E.performance_score DESC;

-- Use GROUP BY with AVG(salary) to get department-wise averages.
-- Avg salary per department
SELECT D.department_name, AVG(S.salary) AS avg_salary
FROM Employees E
JOIN Salaries S ON E.employee_id = S.employee_id
JOIN Departments D ON E.department_id = D.department_id
GROUP BY D.department_name;

-- Use CASE WHEN to classify salaries as High, Medium, Low.
-- Salary classification
SELECT E.name, S.salary,
  CASE
    WHEN S.salary >= 90000 THEN 'High'
    WHEN S.salary >= 70000 THEN 'Medium'
    ELSE 'Low'
  END AS salary_level
FROM Employees E
JOIN Salaries S ON E.employee_id = S.employee_id;

-- Update salaries using UPDATE, and rollback changes if the update fails (use transactions).

-- Assume a 10% salary increase for high performers (score >= 90)

START TRANSACTION;

-- Update statement
UPDATE Salaries
SET salary = salary * 1.10
WHERE employee_id IN (
  SELECT employee_id FROM Employees WHERE performance_score >= 90
);

-- Simulate a possible error (uncomment to test rollback)
-- RAISE ERROR 'Test error'; -- only supported in some DBs like SQL Server

-- If no error, commit
COMMIT;

-- If error occurs, use:
-- ROLLBACK;
-- project2
-- 2. Online Course Enrollment Report
-- Scenario: An education platform tracks enrollments and grades.
-- Requirements:
-- Tables: Students, Courses, Enrollments, Grades.
-- Students Table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Courses Table
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
);

-- Enrollments Table (linking students to courses)
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- Grades Table (score must be >= 0)
CREATE TABLE Grades (
    grade_id INT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL CHECK (score >= 0),
    FOREIGN KEY (enrollment_id) REFERENCES Enrollments(enrollment_id)
);
-- Enforce NOT NULL, CHECK (score >= 0) constraints.
-- Insert student and enrollment data.
-- Insert Students
INSERT INTO Students (student_id, name)
VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana'),
(5, 'Evan');

-- Insert Courses
INSERT INTO Courses (course_id, course_name)
VALUES
(101, 'Math'),
(102, 'Science'),
(103, 'History');

-- Insert Enrollments
INSERT INTO Enrollments (enrollment_id, student_id, course_id)
VALUES
(201, 1, 101),
(202, 2, 101),
(203, 3, 101),
(204, 4, 102),
(205, 5, 103),
(206, 1, 102),
(207, 2, 103),
(208, 3, 103),
(209, 4, 101),
(210, 5, 101),
(211, 2, 102),
(212, 3, 102);

-- Insert Grades
INSERT INTO Grades (grade_id, enrollment_id, score)
VALUES
(301, 201, 85),
(302, 202, 78),
(303, 203, 92),
(304, 204, 88),
(305, 205, 67),
(306, 206, 91),
(307, 207, 72),
(308, 208, 95),
(309, 209, 80),
(310, 210, 75),
(311, 211, 65),
(312, 212, 89);

-- Use JOIN to combine student and course data.
SELECT S.name AS student_name, C.course_name, G.score
FROM Students S
JOIN Enrollments E ON S.student_id = E.student_id
JOIN Courses C ON E.course_id = C.course_id
JOIN Grades G ON E.enrollment_id = G.enrollment_id;

-- Use subqueries to get students who scored above the average in each course.
SELECT S.name, C.course_name, G.score
FROM Students S
JOIN Enrollments E ON S.student_id = E.student_id
JOIN Courses C ON E.course_id = C.course_id
JOIN Grades G ON E.enrollment_id = G.enrollment_id
WHERE G.score > (
    SELECT AVG(G2.score)
    FROM Enrollments E2
    JOIN Grades G2 ON E2.enrollment_id = G2.enrollment_id
    WHERE E2.course_id = C.course_id
);

-- Use GROUP BY, HAVING to show courses with more than 10 enrollments.
SELECT C.course_name, COUNT(*) AS total_enrollments
FROM Enrollments E
JOIN Courses C ON E.course_id = C.course_id
GROUP BY C.course_name
HAVING COUNT(*) > 2;



-- project3
-- 3. Retail Order Summary Dashboard
-- Scenario: The sales team wants a daily report of orders.
-- Requirements:
-- Tables: Customers, Orders, OrderItems, Products.
-- Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

-- Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- OrderItems Table
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Insert multiple orders and products.
-- Insert Customers
INSERT INTO Customers (customer_id, customer_name)
VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

-- Insert Products
INSERT INTO Products (product_id, product_name, price)
VALUES
(101, 'Laptop', 1200.00),
(102, 'Mouse', 25.00),
(103, 'Keyboard', 45.00),
(104, 'Monitor', 200.00);

-- Insert Orders
INSERT INTO Orders (order_id, customer_id, order_date)
VALUES
(201, 1, '2025-07-06'),
(202, 2, '2025-07-06'),
(203, 1, '2025-07-07'),
(204, 3, '2025-07-07');

-- Insert Order Items
INSERT INTO OrderItems (order_item_id, order_id, product_id, quantity)
VALUES
(301, 201, 101, 1),
(302, 201, 102, 2),
(303, 202, 103, 1),
(304, 203, 104, 2),
(305, 204, 102, 3),
(306, 204, 103, 1);

-- Use joins to generate complete order summaries.
SELECT 
    O.order_id,
    O.order_date,
    C.customer_name,
    P.product_name,
    OI.quantity,
    P.price,
    (OI.quantity * P.price) AS total_price
FROM Orders O
JOIN Customers C ON O.customer_id = C.customer_id
JOIN OrderItems OI ON O.order_id = OI.order_id
JOIN Products P ON OI.product_id = P.product_id
ORDER BY O.order_date, C.customer_name;

-- Use SUM(), COUNT(), GROUP BY to calculate total sales per day.
SELECT 
    O.order_date,
    SUM(OI.quantity * P.price) AS total_sales,
    COUNT(DISTINCT O.order_id) AS total_orders
FROM Orders O
JOIN OrderItems OI ON O.order_id = OI.order_id
JOIN Products P ON OI.product_id = P.product_id
GROUP BY O.order_date
ORDER BY O.order_date;

-- Use subqueries to identify best-selling products.
-- Find product(s) with the highest total quantity sold
SELECT product_name, total_quantity
FROM (
    SELECT 
        P.product_name,
        SUM(OI.quantity) AS total_quantity,
        RANK() OVER (ORDER BY SUM(OI.quantity) DESC) AS rnk
    FROM OrderItems OI
    JOIN Products P ON OI.product_id = P.product_id
    GROUP BY P.product_name
) ranked
WHERE rnk = 1;

-- Use DISTINCT, ORDER BY on customer names and order dates.
-- List unique customer names and their order dates, sorted
SELECT DISTINCT C.customer_name, O.order_date
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
ORDER BY C.customer_name, O.order_date;

-- project4:
-- 4. Library Borrowing Management System
-- Scenario: A librarian needs to track borrowed and returned books.
-- Requirements:
-- Tables: Books, Members, BorrowRecords.
-- Books Table
CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    total_copies INT NOT NULL CHECK (total_copies >= 0),
    available_copies INT NOT NULL CHECK (available_copies >= 0)
);

-- Members Table
CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL
);

-- BorrowRecords Table
CREATE TABLE BorrowRecords (
    record_id INT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);

-- Insert book and member data.
-- Insert Books
INSERT INTO Books (book_id, title, total_copies, available_copies)
VALUES
(1, '1984', 5, 3),
(2, 'To Kill a Mockingbird', 3, 0),
(3, 'The Great Gatsby', 2, 1);

-- Insert Members
INSERT INTO Members (member_id, member_name)
VALUES
(101, 'Alice'),
(102, 'Bob'),
(103, 'Charlie');

-- Insert Borrow Records
INSERT INTO BorrowRecords (record_id, book_id, member_id, borrow_date, return_date)
VALUES
(1001, 1, 101, '2025-07-01', '2025-07-05'),
(1002, 2, 102, '2025-07-02', NULL),  -- not yet returned
(1003, 1, 103, '2025-07-03', NULL);  -- not yet returned

-- Use BETWEEN to filter borrow dates in a specific range.
-- Get all borrow records from July 1 to July 3, 2025
SELECT R.record_id, M.member_name, B.title, R.borrow_date
FROM BorrowRecords R
JOIN Members M ON R.member_id = M.member_id
JOIN Books B ON R.book_id = B.book_id
WHERE R.borrow_date BETWEEN '2025-07-01' AND '2025-07-03';

-- Use IS NULL to find overdue books (no return date).
-- Books that have been borrowed but not returned yet
SELECT R.record_id, M.member_name, B.title, R.borrow_date
FROM BorrowRecords R
JOIN Members M ON R.member_id = M.member_id
JOIN Books B ON R.book_id = B.book_id
WHERE R.return_date IS NULL;

-- Use transactions to record borrowing and rollback if the book is unavailable.
-- Sample logic (for MySQL/PostgreSQL style transaction)

START TRANSACTION;

-- Check availability (this would typically be in application logic)
SELECT available_copies FROM Books WHERE book_id = 2;

-- Update availability if available
UPDATE Books
SET available_copies = available_copies - 1
WHERE book_id = 2 AND available_copies > 0;

-- Check if the update actually affected a row
-- If not, rollback
-- (This is application logic; here we simulate the check)

-- Insert into BorrowRecords (assuming book was available)
INSERT INTO BorrowRecords (record_id, book_id, member_id, borrow_date, return_date)
VALUES (1004, 2, 103, '2025-07-07', NULL);

COMMIT;

-- If update fails (e.g. available_copies = 0), then do:
-- ROLLBACK;

-- project5
-- 5. Hospital Appointment & Doctor Tracker
-- Scenario: Admin wants to monitor doctor-patient interactions.
-- Requirements:
-- Tables: Doctors, Patients, Appointments.
-- Doctors Table
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL
);

-- Patients Table
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL
);

-- Appointments Table
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    doctor_id INT NOT NULL,
    patient_id INT NOT NULL,
    appointment_date timestamp NOT NULL ,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);
-- Insert Doctors
INSERT INTO Doctors (doctor_id, doctor_name, specialization)
VALUES
(1, 'Dr. Smith', 'Cardiology'),
(2, 'Dr. Taylor', 'Neurology'),
(3, 'Dr. Adams', 'Pediatrics');

-- Insert Patients
INSERT INTO Patients (patient_id, patient_name)
VALUES
(101, 'Alice Johnson'),
(102, 'Bob Carter'),
(103, 'Charlie Dean'),
(104, 'Diana Ellis');

-- Insert Appointments
INSERT INTO Appointments (appointment_id, doctor_id, patient_id, appointment_date)
VALUES
(1001, 1, 101, '2025-07-07'),
(1002, 2, 102, '2025-07-08'),
(1003, 1, 103, '2025-07-09'),
(1004, 3, 104, '2025-07-07'),
(1005, 1, 104, '2025-07-10');


-- Use JOIN to display doctor schedules.
SELECT 
    A.appointment_id,
    D.doctor_name,
    D.specialization,
    P.patient_name,
    A.appointment_date
FROM Appointments A
JOIN Doctors D ON A.doctor_id = D.doctor_id
JOIN Patients P ON A.patient_id = P.patient_id
ORDER BY A.appointment_date;

-- Use WHERE with LIKE to search patients by name.
-- Search for patients with name containing "Ali"
SELECT * FROM Patients
WHERE patient_name LIKE '%Ali%';

-- Use GROUP BY and COUNT() to find doctors with the most patients.
SELECT 
    D.doctor_name,
    COUNT(DISTINCT A.patient_id) AS total_patients
FROM Appointments A
JOIN Doctors D ON A.doctor_id = D.doctor_id
GROUP BY D.doctor_name
ORDER BY total_patients DESC;

-- Add CHECK constraint for valid appointment dates.
-- Use UPDATE to reschedule and DELETE for cancellations.
-- Reschedule appointment 1002 to a new date
UPDATE Appointments
SET appointment_date = '2025-07-11'
WHERE appointment_id = 1002;
-- Cancel appointment 1005
DELETE FROM Appointments
WHERE appointment_id = 1005;
-- project6
-- 6. Bank Transaction Verifier
-- Scenario: A bank wants to ensure transaction consistency.
-- Requirements:
-- Tables: Accounts, Transactions.
-- Accounts Table
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL,
    balance DECIMAL(12, 2) NOT NULL CHECK (balance >= 0)
);

-- Transactions Table
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

-- Insert multiple records using INSERT.
-- Insert Accounts
INSERT INTO Accounts (account_id, account_holder, balance)
VALUES
(1, 'Alice', 5000.00),
(2, 'Bob', 3000.00);

-- Insert Transactions
INSERT INTO Transactions (transaction_id, account_id, transaction_type, amount)
VALUES
(1001, 1, 'debit', 200.00),
(1002, 1, 'credit', 500.00),
(1003, 2, 'debit', 150.00),
(1004, 2, 'credit', 300.00);

-- Use CHECK (amount > 0) and NOT NULL constraints.
-- Use JOIN, SUM() to get total debits/credits per account.
SELECT 
    A.account_id,
    A.account_holder,
    SUM(CASE WHEN T.transaction_type = 'debit' THEN T.amount ELSE 0 END) AS total_debits,
    SUM(CASE WHEN T.transaction_type = 'credit' THEN T.amount ELSE 0 END) AS total_credits
FROM Accounts A
JOIN Transactions T ON A.account_id = T.account_id
GROUP BY A.account_id, A.account_holder;

-- Use transactions (SAVEPOINT, ROLLBACK) to simulate a transfer.
START TRANSACTION;

-- Savepoint before any change
SAVEPOINT before_transfer;

-- Step 1: Deduct from Alice (Account 1)
UPDATE Accounts
SET balance = balance - 1000
WHERE account_id = 1;

-- Check Alice's balance (simulate logic in app; assume if < 0, rollback)
-- Optionally enforce: SELECT balance FROM Accounts WHERE account_id = 1;

-- Step 2: Credit Bob (Account 2)
UPDATE Accounts
SET balance = balance + 1000
WHERE account_id = 2;

-- Log the transactions
INSERT INTO Transactions (transaction_id, account_id, transaction_type, amount)
VALUES
(1005, 1, 'debit', 1000.00),
(1006, 2, 'credit', 1000.00);

-- Simulate an error (uncomment to test rollback)
-- ROLLBACK TO before_transfer;

-- If all good:
COMMIT;
-- project7:
-- 7. E-Commerce Refund and Payment System
-- Scenario: You need to process order refunds safely.
-- Requirements:
-- Tables: Orders, Refunds, Payments.
-- Orders Table

CREATE TABLE Orders1 (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(20) NOT NULL CHECK (order_status IN ('completed', 'cancelled'))
);

-- Payments Table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Refunds Table
CREATE TABLE Refunds (
    refund_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    refund_date DATE NOT NULL,
    refund_amount DECIMAL(10, 2) NOT NULL,
    refund_reason VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);
-- Orders
INSERT INTO Orders1 (order_id, customer_id, order_date, total_amount, order_status)
VALUES
(1, 101, '2025-07-01', 250.00, 'completed'),
(2, 102, '2025-07-02', 120.00, 'completed'),
(3, 103, '2025-07-03', 450.00, 'cancelled');
SELECT * FROM Orders;

SET FOREIGN_KEY_CHECKS=0;

INSERT INTO Payments (payment_id, order_id, payment_date, amount, payment_method)
VALUES
(201, 1, '2025-07-01', 250.00, 'credit_card'),
(202, 2, '2025-07-02', 120.00, 'paypal'),
(203, 3, '2025-07-03', 450.00, 'bank_transfer');

SET FOREIGN_KEY_CHECKS=1;

-- Refunds (initially only 1)
INSERT INTO Refunds (refund_id, order_id, refund_date, refund_amount, refund_reason)
VALUES
(301, 3, '2025-07-05', 450.00, 'Order cancelled');

-- Use DELETE to cancel an order and insert into the Refunds table in one transaction.
START TRANSACTION;

-- 1. Check if order is eligible (done in app logic or subquery)
-- 2. Update order status instead of deleting (recommended for audit trail)
UPDATE Orders1
SET order_status = 'cancelled'
WHERE order_id = 2;

-- 3. Insert refund record
INSERT INTO Refunds (refund_id, order_id, refund_date, refund_amount, refund_reason)
VALUES (302, 2, '2025-07-07', 120.00, 'Customer request');

COMMIT;

-- Use subqueries to check if an order is eligible for refund.
-- Orders eligible for refund: completed and not already refunded
SELECT order_id
FROM Orders1
WHERE order_status = 'completed'
AND order_id NOT IN (SELECT order_id FROM Refunds);

-- Use JOIN to get complete refund summaries.
SELECT 
    R.refund_id,
    O.order_id,
    O.customer_id,
    O.order_date,
    R.refund_date,
    R.refund_amount,
    R.refund_reason,
    P.payment_method
FROM Refunds R
JOIN Orders1 O ON R.order_id = O.order_id
JOIN Payments P ON O.order_id = P.order_id
ORDER BY R.refund_date;

-- Use CASE to categorize refund reasons.
SELECT 
    refund_id,
    order_id,
    refund_reason,
    CASE
        WHEN refund_reason LIKE '%cancelled%' THEN 'System Cancelled'
        WHEN refund_reason LIKE '%request%' THEN 'Customer Initiated'
        WHEN refund_reason IS NULL THEN 'Unknown'
        ELSE 'Other'
    END AS refund_category
FROM Refunds;
-- project8:
-- 8. Warehouse Stock Movement System
-- Scenario: Monitor stock movement and maintain item counts.
-- Requirements:
-- Tables: Products, Inward, Outward, StockLevels.
CREATE TABLE Products1 (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL
);

CREATE TABLE Inward (
    inward_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    inward_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Outward (
    outward_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    outward_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE StockLevels (
    product_id INT PRIMARY KEY,
    stock_count INT NOT NULL CHECK (stock_count >= 0),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
INSERT INTO Products1(product_id, product_name) VALUES
(1, 'Widget A'),
(2, 'Gadget B');

SET FOREIGN_KEY_CHECKS=0;
INSERT INTO Inward (inward_id, product_id, quantity, inward_date) VALUES
(101, 1, 100, '2025-07-01'),
(102, 2, 200, '2025-07-01');
SET FOREIGN_KEY_CHECKS=1;
INSERT INTO Outward (outward_id, product_id, quantity, outward_date) VALUES
(201, 1, 30, '2025-07-02'),
(202, 2, 50, '2025-07-02');

-- Initialize StockLevels with net stock (can be 0 initially)
INSERT INTO StockLevels (product_id, stock_count) VALUES
(1, 70), -- 100 inward - 30 outward
(2, 150); -- 200 inward - 50 outward

-- Use GROUP BY with SUM() to calculate net stock.
SELECT
    p.product_id,
    p.product_name,
    COALESCE(SUM(i.quantity), 0) AS total_inward,
    COALESCE(SUM(o.quantity), 0) AS total_outward,
    COALESCE(SUM(i.quantity), 0) - COALESCE(SUM(o.quantity), 0) AS net_stock
FROM Products1 p
LEFT JOIN Inward i ON p.product_id = i.product_id
LEFT JOIN Outward o ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name;

-- Use JOIN to display product stock with movement history.
SELECT
    p.product_id,
    p.product_name,
    sl.stock_count,
    COALESCE(i.total_inward, 0) AS total_inward,
    COALESCE(o.total_outward, 0) AS total_outward
FROM Products p
LEFT JOIN StockLevels sl ON p.product_id = sl.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_inward FROM Inward GROUP BY product_id
) i ON p.product_id = i.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_outward FROM Outward GROUP BY product_id
) o ON p.product_id = o.product_id;

-- Use HAVING to find items with negative stock (potential errors).
SELECT
    product_id,
    SUM(quantity_in) - SUM(quantity_out) AS net_stock
FROM (
    SELECT product_id, quantity AS quantity_in, 0 AS quantity_out FROM Inward
    UNION ALL
    SELECT product_id, 0, quantity FROM Outward
) AS movements
GROUP BY product_id
HAVING net_stock < 0;

-- Update stock based on movement and rollback if there's inconsistency.

START TRANSACTION;

-- Suppose we want to record an outward movement of product_id = 1, quantity = 80

-- 1. Insert Outward record
INSERT INTO Outward (outward_id, product_id, quantity, outward_date)
VALUES (204, 1, 80, CURDATE());

-- 2. Update StockLevels (subtract the outward quantity)
UPDATE StockLevels
SET stock_count = stock_count - 80
WHERE product_id = 1;

-- 3. Check stock count after update
SELECT stock_count INTO @new_stock FROM StockLevels WHERE product_id = 1;

-- 4. Rollback if stock is negative
-- (In MySQL, control flow in plain SQL is limited, so this check usually happens in app or procedure)

-- Here is how you could do it in a stored procedure or a script:
-- If @new_stock < 0 then rollback else commit

-- Manual check (run this after update):
SELECT @new_stock AS updated_stock;

-- For demonstration, do this in your app or use a procedure like below:

-- If stock negative, rollback:
-- ROLLBACK;

-- Else commit:
-- COMMIT;

-- project9:
-- 9. Student Marks & Rank Processing System
-- Scenario: Prepare a result summary with rankings.
-- Requirements:
-- Tables: Students, Subjects, Marks.
create database stumarks;
use stumarks;
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

CREATE TABLE Subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);

CREATE TABLE Marks (
    mark_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    score INT NOT NULL CHECK (score >= 0 AND score <= 100),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id)
);

INSERT INTO Students (student_id, student_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO Subjects (subject_id, subject_name) VALUES
(101, 'Math'),
(102, 'Science'),
(103, 'English');

INSERT INTO Marks (mark_id, student_id, subject_id, score) VALUES
(1, 1, 101, 85),
(2, 1, 102, 90),
(3, 1, 103, 78),
(4, 2, 101, 88),
(5, 2, 102, 76),
(6, 2, 103, 95),
(7, 3, 101, 70),
(8, 3, 102, 80),
(9, 3, 103, 65);

-- Use JOIN and GROUP BY to get total marks.
SELECT
    s.student_id,
    s.student_name,
    SUM(m.score) AS total_marks
FROM Students s
JOIN Marks m ON s.student_id = m.student_id
GROUP BY s.student_id, s.student_name
ORDER BY total_marks DESC;

-- Use subqueries or RANK() (if available) for ranking.
SELECT
    s.student_id,
    s.student_name,
    SUM(m.score) AS total_marks,
    CASE
        WHEN SUM(m.score) >= 270 THEN 'A'
        WHEN SUM(m.score) >= 240 THEN 'B'
        WHEN SUM(m.score) >= 210 THEN 'C'
        ELSE 'D'
    END AS grade,
    RANK() OVER (ORDER BY SUM(m.score) DESC) AS rnk
FROM Students s
JOIN Marks m ON s.student_id = m.student_id
GROUP BY s.student_id, s.student_name
ORDER BY rnk;

-- Use CASE for grades based on mark ranges.
SELECT
    s.student_id,
    s.student_name,
    totals.total_marks,
    CASE
        WHEN totals.total_marks >= 270 THEN 'A'
        WHEN totals.total_marks >= 240 THEN 'B'
        WHEN totals.total_marks >= 210 THEN 'C'
        ELSE 'D'
    END AS grade,
    (
        SELECT COUNT(DISTINCT total_marks) 
        FROM (
            SELECT SUM(score) AS total_marks
            FROM Marks
            GROUP BY student_id
        ) AS sub
        WHERE sub.total_marks >= totals.total_marks
    ) AS rnk
FROM Students s
JOIN (
    SELECT student_id, SUM(score) AS total_marks
    FROM Marks
    GROUP BY student_id
) totals ON s.student_id = totals.student_id
ORDER BY rnk;

-- Enforce constraints to prevent invalid scores.

-- project10:
-- 10. Customer Loyalty Points System
-- Scenario: Reward customers based on purchase behavior.
-- Requirements:
-- Tables: Customers, Purchases, Points.
create database customerloyalty;
use customerloyalty;
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE Purchases (
    purchase_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Points (
    points_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    points_earned INT NOT NULL CHECK (points_earned >= 0),
    earned_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO Customers (customer_id, customer_name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

INSERT INTO Purchases (purchase_id, customer_id, purchase_date, amount) VALUES
(101, 1, '2025-07-01', 500.00),
(102, 2, '2025-07-02', 150.00),
(103, 1, '2025-07-03', 200.00),
(104, 3, '2025-07-04', 700.00);

-- Use SUM(), GROUP BY to compute total spending.
SELECT
    c.customer_id,
    c.customer_name,
    SUM(p.amount) AS total_spent,
    CASE
        WHEN SUM(p.amount) >= 1000 THEN 'Platinum'
        WHEN SUM(p.amount) >= 500 THEN 'Gold'
        WHEN SUM(p.amount) >= 200 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_level
FROM Customers c
LEFT JOIN Purchases p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- Use CASE to categorize loyalty levels.
-- Use subqueries to find the top spender of the month.
SELECT customer_id, customer_name, total_spent FROM (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(p.amount) AS total_spent
    FROM Customers c
    JOIN Purchases p ON c.customer_id = p.customer_id
    WHERE p.purchase_date BETWEEN '2025-07-01' AND '2025-07-31'
    GROUP BY c.customer_id, c.customer_name
) AS monthly_totals
ORDER BY total_spent DESC
LIMIT 1;

-- Insert points earned with transactions for consistency.
START TRANSACTION;

INSERT INTO Points (points_id, customer_id, points_earned, earned_date)
SELECT
    NULL,  -- assuming auto-increment or generate unique ID another way
    c.customer_id,
    FLOOR(SUM(p.amount) / 10) AS points_earned,
    CURDATE()
FROM Customers c
JOIN Purchases p ON c.customer_id = p.customer_id
WHERE p.purchase_date = CURDATE()
GROUP BY c.customer_id;

COMMIT;
-- project11:
-- 11. University Course Capacity Tracker
-- Scenario: Manage student limits in each course.
-- Requirements:


create database university1;
use university1;
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    max_capacity INT NOT NULL CHECK (max_capacity > 0)
);

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    UNIQUE(student_id, course_id) -- prevent duplicate enrollments
);
INSERT INTO Courses (course_id, course_name, max_capacity) VALUES
(1, 'Math 101', 2),
(2, 'History 201', 3);

INSERT INTO Students (student_id, student_name) VALUES
(101, 'Alice'),
(102, 'Bob'),
(103, 'Charlie'),
(104, 'David');

-- Use CHECK or a controlled procedure to limit max enrollments.
SELECT
    c.course_id,
    c.course_name,
    c.max_capacity,
    COUNT(e.student_id) AS enrolled_students
FROM Courses c
LEFT JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name, c.max_capacity;

-- Use JOIN, COUNT() to check how many students per course.
SELECT
    c.course_id,
    c.course_name,
    COUNT(e.student_id) AS enrolled_students
FROM Courses c
LEFT JOIN Enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY enrolled_students DESC;

-- project12:
-- 12. Hotel Room Reservation and Cancellation
-- Scenario: Ensure room availability and maintain records.
-- Requirements:
-- Tables: Rooms, Customers, Bookings.
create database hotel1;
use hotel1;
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL,
    room_type VARCHAR(50)
);
INSERT INTO Rooms (room_id, room_number, room_type) VALUES
(1, '101', 'Single'),
(2, '102', 'Double'),
(3, '103', 'Suite');

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);
INSERT INTO Customers (customer_id, customer_name) VALUES
(1, 'Alice Johnson'),
(2, 'Bob Smith'),
(3, 'Charlie Davis');

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    room_id INT NOT NULL,
    customer_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Confirmed',
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (end_date >= start_date)
);
INSERT INTO Bookings (room_id, customer_id, start_date, end_date, status) VALUES
(1, 1, '2025-07-01', '2025-07-05', 'Confirmed'),
(2, 2, '2025-07-03', '2025-07-07', 'Confirmed'),
(3, 3, '2025-07-08', '2025-07-10', 'Confirmed');

-- Use INSERT INTO with validation logic.
-- Use BETWEEN for booking dates.
SELECT *
FROM Bookings
WHERE start_date BETWEEN '2025-07-01' AND '2025-07-10';

-- Use subqueries to find overlapping bookings.
SELECT DISTINCT room_id
FROM Bookings
WHERE NOT (end_date < @desired_start OR start_date > @desired_end);

-- Use DELETE and rollback for cancellations.
START TRANSACTION;

DELETE FROM Bookings
WHERE booking_id = 101;

-- If deletion is successful:
COMMIT;

-- If something fails, rollback:
-- ROLLBACK;

-- Use CASE to tag booking status.
SELECT
    booking_id,
    room_id,
    customer_id,
    start_date,
    end_date,
    status,
    CASE
        WHEN CURDATE() < start_date THEN 'Upcoming'
        WHEN CURDATE() BETWEEN start_date AND end_date THEN 'Ongoing'
        WHEN CURDATE() > end_date THEN 'Completed'
        ELSE 'Unknown'
    END AS booking_status
FROM Bookings;


-- Use subqueries to block over-capacity courses.
SELECT course_id
FROM (
    SELECT
        c.course_id,
        COUNT(e.student_id) AS enrolled_students,
        c.max_capacity
    FROM Courses c
    LEFT JOIN Enrollments e ON c.course_id = e.course_id
    GROUP BY c.course_id, c.max_capacity
) AS course_counts
WHERE enrolled_students >= max_capacity;

-- project13:
-- 13. Doctor Specialty Filter System
-- Scenario: Patients need to find doctors by expertise.
-- Requirements:
create database doctor;
use doctor;
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100),
    specialty VARCHAR(100),
    availability BOOLEAN DEFAULT TRUE
);
INSERT INTO Doctors (doctor_id, doctor_name, specialty, availability) VALUES
(101, 'Dr. Alice Brown', 'Cardiology', TRUE),
(102, 'Dr. Bob Green', 'Neurology', TRUE),
(103, 'Dr. Carol White', 'Cardiothoracic Surgery', TRUE),
(104, 'Dr. David Black', 'Dermatology', TRUE);

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100)
);
INSERT INTO Patients (patient_id, patient_name) VALUES
(201, 'John Doe'),
(202, 'Jane Smith'),
(203, 'Emily Johnson'),
(204, 'Michael Lee');


CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT,
    patient_id INT,
    appointment_date DATE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);
INSERT INTO Appointments (doctor_id, patient_id, appointment_date) VALUES
(101, 201, '2025-07-01'),
(101, 202, '2025-07-02'),
(102, 203, '2025-07-01'),
(103, 204, '2025-07-03'),
(101, 203, '2025-07-04'),
(104, 201, '2025-07-05');

-- Use LIKE to filter by specialty name.
SELECT doctor_id, doctor_name, specialty
FROM Doctors
WHERE specialty LIKE '%cardio%';

-- Use GROUP BY to count patients by each doctor.
SELECT
    d.doctor_id,
    d.doctor_name,
    COUNT(DISTINCT a.patient_id) AS patient_count
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name;

-- Use HAVING to find overloaded doctors.
SELECT
    d.doctor_id,
    d.doctor_name,
    COUNT(DISTINCT a.patient_id) AS patient_count
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.doctor_name
HAVING patient_count > 20;

-- Insert and update doctor availability using transactions.
START TRANSACTION;

UPDATE Doctors
SET availability = FALSE
WHERE doctor_id = 101;

-- if everything is fine
COMMIT;

-- otherwise
-- ROLLBACK;
-- project14:
-- 14. Complaint and Ticketing System
-- Scenario: Support team needs to manage user complaints.
-- Requirements:
-- Tables: Tickets, Users, Responses.
create database tickets;
use tickets;
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL
);
INSERT INTO Users (user_id, user_name) VALUES
(1, 'Alice Johnson'),
(2, 'Bob Smith'),
(3, 'Charlie Davis');

CREATE TABLE Tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    issue_description TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Open',
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
INSERT INTO Tickets (user_id, issue_description, created_at, status) VALUES
(1, 'Cannot log into my account.', '2025-07-01 09:15:00', 'Open'),
(2, 'Payment not processed correctly.', '2025-07-02 14:30:00', 'In Progress'),
(3, 'App crashes on startup.', '2025-07-03 11:00:00', 'Closed');


CREATE TABLE Responses (
    response_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    responder_name VARCHAR(100) NOT NULL,
    response_text TEXT NOT NULL,
    response_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);
INSERT INTO Responses (ticket_id, responder_name, response_text, response_date) VALUES
(1, 'SupportAgent1', 'Please try resetting your password.', '2025-07-01 10:00:00'),
(2, 'SupportAgent2', 'We are checking your payment details.', '2025-07-02 15:00:00'),
(3, 'SupportAgent3', 'Update the app to the latest version.', '2025-07-03 12:00:00'),
(3, 'Charlie Davis', 'Updated and working fine now.', '2025-07-04 08:00:00');

-- Use JOIN to view full complaint and resolution history.
SELECT
    t.ticket_id,
    u.user_name,
    t.issue_description,
    t.created_at,
    t.status,
    r.responder_name,
    r.response_text,
    r.response_date
FROM Tickets t
JOIN Users u ON t.user_id = u.user_id
LEFT JOIN Responses r ON t.ticket_id = r.ticket_id
ORDER BY t.ticket_id, r.response_date;

-- Use ORDER BY and BETWEEN to filter by time.
SELECT *
FROM Tickets
WHERE created_at BETWEEN '2025-06-01' AND '2025-07-01'
ORDER BY created_at DESC;

-- Use INSERT with transactions for batch reply updates.
START TRANSACTION;

INSERT INTO Responses (ticket_id, responder_name, response_text, response_date) VALUES
(1, 'SupportAgent1', 'We are looking into your issue.', NOW()),
(2, 'SupportAgent2', 'Please provide more details.', NOW()),
(1, 'SupportAgent1', 'Issue resolved, please check.', NOW());

COMMIT;

-- Use CASE to display ticket status.
SELECT
    ticket_id,
    issue_description,
    status,
    CASE
        WHEN status = 'Open' THEN 'Pending'
        WHEN status = 'In Progress' THEN 'Being Worked On'
        WHEN status = 'Closed' THEN 'Resolved'
        ELSE 'Unknown Status'
    END AS status_label
FROM Tickets;

-- project15:
-- 15. Transport Route and Booking Analyzer
-- Scenario: Admin needs a report on most booked routes.
-- Requirements:
-- Tables: Routes, Buses, Bookings.
CREATE TABLE Routes (
    route_id INT PRIMARY KEY,
    origin VARCHAR(100),
    destination VARCHAR(100)
);
INSERT INTO Routes (route_id, origin, destination) VALUES
(1, 'New York', 'Boston'),
(2, 'Los Angeles', 'San Francisco'),
(3, 'Chicago', 'Detroit');

CREATE TABLE Buses (
    bus_id INT PRIMARY KEY,
    bus_number VARCHAR(20),
    route_id INT,
    availability BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);
INSERT INTO Buses (bus_id, bus_number, route_id, availability) VALUES
(101, 'NY-BOS-001', 1, TRUE),
(102, 'LA-SF-002', 2, TRUE),
(103, 'CHI-DET-003', 3, TRUE);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    bus_id INT,
    route_id INT,
    passenger_name VARCHAR(100),
    booking_date DATE,
    FOREIGN KEY (bus_id) REFERENCES Buses(bus_id),
    FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);
INSERT INTO Bookings (bus_id, route_id, passenger_name, booking_date) VALUES
(101, 1, 'John Doe', '2025-07-01'),
(101, 1, 'Jane Smith', '2025-07-01'),
(102, 2, 'Alice Johnson', '2025-07-02'),
(103, 3, 'Bob Lee', '2025-07-03'),
(101, 1, 'Charlie Brown', '2025-07-04'),
(102, 2, 'Diana Prince', '2025-07-05');

-- Use subqueries to find most booked route.
SELECT route_id, COUNT(*) AS booking_count
FROM Bookings
GROUP BY route_id
HAVING booking_count = (
    SELECT MAX(route_bookings) FROM (
        SELECT COUNT(*) AS route_bookings
        FROM Bookings
        GROUP BY route_id
    ) AS route_counts
);

-- Use GROUP BY, COUNT() for route-wise bookings.
SELECT
    route_id,
    COUNT(*) AS total_bookings
FROM Bookings
GROUP BY route_id
ORDER BY total_bookings DESC;

-- Use JOIN to get full booking summary.
SELECT
    b.booking_id,
    b.passenger_name,
    b.booking_date,
    r.origin,
    r.destination,
    bus.bus_number
FROM Bookings b
JOIN Routes r ON b.route_id = r.route_id
JOIN Buses bus ON b.bus_id = bus.bus_id
ORDER BY b.booking_date DESC;

-- Use DELETE for cancelled trips and rollback if bus is not available.
START TRANSACTION;

-- Check if bus is available
SELECT availability FROM Buses WHERE bus_id = 101 FOR UPDATE;

-- Suppose you get availability = TRUE, proceed
DELETE FROM Bookings WHERE booking_id = 500;

-- If no issues:
COMMIT;

-- If bus unavailable or error:
-- ROLLBACK;
-- project16:
-- ✅ 16. Sales Incentive Processor
-- Scenario: Calculate bonuses based on sales volume.
-- Requirements:
-- Tables: Salespeople, Sales, Bonuses.
create database sales;
use sales;
CREATE TABLE Salespeople (
    salesperson_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    salesperson_id INT,
    sale_amount DECIMAL(10,2),
    sale_date DATE,
    FOREIGN KEY (salesperson_id) REFERENCES Salespeople(salesperson_id)
);

CREATE TABLE Bonuses (
    bonus_id INT PRIMARY KEY AUTO_INCREMENT,
    salesperson_id INT,
    bonus_amount DECIMAL(10,2),
    bonus_tier VARCHAR(20),
    FOREIGN KEY (salesperson_id) REFERENCES Salespeople(salesperson_id)
);

-- Salespeople
INSERT INTO Salespeople (salesperson_id, name) VALUES
(1, 'Alice Johnson'),
(2, 'Bob Smith'),
(3, 'Charlie Davis');

-- Sales
INSERT INTO Sales (salesperson_id, sale_amount, sale_date) VALUES
(1, 5000.00, '2025-06-01'),
(1, 7000.00, '2025-06-15'),
(2, 3000.00, '2025-06-03'),
(2, 3500.00, '2025-06-20'),
(3, 8000.00, '2025-06-10'),
(3, 9000.00, '2025-06-25');

-- Use CASE to assign bonus tiers.
START TRANSACTION;

-- Clear previous bonuses
DELETE FROM Bonuses;

-- Insert new bonuses based on total sales per salesperson
INSERT INTO Bonuses (salesperson_id, bonus_amount, bonus_tier)
SELECT
    salesperson_id,
    total_sales * 0.10 AS bonus_amount,
    CASE
        WHEN total_sales >= 12000 THEN 'Gold'
        WHEN total_sales >= 8000 THEN 'Silver'
        ELSE 'Bronze'
    END AS bonus_tier
FROM (
    SELECT salesperson_id, SUM(sale_amount) AS total_sales
    FROM Sales
    GROUP BY salesperson_id
) AS sales_summary;

-- Verify all salespeople have bonuses
-- Example check (replace with appropriate logic in your environment)
SELECT COUNT(*) INTO @bonus_count FROM Bonuses;
SELECT COUNT(*) INTO @salespeople_count FROM Salespeople;

-- Rollback if bonus counts don’t match salespeople count (meaning some missing data)
-- This is a simplified example, adjust logic as needed
-- IF @bonus_count <> @salespeople_count THEN
--     ROLLBACK;
-- ELSE
--     COMMIT;
-- END IF;

-- Use SUM() and AVG() to analyze sales data.
SELECT
    salesperson_id,
    SUM(sale_amount) AS total_sales,
    AVG(sale_amount) AS average_sale
FROM Sales
GROUP BY salesperson_id;

-- Use transactions to update bonus and rollback if sales data is incomplete.
START TRANSACTION;

-- Delete old bonuses
DELETE FROM Bonuses;

-- Insert bonuses based on sales summary
INSERT INTO Bonuses (salesperson_id, bonus_amount, bonus_tier)
SELECT
    salesperson_id,
    total_sales * 0.10 AS bonus_amount,
    CASE
        WHEN total_sales >= 12000 THEN 'Gold'
        WHEN total_sales >= 8000 THEN 'Silver'
        ELSE 'Bronze'
    END AS bonus_tier
FROM (
    SELECT salesperson_id, SUM(sale_amount) AS total_sales
    FROM Sales
    GROUP BY salesperson_id
) AS sales_summary;

-- Check for salespeople without sales (no bonus inserted)
SELECT COUNT(*) INTO @missing_bonuses FROM Salespeople s
LEFT JOIN Bonuses b ON s.salesperson_id = b.salesperson_id
WHERE b.salesperson_id IS NULL;

-- Rollback if any salesperson missing a bonus (meaning no sales)
-- IF @missing_bonuses > 0 THEN
--     ROLLBACK;
--     SELECT 'Rollback: Some salespeople have no sales, bonuses not updated.' AS Message;
-- ELSE
--     COMMIT;
--     SELECT 'Bonuses updated successfully.' AS Message;
-- END IF;
-- project17:
-- 17. Insurance Claim Verification System
-- Scenario: Claims should be processed only with verified documents.
-- Requirements:
create database insurance;
use insurance;
CREATE TABLE Policies (
    policy_id INT PRIMARY KEY,
    policy_holder VARCHAR(100),
    policy_type VARCHAR(50)
);

CREATE TABLE Claims (
    claim_id INT PRIMARY KEY,
    policy_id INT,
    claim_amount DECIMAL(10, 2) CHECK (claim_amount <= 100000), -- max claim threshold
    claim_date DATE,
    document_verified BOOLEAN,
    document_submitted BOOLEAN,
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);
INSERT INTO Policies (policy_id, policy_holder, policy_type) VALUES
(1, 'John Doe', 'Health'),
(2, 'Jane Smith', 'Auto'),
(3, 'Alice Johnson', 'Home');

INSERT INTO Claims (claim_id, policy_id, claim_amount, claim_date, document_verified, document_submitted) VALUES
(101, 1, 25000, '2025-07-01', TRUE, TRUE),
(102, 1, 15000, '2025-07-10', FALSE, TRUE),
(103, 2, 50000, '2025-07-05', TRUE, TRUE),
(104, 2, 110000, '2025-07-12', TRUE, TRUE), -- Over max claim amount, should be rejected by CHECK
(105, 3, 30000, '2025-07-08', FALSE, FALSE); -- Missing docs


-- Use IS NULL to find missing documents.
SELECT * FROM Claims
WHERE document_submitted = FALSE OR document_verified = FALSE;

-- Use JOIN to display full claim info.
SELECT
    c.claim_id,
    p.policy_holder,
    p.policy_type,
    c.claim_amount,
    c.claim_date,
    c.document_verified,
    c.document_submitted
FROM Claims c
JOIN Policies p ON c.policy_id = p.policy_id;

-- Use subqueries to find the average claim per policy.
SELECT
    policy_id,
    AVG(claim_amount) AS average_claim_amount
FROM Claims
GROUP BY policy_id;

SELECT
    p.policy_id,
    p.policy_holder,
    avg_claims.average_claim_amount
FROM Policies p
JOIN (
    SELECT policy_id, AVG(claim_amount) AS average_claim_amount
    FROM Claims
    GROUP BY policy_id
) avg_claims ON p.policy_id = avg_claims.policy_id;

-- Use CHECK to prevent claim amount over a certain threshold.
INSERT INTO Claims (claim_id, policy_id, claim_amount, claim_date, document_verified, document_submitted)
VALUES (106, 1, 150000, '2025-07-15', TRUE, TRUE);
-- Error: violates CHECK constraint claim_amount <= 100000

-- project 18:
-- 18. Daily Sales Comparison Report
-- Scenario: Marketing team compares today's vs. yesterday's sales.
-- Requirements:
create database dailysales;
use dailysales;
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100)
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    sale_date DATE,
    quantity_sold INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
-- Products
INSERT INTO Products (product_id, product_name) VALUES
(1, 'Laptop'),
(2, 'Smartphone'),
(3, 'Headphones');
SELECT * FROM Products;


-- Sales for Today (e.g., 2025-07-07)
INSERT INTO Sales (product_id, sale_date, quantity_sold) VALUES
(1, '2025-07-07', 15),
(2, '2025-07-07', 20),
(3, '2025-07-07', 5);
SELECT p.product_name, s.sale_date, s.quantity_sold
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
ORDER BY s.sale_date;

-- Sales for Yesterday (2025-07-06)
INSERT INTO Sales (product_id, sale_date, quantity_sold) VALUES
(1, '2025-07-06', 10),
(2, '2025-07-06', 25),
(3, '2025-07-06', 5);


-- Use DATE_SUB() to get yesterday's data.
-- Use subqueries or joins to compare totals.
-- Use CASE to show increase, decrease, or no change.
-- Sort products by sales delta using ORDER BY.
SELECT
    p.product_name,
    COALESCE(today.total_today, 0) AS today_sales,
    COALESCE(yesterday.total_yesterday, 0) AS yesterday_sales,
    (COALESCE(today.total_today, 0) - COALESCE(yesterday.total_yesterday, 0)) AS sales_delta,
    CASE
        WHEN COALESCE(today.total_today, 0) > COALESCE(yesterday.total_yesterday, 0) THEN 'Increase'
        WHEN COALESCE(today.total_today, 0) < COALESCE(yesterday.total_yesterday, 0) THEN 'Decrease'
        ELSE 'No Change'
    END AS trend
FROM Products p
LEFT JOIN (
    SELECT product_id, SUM(quantity_sold) AS total_today
    FROM Sales
    WHERE sale_date = CURRENT_DATE()
    GROUP BY product_id
) today ON p.product_id = today.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity_sold) AS total_yesterday
    FROM Sales
    WHERE sale_date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    GROUP BY product_id
) yesterday ON p.product_id = yesterday.product_id
ORDER BY sales_delta DESC;

-- project19:
-- 19. Multi-Store Product Consistency Checker
-- Scenario: Ensure product records are consistent across all branches.
-- Requirements:
create database multistore;
use multistore;
CREATE TABLE Products_Master (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE StoreA_Inventory (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE StoreB_Inventory (
    product_id INT,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);
-- Master product list
INSERT INTO Products_Master VALUES
(1, 'Laptop', 1200.00),
(2, 'Smartphone', 800.00),
(3, 'Headphones', 150.00);

-- Store A
INSERT INTO StoreA_Inventory VALUES
(1, 'Laptop', 1200.00),
(2, 'Smartphone', 820.00), -- mismatched price
(3, 'Headphones', 150.00),
(4, 'Tablet', 500.00); -- extra product

-- Store B
INSERT INTO StoreB_Inventory VALUES
(1, 'Laptop', 1200.00),
(2, 'Smartphone', 800.00),
(3, 'Headphones', 150.00),
(5, 'Mouse', 50.00); -- extra product

-- Use UNION, INTERSECT, and EXCEPT to compare inventories.
SELECT DISTINCT product_id, product_name FROM StoreA_Inventory
UNION
SELECT DISTINCT product_id, product_name FROM StoreB_Inventory;
SELECT product_id, product_name
FROM StoreA_Inventory
WHERE product_id IN (
    SELECT product_id FROM StoreB_Inventory
);
SELECT product_id, product_name
FROM StoreA_Inventory
WHERE product_id NOT IN (
    SELECT product_id FROM StoreB_Inventory
);

-- Use joins to merge store data.
SELECT
    a.product_id,
    a.product_name AS store_a_name,
    b.product_name AS store_b_name,
    a.price AS store_a_price,
    b.price AS store_b_price
FROM StoreA_Inventory a
LEFT JOIN StoreB_Inventory b ON a.product_id = b.product_id;

-- Use DISTINCT and GROUP BY to detect duplicates.
SELECT product_id, COUNT(*) AS count
FROM StoreA_Inventory
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Update incorrect entries using UPDATE and transaction blocks.
START TRANSACTION;

-- Check mismatch
SELECT * FROM StoreA_Inventory WHERE product_id = 2;

-- Fix price to match master
UPDATE StoreA_Inventory
SET price = (SELECT price FROM Products_Master WHERE product_id = 2)
WHERE product_id = 2;

-- Optional validation before committing
SELECT * FROM StoreA_Inventory WHERE product_id = 2;

COMMIT;
-- project20:
-- 20. Online Examination Result Portal
-- Scenario: Display results, ranks, and pass/fail status.
-- Requirements:
-- Tables: Candidates, Exams, Results.

create database onlineexam;
use onlineexam;
CREATE TABLE Candidates (
    candidate_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Exams (
    exam_id INT PRIMARY KEY,
    subject VARCHAR(100),
    max_marks INT
);

CREATE TABLE Results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_id INT,
    exam_id INT,
    marks_obtained INT,
    FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id)
);
-- Candidates
INSERT INTO Candidates VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Exams
INSERT INTO Exams VALUES
(101, 'Mathematics', 100),
(102, 'Science', 100);

-- Results (for Mathematics only in this example)
INSERT INTO Results (candidate_id, exam_id, marks_obtained) VALUES
(1, 101, 90),
(2, 101, 70),
(3, 101, 85),
(4, 101, 60);

-- Use JOIN to display candidate and score info.
SELECT
    c.name AS candidate_name,
    e.subject,
    r.marks_obtained,
    e.max_marks
FROM Results r
JOIN Candidates c ON r.candidate_id = c.candidate_id
JOIN Exams e ON r.exam_id = e.exam_id;

-- Use subqueries to calculate percentile.
SELECT
    r.candidate_id,
    c.name,
    r.marks_obtained,
    (
        SELECT ROUND(
            100 * (COUNT(*) - 1) / (SELECT COUNT(*) FROM Results r2 WHERE r2.exam_id = 101),
            2
        )
        FROM Results r1
        WHERE r1.exam_id = 101 AND r1.marks_obtained < r.marks_obtained
    ) AS percentile
FROM Results r
JOIN Candidates c ON r.candidate_id = c.candidate_id
WHERE r.exam_id = 101;

-- Use CASE to assign pass/fail.
SELECT
    c.name,
    r.marks_obtained,
    CASE
        WHEN r.marks_obtained >= 40 THEN 'Pass'
        ELSE 'Fail'
    END AS result_status
FROM Results r
JOIN Candidates c ON r.candidate_id = c.candidate_id
WHERE r.exam_id = 101;

-- Use ORDER BY for rank display.
SELECT
    c.name,
    r.marks_obtained,
    RANK() OVER (ORDER BY r.marks_obtained DESC) AS rnk
FROM Results r
JOIN Candidates c ON r.candidate_id = c.candidate_id
WHERE r.exam_id = 101
ORDER BY marks_obtained DESC;
