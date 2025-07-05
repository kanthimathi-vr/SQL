-- day23 Mini projects 1-20
-- 1. Employee Management System
-- Domain: HR
-- Goal: Maintain employee records and department assignments.
-- Requirements:
-- Create Employees and Departments tables with appropriate constraints.
-- Insert sample employee and department data using INSERT INTO.
-- Allow updating department or salary using UPDATE.
-- Allow deleting employees who resigned.
-- Add CHECK for salary > 3000.
-- Use FOREIGN KEY between Employees.department_id and Departments.dept_id.
-- Use transactions for hiring multiple employees with SAVEPOINT, ROLLBACK, and COMMIT.
create database mp1;
use mp1;
CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INT,
    salary DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_salary CHECK (salary > 3000),
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES Departments(dept_id)
);
INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Finance');
INSERT INTO Employees (emp_id, name, department_id, salary) VALUES
(101, 'Alice', 1, 50000),
(102, 'Bob', 2, 60000),
(103, 'Charlie', 3, 45000);

UPDATE Employees
SET department_id = 2
WHERE emp_id = 101;

UPDATE Employees
SET salary = salary + 5000
WHERE emp_id = 102;

DELETE FROM Employees
WHERE emp_id = 103;

--  FOREIGN KEY (department_id) REFERENCES Departments(dept_id)

START TRANSACTION;

-- Insert first employee
INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (104, 'David', 1, 55000);

SAVEPOINT sp1;

-- Insert second employee (valid)
INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (105, 'Eva', 2, 62000);

SAVEPOINT sp2;

-- Insert third employee (invalid salary to simulate error)
INSERT INTO Employees (emp_id, name, department_id, salary)
VALUES (106, 'Frank', 3, 2500);  -- Violates CHECK constraint

-- Error occurs here; rollback to last good state
ROLLBACK TO sp2;

-- Commit only first two
COMMIT;

-- ✅ 2. Student Enrollment & Fee Tracker
-- Domain: Education
-- Goal: Track students and their fee payments.
-- Requirements:
-- Tables: Students, Courses, Enrollments, Payments
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    fee DECIMAL(10,2) CHECK (fee >= 0)
);
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date timestamp default current_timestamp,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    fee_paid DECIMAL(10,2) NOT NULL CHECK (fee_paid >= 0),
    payment_date timestamp default current_timestamp,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
--  Insert students, enroll them in courses, and record fees.
INSERT INTO Students (student_id, name, email) VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com');
INSERT INTO Courses (course_id, course_name, fee) VALUES
(101, 'Mathematics', 15000),
(102, 'Science', 18000);
INSERT INTO Enrollments (student_id, course_id) VALUES
(1, 101),
(2, 102);
INSERT INTO Payments (student_id, course_id, fee_paid) VALUES
(1, 101, 15000),
(2, 102, 18000);

-- Enforce NOT NULL and CHECK (fee_paid >= 0) constraints.

-- Use DELETE to remove records of dropped students.
-- Delete student and all related records (enrollments and payments)
DELETE FROM Payments WHERE student_id = 2;
DELETE FROM Enrollments WHERE student_id = 2;
DELETE FROM Students WHERE student_id = 2;

-- Rollback partial fee updates in case of errors using SAVEPOINT.
START TRANSACTION;

-- Valid payment update
UPDATE Payments SET fee_paid = 17000 WHERE student_id = 1 AND course_id = 101;

SAVEPOINT after_first_payment;

-- Simulate error: negative fee (CHECK constraint violation)
UPDATE Payments SET fee_paid = -500 WHERE student_id = 1 AND course_id = 101;

-- Rollback to last valid state
ROLLBACK TO after_first_payment;

COMMIT;

-- 3. Hospital Patient Records
-- Domain: Healthcare
-- Goal: Store and manage patient and doctor records.
-- Requirements:
-- Patients, Doctors, Appointments tables.
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT,
    gender VARCHAR(10),
    status VARCHAR(50) DEFAULT 'Admitted'
);
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    treatment_status VARCHAR(100) DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Constraints: PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE (email)
-- Use INSERT INTO to register patients and appointments.
INSERT INTO Patients (patient_id, name, email, age, gender)
VALUES
(1, 'Alice Smith', 'alice.smith@example.com', 30, 'Female'),
(2, 'Bob Johnson', 'bob.johnson@example.com', 45, 'Male');
INSERT INTO Doctors (doctor_id, name, specialization, email)
VALUES
(101, 'Dr. Emily Brown', 'Cardiology', 'emily.brown@hospital.com'),
(102, 'Dr. David Green', 'Orthopedics', 'david.green@hospital.com');

--  Update treatment status with UPDATE.
UPDATE Appointments
SET treatment_status = 'Completed'
WHERE appointment_id = 1;

-- Delete past records after discharge.
DELETE FROM Appointments
WHERE patient_id IN (
    SELECT patient_id FROM Patients WHERE status = 'Discharged'
);

DELETE FROM Patients
WHERE status = 'Discharged';

-- Simulate patient registration with rollback on failure.
START TRANSACTION;

-- Step 1: Insert new patient
INSERT INTO Patients (patient_id, name, email, age, gender)
VALUES (3, 'Charlie Adams', 'charlie.adams@example.com', 50, 'Male');

SAVEPOINT after_patient;

-- Step 2: Simulate failure (duplicate email)
INSERT INTO Patients (patient_id, name, email, age, gender)
VALUES (4, 'Daisy Ray', 'charlie.adams@example.com', 28, 'Female'); -- Error: duplicate email

-- Rollback to previous successful step
ROLLBACK TO after_patient;

-- Finalize only the valid insert
COMMIT;

-- 4. E-Commerce Order Manager
-- Domain: Online Retail
-- Requirements:
-- Tables: Products, Customers, Orders, OrderItems
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock INT NOT NULL CHECK (stock >= 0)
);
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Use constraints to maintain data integrity (foreign keys, unique product codes).
-- Insert product and order details.
INSERT INTO Products (product_name, product_code, price, stock) VALUES
('Smartphone', 'SP1001', 15000, 10),
('Laptop', 'LP2002', 50000, 5);
INSERT INTO Customers (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

-- Update product stock after each order.
-- Use transactions to ensure all order operations complete or none (Atomicity).
START TRANSACTION;

-- Step 1: Insert order
INSERT INTO Orders (customer_id, payment_status) VALUES (1, 'Paid');
SET @last_order_id = LAST_INSERT_ID();

-- Step 2: Insert items
INSERT INTO OrderItems (order_id, product_id, quantity) VALUES
(@last_order_id, 1, 2),  -- Smartphone x2
(@last_order_id, 2, 1);  -- Laptop x1

-- Step 3: Update product stock
UPDATE Products SET stock = stock - 2 WHERE product_id = 1 AND stock >= 2;
SET @row1 = ROW_COUNT();
UPDATE Products SET stock = stock - 1 WHERE product_id = 2 AND stock >= 1;
SET @row2 = ROW_COUNT();
-- Check if stock update succeeded
SELECT @row1, @row2;


-- Step 4: Commit or Rollback
-- App code checks affected rows and decides:

    ROLLBACK;

-- Delete customer orders if payment fails.
-- Find unpaid orders
DELETE FROM OrderItems WHERE order_id IN (
    SELECT order_id FROM Orders WHERE payment_status = 'Failed'
);

DELETE FROM Orders WHERE payment_status = 'Failed';


-- 5. Hotel Booking System
-- Domain: Hospitality
-- Goal: Manage bookings, customers, and room availability.
-- Requirements:
-- Tables: Rooms, Guests, Bookings
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY AUTO_INCREMENT,
    room_type VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(10,2) NOT NULL CHECK (price_per_night > 0),
    is_available BOOLEAN DEFAULT TRUE
);
CREATE TABLE Guests (
    guest_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id),
    CHECK (check_out > check_in)
);

-- Insert room types and guest records.
INSERT INTO Rooms (room_type, price_per_night) VALUES
('Single', 2500.00),
('Double', 4000.00),
('Suite', 7000.00);

INSERT INTO Guests (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

-- Add CHECK on valid booking dates.
-- Use DELETE to cancel bookings.
-- Use transactions to block rooms and rollback if the booking fails.
START TRANSACTION;

-- Step 1: Find an available room
SELECT room_id INTO @room_to_book
FROM Rooms
WHERE room_type = 'Double' AND is_available = TRUE
LIMIT 1;

-- Step 2: Proceed if a room was found
-- (You can simulate this logic in application code or a stored procedure)

-- Step 3: Book the room
INSERT INTO Bookings (guest_id, room_id, check_in, check_out)
VALUES (1, @room_to_book, '2025-07-10', '2025-07-12');

-- Step 4: Mark the room as unavailable
UPDATE Rooms SET is_available = FALSE WHERE room_id = @room_to_book;

-- Step 5: Check if room update succeeded
SELECT ROW_COUNT() INTO @update_result;

-- Step 6: Finalize transaction manually
-- (In MySQL script, check manually or use stored procedure)
SELECT @update_result;
-- If 1 → COMMIT;
-- Else → ROLLBACK;

-- to cancel a booking
-- Step 1: Set the room available again
UPDATE Rooms
SET is_available = TRUE
WHERE room_id = (
    SELECT room_id FROM Bookings WHERE booking_id = 1
);

-- Step 2: Delete the booking
DELETE FROM Bookings WHERE booking_id = 1;

-- 6. Library Management System
-- Domain: Education
-- Goal: Maintain book inventory and borrow/return records.
-- Requirements:
-- Tables: Books, Members, BorrowRecords
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    total_copies INT NOT NULL CHECK (total_copies >= 0),
    available_copies INT NOT NULL CHECK (available_copies >= 0)
);
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE BorrowRecords (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    CHECK (return_date IS NULL OR return_date >= borrow_date)
);
-- Use NOT NULL, PRIMARY KEY, and CHECK (borrow_date <= return_date)
-- Insert books and members.
INSERT INTO Books (title, author, total_copies, available_copies) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 5, 5),
('1984', 'George Orwell', 3, 3);
INSERT INTO Members (name, email) VALUES
('Alice Johnson', 'alice@library.com'),
('Bob Smith', 'bob@library.com');

-- Update book availability.
START TRANSACTION;

-- Step 1: Check availability
SELECT available_copies INTO @copies FROM Books WHERE book_id = 1;

-- Step 2: If available, borrow
-- (Handled manually or via stored procedure in SQL)

-- Step 3: Insert borrow record
INSERT INTO BorrowRecords (book_id, member_id, borrow_date)
VALUES (1, 1, CURDATE());

-- Step 4: Decrease available copies
UPDATE Books SET available_copies = available_copies - 1
WHERE book_id = 1 AND available_copies > 0;

-- Step 5: Confirm
SELECT ROW_COUNT() INTO @updated;
SELECT @updated;

-- If @updated = 1 → COMMIT;
-- Else → ROLLBACK;

-- Delete outdated borrow records.
DELETE FROM BorrowRecords
WHERE return_date IS NOT NULL AND return_date < '2024-01-01';

-- Use transactions for borrowing multiple books at once.
-- Update return date
UPDATE BorrowRecords
SET return_date = CURDATE()
WHERE record_id = 1;

-- Increase available copies
UPDATE Books
SET available_copies = available_copies + 1
WHERE book_id = (
    SELECT book_id FROM BorrowRecords WHERE record_id = 1
);
-- ✅ 7. Inventory and Stock Control
-- Domain: Supply Chain
-- Goal: Track inventory levels and restocking.
-- Requirements:
-- Tables: Inventory, Suppliers, PurchaseOrders
CREATE TABLE Inventory (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    reorder_level INT NOT NULL CHECK (reorder_level >= 0),
    discontinued BOOLEAN DEFAULT FALSE
);
CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE PurchaseOrders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    supplier_id INT NOT NULL,
    order_date timestamp NOT NULL DEFAULT current_timestamp,
    quantity_ordered INT NOT NULL CHECK (quantity_ordered > 0),
    FOREIGN KEY (item_id) REFERENCES Inventory(item_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- Add stock items using INSERT INTO.
INSERT INTO Inventory (item_name, quantity, reorder_level) VALUES
('Laptop', 25, 10),
('Printer', 15, 5),
('Router', 5, 3);
INSERT INTO Suppliers (name, contact_email) VALUES
('TechSupply Co.', 'contact@techsupply.com'),
('NetGear Inc.', 'support@netgear.com');

-- Update quantities and reorder levels.
-- Increase quantity of item_id 1 (Laptop)
UPDATE Inventory
SET quantity = quantity + 10
WHERE item_id = 1;

-- Change reorder level for item_id 3 (Router)
UPDATE Inventory
SET reorder_level = 4
WHERE item_id = 3;

-- Use CHECK (quantity >= 0)
-- Delete discontinued items.
-- Mark item as discontinued
UPDATE Inventory
SET discontinued = TRUE
WHERE item_id = 2;

-- Delete discontinued items (optional cleanup)
DELETE FROM Inventory
WHERE discontinued = TRUE;

-- Use transactions for batch inventory updates.
START TRANSACTION;

-- Simulate restocking multiple items
UPDATE Inventory SET quantity = quantity + 20 WHERE item_id = 1;
UPDATE Inventory SET quantity = quantity + 15 WHERE item_id = 3;

-- Check both updates
SELECT ROW_COUNT() INTO @rows;

-- Manually check and COMMIT/ROLLBACK based on outcome
SELECT @rows;
-- If updates OK → COMMIT;
-- Else → ROLLBACK;

-- 8. Banking Transaction Simulator
-- Domain: Finance
-- Goal: Handle account balances and transactions.
-- Requirements:
-- Tables: Customers, Accounts, Transactions
select * from customers;
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(12,2) NOT NULL CHECK (balance >= 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
CREATE TABLE Transactions (
    txn_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    txn_type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    txn_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

-- Insert new accounts with NOT NULL and CHECK (balance >= 0)
INSERT INTO Customers (name, email) VALUES
('Alice Brown', 'alice@bank.com'),
('Bob Green', 'bob@bank.com');
INSERT INTO Accounts (customer_id, account_type, balance) VALUES
(1, 'Savings', 5000.00),
(2, 'Checking', 3000.00);

-- Update balances on debit/credit.
START TRANSACTION;

UPDATE Accounts
SET balance = balance + 1000
WHERE account_id = 1;

INSERT INTO Transactions (account_id, txn_type, amount)
VALUES (1, 'credit', 1000);

COMMIT;
-- debit from an account (only if sufficient balance)
START TRANSACTION;

-- Check sufficient balance
SELECT balance INTO @bal FROM Accounts WHERE account_id = 2;

-- If enough balance, proceed
UPDATE Accounts
SET balance = balance - 500
WHERE account_id = 2 AND balance >= 500;

-- Log transaction
INSERT INTO Transactions (account_id, txn_type, amount)
VALUES (2, 'debit', 500);

COMMIT;

-- 9. Retail Point of Sale System
-- Domain: Retail
-- Goal: Track in-store purchases and billing.
-- Requirements:
-- Tables: Products, Sales, Cashiers
CREATE TABLE Cashiers (
    cashier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    employee_code VARCHAR(20) UNIQUE NOT NULL
);
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    cashier_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    sale_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (cashier_id) REFERENCES Cashiers(cashier_id)
);
INSERT INTO Cashiers (name, employee_code) VALUES
('Rita Patel', 'EMP001'),
('Amit Kumar', 'EMP002');

-- Enforce uniqueness on product barcodes.
-- Insert products and sales.
-- Update product stock post-sale.
-- Step 1: Start transaction
START TRANSACTION;

-- Step 2: Insert the sale
INSERT INTO Sales (product_id, cashier_id, quantity)
VALUES (1, 1, 2);

-- Step 3: Savepoint after sale insert
SAVEPOINT after_sale;

-- Step 4: Update stock
UPDATE Products
SET stock = stock - 2
WHERE product_id = 1 AND stock >= 2;

-- Step 5: Check result of stock update
-- Run this separately to see result manually
SELECT ROW_COUNT() AS updated_rows;
COMMIT;
ROLLBACK TO after_sale;

-- Optional: delete the inserted sale (most recent one)
DELETE FROM Sales
ORDER BY sale_id DESC
LIMIT 1;

COMMIT;
-- Use DELETE to remove voided sales.
-- Use SAVEPOINT during billing for partial rollback.
-- Delete closed accounts.
-- Use transactions to perform transfers and rollback on errors.

-- 10. Car Rental Booking System
-- Domain: Transportation
-- Goal: Manage car availability and bookings.
-- Requirements:
-- Tables: Cars, Customers, Bookings
create database carrental;
use carrental;
CREATE TABLE Cars (
    car_id INT PRIMARY KEY AUTO_INCREMENT,
    model VARCHAR(100) NOT NULL,
    registration_no VARCHAR(50) UNIQUE NOT NULL,
    available BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE
);
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    car_id INT NOT NULL,
    customer_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (car_id) REFERENCES Cars(car_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (end_date >= start_date)
);

-- Insert booking records and car info.
INSERT INTO Cars (model, registration_no) VALUES
('Toyota Corolla', 'MH12AB1234'),
('Honda City', 'MH12CD5678');
INSERT INTO Customers (name, phone) VALUES
('Rahul Mehta', '9876543210'),
('Priya Shah', '9123456780');

-- Update car availability.
UPDATE Cars
SET available = TRUE
WHERE car_id IN (
    SELECT car_id FROM Bookings
    WHERE end_date < CURDATE()
);

-- Delete expired bookings.
-- Delete bookings that ended before today
DELETE FROM Bookings
WHERE end_date < CURDATE();

-- Use CHECK on valid booking dates.
-- Use transactions to ensure consistency during multi-day bookings.
START TRANSACTION;

-- Step 1: Ensure car is available
SELECT available INTO @car_status FROM Cars WHERE car_id = 1;
set sql_safe_updates = 0;
-- Step 2: If available, insert booking
INSERT INTO Bookings (car_id, customer_id, start_date, end_date)
VALUES (1, 1, '2025-07-10', '2025-07-12');

-- Step 3: Update car availability
UPDATE Cars SET available = FALSE WHERE car_id = 1;

COMMIT;

-- 11. University Course Registration
-- Domain: Education
drop  database university1;
create database university;
use university;
-- Goal: Register students into courses with capacity limits.
-- Requirements:
-- Tables: Students, Courses, Registrations
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE Courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    max_capacity INT NOT NULL CHECK (max_capacity > 0),
    seats_remaining INT NOT NULL CHECK (seats_remaining >= 0)
);
CREATE TABLE Registrations (
    registration_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    UNIQUE (student_id, course_id)
);

-- Use UNIQUE (student_id, course_id) to prevent duplicates.
-- Insert students and course registrations.
INSERT INTO Students (name, email) VALUES
('Ananya Singh', 'ananya@example.com'),
('Ravi Verma', 'ravi@example.com');

INSERT INTO Courses (course_name, max_capacity, seats_remaining) VALUES
('Database Systems', 30, 30),
('Operating Systems', 40, 40);

-- Update seats remaining per course.
-- Step 2: Register the student
INSERT INTO Registrations (student_id, course_id)
VALUES (1, 1); -- Ananya into Database Systems

-- Step 3: Decrease seat count
UPDATE Courses
SET seats_remaining = seats_remaining - 1
WHERE course_id = 1;

COMMIT;

-- Delete dropped registrations.
-- Use rollback if course capacity exceeded.
START TRANSACTION;

-- Step 1: Delete registration
DELETE FROM Registrations
WHERE student_id = 1 AND course_id = 1;

-- Step 2: Restore seat
UPDATE Courses
SET seats_remaining = seats_remaining + 1
WHERE course_id = 1;

COMMIT;
-- 12. Gym Membership System
-- Domain: Fitness
-- Goal: Manage memberships and class bookings.
-- Requirements:
-- Tables: Members, MembershipPlans, ClassBookings
create database gymmember;
use gymmember;
-- Insert new members and bookings.
CREATE TABLE MembershipPlans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(50) NOT NULL,
    duration_days INT NOT NULL CHECK (duration_days > 0),
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0)
);
CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    join_date timestamp NOT NULL DEFAULT current_timestamp,
    expiry_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    plan_id INT NOT NULL,
    FOREIGN KEY (plan_id) REFERENCES MembershipPlans(plan_id)
);
CREATE TABLE ClassBookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    class_name VARCHAR(100) NOT NULL,
    booking_date TIMESTAMP NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);
INSERT INTO MembershipPlans (plan_name, duration_days, price) VALUES
('Monthly', 30, 1000),
('Quarterly', 90, 2700),
('Yearly', 365, 10000);

INSERT INTO Members (name, plan_id, expiry_date)
VALUES ('Amit Sharma', 1, DATE_ADD(CURDATE(), INTERVAL 30 DAY));

-- Update membership status.
INSERT INTO ClassBookings (member_id, class_name, booking_date)
VALUES (1, 'Yoga', CURDATE()); -- ✅ Allowed

-- This will fail:
-- INSERT INTO ClassBookings (member_id, class_name, booking_date)
-- VALUES (1, 'Zumba', '2024-01-01'); -- ❌ Past date

-- Enforce CHECK on booking date validity.
-- Delete expired memberships.
-- Set status to 'Expired' for past expiry
UPDATE Members
SET status = 'Expired'
WHERE expiry_date < CURDATE();

-- Use transactions for membership purchase + booking together.
START TRANSACTION;

-- Step 1: New member joins with yearly plan (plan_id = 3)
INSERT INTO Members (name, plan_id, expiry_date)
VALUES ('Priya Desai', 3, DATE_ADD(CURDATE(), INTERVAL 365 DAY));

-- Step 2: Get new member ID
SET @new_member_id = LAST_INSERT_ID();

-- Step 3: Book a class for the new member
INSERT INTO ClassBookings (member_id, class_name, booking_date)
VALUES (@new_member_id, 'Pilates', CURDATE());

COMMIT;

-- 13. Restaurant Order Processing
-- Domain: Food & Beverage
-- Goal: Track orders, menu items, and bill payments.
-- Requirements:
-- Tables: Orders, MenuItems, OrderItems
-- Insert menu and order data.
-- Update kitchen status (e.g., ‘In Progress’, ‘Served’).
-- Delete cancelled orders.
-- Use transaction to handle full meal order atomicity.
drop database restaurant1;
create database restaurant1;
CREATE TABLE MenuItems (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    table_number INT NOT NULL,
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'In Progress', 'Served', 'Cancelled') DEFAULT 'Pending'
);

CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES MenuItems(item_id)
);
INSERT INTO MenuItems (item_name, price) VALUES
('Margherita Pizza', 8.99),
('Caesar Salad', 5.50),
('Chocolate Cake', 4.25);

INSERT INTO Orders (table_number) VALUES (12);

START TRANSACTION;

-- Insert new order for table 5
INSERT INTO Orders (table_number) VALUES (5);
SET @last_order_id = LAST_INSERT_ID();

-- Insert order items
INSERT INTO OrderItems (order_id, item_id, quantity) VALUES
(@last_order_id, 1, 2),  -- 2 Margherita Pizzas
(@last_order_id, 3, 1);  -- 1 Chocolate Cake

-- Commit or rollback if any error occurs
COMMIT;

UPDATE Orders
SET status = 'In Progress'
WHERE order_id = 1;

UPDATE Orders
SET status = 'Served'
WHERE order_id = 1;

DELETE FROM Orders WHERE status = 'Cancelled';

-- 14. Online Exam System
-- Domain: Education / Training
-- Goal: Store candidate and exam result data.
-- Requirements:
-- Tables: Candidates, Exams, Results
create database exam;
use exam;
CREATE TABLE Candidates (
    candidate_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Exams (
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_name VARCHAR(100) NOT NULL,
    max_marks INT NOT NULL DEFAULT 100
);

CREATE TABLE Results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_id INT NOT NULL,
    exam_id INT NOT NULL,
    marks INT NOT NULL CHECK (marks >= 0 AND marks <= 100),
    result_date timestamp DEFAULT current_timestamp,
    FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id),
    UNIQUE (candidate_id, exam_id)  -- prevent duplicates
);

-- Enforce CHECK (marks >= 0 AND marks <= 100)
-- Insert new results.
INSERT INTO Candidates (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com');

INSERT INTO Exams (exam_name) VALUES
('Math 101'),
('Physics 101');
INSERT INTO Results (candidate_id, exam_id, marks) VALUES
(1, 1, 85),
(2, 1, 90);


-- Update marks if re-evaluated.
UPDATE Results
SET marks = 88
WHERE candidate_id = 1 AND exam_id = 1;

-- Delete invalid or duplicate results.
DELETE FROM Results WHERE result_id = 3;

-- Use transaction for result entry + certificate generation.
CREATE TABLE Certificates (
    certificate_id INT PRIMARY KEY AUTO_INCREMENT,
    candidate_id INT NOT NULL,
    exam_id INT NOT NULL,
    issue_date timestamp DEFAULT current_timestamp,
    FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id)
);
START TRANSACTION;

INSERT INTO Results (candidate_id, exam_id, marks) VALUES (1, 2, 92);

INSERT INTO Certificates (candidate_id, exam_id) VALUES (1, 2);

COMMIT;
-- 15. Clinic Appointment Scheduler
-- Domain: Health
-- Goal: Book and manage appointments.
-- Requirements:
-- Tables: Doctors, Patients, Appointments
create database clinicappoint;

use clinicappoint;

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100)
);

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15)
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    doctor_id INT NOT NULL,
    patient_id INT NOT NULL,
    appointment_start DATETIME NOT NULL,
    appointment_end DATETIME NOT NULL,
    status ENUM('Scheduled', 'Cancelled', 'Completed') DEFAULT 'Scheduled',
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    CONSTRAINT chk_time CHECK (appointment_end > appointment_start),
    -- Avoid booking conflicts for the same doctor: no overlapping appointments
    UNIQUE KEY unique_appointment (doctor_id, appointment_start, appointment_end)
);

-- Insert doctor and patient records.
INSERT INTO Doctors (name, specialization) VALUES
('Dr. Smith', 'Cardiology'),
('Dr. Lee', 'Dermatology');

INSERT INTO Patients (name, phone) VALUES
('John Doe', '1234567890'),
('Jane Roe', '0987654321');

START TRANSACTION;

INSERT INTO Appointments (doctor_id, patient_id, appointment_start, appointment_end)
VALUES
(1, 1, '2025-07-10 09:00:00', '2025-07-10 09:30:00'),
(1, 2, '2025-07-10 09:30:00', '2025-07-10 10:00:00');

COMMIT;

-- Update appointment status (e.g., Scheduled, Cancelled).
UPDATE Appointments
SET status = 'Cancelled'
WHERE appointment_id = 1;

-- Delete old appointments.
DELETE FROM Appointments WHERE appointment_end < CURDATE();

-- Use constraints to avoid booking conflicts.
-- Check if doctor has appointment overlapping requested time
SELECT COUNT(*) AS conflict_count
FROM Appointments
WHERE doctor_id = 1
  AND status = 'Scheduled'
  AND appointment_start < '2025-07-10 10:00:00'
  AND appointment_end > '2025-07-10 09:30:00';

-- Use transactions to batch-schedule multiple appointments.
START TRANSACTION;

-- Insert multiple appointments atomically
INSERT INTO Appointments (doctor_id, patient_id, appointment_start, appointment_end)
VALUES
    (1, 1, '2025-07-10 09:00:00', '2025-07-10 09:30:00'),
    (1, 2, '2025-07-10 09:30:00', '2025-07-10 10:00:00'),
    (2, 1, '2025-07-11 11:00:00', '2025-07-11 11:30:00');

-- Optionally check for errors, conflicts etc. in application logic

COMMIT;

-- 16. Transport Ticket Booking System
-- Domain: Travel
-- Goal: Manage bus/train tickets and cancellations.
-- Requirements:
-- Tables: Passengers, Routes, Tickets
create database transport;
use transport;
CREATE TABLE Passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15)
);

CREATE TABLE Routes (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    origin VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    total_seats INT NOT NULL CHECK (total_seats > 0)
);

CREATE TABLE Tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    passenger_id INT NOT NULL,
    route_id INT NOT NULL,
    seat_number INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Booked', 'Cancelled') DEFAULT 'Booked',
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id),
    FOREIGN KEY (route_id) REFERENCES Routes(route_id),
    CHECK (seat_number >= 1 AND seat_number <= 100) -- example max seat number 100
);

-- Insert passenger bookings.
INSERT INTO Passengers (name, phone) VALUES
('Alice', '1234567890'),
('Bob', '0987654321');

INSERT INTO Routes (origin, destination, total_seats) VALUES
('City A', 'City B', 50),
('City C', 'City D', 100);
INSERT INTO Tickets (passenger_id, route_id, seat_number)
VALUES (1, 1, 10),
       (2, 1, 11);

-- Update seat availability.
-- Assuming you track available seats in Routes table as a column available_seats (you can add this column)
ALTER TABLE Routes ADD COLUMN available_seats INT DEFAULT NULL;

-- Initialize available_seats equal to total_seats
UPDATE Routes SET available_seats = total_seats;

-- When ticket booked, reduce available seats
UPDATE Routes
SET available_seats = available_seats - 1
WHERE route_id = 1 AND available_seats > 0;

-- Delete cancelled tickets.
DELETE FROM Tickets WHERE status = 'Cancelled';

-- Use CHECK on seat number range.
-- Use SAVEPOINT and rollback on payment failure.
START TRANSACTION;

-- Step 1: Book Ticket
INSERT INTO Tickets (passenger_id, route_id, seat_number)
VALUES (1, 2, 20);
SAVEPOINT after_booking;

-- Step 2: Update Seat Availability
UPDATE Routes
SET available_seats = available_seats - 1
WHERE route_id = 2 AND available_seats > 0;

-- Step 3: Check how many rows updated (seat availability reduced)
SELECT ROW_COUNT() INTO @rows_affected;

-- Step 4: Simulate payment success/failure by setting @payment_success manually
SET @payment_success = FALSE;

-- Step 5: Use a condition to rollback or commit without IF ELSE
-- If either seat update failed or payment failed, rollback entire transaction

-- Rollback if seat update failed
ROLLBACK TO after_booking;
DELETE FROM Tickets WHERE ticket_id = LAST_INSERT_ID();

-- Commit only if seat updated and payment success
-- This next commit statement will be ignored if you rollback immediately before

COMMIT;

-- 17. Employee Attendance Tracker
-- Domain: Corporate HR
-- Goal: Track daily attendance records.
-- Requirements:
-- Tables: Employees, Attendance
create database empattendance;
use  empattendance;
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    department_id INT,
    salary DECIMAL(10,2)
    -- You can add FOREIGN KEY to Departments if needed
);

CREATE TABLE Attendance (
    att_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    att_date timestamp NOT NULL DEFAULT current_timestamp,
    check_in_time TIME NOT NULL,
    check_out_time TIME,
    CHECK (check_out_time IS NULL OR check_out_time >= check_in_time),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

-- Insert check-in/check-out times.
START TRANSACTION;

INSERT INTO Attendance (emp_id, att_date, check_in_time, check_out_time) VALUES
(101, '2025-07-05', '09:00:00', '18:00:00'),
(102, '2025-07-05', '09:15:00', '17:45:00'),
(103, '2025-07-05', '08:50:00', '18:10:00');

COMMIT;

-- Update records if employee corrects check-out.
UPDATE Attendance
SET check_out_time = '18:30:00'
WHERE att_id = 2; -- Example: Employee with att_id=2 corrects checkout time

-- Delete invalid entries.
DELETE FROM Attendance
WHERE check_out_time < check_in_time;

-- Add CHECK (check_out_time >= check_in_time)
-- Use transactions to insert multiple employees' attendance at once.
START TRANSACTION;

INSERT INTO Attendance (emp_id, att_date, check_in_time, check_out_time) VALUES
(101, '2025-07-05', '09:00:00', '18:00:00'),
(102, '2025-07-05', '09:15:00', '17:45:00'),
(103, '2025-07-05', '08:50:00', NULL);  -- NULL check_out_time allowed

COMMIT;

-- 18. NGO Donation Record System
-- Domain: Non-Profit
-- Goal: Store donor information and donations.
-- Requirements:
-- Tables: Donors, Donations
create database ngo;
use ngo;
CREATE TABLE Donors (
    donor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    last_donation_date DATE
);

CREATE TABLE Donations (
    donation_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT NOT NULL,
    donation_date timestamp NOT NULL DEFAULT current_timestamp,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    purpose VARCHAR(255),
    FOREIGN KEY (donor_id) REFERENCES Donors(donor_id)
);

-- Insert new donor info and donation records.
INSERT INTO Donors (name, email, phone) VALUES
('Alice Johnson', 'alice@example.com', '1234567890'),
('Bob Smith', 'bob@example.com', '0987654321');

INSERT INTO Donations (donor_id, amount, purpose) VALUES
(1, 500.00, 'Education Support'),
(2, 1000.00, 'Medical Aid');

-- Update donation purpose or amount.
UPDATE Donations
SET purpose = 'Scholarship Fund', amount = 750.00
WHERE donation_id = 1;

-- Enforce CHECK (amount > 0)
-- Delete old donors if inactive.
DELETE FROM Donors
WHERE last_donation_date < CURDATE() - INTERVAL 2 YEAR
   OR last_donation_date IS NULL;

-- Use transactions for pledge and donation recording.
START TRANSACTION;

-- Insert a new pledge as a donation record (with zero amount initially)
INSERT INTO Donations (donor_id, amount, purpose)
VALUES (1, 0.00, 'Pledge for Future Project');

-- Later update the pledge amount once confirmed
UPDATE Donations
SET amount = 1000.00
WHERE donation_id = LAST_INSERT_ID();

COMMIT;

-- 19. Payroll & Salary System
-- Domain: HR / Finance
-- Goal: Generate salary records and deductions.
-- Requirements:
-- Tables: Employees, Salaries, Deductions
create database payroll;
use payroll;
CREATE TABLE Employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50)
);

CREATE TABLE Salaries (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    salary_date DATE NOT NULL,
    base_salary DECIMAL(10, 2) NOT NULL CHECK (base_salary >= 3000),
    bonus DECIMAL(10, 2) DEFAULT 0,
    total_salary DECIMAL(10, 2) GENERATED ALWAYS AS (base_salary + bonus) STORED,
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

CREATE TABLE Deductions (
    deduction_id INT PRIMARY KEY AUTO_INCREMENT,
    salary_id INT NOT NULL,
    deduction_amount DECIMAL(10, 2) NOT NULL CHECK (deduction_amount >= 0),
    reason VARCHAR(255),
    FOREIGN KEY (salary_id) REFERENCES Salaries(salary_id)
);

-- Insert monthly salary slips.
INSERT INTO Salaries (emp_id, salary_date, base_salary, bonus)
VALUES (1, '2025-07-01', 50000, 5000);

-- Update with bonus or deduction.
-- Update bonus for a salary slip
UPDATE Salaries
SET bonus = 6000
WHERE salary_id = 1;

-- Insert deduction record
INSERT INTO Deductions (salary_id, deduction_amount, reason)
VALUES (1, 1000, 'Tax');

-- Enforce constraints on minimum salary using CHECK.
ALTER TABLE Salaries
ADD CONSTRAINT chk_min_salary CHECK (base_salary >= 3000);

-- Delete old salary records after 2 years.
DELETE FROM Salaries
WHERE salary_date < CURDATE() - INTERVAL 2 YEAR;

-- Use transactions for salary + deduction insertion.
START TRANSACTION;

-- Insert salary record
INSERT INTO Salaries (emp_id, salary_date, base_salary, bonus)
VALUES (2, '2025-07-01', 40000, 2000);

-- Get last inserted salary_id
SET @last_salary_id = LAST_INSERT_ID();

-- Insert deduction linked to salary
INSERT INTO Deductions (salary_id, deduction_amount, reason)
VALUES (@last_salary_id, 500, 'Health Insurance');

COMMIT;

-- 20. Warehouse Inward/Outward System
-- Domain: Logistics
-- Goal: Track goods entering and leaving the warehouse.
-- Requirements:
-- Tables: Items, Inward, Outward
use warehouse;
CREATE TABLE Items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL UNIQUE,
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE Inward (
    inward_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    inward_date timestamp NOT NULL DEFAULT current_timestamp,
    FOREIGN KEY (item_id) REFERENCES Items(item_id)
);

CREATE TABLE Outward (
    outward_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    outward_date timestamp NOT NULL DEFAULT current_timestamp,
    FOREIGN KEY (item_id) REFERENCES Items(item_id)
);

-- Insert item details and quantities.
INSERT INTO Items (item_name, stock_quantity) VALUES
('Item A', 100),
('Item B', 50);

-- Update item stock based on movement.
-- When items come IN (Inward), increase stock
UPDATE Items
SET stock_quantity = stock_quantity + @inward_qty
WHERE item_id = @item_id;

-- When items go OUT (Outward), decrease stock only if enough stock available
UPDATE Items
SET stock_quantity = stock_quantity - @outward_qty
WHERE item_id = @item_id
  AND stock_quantity >= @outward_qty;

-- Enforce CHECK (quantity >= 0)
ALTER TABLE Items
ADD CONSTRAINT chk_quantity_nonnegative CHECK (stock_quantity >= 0);

-- Use DELETE to clear damaged or expired stock.
-- Delete items marked as damaged
DELETE FROM Items WHERE is_damaged = TRUE;

-- OR delete expired items based on expiry date
DELETE FROM Items WHERE expiry_date < CURDATE();

-- Use transactions for batch stock updates.
START TRANSACTION;

-- Insert inward stock
INSERT INTO Inward (item_id, quantity) VALUES (1, 20);

-- Update stock quantity for inward
UPDATE Items SET stock_quantity = stock_quantity + 20 WHERE item_id = 1;

SAVEPOINT after_inward;

-- Insert outward stock
INSERT INTO Outward (item_id, quantity) VALUES (2, 10);

-- Update stock quantity for outward (only if enough stock)
UPDATE Items SET stock_quantity = stock_quantity - 10 WHERE item_id = 2 AND stock_quantity >= 10;

-- Check rows affected by outward update
SELECT ROW_COUNT() AS affected_rows;

-- If rows affected = 0, simulate failure by causing an error to rollback
-- For example, do an invalid operation to force rollback
-- Note: This must be handled by the app or via stored procedure

COMMIT;

