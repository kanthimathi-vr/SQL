-- Project1:

## 1. Employee Management System
## Domain: HR
## Description: Manage employee data, departments, and salaries.
-- Key Features:
CREATE DATABASE EmployeeSystem;
USE EmployeeSystem;

-- Create Employees and Departments tables using PRIMARY KEY, FOREIGN KEY, NOT NULL, CHECK, and UNIQUE.
-- Departments table
CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- Employees table
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    department_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id) ON DELETE SET NULL,
    CHECK (salary >= 5000)
);

-- Use INSERT INTO to add employee data.
INSERT INTO Departments (department_name)
VALUES ('HR'), ('IT'), ('Finance');

INSERT INTO Employees (name, email, department_id, salary)
VALUES
('Alice', 'alice@company.com', 1, 6000),
('Bob', 'bob@company.com', 2, 7000),
('Charlie', 'charlie@company.com', 2, 8000);

-- Use UPDATE to change departments and salary.
-- Change Bob's department to Finance
UPDATE Employees
SET department_id = 3
WHERE name = 'Bob';

-- Give Alice a raise
UPDATE Employees
SET salary = 6500
WHERE name = 'Alice';

-- Use DELETE to remove resigned employees.
DELETE FROM Employees
WHERE name = 'Charlie';

-- Perform joins to get employee and department data.

SELECT
    e.name AS employee_name,
    e.email,
    d.department_name,
    e.salary
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id;

-- Use GROUP BY to calculate department-wise average salary.
SELECT
    d.department_name,
    AVG(e.salary) AS avg_salary
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- Use TRANSACTIONS for batch salary updates with SAVEPOINT, ROLLBACK, COMMIT.
START TRANSACTION;

UPDATE Employees
SET salary = salary + 500
WHERE name = 'Alice';

SAVEPOINT after_alice;

UPDATE Employees
SET salary = salary + 1000
WHERE name = 'Bob';

ROLLBACK TO SAVEPOINT after_alice;

COMMIT;

-- Project2:

## 2. Student Course Registration System
## Domain: Education
## Description: Track students, courses, and enrollments.
CREATE DATABASE StudentCourseSystem;
USE StudentCourseSystem;

-- Key Features:
-- Students, Courses, Enrollments tables with relationships.
-- Students table
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Courses table
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits BETWEEN 1 AND 6)
);

-- Enrollments table
CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    UNIQUE (student_id, course_id) -- Prevent duplicate enrollments
);
-- Use INSERT INTO for student and course registration.
-- Insert students
INSERT INTO Students (name, email)
VALUES ('Ananya Sharma', 'ananya@example.edu'),
       ('Ravi Kumar', 'ravi@example.edu');

-- Insert courses
INSERT INTO Courses (course_name, credits)
VALUES ('Database Systems', 4),
       ('Operating Systems', 3);
       
ALTER TABLE Enrollments
MODIFY enrollment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

INSERT INTO Enrollments (student_id, course_id, enrollment_date)
VALUES
  (1, 1, CURDATE()),
  (1, 2, CURDATE());

-- Use JOIN to show student-course mapping.
SELECT
    s.name AS student_name,
    c.course_name,
    e.enrollment_date
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id;

-- Use DISTINCT, WHERE, BETWEEN, LIKE for filtering.
-- Students enrolled in 'Database Systems'
SELECT DISTINCT s.name
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE c.course_name = 'Database Systems';

-- Courses with 2–5 credits
SELECT * FROM Courses
WHERE credits BETWEEN 2 AND 5;

-- Students with name like 'R%'
SELECT * FROM Students
WHERE name LIKE 'R%';

-- Aggregate course registrations with COUNT(), GROUP BY.
SELECT
    c.course_name,
    COUNT(e.student_id) AS student_count
FROM Enrollments e
JOIN Courses c ON e.course_id = c.course_id
GROUP BY c.course_name;

-- Handle enrollment failures with TRANSACTIONS.
START TRANSACTION;

INSERT INTO Enrollments (student_id, course_id) VALUES (2, 1);

SAVEPOINT after_first_enrollment;

INSERT INTO Enrollments (student_id, course_id) VALUES (2, 999);

ROLLBACK TO SAVEPOINT after_first_enrollment;

COMMIT;

-- Project3:

## 3. Online Shopping Platform Database
## Domain: E-Commerce
## Description: Track customers, orders, and products.
## Key Features:
CREATE DATABASE OnlineShoppingPlatform;
USE OnlineShoppingPlatform;

-- Create tables: Customers, Products, Orders, OrderItems.
-- Use constraints for IDs, stock checks.\
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    UNIQUE (order_id, product_id) -- prevent duplicate product entries in an order
);

INSERT INTO Customers (name, email) VALUES
('John Doe', 'john.doe@example.com'),
('Jane Smith', 'jane.smith@example.com'),
('Alice Johnson', 'alice.johnson@example.com');

INSERT INTO Products (product_name, price, stock) VALUES
('Wireless Mouse', 25.99, 100),
('Mechanical Keyboard', 89.50, 50),
('USB-C Charger', 19.99, 200),
('27-inch Monitor', 249.00, 30),
('Noise Cancelling Headphones', 129.99, 40);

INSERT INTO Orders (customer_id, order_date) VALUES
(1, '2025-07-01'),
(2, '2025-07-02'),
(1, '2025-07-03');

INSERT INTO OrderItems (order_id, product_id, quantity) VALUES
(1, 1, 2),  
(1, 3, 1),  
(2, 2, 1),
(2, 5, 1),  
(3, 4, 1);

-- Use JOINs to get customer order details.
SELECT
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    p.price,
    (oi.quantity * p.price) AS item_total
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id;

-- Use SUM() for order totals.
SELECT
    o.order_id,
    c.name AS customer_name,
    SUM(oi.quantity * p.price) AS order_total
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
GROUP BY o.order_id, c.name;

-- Filter products by price range (BETWEEN), availability (IS NOT NULL), etc.
-- Products priced between $10 and $100 and in stock
SELECT * FROM Products
WHERE price BETWEEN 10 AND 100
AND stock > 0;

-- Products with stock NOT NULL and greater than zero
SELECT * FROM Products
WHERE stock IS NOT NULL AND stock > 0;

-- Implement FULL OUTER JOIN to show orders with and without items.
SELECT
    o.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.quantity
FROM Orders o
LEFT JOIN OrderItems oi ON o.order_id = oi.order_id

UNION

SELECT
    o.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.quantity
FROM Orders o
RIGHT JOIN OrderItems oi ON o.order_id = oi.order_id;

-- Use subqueries to get top-selling products.
SELECT
    p.product_id,
    p.product_name,
    total_sold
FROM Products p
JOIN (
    SELECT product_id, SUM(quantity) AS total_sold
    FROM OrderItems
    GROUP BY product_id
) sales ON p.product_id = sales.product_id
ORDER BY total_sold DESC
LIMIT 5;

-- Project4:

## 4. Library Management System
## Domain: Education
## Description: Manage books, members, and borrow/return records.
-- Key Features:
CREATE DATABASE LibraryManageSystem;
USE LibraryManageSystem;

-- Tables: Books, Members, BorrowRecords.
-- Use CHECK for due dates.
-- Books table
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100),
    total_copies INT NOT NULL CHECK (total_copies >= 0)
);

-- Members table
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- BorrowRecords table
CREATE TABLE BorrowRecords (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    CHECK (due_date >= borrow_date)
);

-- Insert borrow records and update return status.
INSERT INTO Books (title, author, total_copies) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 5),
('1984', 'George Orwell', 3),
('To Kill a Mockingbird', 'Harper Lee', 4);

-- Insert members
INSERT INTO Members (name, email) VALUES
('Ananya Sharma', 'ananya@example.com'),
('Ravi Kumar', 'ravi@example.com');

-- Insert borrow records
INSERT INTO BorrowRecords (book_id, member_id, borrow_date, due_date)
VALUES
(1, 1, '2025-07-01', '2025-07-15'),
(2, 2, '2025-07-03', '2025-07-17');

-- Member returns a book
UPDATE BorrowRecords
SET return_date = '2025-07-10'
WHERE record_id = 1;
-- Use JOIN to show which member has which book.
SELECT
    m.name AS member_name,
    b.title AS book_title,
    br.borrow_date,
    br.due_date,
    br.return_date
FROM BorrowRecords br
JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id;

-- Use CASE WHEN to label books as "Available", "Borrowed".
SELECT
    b.book_id,
    b.title,
    b.total_copies,
    (b.total_copies - IFNULL(active_borrows.borrowed, 0)) AS available_copies,
    CASE
        WHEN IFNULL(active_borrows.borrowed, 0) = 0 THEN 'Available'
        ELSE 'Borrowed'
    END AS status
FROM Books b
LEFT JOIN (
    SELECT book_id, COUNT(*) AS borrowed
    FROM BorrowRecords
    WHERE return_date IS NULL
    GROUP BY book_id
) AS active_borrows ON b.book_id = active_borrows.book_id;

-- Aggregate borrowed books by member.
SELECT
    m.name,
    COUNT(br.book_id) AS total_borrowed
FROM Members m
JOIN BorrowRecords br ON m.member_id = br.member_id
GROUP BY m.member_id;

-- Use subqueries to identify the most borrowed book.
SELECT
    b.title,
    borrow_count
FROM Books b
JOIN (
    SELECT book_id, COUNT(*) AS borrow_count
    FROM BorrowRecords
    GROUP BY book_id
    ORDER BY borrow_count DESC
    LIMIT 1
) AS most_borrowed ON b.book_id = most_borrowed.book_id;

-- Project5:

## 5. Sales and Inventory System
## Domain: Retail
## Description: Manage inventory and sales transactions.
CREATE DATABASE SalesInventorySystem;
USE SalesInventorySystem;

-- Key Features:
-- Tables: Products, Sales, SalesItems.
-- Products table
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock INT NOT NULL CHECK (stock >= 0)
);

-- Sales table
CREATE TABLE Sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_date DATE NOT NULL,
    customer_name VARCHAR(100) NOT NULL
);

-- SalesItems table
CREATE TABLE SalesItems (
    sale_item_id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (sale_id) REFERENCES Sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- INSERT, UPDATE to maintain stock.
INSERT INTO Products (product_name, category, price, stock) VALUES
('Shampoo', 'Personal Care', 120.00, 100),
('Toothpaste', 'Personal Care', 80.00, 150),
('Rice 5kg', 'Grocery', 300.00, 200),
('Smartphone', 'Electronics', 15000.00, 20),
('Bluetooth Speaker', 'Electronics', 2500.00, 40);

-- Sales (invoices)
INSERT INTO Sales (sale_date, customer_name) VALUES
('2025-07-01', 'Amit Singh'),
('2025-07-02', 'Priya Rao');

-- SalesItems
INSERT INTO SalesItems (sale_id, product_id, quantity) VALUES
(1, 1, 2),  
(1, 3, 1),  
(2, 4, 1),  
(2, 5, 2);  

UPDATE Products SET stock = stock - 2 WHERE product_id = 1;
UPDATE Products SET stock = stock - 1 WHERE product_id = 3;
UPDATE Products SET stock = stock - 1 WHERE product_id = 4;
UPDATE Products SET stock = stock - 2 WHERE product_id = 5;

-- Use ORDER BY with multiple columns (price, category).
SELECT * FROM Products
ORDER BY category ASC, price DESC;

-- Use HAVING to filter categories with total sales > ₹1 lakh.
SELECT
    p.category,
    SUM(si.quantity * p.price) AS category_sales
FROM SalesItems si
JOIN Products p ON si.product_id = p.product_id
GROUP BY p.category
HAVING category_sales > 50000;

-- GROUP BY to see sales by product and category.
SELECT
    p.category,
    p.product_name,
    SUM(si.quantity * p.price) AS total_sales
FROM SalesItems si
JOIN Products p ON si.product_id = p.product_id
GROUP BY p.category, p.product_name;

-- Use transactions for invoice generation.
START TRANSACTION;

INSERT INTO Sales (sale_date, customer_name)
VALUES (CURDATE(), 'Karan Mehta');
SET @sale_id = LAST_INSERT_ID();

INSERT INTO SalesItems (sale_id, product_id, quantity)
VALUES
(@sale_id, 2, 3),
(@sale_id, 3, 1);  

UPDATE Products SET stock = stock - 3 WHERE product_id = 2;
UPDATE Products SET stock = stock - 1 WHERE product_id = 3;

COMMIT;

-- Project6:

## 6. Banking and Account System
## Domain: Finance
## Description: Track accounts, customers, and transactions.
-- Key Features:
CREATE DATABASE BankingAccountSystem;
USE BankingAccountSystem;

-- Tables: Customers, Accounts, Transactions.
-- CHECK (balance >= 0) constraint.
-- Customers table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Accounts table
CREATE TABLE Accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_type ENUM('Savings', 'Checking') NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

-- Transactions table
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer') NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id) ON DELETE CASCADE
);

-- Use INSERT INTO for deposits/withdrawals.
INSERT INTO Customers (name, email) VALUES
('Rahul Mehta', 'rahul@example.com'),
('Sita Iyer', 'sita@example.com');

INSERT INTO Accounts (customer_id, account_type, balance) VALUES
(1, 'Savings', 50000.00),
(2, 'Checking', 80000.00);

INSERT INTO Transactions (account_id, transaction_type, amount)
VALUES (1, 'Deposit', 10000);

UPDATE Accounts SET balance = balance + 10000 WHERE account_id = 1;

INSERT INTO Transactions (account_id, transaction_type, amount)
VALUES (2, 'Withdrawal', 5000);

UPDATE Accounts SET balance = balance - 5000 WHERE account_id = 2;

-- Use subqueries to find customers with highest balance.
SELECT c.name, a.balance
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
WHERE a.balance = (
    SELECT MAX(balance) FROM Accounts
);

-- Use TRANSACTIONS to simulate fund transfers.
START TRANSACTION;

UPDATE Accounts SET balance = balance - 7000 WHERE account_id = 2;

UPDATE Accounts SET balance = balance + 7000 WHERE account_id = 1;

INSERT INTO Transactions (account_id, transaction_type, amount)
VALUES (2, 'Transfer', 7000);

INSERT INTO Transactions (account_id, transaction_type, amount)
VALUES (1, 'Transfer', 7000);

COMMIT;

-- Project7:

## 7. Hospital Patient Record System
## Domain: Healthcare
## Description: Track doctors, patients, and appointments.
-- Key Features:
CREATE DATABASE HospitalPatientRecord;
USE HospitalPatientRecord;

-- Tables: Patients, Doctors, Appointments.
-- Patients Table
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(15) NOT NULL
);

-- Doctors Table
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL
);

-- Appointments Table
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    status ENUM('Upcoming', 'Completed', 'Cancelled') DEFAULT 'Upcoming',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE CASCADE
);

-- Insert and manage appointment records.
INSERT INTO Patients (name, contact) VALUES
('Aarav Patel', '9876543210'),
('Meera Singh', '9123456789');

INSERT INTO Doctors (name, specialization) VALUES
('Dr. Neha Verma', 'Cardiologist'),
('Dr. Arjun Rao', 'Dermatologist');

INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status) VALUES
(1, 1, '2025-07-06', 'Upcoming'),
(2, 2, '2025-07-01', 'Completed'),
(1, 2, '2025-07-03', 'Cancelled');

-- Use JOINs to connect patients with doctors.
SELECT
    a.appointment_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    d.specialization,
    a.appointment_date,
    a.status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

-- Filter appointments with WHERE, LIKE, and BETWEEN.
-- All appointments with a Cardiologist
SELECT * FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
WHERE d.specialization LIKE '%Cardio%';

-- Appointments scheduled between July 1 and July 5, 2025
SELECT * FROM Appointments
WHERE appointment_date BETWEEN '2025-07-01' AND '2025-07-05';

-- Upcoming appointments only
SELECT * FROM Appointments
WHERE status = 'Upcoming';

-- Use CASE to show status: "Upcoming", "Completed", "Cancelled".
SELECT
    a.appointment_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appointment_date,
    CASE
        WHEN a.status = 'Upcoming' THEN '✅ Scheduled'
        WHEN a.status = 'Completed' THEN '✔️ Done'
        WHEN a.status = 'Cancelled' THEN '❌ Cancelled'
        ELSE '⚠️ Unknown'
    END AS appointment_status
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id;

-- Transactions for bulk appointment updates.
START TRANSACTION;

UPDATE Appointments
SET status = 'Cancelled'
WHERE patient_id = 1 AND appointment_date > CURDATE();

UPDATE Appointments
SET status = 'Completed'
WHERE appointment_date < CURDATE() AND status = 'Upcoming';

COMMIT;

-- Project8:

## 8. Gym Membership System
## Domain: Fitness
## Description: Manage members, plans, and class bookings.
-- Key Features:
CREATE DATABASE GymMembershipSystem;
USE GymMembershipSystem;

-- Tables: Members, Plans, Bookings.
-- Use constraints to prevent duplicate memberships.
-- Members Table
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    plan_id INT,
    registration_date DATE NOT NULL,
    FOREIGN KEY (plan_id) REFERENCES Plans(plan_id)
);

-- Plans Table
CREATE TABLE Plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    duration_months INT NOT NULL CHECK (duration_months > 0),
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0)
);

-- Bookings Table
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    class_name VARCHAR(100) NOT NULL,
    booking_date DATE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    UNIQUE (member_id, class_name, booking_date) -- prevent duplicate bookings
);

INSERT INTO Plans (plan_name, duration_months, price) VALUES
('Basic', 1, 1000.00),
('Standard', 3, 2500.00),
('Premium', 6, 4500.00);

-- Members
INSERT INTO Members (name, email, phone, plan_id, registration_date) VALUES
('Riya Sharma', 'riya@example.com', '9876543210', 2, '2025-07-01'),
('Amit Verma', 'amit@example.com', '9123456789', 3, '2025-07-02'),
('Karan Das', NULL, NULL, NULL, '2025-07-03');  

-- Bookings
INSERT INTO Bookings (member_id, class_name, booking_date) VALUES
(1, 'Zumba', '2025-07-04'),
(2, 'Yoga', '2025-07-05');

-- GROUP BY for plan-wise member count.
SELECT
    p.plan_name,
    COUNT(m.member_id) AS total_members
FROM Plans p
LEFT JOIN Members m ON p.plan_id = m.plan_id
GROUP BY p.plan_name;

-- Use LIKE for member name filters.
SELECT * FROM Members
WHERE name LIKE 'Ri%';

-- Use IS NULL to find incomplete registrations.
SELECT * FROM Members
WHERE email IS NULL OR phone IS NULL OR plan_id IS NULL;

-- Subqueries for highest paying member.
SELECT
    name,
    price AS plan_price
FROM Members m
JOIN Plans p ON m.plan_id = p.plan_id
WHERE p.price = (
    SELECT MAX(price) FROM Plans
);

-- Project9:

## 9. Restaurant Order Management System
## Domain: Food & Beverage
## Description: Manage menu, orders, and billing.
-- Key Features:
CREATE DATABASE RestaurantOrderSystem;
USE RestaurantOrderSystem;

-- Tables: MenuItems, Orders, OrderDetails, Customers.
-- Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15)
);

-- MenuItems Table
CREATE TABLE MenuItems (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(8, 2) NOT NULL CHECK (price > 0)
);

-- Orders Table
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

-- OrderDetails Table
CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id)
);

-- Insert multiple orders using INSERT INTO.
INSERT INTO Customers (name, phone) VALUES
('Rohit Sharma', '9876543210'),
('Neha Gupta', '9123456789');

-- Menu Items
INSERT INTO MenuItems (item_name, price) VALUES
('Paneer Tikka', 250.00),
('Butter Naan', 40.00),
('Biryani', 180.00),
('Soft Drink', 60.00);

-- Orders
INSERT INTO Orders (customer_id, order_date) VALUES
(1, '2025-07-05'),
(2, '2025-07-06');

-- Order Details (Items per order)
INSERT INTO OrderDetails (order_id, item_id, quantity) VALUES
(1, 1, 2),
(1, 2, 4),  
(2, 3, 1),  
(2, 4, 2);  

-- Use joins to get full order details.
SELECT
    o.order_id,
    c.name AS customer_name,
    m.item_name,
    od.quantity,
    m.price,
    (od.quantity * m.price) AS item_total
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
JOIN MenuItems m ON od.item_id = m.item_id;

-- Calculate total bill with SUM(), GROUP BY.
SELECT
    o.order_id,
    c.name AS customer_name,
    SUM(od.quantity * m.price) AS total_bill
FROM OrderDetails od
JOIN Orders o ON od.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
JOIN MenuItems m ON od.item_id = m.item_id
GROUP BY o.order_id, c.name;

-- Use HAVING to find high-value customers.
SELECT
    c.customer_id,
    c.name,
    SUM(od.quantity * m.price) AS total_spent
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN MenuItems m ON od.item_id = m.item_id
GROUP BY c.customer_id
HAVING total_spent > 500;

-- Use transactions for placing and cancelling orders.
START TRANSACTION;

INSERT INTO Orders (customer_id, order_date)
VALUES (1, CURDATE());
SET @order_id = LAST_INSERT_ID();

INSERT INTO OrderDetails (order_id, item_id, quantity)
VALUES
(@order_id, 1, 1),  
(@order_id, 2, 2);  

COMMIT;

-- Project10:

## 10. Hotel Booking System
## Domain: Travel/Hospitality
## Description: Manage rooms, customers, and bookings.
-- Key Features:
CREATE DATABASE HotelBookingSystem;
USE HotelBookingSystem;

-- Tables: Rooms, Customers, Bookings.
-- Rooms Table
CREATE TABLE Rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_type VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL CHECK (price_per_night > 0),
    is_available BOOLEAN DEFAULT TRUE
);

-- Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Bookings Table
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    room_id INT NOT NULL,
    customer_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (check_out > check_in)
);

-- Insert new bookings and update room availability.
INSERT INTO Rooms (room_type, price_per_night, is_available) VALUES
('Single', 1500.00, TRUE),
('Double', 2500.00, TRUE),
('Suite', 4500.00, TRUE);

-- Customers
INSERT INTO Customers (name, email) VALUES
('Anjali Kapoor', 'anjali@example.com'),
('Vikram Reddy', 'vikram@example.com');

-- Bookings
INSERT INTO Bookings (room_id, customer_id, check_in, check_out) VALUES
(1, 1, '2025-07-10', '2025-07-12'),
(2, 2, '2025-07-08', '2025-07-11');

UPDATE Rooms SET is_available = FALSE WHERE room_id IN (1, 2);

-- Use BETWEEN to filter bookings within a date range.
SELECT * FROM Bookings
WHERE check_in BETWEEN '2025-07-08' AND '2025-07-12';

INSERT INTO Bookings (room_id, customer_id, check_in, check_out)
VALUES (3, 1, '2025-07-15', '2025-07-17');

UPDATE Rooms SET is_available = FALSE WHERE room_id = 3;
-- Use subqueries to check room status.
SELECT * FROM Rooms
WHERE room_id NOT IN (
    SELECT room_id FROM Bookings
    WHERE '2025-07-10' BETWEEN check_in AND check_out
);

-- Use ORDER BY to sort bookings by check-in date.
SELECT
    b.booking_id,
    c.name AS customer_name,
    r.room_type,
    b.check_in,
    b.check_out
FROM Bookings b
JOIN Customers c ON b.customer_id = c.customer_id
JOIN Rooms r ON b.room_id = r.room_id
ORDER BY b.check_in ASC;

-- Project11:

## 20. Warehouse Product Movement System
## Domain: Logistics
## Description: Track inward and outward product movement.
-- Key Features:
CREATE DATABASE ProductMovementSystem;
USE ProductMovementSystem;

-- Tables: Products, Inward, Outward, StockLevels.
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Inward (
    inward_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    inward_date DATE NOT NULL,
    warehouse VARCHAR(100) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Outward (
    outward_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    outward_date DATE NOT NULL,
    warehouse VARCHAR(100) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE StockLevels (
    product_id INT PRIMARY KEY,
    warehouse VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Products (product_name) VALUES
('Widget A'),
('Gadget B'),
('Tool C');

-- Initialize StockLevels with zero quantity
INSERT INTO StockLevels (product_id, warehouse, quantity) VALUES
(1, 'Warehouse 1', 0),
(2, 'Warehouse 1', 0),
(3, 'Warehouse 1', 0);

-- Use UPDATE stock after movement.
START TRANSACTION;

INSERT INTO Outward (product_id, quantity, outward_date, warehouse) VALUES
(1, 20, CURDATE(), 'Warehouse 1'),
(2, 10, CURDATE(), 'Warehouse 1');

UPDATE StockLevels
SET quantity = quantity - 20
WHERE product_id = 1 AND warehouse = 'Warehouse 1';

UPDATE StockLevels
SET quantity = quantity - 10
WHERE product_id = 2 AND warehouse = 'Warehouse 1';

COMMIT;

-- Use GROUP BY for warehouse-level stock reports.
SELECT
    warehouse,
    product_id,
    SUM(quantity) AS total_stock
FROM StockLevels
GROUP BY warehouse, product_id
ORDER BY warehouse, product_id;

-- Use transactions for large deliveries.
START TRANSACTION;

INSERT INTO Inward (product_id, quantity, inward_date, warehouse) VALUES
(1, 100, CURDATE(), 'Warehouse 1'),
(2, 50, CURDATE(), 'Warehouse 1');

UPDATE StockLevels
SET quantity = quantity + 100
WHERE product_id = 1 AND warehouse = 'Warehouse 1';

UPDATE StockLevels
SET quantity = quantity + 50
WHERE product_id = 2 AND warehouse = 'Warehouse 1';

COMMIT;

-- Use subqueries to list most moved products.
SELECT
    p.product_id,
    p.product_name,
    (IFNULL(in_total, 0) + IFNULL(out_total, 0)) AS total_moved
FROM Products p
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS in_total
    FROM Inward
    GROUP BY product_id
) AS inward_sum ON p.product_id = inward_sum.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS out_total
    FROM Outward
    GROUP BY product_id
) AS outward_sum ON p.product_id = outward_sum.product_id
ORDER BY total_moved DESC;

-- Project12:

## 12. Donation and NGO System
## Domain: Nonprofit
## Description: Track donors, causes, and donation history.
-- Key Features:
CREATE DATABASE DonationSystem;
USE DonationSystem;

-- Tables: Donors, Donations, Campaigns.
CREATE TABLE Donors (
    donor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_name VARCHAR(150) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE Donations (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT NOT NULL,
    campaign_id INT NOT NULL,
    donation_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    FOREIGN KEY (donor_id) REFERENCES Donors(donor_id) ON DELETE CASCADE,
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id) ON DELETE CASCADE
);

-- Use INSERT, UPDATE, DELETE.
INSERT INTO Donors (name, email) VALUES
('Rahul Mehta', 'rahul@example.com'),
('Sunita Sharma', 'sunita@example.com'),
('Amit Singh', 'amit@example.com');

INSERT INTO Campaigns (campaign_name, start_date, end_date) VALUES
('Clean Water Project', '2025-01-01', '2025-12-31'),
('Education for All', '2025-03-01', '2025-09-30');

INSERT INTO Donations (donor_id, campaign_id, donation_date, amount) VALUES
(1, 1, '2025-04-15', 5000),
(2, 1, '2025-05-10', 15000),
(1, 2, '2025-06-05', 2500),
(3, 2, '2025-07-20', 20000);

UPDATE Donations
SET amount = 6000
WHERE donation_id = 1;

DELETE FROM Donations
WHERE donation_id = 3;

-- Use SUM() and GROUP BY to show total donations per donor/cause.
SELECT
    d.name AS donor_name,
    SUM(don.amount) AS total_donated
FROM Donors d
JOIN Donations don ON d.donor_id = don.donor_id
GROUP BY d.donor_id, d.name;

SELECT
    c.campaign_name,
    SUM(don.amount) AS total_donated
FROM Campaigns c
JOIN Donations don ON c.campaign_id = don.campaign_id
GROUP BY c.campaign_id, c.campaign_name;

-- Use CASE WHEN to tag donation as small/medium/large.
SELECT
    donor_id,
    amount,
    CASE
        WHEN amount < 5000 THEN 'Small'
        WHEN amount BETWEEN 5000 AND 15000 THEN 'Medium'
        ELSE 'Large'
    END AS donation_size
FROM Donations;

-- Use subqueries to find the most generous donor.
SELECT name, total_donated FROM (
    SELECT
        d.name,
        SUM(don.amount) AS total_donated
    FROM Donors d
    JOIN Donations don ON d.donor_id = don.donor_id
    GROUP BY d.donor_id, d.name
) AS donor_totals
ORDER BY total_donated DESC
LIMIT 1;

-- Project13:

## 13. Event Registration System
## Domain: Event Management
## Description: Track events and participant data.
-- Key Features:
CREATE DATABASE EventRegisterSystem;
USE EventRegisterSystem;

-- Tables: Events, Participants, Registrations.
-- Enforce UNIQUE registration with constraints.
CREATE TABLE Events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(150) NOT NULL,
    event_date DATE NOT NULL
);

CREATE TABLE Participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100)
);

CREATE TABLE Registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    participant_id INT NOT NULL,
    registration_date DATE NOT NULL,
    FOREIGN KEY (event_id) REFERENCES Events(event_id),
    FOREIGN KEY (participant_id) REFERENCES Participants(participant_id),
    UNIQUE (event_id, participant_id) -- enforce unique registration per event per participant
);

INSERT INTO Events (event_name, event_date) VALUES
('Tech Conference 2025', '2025-09-15'),
('Health & Wellness Expo', '2025-10-10'),
('Art & Culture Festival', '2025-11-05');

INSERT INTO Participants (name, city) VALUES
('Aisha Khan', 'Mumbai'),
('Rahul Sharma', 'Delhi'),
('Sonia Patel', 'Mumbai'),
('Karan Singh', 'Bangalore');

INSERT INTO Registrations (event_id, participant_id, registration_date) VALUES
(1, 1, '2025-07-01'),
(1, 2, '2025-07-02'),
(2, 3, '2025-07-05'),
(3, 4, '2025-07-10'),
(1, 4, '2025-07-15');

-- Use joins to list participants per event.
SELECT
    e.event_name,
    p.name AS participant_name,
    p.city,
    r.registration_date
FROM Registrations r
JOIN Events e ON r.event_id = e.event_id
JOIN Participants p ON r.participant_id = p.participant_id
ORDER BY e.event_name, r.registration_date;


-- Use DISTINCT to show all cities participants are from.
SELECT DISTINCT city FROM Participants WHERE city IS NOT NULL;

-- Subqueries to list most popular events.
SELECT
    event_name,
    participant_count
FROM (
    SELECT
        e.event_name,
        COUNT(r.participant_id) AS participant_count
    FROM Events e
    LEFT JOIN Registrations r ON e.event_id = r.event_id
    GROUP BY e.event_id, e.event_name
) AS event_counts
WHERE participant_count = (
    SELECT MAX(participant_count) FROM (
        SELECT COUNT(participant_id) AS participant_count
        FROM Registrations
        GROUP BY event_id
    ) AS counts
);


-- Project14:

## 14. Transport & Ticket Booking System
## Domain: Travel
## Description: Book tickets and track bus/train occupancy.
-- Key Features:
CREATE DATABASE TransportSystem;
USE TransportSystem;

-- Tables: Routes, Seats, Tickets, Passengers.
CREATE TABLE Routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,
    departure VARCHAR(100),
    destination VARCHAR(100),
    travel_date DATE NOT NULL
);
-- Use CHECK on seat numbers.
CREATE TABLE Seats (
    seat_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT NOT NULL,
    seat_number INT NOT NULL CHECK (seat_number > 0 AND seat_number <= 100),
    FOREIGN KEY (route_id) REFERENCES Routes(route_id),
    UNIQUE (route_id, seat_number)
);

CREATE TABLE Passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(15)
);

CREATE TABLE Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    passenger_id INT NOT NULL,
    route_id INT NOT NULL,
    seat_id INT,
    booking_time DATETIME NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id),
    FOREIGN KEY (route_id) REFERENCES Routes(route_id),
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id),
    UNIQUE (route_id, seat_id) -- ensures seat can't be double booked on the same route
);

INSERT INTO Routes (route_name, departure, destination, travel_date) VALUES
('City A to City B', 'City A', 'City B', '2025-08-01'),
('City B to City C', 'City B', 'City C', '2025-08-02');

INSERT INTO Seats (route_id, seat_number) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2);

INSERT INTO Passengers (name, contact) VALUES
('John Doe', '1234567890'),
('Jane Smith', '0987654321');

INSERT INTO Tickets (passenger_id, route_id, seat_id, booking_time) VALUES
(1, 1, 1, '2025-07-15 10:00:00'),
(2, 1, 2, '2025-07-15 11:00:00');

-- Use IS NULL to show available seats.
SELECT s.seat_number
FROM Seats s
LEFT JOIN Tickets t ON s.seat_id = t.seat_id
WHERE s.route_id = 1 AND t.seat_id IS NULL;

-- Use BETWEEN to find bookings in a time range.
SELECT
    t.ticket_id, p.name, r.route_name, t.booking_time, s.seat_number
FROM Tickets t
JOIN Passengers p ON t.passenger_id = p.passenger_id
JOIN Routes r ON t.route_id = r.route_id
JOIN Seats s ON t.seat_id = s.seat_id
WHERE t.booking_time BETWEEN '2025-07-01 00:00:00' AND '2025-07-31 23:59:59';

-- Use CASE to show seat status (booked/available).
SELECT
    s.seat_number,
    CASE
        WHEN t.ticket_id IS NULL THEN 'Available'
        ELSE 'Booked'
    END AS seat_status
FROM Seats s
LEFT JOIN Tickets t ON s.seat_id = t.seat_id AND s.route_id = t.route_id
WHERE s.route_id = 1
ORDER BY s.seat_number;

-- Project15:

## 15. Retail Customer Loyalty Tracker
## Domain: Retail
## Description: Track customers and reward points.
-- Key Features:
CREATE DATABASE RetailCustomerTracker;
USE RetailCustomerTracker;

-- Tables: Customers, Transactions, Rewards.
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Rewards (
    reward_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    points INT DEFAULT 0 CHECK (points >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Use INSERT INTO to add transactions.
INSERT INTO Customers (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

INSERT INTO Transactions (customer_id, transaction_date, amount) VALUES
(1, '2025-06-01', 1500),
(1, '2025-06-15', 800),
(2, '2025-06-10', 2000);

INSERT INTO Rewards (customer_id, points) VALUES
(1, 0),
(2, 0);

-- Use SUM() for total spend.
SELECT
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_spent
FROM Customers c
JOIN Transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name;

-- Use CASE to assign loyalty tier.
SELECT
    c.name,
    SUM(t.amount) AS total_spent,
    CASE
        WHEN SUM(t.amount) >= 5000 THEN 'Platinum'
        WHEN SUM(t.amount) >= 3000 THEN 'Gold'
        WHEN SUM(t.amount) >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_tier
FROM Customers c
JOIN Transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name;

-- Use UPDATE to increase points on repeat purchases.
UPDATE Rewards r
JOIN (
    SELECT customer_id, FLOOR(SUM(amount)/100) AS points_earned
    FROM Transactions
    GROUP BY customer_id
) t ON r.customer_id = t.customer_id
SET r.points = t.points_earned;

-- Project16:

## 16. Attendance Management System
## Domain: Corporate / Schools
## Description: Track daily attendance.
-- Key Features:
CREATE DATABASE AttendanceManagement;
USE AttendanceManagement;

-- Tables: Employees, Attendance.
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100)
);

CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    check_in TIME NOT NULL,
    check_out TIME,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    CHECK (check_out IS NULL OR check_out >= check_in)
);

INSERT INTO Employees (name, department) VALUES
('Alice Johnson', 'HR'),
('Bob Smith', 'IT'),
('Charlie Lee', 'Finance');

-- Use BETWEEN to find late check-ins.
SELECT
    e.name, a.attendance_date, a.check_in
FROM Attendance a
JOIN Employees e ON a.employee_id = e.employee_id
WHERE a.check_in BETWEEN '09:00:00' AND '10:00:00';

-- Use subqueries to find most punctual employee.
SELECT
    e.employee_id, e.name,
    AVG(TIME_TO_SEC(a.check_in)) AS avg_check_in_seconds
FROM Attendance a
JOIN Employees e ON a.employee_id = e.employee_id
GROUP BY e.employee_id, e.name
ORDER BY avg_check_in_seconds ASC
LIMIT 1;

-- Use transactions to record daily bulk entries.
START TRANSACTION;

INSERT INTO Attendance (employee_id, attendance_date, check_in, check_out) VALUES
(1, '2025-07-01', '09:05:00', '17:00:00'),
(2, '2025-07-01', '08:55:00', '17:10:00'),
(3, '2025-07-01', '09:20:00', '17:00:00');

COMMIT;

-- Project17:

## 17. Movie Ticket Booking System
## Domain: Entertainment
## Description: Manage cinema shows and bookings.
-- Key Features:
CREATE DATABASE MovieTicketSystem;
USE MovieTicketSystem;

-- Tables: Movies, Shows, Tickets, Customers.
CREATE TABLE Movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    duration_minutes INT NOT NULL
);

CREATE TABLE Shows (
    show_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    show_date DATE NOT NULL,
    show_time TIME NOT NULL,
    total_seats INT NOT NULL CHECK (total_seats > 0),
    available_seats INT NOT NULL CHECK (available_seats >= 0),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    show_id INT NOT NULL,
    seat_number INT NOT NULL,
    booking_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id),
    UNIQUE (show_id, seat_number)  -- prevent double booking of seat in same show
);


-- Use INSERT, UPDATE, and DELETE for seat booking.
INSERT INTO Movies (title, genre, duration_minutes) VALUES
('Avengers: Endgame', 'Action', 181),
('The Lion King', 'Animation', 118);

INSERT INTO Shows (movie_id, show_date, show_time, total_seats, available_seats) VALUES
(1, '2025-07-10', '18:00:00', 100, 100),
(2, '2025-07-10', '15:00:00', 80, 80);

INSERT INTO Customers (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

UPDATE Tickets
SET seat_number = 11
WHERE ticket_id = 1;

DELETE FROM Tickets WHERE ticket_id = 1;

-- Use JOINs for full booking info.
SELECT
    t.ticket_id,
    c.name AS customer_name,
    m.title AS movie_title,
    s.show_date,
    s.show_time,
    t.seat_number,
    t.booking_time
FROM Tickets t
JOIN Customers c ON t.customer_id = c.customer_id
JOIN Shows s ON t.show_id = s.show_id
JOIN Movies m ON s.movie_id = m.movie_id;

-- Use GROUP BY to show most watched movie.
SELECT
    m.title,
    COUNT(t.ticket_id) AS tickets_sold
FROM Tickets t
JOIN Shows s ON t.show_id = s.show_id
JOIN Movies m ON s.movie_id = m.movie_id
GROUP BY m.movie_id, m.title
ORDER BY tickets_sold DESC
LIMIT 1;

-- Handle rollback in case of overbooking.
START TRANSACTION;

SET @desired_show_id = 1;
SET @desired_seat_number = 10;
SET @customer_id = 1;

SELECT available_seats INTO @avail_seats FROM Shows WHERE show_id = @desired_show_id FOR UPDATE;

INSERT INTO Tickets (customer_id, show_id, seat_number) VALUES (@customer_id, @desired_show_id, @desired_seat_number);

UPDATE Shows SET available_seats = available_seats - 1 WHERE show_id = @desired_show_id;

COMMIT;

ROLLBACK;
SELECT 'Booking failed: No available seats' AS message;


-- Project18:

## 18. Freelance Project Tracker
## Domain: Freelancing
## Description: Track freelancers, projects, and payments.
-- Key Features:
CREATE DATABASE FreelanceTracker;
USE FreelanceTracker;

-- Tables: Freelancers, Projects, Payments.
CREATE TABLE Freelancers (
    freelancer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    freelancer_id INT NOT NULL,
    project_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('Pending', 'Completed') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (freelancer_id) REFERENCES Freelancers(freelancer_id)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

INSERT INTO Freelancers (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

INSERT INTO Projects (freelancer_id, project_name, start_date, end_date, status) VALUES
(1, 'Website Development', '2025-01-01', '2025-02-28', 'Completed'),
(1, 'Mobile App Design', '2025-03-05', NULL, 'Pending'),
(2, 'SEO Optimization', '2025-01-15', '2025-02-15', 'Completed');

INSERT INTO Payments (project_id, payment_date, amount) VALUES
(1, '2025-03-01', 5000),
(3, '2025-02-20', 3000);

-- Use CASE to classify project status (Pending, Completed).
SELECT
    p.project_id,
    p.project_name,
    p.start_date,
    p.end_date,
    CASE
        WHEN p.status = 'Pending' THEN 'In Progress'
        WHEN p.status = 'Completed' THEN 'Finished'
        ELSE 'Unknown'
    END AS project_status
FROM Projects p;

-- Use SUM() to track earnings per freelancer.
SELECT
    f.freelancer_id,
    f.name,
    COALESCE(SUM(pay.amount), 0) AS total_earnings
FROM Freelancers f
LEFT JOIN Projects p ON f.freelancer_id = p.freelancer_id
LEFT JOIN Payments pay ON p.project_id = pay.project_id
GROUP BY f.freelancer_id, f.name;

-- Use subqueries to find most paid freelancer.
SELECT
    freelancer_id, name, total_earnings
FROM (
    SELECT
        f.freelancer_id,
        f.name,
        COALESCE(SUM(pay.amount), 0) AS total_earnings
    FROM Freelancers f
    LEFT JOIN Projects p ON f.freelancer_id = p.freelancer_id
    LEFT JOIN Payments pay ON p.project_id = pay.project_id
    GROUP BY f.freelancer_id, f.name
) AS earnings
ORDER BY total_earnings DESC
LIMIT 1;

-- Project19:

## 19. Clinic and Medical Record System
## Domain: Healthcare
## Description: Manage patient history and medical procedures.
-- Key Features:
CREATE DATABASE ClinicSystem;
USE ClinicSystem;

-- Tables: Patients, Doctors, Visits, Prescriptions.
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dob DATE,
    contact VARCHAR(50)
);

CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100)
);

CREATE TABLE Visits (
    visit_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    follow_up_date DATE,
    diagnosis VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    visit_id INT NOT NULL,
    medicine VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    duration VARCHAR(100),
    FOREIGN KEY (visit_id) REFERENCES Visits(visit_id)
);

INSERT INTO Patients (name, dob, contact) VALUES
('John Doe', '1980-05-15', '555-1234'),
('Jane Smith', '1990-08-22', '555-5678'),
('Mike Brown', '1975-11-02', '555-8765');

INSERT INTO Doctors (name, specialty) VALUES
('Dr. Alice', 'Cardiology'),
('Dr. Bob', 'Dermatology');

INSERT INTO Visits (patient_id, doctor_id, visit_date, follow_up_date, diagnosis) VALUES
(1, 1, '2025-06-01', '2025-06-15', 'Hypertension'),
(2, 2, '2025-06-05', NULL, 'Skin Rash'),
(3, 1, '2025-06-10', '2025-06-20', 'Chest Pain');


-- Use JOIN, GROUP BY, ORDER BY.
SELECT
    p.name AS patient_name,
    d.name AS doctor_name,
    v.visit_date,
    v.diagnosis,
    v.follow_up_date
FROM Visits v
JOIN Patients p ON v.patient_id = p.patient_id
JOIN Doctors d ON v.doctor_id = d.doctor_id
ORDER BY v.visit_date DESC;

SELECT
    p.name,
    COUNT(v.visit_id) AS total_visits
FROM Patients p
LEFT JOIN Visits v ON p.patient_id = v.patient_id
GROUP BY p.patient_id, p.name;

-- Use transactions for multiple prescriptions at once.
START TRANSACTION;

INSERT INTO Prescriptions (visit_id, medicine, dosage, duration) VALUES
(1, 'Lisinopril', '10mg', '30 days'),
(1, 'Aspirin', '81mg', '30 days');

COMMIT;

-- Use IS NULL to list patients without follow-up.
SELECT DISTINCT
    p.patient_id,
    p.name
FROM Patients p
LEFT JOIN Visits v ON p.patient_id = v.patient_id
WHERE v.follow_up_date IS NULL;

-- Project20:

## 20. Warehouse Product Movement System
## Domain: Logistics
## Description: Track inward and outward product movement.
-- Key Features:
CREATE DATABASE ProductMovementSystem;
USE ProductMovementSystem;

-- Tables: Products, Inward, Outward, StockLevels.
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Inward (
    inward_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    inward_date DATE NOT NULL,
    warehouse VARCHAR(100) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Outward (
    outward_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    outward_date DATE NOT NULL,
    warehouse VARCHAR(100) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE StockLevels (
    product_id INT PRIMARY KEY,
    warehouse VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Products (product_name) VALUES
('Widget A'),
('Gadget B'),
('Tool C');

-- Initialize StockLevels with zero quantity
INSERT INTO StockLevels (product_id, warehouse, quantity) VALUES
(1, 'Warehouse 1', 0),
(2, 'Warehouse 1', 0),
(3, 'Warehouse 1', 0);

-- Use UPDATE stock after movement.
START TRANSACTION;

INSERT INTO Outward (product_id, quantity, outward_date, warehouse) VALUES
(1, 20, CURDATE(), 'Warehouse 1'),
(2, 10, CURDATE(), 'Warehouse 1');

UPDATE StockLevels
SET quantity = quantity - 20
WHERE product_id = 1 AND warehouse = 'Warehouse 1';

UPDATE StockLevels
SET quantity = quantity - 10
WHERE product_id = 2 AND warehouse = 'Warehouse 1';

COMMIT;

-- Use GROUP BY for warehouse-level stock reports.
SELECT
    warehouse,
    product_id,
    SUM(quantity) AS total_stock
FROM StockLevels
GROUP BY warehouse, product_id
ORDER BY warehouse, product_id;

-- Use transactions for large deliveries.
START TRANSACTION;

INSERT INTO Inward (product_id, quantity, inward_date, warehouse) VALUES
(1, 100, CURDATE(), 'Warehouse 1'),
(2, 50, CURDATE(), 'Warehouse 1');

UPDATE StockLevels
SET quantity = quantity + 100
WHERE product_id = 1 AND warehouse = 'Warehouse 1';

UPDATE StockLevels
SET quantity = quantity + 50
WHERE product_id = 2 AND warehouse = 'Warehouse 1';

COMMIT;

-- Use subqueries to list most moved products.
SELECT
    p.product_id,
    p.product_name,
    (IFNULL(in_total, 0) + IFNULL(out_total, 0)) AS total_moved
FROM Products p
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS in_total
    FROM Inward
    GROUP BY product_id
) AS inward_sum ON p.product_id = inward_sum.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS out_total
    FROM Outward
    GROUP BY product_id
) AS outward_sum ON p.product_id = outward_sum.product_id
ORDER BY total_moved DESC;