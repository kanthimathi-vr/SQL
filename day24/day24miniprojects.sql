use day24;
-- ✅ 1. Employee Search Optimization System
-- Domain: HRMS
-- Goal: Optimize employee search and reporting.
-- Requirements:
-- Create Employees table with emp_id, emp_name, dept_id, salary, joining_date.
select * from employees;
select * from departments;
-- Create indexes on emp_name, dept_id for faster searches.
-- Use EXPLAIN to analyze employee search queries.
EXPLAIN SELECT * FROM Employees WHERE emp_name = 'Alice';
EXPLAIN SELECT * FROM Employees WHERE dept_id = 2;

-- Normalize data into Employees and Departments.
-- Show benefit of denormalization by combining department info in a single table.
-- Denormalized Table
CREATE TABLE Employees_Denorm (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    dept_name VARCHAR(100),
    salary DECIMAL(10,2)
);
drop table employees_denorm;
INSERT INTO Employees_Denorm (emp_id, emp_name, dept_id, dept_name, salary)
SELECT 
    e.emp_id,
    e.emp_name,
    e.dept_id,
    d.dept_name,
    e.salary
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;
select * from employees_denorm;
-- normalized
EXPLAIN
SELECT e.emp_id, e.emp_name, d.dept_name, e.salary
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'IT';
-- denormalized
EXPLAIN
SELECT emp_id, emp_name, salary
FROM Employees_Denorm
WHERE dept_name = 'IT';

-- Compare performance with and without LIMIT.
EXPLAIN SELECT * FROM Employees ORDER BY salary DESC;
EXPLAIN SELECT * FROM Employees ORDER BY salary DESC LIMIT 10;
-- project2:
-- 2. E-Commerce Product Search Engine
-- Domain: Online Retail
-- Goal: Speed up product lookup and listing.
-- Requirements:
-- Create Products, Categories, Inventory tables.
create database ecommerce;
use ecommerce;
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);
drop table categories;
INSERT INTO Categories (category_id, category_name) VALUES
(1, 'Computer Accessories'),
(2, 'Monitors'),
(3, 'Chargers'),
(4, 'Audio Devices'),
(5, 'Office Supplies'),
(6, 'Cameras'),
(7, 'Mobile Accessories'),
(8, 'Fitness Devices'),
(9, 'Lighting'),
(10, 'Smart Home'),
(11, 'Kitchen Appliances'),
(12, 'Watches');

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);
INSERT INTO Products (product_id, product_name, category_id, price, description) VALUES
(1, 'Wireless Mouse', 1, 25.99, 'Ergonomic wireless mouse with USB receiver'),
(2, 'Gaming Keyboard', 1, 49.99, 'Mechanical RGB keyboard with macro keys'),
(3, 'HD Monitor', 2, 129.99, '24-inch full HD LED monitor'),
(4, 'USB-C Charger', 3, 18.50, 'Fast charging USB-C wall charger'),
(5, 'Bluetooth Speaker', 4, 39.95, 'Portable speaker with deep bass'),
(6, 'Laptop Stand', 5, 21.00, 'Adjustable aluminum laptop stand'),
(7, 'Webcam 1080p', 6, 32.75, 'HD webcam with built-in microphone'),
(8, 'Noise Cancelling Headphones', 4, 89.99, 'Over-ear wireless headphones'),
(9, 'Smartphone Case', 7, 14.99, 'Shockproof case for smartphones'),
(10, 'Tablet Stylus', 7, 19.95, 'Digital stylus compatible with tablets'),
(11, 'Fitness Tracker', 8, 59.90, 'Waterproof smart fitness band'),
(12, 'Wireless Earbuds', 4, 44.00, 'Bluetooth earbuds with charging case'),
(13, 'External SSD 1TB', 2, 109.99, 'High-speed external solid-state drive'),
(14, 'LED Desk Lamp', 9, 22.50, 'Touch control LED lamp with brightness levels'),
(15, 'WiFi Router', 3, 65.00, 'Dual-band wireless router'),
(16, 'Action Camera', 6, 120.00, '4K waterproof action camera'),
(17, 'Smart Thermostat', 10, 150.00, 'WiFi-enabled smart home thermostat'),
(18, 'Coffee Grinder', 11, 30.00, 'Electric grinder with multiple settings'),
(19, 'Mechanical Watch', 12, 199.99, 'Automatic analog watch with leather strap'),
(20, 'LED Strip Light', 9, 12.99, 'Color-changing LED light strip'),
(21, 'Portable Projector', 2, 220.00, 'Mini HD projector for home and travel'),
(22, 'Smart Plug', 10, 16.50, 'Voice-controlled smart plug adapter'),
(23, 'Standing Desk', 5, 275.00, 'Height-adjustable standing desk'),
(24, 'Wireless Charger', 3, 29.99, 'Qi-certified fast charger pad'),
(25, 'Bluetooth Mouse', 1, 20.00, 'Slim rechargeable mouse'),
(26, 'Laptop Sleeve', 5, 17.45, 'Protective case for laptops'),
(27, 'Smart Light Bulb', 10, 13.99, 'WiFi LED bulb with app control'),
(28, 'USB Hub', 3, 15.25, '4-port USB 3.0 hub'),
(29, 'Gaming Chair', 5, 199.50, 'Ergonomic high-back gaming chair'),
(30, 'Electric Kettle', 11, 34.99, 'Stainless steel kettle with auto shutoff');

CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    stock_quantity INT NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
INSERT INTO Inventory (inventory_id, product_id, stock_quantity, last_updated) VALUES
(1, 1, 150, CURRENT_TIMESTAMP),
(2, 2, 120, CURRENT_TIMESTAMP),
(3, 3, 80, CURRENT_TIMESTAMP),
(4, 4, 200, CURRENT_TIMESTAMP),
(5, 5, 90, CURRENT_TIMESTAMP),
(6, 6, 60, CURRENT_TIMESTAMP),
(7, 7, 75, CURRENT_TIMESTAMP),
(8, 8, 65, CURRENT_TIMESTAMP),
(9, 9, 180, CURRENT_TIMESTAMP),
(10, 10, 160, CURRENT_TIMESTAMP),
(11, 11, 140, CURRENT_TIMESTAMP),
(12, 12, 100, CURRENT_TIMESTAMP),
(13, 13, 70, CURRENT_TIMESTAMP),
(14, 14, 110, CURRENT_TIMESTAMP),
(15, 15, 95, CURRENT_TIMESTAMP),
(16, 16, 85, CURRENT_TIMESTAMP),
(17, 17, 55, CURRENT_TIMESTAMP),
(18, 18, 125, CURRENT_TIMESTAMP),
(19, 19, 45, CURRENT_TIMESTAMP),
(20, 20, 135, CURRENT_TIMESTAMP),
(21, 21, 30, CURRENT_TIMESTAMP),
(22, 22, 170, CURRENT_TIMESTAMP),
(23, 23, 25, CURRENT_TIMESTAMP),
(24, 24, 155, CURRENT_TIMESTAMP),
(25, 25, 145, CURRENT_TIMESTAMP),
(26, 26, 115, CURRENT_TIMESTAMP),
(27, 27, 185, CURRENT_TIMESTAMP),
(28, 28, 195, CURRENT_TIMESTAMP),
(29, 29, 50, CURRENT_TIMESTAMP),
(30, 30, 105, CURRENT_TIMESTAMP);


-- Index product_name, category_id, and price.
CREATE INDEX idx_product_name ON Products(product_name);
CREATE INDEX idx_category_id ON Products(category_id);
CREATE INDEX idx_price ON Products(price);

-- Use EXPLAIN to analyze filtered queries (e.g., WHERE price BETWEEN).
EXPLAIN SELECT * FROM Products WHERE price BETWEEN 100 AND 500;
EXPLAIN
SELECT * FROM Products
WHERE product_name LIKE 'Laptop%'
  AND category_id = 2;

-- Normalize product and category data to 3NF.
-- Denormalize by merging category_name into Products for faster reporting.
CREATE TABLE Products_Denorm (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT,
    category_name VARCHAR(100),
    price DECIMAL(10, 2),
    description TEXT
);
INSERT INTO Products_Denorm (product_id, product_name, category_id, category_name, price, description)
SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    c.category_name,
    p.price,
    p.description
FROM Products p
JOIN Categories c ON p.category_id = c.category_id;

-- Use LIMIT with pagination logic.
SELECT * FROM Products
ORDER BY price DESC
LIMIT 10 OFFSET 10;  -- OFFSET = (page - 1) * limit

-- project3:
-- 3. Library Book Search System
-- Domain: Education
-- Goal: Efficient book search and check-out history.
-- Requirements:
-- Tables: Books, Authors, BorrowHistory.
create database library;
use library;
CREATE TABLE Authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL
);
INSERT INTO Authors (author_id, author_name) VALUES
(1, 'J.K. Rowling'),
(2, 'George Orwell'),
(3, 'Jane Austen'),
(4, 'J.R.R. Tolkien'),
(5, 'Agatha Christie'),
(6, 'Mark Twain'),
(7, 'F. Scott Fitzgerald'),
(8, 'Ernest Hemingway'),
(9, 'Leo Tolstoy'),
(10, 'Stephen King');

CREATE TABLE Genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL
);
INSERT INTO Genres (genre_id, genre_name) VALUES
(1, 'Fantasy'),
(2, 'Mystery'),
(3, 'Romance'),
(4, 'Classic'),
(5, 'Horror');

CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    book_title VARCHAR(255) NOT NULL,
    author_id INT NOT NULL,
    genre_id INT NOT NULL,
    published_year INT,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id),
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);INSERT INTO Books (book_id, book_title, author_id, genre_id, published_year) VALUES
(1, 'Harry Potter and the Sorcerer\'s Stone', 1, 1, 1997),
(2, '1984', 2, 4, 1949),
(3, 'Pride and Prejudice', 3, 3, 1813),
(4, 'The Hobbit', 4, 1, 1937),
(5, 'Murder on the Orient Express', 5, 2, 1934),
(6, 'Adventures of Huckleberry Finn', 6, 4, 1884),
(7, 'The Great Gatsby', 7, 4, 1925),
(8, 'The Old Man and the Sea', 8, 4, 1952),
(9, 'War and Peace', 9, 4, 1869),
(10, 'The Shining', 10, 5, 1977),
(11, 'Harry Potter and the Chamber of Secrets', 1, 1, 1998),
(12, 'Harry Potter and the Prisoner of Azkaban', 1, 1, 1999),
(13, 'And Then There Were None', 5, 2, 1939),
(14, 'Emma', 3, 3, 1815),
(15, 'The Fellowship of the Ring', 4, 1, 1954),
(16, 'The Two Towers', 4, 1, 1954),
(17, 'The Return of the King', 4, 1, 1955),
(18, 'A Farewell to Arms', 8, 4, 1929),
(19, 'It', 10, 5, 1986),
(20, 'The Adventures of Tom Sawyer', 6, 4, 1876);

CREATE TABLE BorrowHistory (
    borrow_id INT PRIMARY KEY,
    book_id INT NOT NULL,
    borrower_name VARCHAR(100),
    borrow_date DATE NOT NULL,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

SELECT MAX(borrow_id) FROM BorrowHistory;

INSERT INTO BorrowHistory (borrow_id, book_id, borrower_name, borrow_date, return_date) VALUES
(16, 1, 'Alice Johnson', '2024-06-01', '2024-06-14'),
(17, 2, 'Bob Smith', '2024-06-03', '2024-06-20'),
(18, 3, 'Charlie Brown', '2024-06-10', '2024-06-25'),
(19, 4, 'Dana White', '2024-06-15', NULL),
(20, 5, 'Ella Fitzgerald', '2024-06-17', '2024-06-30'),
(21, 6, 'Frank Castle', '2024-07-01', NULL),
(22, 7, 'Grace Hopper', '2024-07-02', NULL),
(23, 8, 'Henry Ford', '2024-07-03', NULL),
(24, 9, 'Ivy Clark', '2024-07-04', NULL),
(25, 10, 'Jack Reacher', '2024-07-05', NULL),
(26, 11, 'Kate Winslet', '2024-07-06', NULL),
(27, 12, 'Liam Neeson', '2024-07-07', NULL),
(28, 13, 'Mona Lisa', '2024-07-08', NULL),
(29, 14, 'Nina Simone', '2024-07-09', NULL),
(30, 15, 'Oscar Wilde', '2024-07-09', NULL);


-- Index book_title, author_name, borrow_date.
CREATE INDEX idx_book_title ON Books(book_title);
CREATE INDEX idx_author_name ON Authors(author_name);
CREATE INDEX idx_borrow_date ON BorrowHistory(borrow_date);

-- Normalize into 3NF by separating Authors and Genres.
-- Use JOIN and EXPLAIN to evaluate performance.
EXPLAIN
SELECT b.book_title, a.author_name
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
WHERE a.author_name LIKE 'J.K.%';
EXPLAIN
SELECT bh.borrow_id, b.book_title, bh.borrower_name, bh.borrow_date
FROM BorrowHistory bh
JOIN Books b ON bh.book_id = b.book_id
WHERE bh.borrow_date BETWEEN '2024-06-01' AND '2024-06-30';
-- denormalzed view
CREATE VIEW BookBorrowReport AS
SELECT
    b.book_id,
    b.book_title,
    a.author_name,
    g.genre_name,
    bh.borrower_name,
    bh.borrow_date,
    bh.return_date
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Genres g ON b.genre_id = g.genre_id
LEFT JOIN BorrowHistory bh ON b.book_id = bh.book_id;
-- Denormalize into a reporting table with book_title, author_name, last_borrowed.
CREATE TABLE BookReport (
    book_id INT PRIMARY KEY,
    book_title VARCHAR(255),
    author_name VARCHAR(100),
    last_borrowed DATE
);
INSERT INTO BookReport (book_id, book_title, author_name, last_borrowed)
SELECT 
    b.book_id,
    b.book_title,
    a.author_name,
    MAX(bh.borrow_date) AS last_borrowed
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
LEFT JOIN BorrowHistory bh ON b.book_id = bh.book_id
GROUP BY b.book_id, b.book_title, a.author_name;
ALTER TABLE BookReport ADD COLUMN borrow_count INT;
UPDATE BookReport br
SET borrow_count = (
    SELECT COUNT(*) 
    FROM BorrowHistory bh
    WHERE bh.book_id = br.book_id
)
WHERE EXISTS (
    SELECT 1 FROM BorrowHistory bh2 WHERE bh2.book_id = br.book_id
);

-- Implement LIMIT for top borrowed books.
SELECT * FROM BookReport
ORDER BY borrow_count DESC
LIMIT 5;
SELECT * FROM BookReport
ORDER BY borrow_count DESC
LIMIT 5 OFFSET 5;  -- (PageNumber - 1) * PageSize

-- project4:
-- 4. Sales Dashboard with Performance Tuning
-- Domain: Sales
-- Goal: Fast reporting on sales trends.
-- Requirements:
-- Tables: Sales, Products, Customers, SalesPersons.
create database salesdashboard;
use salesdashboard;
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
INSERT INTO Products (product_id, product_name, price) VALUES
(1, 'Laptop', 1200.00),
(2, 'Smartphone', 800.00),
(3, 'Headphones', 150.00),
(4, 'Monitor', 300.00),
(5, 'Keyboard', 70.00),
(6, 'Mouse', 40.00),
(7, 'External Hard Drive', 100.00),
(8, 'Webcam', 90.00),
(9, 'Desk Lamp', 45.00),
(10, 'USB-C Hub', 60.00);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);
INSERT INTO Customers (customer_id, customer_name, contact_email) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com'),
(2, 'Bob Smith', 'bob.smith@example.com'),
(3, 'Charlie Brown', 'charlie.brown@example.com'),
(4, 'Dana White', 'dana.white@example.com'),
(5, 'Ella Fitzgerald', 'ella.fitzgerald@example.com'),
(6, 'Frank Castle', 'frank.castle@example.com'),
(7, 'Grace Hopper', 'grace.hopper@example.com'),
(8, 'Henry Ford', 'henry.ford@example.com'),
(9, 'Ivy Clark', 'ivy.clark@example.com'),
(10, 'Jack Reacher', 'jack.reacher@example.com');

CREATE TABLE SalesPersons (
    sales_person_id INT PRIMARY KEY,
    sales_person_name VARCHAR(100) NOT NULL
);
INSERT INTO SalesPersons (sales_person_id, sales_person_name) VALUES
(1, 'John Sales'),
(2, 'Mary Marketing'),
(3, 'Steve Seller'),
(4, 'Rachel Revenue'),
(5, 'David Deal'),
(6, 'Laura Lead'),
(7, 'Tom Target'),
(8, 'Sophie Sales'),
(9, 'Ethan Enterprise'),
(10, 'Nina Numbers');

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    sales_person_id INT NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (sales_person_id) REFERENCES SalesPersons(sales_person_id)
);
INSERT INTO Sales (sale_id, sale_date, product_id, customer_id, sales_person_id, quantity, total_amount) VALUES
(1, '2024-01-05', 1, 1, 1, 2, 2400.00),
(2, '2024-01-07', 3, 2, 2, 1, 150.00),
(3, '2024-01-10', 2, 3, 3, 1, 800.00),
(4, '2024-02-15', 5, 4, 4, 3, 210.00),
(5, '2024-02-20', 6, 5, 5, 5, 200.00),
(6, '2024-03-01', 4, 6, 6, 2, 600.00),
(7, '2024-03-05', 7, 7, 7, 1, 100.00),
(8, '2024-03-10', 8, 8, 8, 4, 360.00),
(9, '2024-03-15', 9, 9, 9, 2, 90.00),
(10, '2024-03-20', 10, 10, 10, 1, 60.00);

-- Index sale_date, product_id, customer_id.
CREATE INDEX idx_sale_date ON Sales(sale_date);
CREATE INDEX idx_product_id ON Sales(product_id);
CREATE INDEX idx_customer_id ON Sales(customer_id);

-- Use GROUP BY and HAVING to show total sales by month.
EXPLAIN
SELECT 
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    SUM(total_amount) AS total_sales
FROM Sales
GROUP BY sale_year, sale_month
HAVING total_sales > 10000;

-- Use EXPLAIN to detect full table scans.
EXPLAIN
SELECT s.sale_id, s.sale_date, c.customer_name, p.product_name, s.total_amount
FROM Sales s
JOIN Customers c ON s.customer_id = c.customer_id
JOIN Products p ON s.product_id = p.product_id
WHERE s.sale_date BETWEEN '2024-01-01' AND '2024-03-31'
  AND c.customer_name LIKE 'A%';

-- Normalize customer and sales data to 3NF.
CREATE TABLE CustomerContacts (
    contact_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    contact_type VARCHAR(50),  -- e.g., 'email', 'phone'
    contact_value VARCHAR(100),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Create denormalized summary table for quick report generation.
CREATE TABLE SalesSummary (
    sale_year INT,
    sale_month INT,
    product_id INT,
    total_quantity INT,
    total_sales DECIMAL(15,2),
    PRIMARY KEY (sale_year, sale_month, product_id)
);
INSERT INTO SalesSummary (sale_year, sale_month, product_id, total_quantity, total_sales)
SELECT 
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month,
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(total_amount) AS total_sales
FROM Sales
GROUP BY sale_year, sale_month, product_id;
select * from SalesSummary;
-- project5:
-- ✅ 5. Hospital Patient Records System
-- Domain: Healthcare
-- Goal: Fast access to patient visit data.
-- Requirements:
-- Tables: Patients, Visits, Doctors, Diagnoses.
create database hospital;
use hospital;
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    gender CHAR(1)
);
INSERT INTO Patients (patient_id, patient_name, date_of_birth, gender) VALUES
(1, 'John Doe', '1980-05-15', 'M'),
(2, 'Jane Smith', '1990-08-22', 'F'),
(3, 'Alice Johnson', '1975-12-30', 'F'),
(4, 'Bob Brown', '1985-03-10', 'M'),
(5, 'Carol White', '2000-01-05', 'F');

CREATE INDEX idx_patient_name ON Patients(patient_name);
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100)
);
INSERT INTO Doctors (doctor_id, doctor_name, specialty) VALUES
(1, 'Dr. Smith', 'Cardiology'),
(2, 'Dr. Jones', 'Neurology'),
(3, 'Dr. Taylor', 'General Medicine'),
(4, 'Dr. Wilson', 'Orthopedics'),
(5, 'Dr. Lee', 'Pediatrics');

CREATE INDEX idx_doctor_id ON Doctors(doctor_id);
CREATE TABLE Diagnoses (
    diagnosis_id INT PRIMARY KEY,
    diagnosis_name VARCHAR(255) NOT NULL
);
INSERT INTO Diagnoses (diagnosis_id, diagnosis_name) VALUES
(1, 'Hypertension'),
(2, 'Diabetes Mellitus'),
(3, 'Migraine'),
(4, 'Fracture'),
(5, 'Common Cold');

CREATE TABLE Visits (
    visit_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL,
    diagnosis_id INT,
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
    FOREIGN KEY (diagnosis_id) REFERENCES Diagnoses(diagnosis_id)
);
CREATE INDEX idx_visit_date ON Visits(visit_date);
INSERT INTO Visits (visit_id, patient_id, doctor_id, visit_date, diagnosis_id, notes) VALUES
(1, 1, 1, '2024-06-01', 1, 'Patient shows elevated blood pressure.'),
(2, 2, 2, '2024-06-05', 3, 'Frequent headaches, prescribed medication.'),
(3, 3, 3, '2024-06-07', NULL, 'Routine check-up.'),
(4, 1, 1, '2024-06-15', 2, 'Follow-up for diabetes management.'),
(5, 4, 4, '2024-06-20', 4, 'Broken arm, cast applied.'),
(6, 5, 5, '2024-06-25', 5, 'Symptoms of common cold.'),
(7, 2, 2, '2024-07-01', 3, 'Migraine medication adjusted.'),
(8, 3, 3, '2024-07-03', NULL, 'General health assessment.'),
(9, 4, 4, '2024-07-10', 4, 'Follow-up on fracture healing.'),
(10, 5, 5, '2024-07-12', 5, 'Cold symptoms improving.');


-- Create indexes on patient_name, doctor_id, visit_date.
-- Use JOIN and EXPLAIN to optimize patient history queries.
EXPLAIN
SELECT p.patient_name, v.visit_date, d.doctor_name, dg.diagnosis_name, v.notes
FROM Visits v
JOIN Patients p ON v.patient_id = p.patient_id
JOIN Doctors d ON v.doctor_id = d.doctor_id
LEFT JOIN Diagnoses dg ON v.diagnosis_id = dg.diagnosis_id
WHERE p.patient_name LIKE 'John%'
ORDER BY v.visit_date DESC
LIMIT 10;

-- Normalize data up to 3NF.
-- Create a denormalized flat table for quick doctor-wise reporting.
CREATE TABLE DoctorVisitReport (
    visit_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    doctor_name VARCHAR(100),
    visit_date DATE,
    diagnosis_name VARCHAR(255),
    notes TEXT
);

INSERT INTO DoctorVisitReport (visit_id, patient_name, doctor_name, visit_date, diagnosis_name, notes)
SELECT 
    v.visit_id,
    p.patient_name,
    d.doctor_name,
    v.visit_date,
    dg.diagnosis_name,
    v.notes
FROM Visits v
JOIN Patients p ON v.patient_id = p.patient_id
JOIN Doctors d ON v.doctor_id = d.doctor_id
LEFT JOIN Diagnoses dg ON v.diagnosis_id = dg.diagnosis_id;
CREATE INDEX idx_doctor_name ON DoctorVisitReport(doctor_name);

-- Use LIMIT to show top 10 recent visits.
SELECT * 
FROM DoctorVisitReport
WHERE doctor_name = 'Dr. Smith'
ORDER BY visit_date DESC
LIMIT 10;

-- project6:
-- 6. Online Course Enrollment Platform
-- Domain: E-learning
-- Goal: Speed up enrollments and search.
-- Requirements:
-- Tables: Students, Courses, Enrollments.
create database onlinecourse;
use onlinecourse;
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);
INSERT INTO Students (student_id, student_name, email) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com'),
(2, 'Bob Smith', 'bob.smith@example.com'),
(3, 'Charlie Brown', 'charlie.brown@example.com'),
(4, 'Diana Prince', 'diana.prince@example.com'),
(5, 'Ethan Hunt', 'ethan.hunt@example.com');

CREATE INDEX idx_student_name ON Students(student_name);
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    course_description TEXT
);
INSERT INTO Courses (course_id, course_name, course_description) VALUES
(101, 'Introduction to Python', 'Learn Python basics and programming logic.'),
(102, 'Data Structures', 'Covers arrays, linked lists, stacks, and queues.'),
(103, 'Database Systems', 'Introduction to relational databases and SQL.'),
(104, 'Web Development', 'HTML, CSS, JavaScript, and backend fundamentals.'),
(105, 'Machine Learning', 'Supervised and unsupervised learning techniques.');

CREATE INDEX idx_course_name ON Courses(course_name);
CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enroll_date DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);
CREATE INDEX idx_enroll_date ON Enrollments(enroll_date);
INSERT INTO Enrollments (enrollment_id, student_id, course_id, enroll_date) VALUES
(1001, 1, 101, '2024-06-01'),
(1002, 2, 102, '2024-06-02'),
(1003, 3, 103, '2024-06-03'),
(1004, 1, 104, '2024-06-10'),
(1005, 4, 101, '2024-06-15'),
(1006, 5, 105, '2024-06-20'),
(1007, 2, 103, '2024-07-01'),
(1008, 3, 104, '2024-07-05'),
(1009, 4, 105, '2024-07-07'),
(1010, 5, 102, '2024-07-09');

-- Index student_name, course_name, enroll_date.
-- Normalize to 3NF to avoid course data duplication.
-- Use EXPLAIN to compare JOIN vs subquery performance.
EXPLAIN
SELECT e.enrollment_id, s.student_name, c.course_name, e.enroll_date
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id
WHERE s.student_name LIKE 'A%'
ORDER BY e.enroll_date DESC
LIMIT 10;

EXPLAIN
SELECT enrollment_id,
    (SELECT student_name FROM Students WHERE student_id = e.student_id) AS student_name,
    (SELECT course_name FROM Courses WHERE course_id = e.course_id) AS course_name,
    enroll_date
FROM Enrollments e
WHERE enrollment_id IN (
    SELECT enrollment_id FROM Enrollments e2
    JOIN Students s ON e2.student_id = s.student_id
    WHERE s.student_name LIKE 'A%'
)
ORDER BY enroll_date DESC
LIMIT 10;

-- Denormalize for reporting by combining course and student details.
CREATE TABLE EnrollmentReport (
    enrollment_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    course_name VARCHAR(255),
    enroll_date DATE
);
INSERT INTO EnrollmentReport (enrollment_id, student_name, course_name, enroll_date)
SELECT e.enrollment_id, s.student_name, c.course_name, e.enroll_date
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id;
select * from EnrollmentReport;
CREATE INDEX idx_student_enroll ON EnrollmentReport(student_name, enroll_date DESC);

-- Use LIMIT to show latest 5 enrollments per student.
SELECT enrollment_id, student_name, course_name, enroll_date
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY student_name ORDER BY enroll_date DESC) AS rn
    FROM EnrollmentReport
) sub
WHERE rn <= 2
ORDER BY student_name, enroll_date DESC;
-- project7:
-- 7. Ticket Booking System (Bus/Train)
-- Domain: Travel
-- Goal: Speed up ticket lookup and booking process.
-- Requirements:
-- Tables: Bookings, Passengers, Routes, Vehicles.
create database ticketbooking;
use ticketbooking;
CREATE TABLE Passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);
INSERT INTO Passengers (passenger_id, passenger_name, contact_email) VALUES
(1, 'Alice Johnson', 'alice@example.com'),
(2, 'Bob Smith', 'bob@example.com'),
(3, 'Charlie Brown', 'charlie@example.com'),
(4, 'Diana Prince', 'diana@example.com'),
(5, 'Ethan Hunt', 'ethan@example.com');

CREATE INDEX idx_passenger_name ON Passengers(passenger_name);
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY,
    vehicle_type VARCHAR(20), -- e.g., 'Bus', 'Train'
    capacity INT
);
INSERT INTO Vehicles (vehicle_id, vehicle_type, capacity) VALUES
(101, 'Bus', 50),
(102, 'Train', 200),
(103, 'Bus', 40),
(104, 'Train', 150),
(105, 'Bus', 45);


CREATE TABLE Cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL
);
INSERT INTO Cities (city_id, city_name) VALUES
(1, 'New York'),
(2, 'Boston'),
(3, 'Chicago'),
(4, 'Philadelphia'),
(5, 'Washington D.C.');

CREATE TABLE Routes (
    route_id INT PRIMARY KEY,
    origin_city_id INT,
    destination_city_id INT,
    departure_time TIME,
    arrival_time TIME,
    FOREIGN KEY (origin_city_id) REFERENCES Cities(city_id),
    FOREIGN KEY (destination_city_id) REFERENCES Cities(city_id)
);
CREATE INDEX idx_route_id ON Routes(route_id);
INSERT INTO Routes (route_id, origin_city_id, destination_city_id, departure_time, arrival_time) VALUES
(101, 1, 2, '08:00:00', '12:00:00'),
(102, 2, 3, '10:00:00', '15:00:00'),
(103, 3, 4, '09:30:00', '13:00:00'),
(104, 4, 5, '11:00:00', '14:30:00'),
(105, 5, 1, '13:00:00', '18:00:00');

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    passenger_id INT,
    route_id INT,
    vehicle_id INT,
    booking_date DATE,
    seat_number INT,
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id),
    FOREIGN KEY (route_id) REFERENCES Routes(route_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);
CREATE INDEX idx_booking_date ON Bookings(booking_date);
INSERT INTO Bookings (booking_id, passenger_id, route_id, vehicle_id, booking_date, seat_number) VALUES
(1001, 1, 101, 101, '2024-07-01', 12),
(1002, 2, 101, 101, '2024-07-01', 15),
(1003, 3, 102, 102, '2024-07-02', 22),
(1004, 4, 103, 103, '2024-07-03', 8),
(1005, 5, 104, 104, '2024-07-04', 33),
(1006, 1, 105, 105, '2024-07-05', 4);


-- Index route_id, booking_date, passenger_name.
-- Use EXPLAIN to analyze filtered queries like "next available trips".
EXPLAIN
SELECT r.route_id, c1.city_name AS origin, c2.city_name AS destination, r.departure_time
FROM Routes r
JOIN Cities c1 ON r.origin_city_id = c1.city_id
JOIN Cities c2 ON r.destination_city_id = c2.city_id
WHERE r.departure_time > CURRENT_TIME
ORDER BY r.departure_time
LIMIT 5;

-- Normalize all lookup tables (e.g., city names, route details).
-- Create denormalized flat table for schedule display.
CREATE TABLE ScheduleDisplay (
    schedule_id INT PRIMARY KEY,
    route_id INT,
    origin VARCHAR(100),
    destination VARCHAR(100),
    departure_time TIME,
    arrival_time TIME,
    vehicle_type VARCHAR(20),
    total_seats INT,
    available_seats INT
);
INSERT INTO ScheduleDisplay (schedule_id, route_id, origin, destination, departure_time, arrival_time, vehicle_type, total_seats, available_seats)
SELECT 
    r.route_id,
    r.route_id,
    c1.city_name,
    c2.city_name,
    r.departure_time,
    r.arrival_time,
    v.vehicle_type,
    v.capacity,
    v.capacity - IFNULL(b.booked, 0) AS available_seats
FROM Routes r
JOIN Cities c1 ON r.origin_city_id = c1.city_id
JOIN Cities c2 ON r.destination_city_id = c2.city_id
JOIN Vehicles v ON v.vehicle_id = r.route_id
LEFT JOIN (
    SELECT route_id, COUNT(*) AS booked
    FROM Bookings
    GROUP BY route_id
) b ON r.route_id = b.route_id;
select * from  ScheduleDisplay;
-- Implement pagination using LIMIT for available seats.
SELECT * FROM ScheduleDisplay
WHERE available_seats > 0
ORDER BY departure_time
LIMIT 10 OFFSET 0;
-- project8:
-- 8. Banking Transaction Monitor
-- Domain: Finance
-- Goal: Fast transaction retrieval and fraud detection.
-- Requirements:
-- Tables: Accounts, Transactions, Customers.
create database bankingtxn;
use bankingtxn;
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);
INSERT INTO Customers (customer_id, customer_name, email) VALUES
(1, 'Alice Johnson', 'alice@example.com'),
(2, 'Bob Smith', 'bob@example.com'),
(3, 'Charlie Brown', 'charlie@example.com'),
(4, 'Diana Prince', 'diana@example.com'),
(5, 'Ethan Hunt', 'ethan@example.com');

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_type VARCHAR(50),
    open_date DATE,
    balance DECIMAL(15, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO Accounts (account_id, customer_id, account_type, open_date, balance) VALUES
(101, 1, 'Savings', '2022-01-01', 15000.00),
(102, 2, 'Checking', '2022-05-10', 7200.00),
(103, 3, 'Savings', '2023-03-15', 18500.00),
(104, 4, 'Business', '2023-08-01', 30200.00),
(105, 5, 'Checking', '2024-02-20', 4200.00);

CREATE INDEX idx_account_customer ON Accounts(customer_id);
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_date DATETIME NOT NULL,
    amount DECIMAL(15, 2),
    transaction_type VARCHAR(20), -- e.g., 'DEPOSIT', 'WITHDRAWAL', 'TRANSFER'
    description TEXT,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);
INSERT INTO Transactions (transaction_id, account_id, transaction_date, amount, transaction_type, description) VALUES
(1001, 101, '2024-07-01 09:30:00', 2000.00, 'DEPOSIT', 'Paycheck deposit'),
(1002, 101, '2024-07-03 11:15:00', 15000.00, 'WITHDRAWAL', 'Car purchase'),
(1003, 102, '2024-07-02 14:00:00', 500.00, 'WITHDRAWAL', 'Grocery shopping'),
(1004, 103, '2024-07-01 16:45:00', 300.00, 'DEPOSIT', 'Refund'),
(1005, 104, '2024-07-04 10:00:00', 12000.00, 'TRANSFER', 'Supplier payment'),
(1006, 105, '2024-07-04 17:20:00', 100.00, 'WITHDRAWAL', 'ATM withdrawal'),
(1007, 103, '2024-07-05 08:30:00', 8000.00, 'WITHDRAWAL', 'Tuition payment'),
(1008, 102, '2024-07-05 09:00:00', 2000.00, 'DEPOSIT', 'Bonus'),
(1009, 105, '2024-07-05 11:00:00', 350.00, 'WITHDRAWAL', 'Fuel'),
(1010, 101, '2024-07-05 12:00:00', 10000.00, 'WITHDRAWAL', 'Rent');

CREATE INDEX idx_account_id ON Transactions(account_id);
CREATE INDEX idx_transaction_date ON Transactions(transaction_date);
CREATE INDEX idx_amount ON Transactions(amount);

-- Index account_id, transaction_date, amount.
-- Use EXPLAIN for queries like "suspicious high-value transactions".
EXPLAIN
SELECT t.transaction_id, a.account_id, c.customer_name, t.amount, t.transaction_date
FROM Transactions t
JOIN Accounts a ON t.account_id = a.account_id
JOIN Customers c ON a.customer_id = c.customer_id
WHERE t.amount > 10000
ORDER BY t.transaction_date DESC;

-- Normalize customers and accounts data to 3NF.
-- Create denormalized reporting view for account statements.
CREATE VIEW AccountStatementView AS
SELECT 
    t.transaction_id,
    c.customer_name,
    a.account_id,
    a.account_type,
    t.transaction_date,
    t.transaction_type,
    t.amount,
    t.description
FROM Transactions t
JOIN Accounts a ON t.account_id = a.account_id
JOIN Customers c ON a.customer_id = c.customer_id;

-- Use LIMIT for recent transactions.
SELECT *
FROM AccountStatementView
WHERE account_id = 101
ORDER BY transaction_date DESC
LIMIT 5;
CREATE TABLE AccountStatementReport (
    transaction_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    account_id INT,
    account_type VARCHAR(50),
    transaction_date DATETIME,
    transaction_type VARCHAR(20),
    amount DECIMAL(15,2),
    description TEXT
);
INSERT INTO AccountStatementReport
SELECT * FROM AccountStatementView;
-- project9:
-- 9. Warehouse Inventory Optimizer
-- Domain: Logistics
-- Goal: Improve item lookup and stock tracking.
-- Requirements:
-- Tables: Items, Warehouses, StockMovements.
-- Index item_name, warehouse_id, movement_date.
-- Normalize into Items, ItemCategories, StockMovementTypes.
use warehouse;
CREATE TABLE ItemCategories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);
INSERT INTO ItemCategories (category_id, category_name) VALUES
(1, 'Hardware'),
(2, 'Electronics'),
(3, 'Packaging'),
(4, 'Tools'),
(5, 'Office Supplies');
CREATE TABLE Items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES ItemCategories(category_id)
);
INSERT INTO Items (item_id, item_name, category_id) VALUES
(1, 'Hex Bolt', 1),
(2, 'Screwdriver', 4),
(3, 'Packing Tape', 3),
(4, 'LED Light', 2),
(5, 'Notebook', 5),
(6, 'Nuts', 1),
(7, 'Wire Cutter', 4),
(8, 'USB Cable', 2),
(9, 'Stapler', 5),
(10, 'Bubble Wrap', 3);

CREATE INDEX idx_item_name ON Items(item_name);
CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(100) NOT NULL,
    location VARCHAR(255)
);
INSERT INTO Warehouses (warehouse_id, warehouse_name, location) VALUES
(1, 'Central Warehouse', 'New York'),
(2, 'East Depot', 'Boston'),
(3, 'West Storage', 'Chicago');

CREATE INDEX idx_warehouse_id ON Warehouses(warehouse_id);
CREATE TABLE StockMovementTypes (
    movement_type_id INT PRIMARY KEY,
    movement_type_name VARCHAR(50) NOT NULL -- e.g., 'IN', 'OUT', 'TRANSFER'
);
INSERT INTO StockMovementTypes (movement_type_id, movement_type_name) VALUES
(1, 'IN'),
(2, 'OUT'),
(3, 'TRANSFER');

CREATE TABLE StockMovements (
    movement_id INT PRIMARY KEY,
    item_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    movement_type_id INT NOT NULL,
    quantity INT NOT NULL,
    movement_date DATE NOT NULL,
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id),
    FOREIGN KEY (movement_type_id) REFERENCES StockMovementTypes(movement_type_id)
);
INSERT INTO StockMovements (movement_id, item_id, warehouse_id, movement_type_id, quantity, movement_date) VALUES
(1001, 1, 1, 1, 100, '2024-06-01'),
(1002, 1, 1, 2, 20, '2024-06-05'),
(1003, 2, 1, 1, 50, '2024-06-03'),
(1004, 3, 2, 1, 200, '2024-06-10'),
(1005, 4, 3, 1, 80, '2024-06-15'),
(1006, 5, 2, 1, 120, '2024-06-18'),
(1007, 1, 2, 1, 70, '2024-06-20'),
(1008, 6, 1, 1, 150, '2024-06-21'),
(1009, 6, 1, 2, 145, '2024-07-01'),
(1010, 7, 3, 1, 60, '2024-07-02'),
(1011, 8, 2, 1, 30, '2024-07-03'),
(1012, 9, 1, 1, 90, '2024-07-04'),
(1013, 10, 2, 1, 200, '2024-07-05'),
(1014, 3, 2, 2, 195, '2024-07-06'),
(1015, 5, 2, 2, 110, '2024-07-07');

CREATE INDEX idx_movement_date ON StockMovements(movement_date);
-- Use EXPLAIN and ORDER BY with indexed columns.
EXPLAIN
SELECT sm.movement_id, i.item_name, sm.quantity, sm.movement_date
FROM StockMovements sm
JOIN Items i ON sm.item_id = i.item_id
WHERE i.item_name LIKE 'Bolt%'
ORDER BY sm.movement_date DESC
LIMIT 10;

-- Create denormalized summary table for stock levels.
CREATE TABLE StockSummary (
    item_id INT,
    item_name VARCHAR(100),
    warehouse_id INT,
    warehouse_name VARCHAR(100),
    current_stock INT,
    PRIMARY KEY (item_id, warehouse_id)
);
INSERT INTO StockSummary (item_id, item_name, warehouse_id, warehouse_name, current_stock)
SELECT 
    i.item_id,
    i.item_name,
    w.warehouse_id,
    w.warehouse_name,
    SUM(CASE smt.movement_type_name
        WHEN 'IN' THEN sm.quantity
        WHEN 'OUT' THEN -sm.quantity
        ELSE 0 END) AS current_stock
FROM StockMovements sm
JOIN Items i ON sm.item_id = i.item_id
JOIN Warehouses w ON sm.warehouse_id = w.warehouse_id
JOIN StockMovementTypes smt ON sm.movement_type_id = smt.movement_type_id
GROUP BY i.item_id, w.warehouse_id;

-- Limit rows when displaying low stock alerts.
SELECT * FROM StockSummary
WHERE current_stock <= 10
ORDER BY current_stock ASC
LIMIT 10;
-- project10:
-- 10. Online Forum or Blog Platform
-- Domain: Content Management
-- Goal: Optimize post and comment loading.
-- Requirements:
-- Tables: Users, Posts, Comments.
-- Index user_id, post_date, post_title.
-- Normalize into 3NF.
create database onlineforum;
use onlineforum;
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);
INSERT INTO Users (user_id, username, email) VALUES
(1, 'alice', 'alice@example.com'),
(2, 'bob', 'bob@example.com'),
(3, 'charlie', 'charlie@example.com'),
(4, 'diana', 'diana@example.com'),
(5, 'ethan', 'ethan@example.com');

CREATE TABLE Posts (
    post_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    post_title VARCHAR(255),
    post_content TEXT,
    post_date DATETIME,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
INSERT INTO Posts (post_id, user_id, post_title, post_content, post_date) VALUES
(101, 1, 'Welcome to the Forum', 'This is our first post!', '2024-07-01 10:00:00'),
(102, 2, 'Tips for Beginners', 'Here are some tips to get started...', '2024-07-02 12:15:00'),
(103, 3, 'How to Customize Your Profile', 'You can update your info under settings.', '2024-07-03 14:30:00'),
(104, 4, 'Bug Reporting Guidelines', 'Please follow this format for bug reports.', '2024-07-04 16:00:00'),
(105, 5, 'Feature Requests', 'Tell us what features you want!', '2024-07-05 17:45:00');

CREATE INDEX idx_post_user_id ON Posts(user_id);
CREATE INDEX idx_post_title ON Posts(post_title);
CREATE INDEX idx_post_date ON Posts(post_date);
CREATE TABLE Comments (
    comment_id INT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT,
    comment_date DATETIME,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
INSERT INTO Comments (comment_id, post_id, user_id, comment_text, comment_date) VALUES
(1001, 101, 2, 'Thanks for launching this platform!', '2024-07-01 11:00:00'),
(1002, 101, 3, 'Excited to be here!', '2024-07-01 11:15:00'),
(1003, 102, 1, 'Great tips, very helpful.', '2024-07-02 13:00:00'),
(1004, 103, 4, 'This helped me update my profile.', '2024-07-03 15:00:00'),
(1005, 104, 5, 'Will follow the template next time.', '2024-07-04 17:00:00'),
(1006, 105, 2, 'Can we get dark mode?', '2024-07-05 18:00:00'),
(1007, 105, 3, '+1 for dark mode!', '2024-07-05 18:10:00');

CREATE INDEX idx_comment_post_id ON Comments(post_id);
CREATE INDEX idx_comment_date ON Comments(comment_date);

-- Use EXPLAIN to optimize comment fetching per post.
EXPLAIN
SELECT c.comment_id, c.comment_text, c.comment_date, u.username
FROM Comments c
JOIN Users u ON c.user_id = u.user_id
WHERE c.post_id = 101
ORDER BY c.comment_date DESC
LIMIT 10;

-- Create denormalized view with post + comment + author data.
CREATE VIEW PostCommentAuthorView AS
SELECT 
    p.post_id,
    p.post_title,
    p.post_date,
    p.post_content,
    u.username AS post_author,
    c.comment_id,
    c.comment_text,
    c.comment_date,
    cu.username AS comment_author
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
LEFT JOIN Comments c ON p.post_id = c.post_id
LEFT JOIN Users cu ON c.user_id = cu.user_id;

-- Use LIMIT for recent posts and recent comments.
SELECT * FROM Posts
ORDER BY post_date DESC
LIMIT 5;
SELECT * FROM Comments
ORDER BY comment_date DESC
LIMIT 5;
-- project11
-- 11. Order Fulfillment System
-- Domain: E-Commerce
-- Goal: Speed up dispatch and delivery lookup.
-- Requirements:
-- Tables: Orders, OrderItems, Shipments, Customers.
-- Index order_date, shipment_status, customer_id.
create database ecommerce1;
use ecommerce1;
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);
INSERT INTO Customers (customer_id, customer_name, email) VALUES
(1, 'Alice Johnson', 'alice@example.com'),
(2, 'Bob Smith', 'bob@example.com'),
(3, 'Charlie Brown', 'charlie@example.com'),
(4, 'Diana Prince', 'diana@example.com'),
(5, 'Ethan Hunt', 'ethan@example.com');

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);
INSERT INTO Products (product_id, product_name, price) VALUES
(101, 'Wireless Mouse', 25.99),
(102, 'Laptop Stand', 45.00),
(103, 'USB-C Cable', 9.99),
(104, 'Bluetooth Keyboard', 39.50),
(105, 'Notebook Cooling Pad', 29.95);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE,
    total_amount DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO Orders (order_id, customer_id, order_date, total_amount) VALUES
(1001, 1, '2024-07-01', 80.99),
(1002, 2, '2024-07-02', 129.95),
(1003, 3, '2024-07-03', 84.99),
(1004, 4, '2024-07-04', 25.99),
(1005, 5, '2024-07-05', 75.00);

CREATE INDEX idx_order_date ON Orders(order_date);
CREATE INDEX idx_order_customer ON Orders(customer_id);
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
INSERT INTO OrderItems (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 101, 1, 25.99),
(2, 1001, 103, 3, 9.99),
(3, 1002, 104, 2, 39.50),
(4, 1002, 105, 1, 29.95),
(5, 1003, 102, 1, 45.00),
(6, 1003, 103, 4, 9.99),
(7, 1004, 101, 1, 25.99),
(8, 1005, 105, 2, 29.95),
(9, 1005, 103, 1, 9.99);

CREATE TABLE Shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    shipment_date DATE,
    delivery_date DATE,
    shipment_status VARCHAR(50), -- e.g. Pending, Shipped, Delivered
    tracking_number VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);
INSERT INTO Shipments (shipment_id, order_id, shipment_date, delivery_date, shipment_status, tracking_number) VALUES
(501, 1001, '2024-07-02', '2024-07-04', 'Delivered', 'TRK1001'),
(502, 1002, '2024-07-03', NULL, 'Pending', 'TRK1002'),
(503, 1003, '2024-07-04', '2024-07-07', 'Delivered', 'TRK1003'),
(504, 1004, '2024-07-05', NULL, 'Shipped', 'TRK1004'),
(505, 1005, '2024-07-06', NULL, 'Pending', 'TRK1005');

CREATE INDEX idx_shipment_status ON Shipments(shipment_status);

-- Use JOIN and EXPLAIN to optimize dispatch queries.
EXPLAIN
SELECT o.order_id, c.customer_name, s.shipment_status, s.shipment_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Shipments s ON o.order_id = s.order_id
WHERE s.shipment_status = 'Pending'
ORDER BY s.shipment_date ASC
LIMIT 10;

-- Normalize product and order details to 3NF.
-- Denormalize for quick delivery dashboard display.
CREATE  VIEW DeliveryDashboard AS
SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    s.shipment_date,
    s.delivery_date,
    s.shipment_status,
    s.tracking_number,
    SUM(oi.quantity) AS total_items,
    SUM(oi.unit_price * oi.quantity) AS item_total
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Shipments s ON o.order_id = s.order_id
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_id, o.order_date, c.customer_name, s.shipment_date,
    s.delivery_date, s.shipment_status, s.tracking_number;
drop view deliverydashboard;
SELECT *
FROM DeliveryDashboard;
-- Use LIMIT to load only pending deliveries.
SELECT *
FROM DeliveryDashboard
WHERE shipment_status = 'Pending'
ORDER BY shipment_date ASC
LIMIT 10;

-- project12:
-- 12. Gym Membership and Attendance Tracker
-- Domain: Fitness
-- Goal: Optimize member check-in and plan tracking.
-- Requirements:
-- Tables: Members, Plans, CheckIns, Trainers.
-- Index member_name, checkin_date, plan_type.
create database gymmember;
use gymmember;
-- 1. Plans table
CREATE TABLE Plans (
    plan_id INT PRIMARY KEY,
    plan_type VARCHAR(50) NOT NULL,
    duration_months INT NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
CREATE INDEX idx_plan_type ON Plans(plan_type);

-- 2. Trainers table
CREATE TABLE Trainers (
    trainer_id INT PRIMARY KEY,
    trainer_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100)
);

-- 3. Members table
CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    plan_id INT,
    trainer_id INT,
    FOREIGN KEY (plan_id) REFERENCES Plans(plan_id),
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id)
);
CREATE INDEX idx_member_name ON Members(member_name);

-- 4. CheckIns table
CREATE TABLE CheckIns (
    checkin_id INT PRIMARY KEY,
    member_id INT NOT NULL,
    checkin_date DATETIME NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Members(member_id)
);
CREATE INDEX idx_checkin_date ON CheckIns(checkin_date);

-- Plans
INSERT INTO Plans (plan_id, plan_type, duration_months, price) VALUES
(1, 'Monthly', 1, 30.00),
(2, 'Quarterly', 3, 80.00),
(3, 'Yearly', 12, 300.00);

-- Trainers
INSERT INTO Trainers (trainer_id, trainer_name, specialty) VALUES
(1, 'John Doe', 'Strength Training'),
(2, 'Jane Smith', 'Yoga'),
(3, 'Mike Brown', 'Cardio');

-- Members
INSERT INTO Members (member_id, member_name, email, plan_id, trainer_id) VALUES
(1, 'Alice Johnson', 'alice@example.com', 1, 1),
(2, 'Bob Smith', 'bob@example.com', 2, 2),
(3, 'Charlie Brown', 'charlie@example.com', 3, 3),
(4, 'Diana Prince', 'diana@example.com', 1, 1),
(5, 'Ethan Hunt', 'ethan@example.com', 2, 2);

-- CheckIns
INSERT INTO CheckIns (checkin_id, member_id, checkin_date) VALUES
(1, 1, '2025-07-01 08:00:00'),
(2, 2, '2025-07-01 09:00:00'),
(3, 3, '2025-07-02 07:30:00'),
(4, 1, '2025-07-03 08:15:00'),
(5, 4, '2025-07-03 10:00:00'),
(6, 5, '2025-07-04 07:45:00'),
(7, 2, '2025-07-05 08:30:00'),
(8, 3, '2025-07-06 09:00:00'),
(9, 4, '2025-07-06 10:30:00'),
(10, 5, '2025-07-07 08:45:00');
-- optimised search
-- Search members by name (fast via index)
SELECT * FROM Members WHERE member_name LIKE '%Alice%';

-- Get check-ins on a specific date (fast via index)
SELECT * FROM CheckIns WHERE DATE(checkin_date) = '2025-07-03';

-- Search plans by type
SELECT * FROM Plans WHERE plan_type = 'Monthly';

-- Normalize member plans and visits.
-- Denormalize for trainer-wise dashboard.
CREATE OR REPLACE VIEW TrainerDashboard AS
SELECT 
    t.trainer_id,
    t.trainer_name,
    p.plan_type,
    m.member_name,
    COUNT(c.checkin_id) AS total_checkins
FROM Trainers t
JOIN Members m ON t.trainer_id = m.trainer_id
JOIN Plans p ON m.plan_id = p.plan_id
LEFT JOIN CheckIns c ON m.member_id = c.member_id
GROUP BY t.trainer_id, t.trainer_name, p.plan_type, m.member_name;

SELECT * FROM TrainerDashboard ORDER BY total_checkins DESC LIMIT 10;

-- Use LIMIT and ORDER BY for recent check-ins.
SELECT c.checkin_id, m.member_name, c.checkin_date
FROM CheckIns c
JOIN Members m ON c.member_id = m.member_id
ORDER BY c.checkin_date DESC
LIMIT 10;
-- project13:
-- 13. Restaurant Order & Kitchen Monitor
-- Domain: F&B
-- Goal: Speed up kitchen view of incoming orders.
-- Requirements:
-- Tables: Orders, MenuItems, Tables, Chefs.
-- Index order_status, table_id, order_time.
create database restaurantorder;
use restaurantorder;
-- 1. Tables (restaurant tables where customers sit)
CREATE TABLE Tables (
    table_id INT PRIMARY KEY,
    table_number INT NOT NULL,
    capacity INT NOT NULL
);
CREATE INDEX idx_table_number ON Tables(table_number);

-- 2. Chefs (kitchen staff)
CREATE TABLE Chefs (
    chef_id INT PRIMARY KEY,
    chef_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100)
);

-- 3. MenuItems (food items)
CREATE TABLE MenuItems (
    menu_item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50)
);
CREATE INDEX idx_item_name ON MenuItems(item_name);

-- 4. Orders (orders placed by customers)
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    table_id INT NOT NULL,
    order_status VARCHAR(20) NOT NULL,  -- e.g., 'Pending', 'Preparing', 'Served'
    order_time DATETIME NOT NULL,
    chef_id INT,
    FOREIGN KEY (table_id) REFERENCES Tables(table_id),
    FOREIGN KEY (chef_id) REFERENCES Chefs(chef_id)
);
CREATE INDEX idx_order_status ON Orders(order_status);
CREATE INDEX idx_table_id ON Orders(table_id);
CREATE INDEX idx_order_time ON Orders(order_time);

-- 5. OrderItems (items ordered in each order)
CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES MenuItems(menu_item_id)
);
-- Tables
INSERT INTO Tables (table_id, table_number, capacity) VALUES
(1, 101, 4),
(2, 102, 2),
(3, 103, 6),
(4, 104, 4),
(5, 105, 8);

-- Chefs
INSERT INTO Chefs (chef_id, chef_name, specialty) VALUES
(1, 'Gordon Ramsay', 'Grill'),
(2, 'Jamie Oliver', 'Italian'),
(3, 'Nigella Lawson', 'Desserts');

-- MenuItems
INSERT INTO MenuItems (menu_item_id, item_name, price, category) VALUES
(1, 'Margherita Pizza', 8.99, 'Pizza'),
(2, 'Caesar Salad', 6.50, 'Salad'),
(3, 'Spaghetti Carbonara', 12.00, 'Pasta'),
(4, 'Grilled Chicken', 15.50, 'Main Course'),
(5, 'Chocolate Cake', 5.00, 'Dessert');

-- Orders
INSERT INTO Orders (order_id, table_id, order_status, order_time, chef_id) VALUES
(1001, 1, 'Pending', '2025-07-09 12:15:00', 1),
(1002, 2, 'Preparing', '2025-07-09 12:20:00', 2),
(1003, 3, 'Pending', '2025-07-09 12:25:00', 1),
(1004, 4, 'Served', '2025-07-09 12:30:00', 3),
(1005, 5, 'Pending', '2025-07-09 12:35:00', 2),
(1006, 1, 'Pending', '2025-07-09 12:40:00', 1);

-- OrderItems
INSERT INTO OrderItems (order_item_id, order_id, menu_item_id, quantity) VALUES
(1, 1001, 1, 2),
(2, 1001, 2, 1),
(3, 1002, 3, 1),
(4, 1003, 4, 2),
(5, 1004, 5, 1),
(6, 1005, 1, 1),
(7, 1005, 4, 1),
(8, 1006, 2, 3);

-- Normalize to separate menu details and orders.
-- Use EXPLAIN to detect performance issues.
EXPLAIN
SELECT o.order_id, t.table_number, o.order_status, o.order_time, c.chef_name
FROM Orders o
JOIN Tables t ON o.table_id = t.table_id
JOIN Chefs c ON o.chef_id = c.chef_id
WHERE o.order_status = 'Pending'
ORDER BY o.order_time ASC;

-- Create denormalized view for kitchen display.
CREATE  VIEW KitchenDisplay AS
SELECT
    o.order_id,
    t.table_number,
    o.order_status,
    o.order_time,
    c.chef_name,
    GROUP_CONCAT(CONCAT(oi.quantity, 'x ', mi.item_name) SEPARATOR ', ') AS items_ordered
FROM Orders o
JOIN Tables t ON o.table_id = t.table_id
JOIN Chefs c ON o.chef_id = c.chef_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN MenuItems mi ON oi.menu_item_id = mi.menu_item_id
GROUP BY o.order_id, t.table_number, o.order_status, o.order_time, c.chef_name
ORDER BY o.order_time ASC;

-- Show only top 5 pending orders using LIMIT.
SELECT * FROM KitchenDisplay
WHERE order_status = 'Pending'
ORDER BY order_time ASC
LIMIT 5;

-- project14:
-- 14. Vehicle Service Booking System
-- Domain: Automobile
-- Goal: Track and optimize service bookings.
-- Requirements:
-- Tables: Bookings, Vehicles, Customers, Services.
-- Index vehicle_id, service_date, customer_name.
-- Normalize to 3NF.
create database vehicle;
use vehicle;
-- Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);
CREATE INDEX idx_customer_name ON Customers(customer_name);

-- Vehicles table
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_make VARCHAR(50),
    vehicle_model VARCHAR(50),
    vehicle_year INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
CREATE INDEX idx_vehicle_id ON Vehicles(vehicle_id);

-- Services table
CREATE TABLE Services (
    service_id INT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    service_description TEXT
);

-- Bookings table
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    service_id INT NOT NULL,
    service_date DATE NOT NULL,
    booking_status VARCHAR(20), -- e.g., Scheduled, Completed, Cancelled
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);
CREATE INDEX idx_service_date ON Bookings(service_date);
-- Customers
INSERT INTO Customers (customer_id, customer_name, contact_email) VALUES
(1, 'John Doe', 'john@example.com'),
(2, 'Alice Smith', 'alice@example.com'),
(3, 'Bob Johnson', 'bob@example.com'),
(4, 'Diana Prince', 'diana@example.com'),
(5, 'Ethan Hunt', 'ethan@example.com');

-- Vehicles
INSERT INTO Vehicles (vehicle_id, customer_id, vehicle_make, vehicle_model, vehicle_year) VALUES
(100, 1, 'Toyota', 'Camry', 2019),
(101, 1, 'Honda', 'Civic', 2018),
(102, 2, 'Ford', 'Mustang', 2020),
(103, 3, 'Tesla', 'Model 3', 2021),
(104, 4, 'BMW', 'X5', 2017);

-- Services
INSERT INTO Services (service_id, service_name, service_description) VALUES
(1, 'Oil Change', 'Replace engine oil and filter'),
(2, 'Tire Rotation', 'Rotate tires to extend life'),
(3, 'Brake Inspection', 'Check brake pads and discs'),
(4, 'Battery Check', 'Test battery health'),
(5, 'Full Service', 'Complete vehicle checkup and maintenance');

-- Bookings
INSERT INTO Bookings (booking_id, vehicle_id, service_id, service_date, booking_status) VALUES
(1001, 100, 1, '2025-07-01', 'Completed'),
(1002, 100, 2, '2025-07-10', 'Completed'),
(1003, 101, 1, '2025-07-05', 'Completed'),
(1004, 102, 5, '2025-07-08', 'Scheduled'),
(1005, 103, 3, '2025-07-12', 'Scheduled'),
(1006, 104, 4, '2025-07-03', 'Completed'),
(1007, 100, 5, '2025-07-15', 'Scheduled'),
(1008, 101, 3, '2025-07-18', 'Scheduled'),
(1009, 102, 2, '2025-07-20', 'Scheduled');

-- Use EXPLAIN and JOIN for service history queries.
EXPLAIN
SELECT b.booking_id, v.vehicle_make, v.vehicle_model, s.service_name, b.service_date, b.booking_status
FROM Bookings b
JOIN Vehicles v ON b.vehicle_id = v.vehicle_id
JOIN Services s ON b.service_id = s.service_id
JOIN Customers c ON v.customer_id = c.customer_id
WHERE c.customer_name = 'John Doe'
ORDER BY b.service_date DESC;

-- Create denormalized service history report.
CREATE TABLE ServiceHistoryReport AS
SELECT
    c.customer_id,
    c.customer_name,
    v.vehicle_id,
    v.vehicle_make,
    v.vehicle_model,
    s.service_name,
    b.service_date,
    b.booking_status
FROM Bookings b
JOIN Vehicles v ON b.vehicle_id = v.vehicle_id
JOIN Services s ON b.service_id = s.service_id
JOIN Customers c ON v.customer_id = c.customer_id;

-- Use LIMIT to display last 5 services per customer.
SELECT *
FROM ServiceHistoryReport shr
WHERE shr.customer_id = 1 -- example for customer_id 1
ORDER BY shr.service_date DESC
LIMIT 5;

-- project15:
-- 15. Online Movie Ticket Booking
-- Domain: Entertainment
-- Goal: Fast lookup of available shows and seats.
-- Requirements:
-- Tables: Movies, Shows, Bookings, Users.
-- Index movie_name, show_time, hall_id.
create database movie;
use movie;
-- Movies table
CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(255) NOT NULL,
    genre VARCHAR(50),
    duration_minutes INT
);
CREATE INDEX idx_movie_name ON Movies(movie_name);

-- Halls table (movie theaters halls)
CREATE TABLE Halls (
    hall_id INT PRIMARY KEY,
    hall_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL
);

-- Shows table (each show is a movie shown in a hall at a specific time)
CREATE TABLE Shows (
    show_id INT PRIMARY KEY,
    movie_id INT NOT NULL,
    hall_id INT NOT NULL,
    show_time DATETIME NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (hall_id) REFERENCES Halls(hall_id)
);
CREATE INDEX idx_show_time ON Shows(show_time);
CREATE INDEX idx_hall_id ON Shows(hall_id);

-- Users table (customers)
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Bookings table (tickets booked by users for shows)
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    show_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);
CREATE INDEX idx_booking_show ON Bookings(show_id);
CREATE INDEX idx_booking_user ON Bookings(user_id);
-- Movies
INSERT INTO Movies (movie_id, movie_name, genre, duration_minutes) VALUES
(1, 'The Great Escape', 'Action', 130),
(2, 'Romantic Sunset', 'Romance', 110),
(3, 'Sci-Fi Adventure', 'Science Fiction', 140),
(4, 'Comedy Nights', 'Comedy', 100),
(5, 'Horror House', 'Horror', 90);

-- Halls
INSERT INTO Halls (hall_id, hall_name, capacity) VALUES
(1, 'Hall A', 150),
(2, 'Hall B', 100),
(3, 'Hall C', 200);

-- Shows
INSERT INTO Shows (show_id, movie_id, hall_id, show_time) VALUES
(101, 1, 1, '2025-07-10 18:00:00'),
(102, 1, 2, '2025-07-10 21:00:00'),
(103, 2, 1, '2025-07-11 17:00:00'),
(104, 3, 3, '2025-07-11 20:00:00'),
(105, 4, 2, '2025-07-12 19:00:00'),
(106, 5, 3, '2025-07-12 22:00:00'),
(107, 2, 1, '2025-07-13 15:00:00'),
(108, 3, 2, '2025-07-13 18:00:00');

-- Users
INSERT INTO Users (user_id, user_name, email) VALUES
(1, 'Alice', 'alice@example.com'),
(2, 'Bob', 'bob@example.com'),
(3, 'Charlie', 'charlie@example.com');

-- Bookings
INSERT INTO Bookings (booking_id, user_id, show_id, seat_number) VALUES
(1001, 1, 101, 'A1'),
(1002, 2, 101, 'A2'),
(1003, 1, 102, 'B10'),
(1004, 3, 104, 'C15'),
(1005, 2, 105, 'B5');

-- Use EXPLAIN to optimize JOINs across tables.
EXPLAIN
SELECT
    m.movie_name,
    s.show_id,
    s.show_time,
    h.hall_name,
    h.capacity,
    COUNT(b.booking_id) AS booked_seats,
    (h.capacity - COUNT(b.booking_id)) AS available_seats
FROM Shows s
JOIN Movies m ON s.movie_id = m.movie_id
JOIN Halls h ON s.hall_id = h.hall_id
LEFT JOIN Bookings b ON s.show_id = b.show_id
GROUP BY s.show_id
HAVING available_seats > 0
ORDER BY s.show_time ASC
LIMIT 10 OFFSET 0;  -- Pagination: first 10 shows

-- Normalize to 3NF: separate halls, timings, bookings.
-- Denormalize for movie-wise show dashboards.
CREATE VIEW MovieShowDashboard AS
SELECT
    m.movie_id,
    m.movie_name,
    s.show_id,
    s.show_time,
    h.hall_name,
    h.capacity,
    COUNT(b.booking_id) AS booked_seats,
    (h.capacity - COUNT(b.booking_id)) AS available_seats
FROM Shows s
JOIN Movies m ON s.movie_id = m.movie_id
JOIN Halls h ON s.hall_id = h.hall_id
LEFT JOIN Bookings b ON s.show_id = b.show_id
GROUP BY s.show_id;

-- Use LIMIT to paginate available shows.
SELECT * FROM MovieShowDashboard
WHERE available_seats > 0
ORDER BY show_time ASC
LIMIT 5 OFFSET 0;  -- Get first 5 available shows
-- To get next page, increase OFFSET, e.g. OFFSET 5 for second page, OFFSET 10 for third, etc.

-- project16:
-- ✅ 16. Freelancer Payment and Project Portal
-- Domain: Freelancing
-- Goal: Optimize invoice retrieval and project lookup.
-- Requirements:
-- Tables: Freelancers, Projects, Invoices, Clients.
-- Index freelancer_id, payment_status, project_date.
-- Normalize project details and client info.
create database freelance;
use freelance;
-- Freelancers table
CREATE TABLE Freelancers (
    freelancer_id INT PRIMARY KEY,
    freelancer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);
CREATE INDEX idx_freelancer_name ON Freelancers(freelancer_name);

-- Clients table
CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);
CREATE INDEX idx_client_name ON Clients(client_name);

-- Projects table
CREATE TABLE Projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    client_id INT NOT NULL,
    freelancer_id INT NOT NULL,
    project_date DATE NOT NULL,
    status VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (freelancer_id) REFERENCES Freelancers(freelancer_id)
);
CREATE INDEX idx_project_date ON Projects(project_date);
CREATE INDEX idx_freelancer_id ON Projects(freelancer_id);

-- Invoices table
CREATE TABLE Invoices (
    invoice_id INT PRIMARY KEY,
    project_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,  -- e.g., Paid, Pending
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);
CREATE INDEX idx_payment_status ON Invoices(payment_status);
CREATE INDEX idx_invoice_date ON Invoices(invoice_date);
-- Freelancers
INSERT INTO Freelancers (freelancer_id, freelancer_name, email) VALUES
(1, 'Alice Smith', 'alice@example.com'),
(2, 'Bob Johnson', 'bob@example.com'),
(3, 'Charlie Davis', 'charlie@example.com');

-- Clients
INSERT INTO Clients (client_id, client_name, contact_email) VALUES
(1, 'Acme Corp', 'contact@acme.com'),
(2, 'Beta LLC', 'info@beta.com'),
(3, 'Gamma Inc', 'support@gamma.com');

-- Projects
INSERT INTO Projects (project_id, project_name, client_id, freelancer_id, project_date, status) VALUES
(101, 'Website Redesign', 1, 1, '2025-06-01', 'Completed'),
(102, 'Mobile App Development', 2, 2, '2025-06-15', 'In Progress'),
(103, 'SEO Optimization', 3, 1, '2025-06-20', 'Completed'),
(104, 'Database Migration', 1, 3, '2025-07-01', 'In Progress'),
(105, 'Marketing Campaign', 2, 2, '2025-07-05', 'Completed');

-- Invoices
INSERT INTO Invoices (invoice_id, project_id, invoice_date, amount, payment_status) VALUES
(1001, 101, '2025-06-10', 2500.00, 'Paid'),
(1002, 102, '2025-06-25', 4000.00, 'Pending'),
(1003, 103, '2025-06-30', 1200.00, 'Paid'),
(1004, 104, '2025-07-10', 3000.00, 'Pending'),
(1005, 105, '2025-07-15', 1500.00, 'Paid');

EXPLAIN
SELECT
    i.invoice_id,
    i.invoice_date,
    i.amount,
    i.payment_status,
    p.project_name,
    f.freelancer_name,
    c.client_name
FROM Invoices i
JOIN Projects p ON i.project_id = p.project_id
JOIN Freelancers f ON p.freelancer_id = f.freelancer_id
JOIN Clients c ON p.client_id = c.client_id
ORDER BY i.invoice_date DESC
LIMIT 10;

-- Denormalize into a reporting view.
CREATE VIEW InvoiceReport AS
SELECT
    i.invoice_id,
    i.invoice_date,
    i.amount,
    i.payment_status,
    p.project_name,
    p.project_date,
    f.freelancer_name,
    c.client_name
FROM Invoices i
JOIN Projects p ON i.project_id = p.project_id
JOIN Freelancers f ON p.freelancer_id = f.freelancer_id
JOIN Clients c ON p.client_id = c.client_id;

-- Use LIMIT to show 10 recent invoices.
SELECT *
FROM InvoiceReport
ORDER BY invoice_date DESC
LIMIT 10;
-- project17:
-- 17. Online Exam Management System
-- Domain: Education
-- Goal: Optimize student results and score access.
-- Requirements:
-- Tables: Students, Exams, Scores, Subjects.
-- Index student_id, exam_date, score.
create database onlineexam;
use onlineexam;
-- Students table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(100)
);
CREATE INDEX idx_student_name ON Students(student_name);

-- Subjects table
CREATE TABLE Subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);
CREATE INDEX idx_subject_name ON Subjects(subject_name);

-- Exams table
CREATE TABLE Exams (
    exam_id INT PRIMARY KEY,
    subject_id INT NOT NULL,
    exam_date DATE NOT NULL,
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id)
);
CREATE INDEX idx_exam_date ON Exams(exam_date);

-- Scores table
CREATE TABLE Scores (
    score_id INT PRIMARY KEY,
    student_id INT NOT NULL,
    exam_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id)
);
CREATE INDEX idx_score ON Scores(score);
CREATE INDEX idx_student_id ON Scores(student_id);

-- Students
INSERT INTO Students (student_id, student_name, email) VALUES
(1, 'Alice Smith', 'alice@example.com'),
(2, 'Bob Johnson', 'bob@example.com'),
(3, 'Charlie Brown', 'charlie@example.com');

-- Subjects
INSERT INTO Subjects (subject_id, subject_name) VALUES
(101, 'Mathematics'),
(102, 'Physics'),
(103, 'Chemistry');

-- Exams
INSERT INTO Exams (exam_id, subject_id, exam_date) VALUES
(1001, 101, '2025-06-10'),
(1002, 102, '2025-06-12'),
(1003, 103, '2025-06-15');

-- Scores
INSERT INTO Scores (score_id, student_id, exam_id, score) VALUES
(1, 1, 1001, 88.5),
(2, 1, 1002, 92.0),
(3, 2, 1001, 76.0),
(4, 2, 1003, 81.5),
(5, 3, 1002, 69.0),
(6, 3, 1003, 74.5);

-- Use CASE WHEN for grade categorization.
SELECT
    s.student_name,
    sub.subject_name,
    e.exam_date,
    sc.score,
    CASE
        WHEN sc.score >= 90 THEN 'A'
        WHEN sc.score >= 80 THEN 'B'
        WHEN sc.score >= 70 THEN 'C'
        WHEN sc.score >= 60 THEN 'D'
        ELSE 'F'
    END AS grade
FROM Scores sc
JOIN Students s ON sc.student_id = s.student_id
JOIN Exams e ON sc.exam_id = e.exam_id
JOIN Subjects sub ON e.subject_id = sub.subject_id
ORDER BY sc.score DESC;

-- Use JOIN and EXPLAIN for performance.
EXPLAIN
SELECT
    s.student_name,
    sub.subject_name,
    e.exam_date,
    sc.score,
    CASE
        WHEN sc.score >= 90 THEN 'A'
        WHEN sc.score >= 80 THEN 'B'
        WHEN sc.score >= 70 THEN 'C'
        WHEN sc.score >= 60 THEN 'D'
        ELSE 'F'
    END AS grade
FROM Scores sc
JOIN Students s ON sc.student_id = s.student_id
JOIN Exams e ON sc.exam_id = e.exam_id
JOIN Subjects sub ON e.subject_id = sub.subject_id
ORDER BY sc.score DESC
LIMIT 10;

-- Create denormalized dashboard with student + subject + score.
CREATE VIEW ScoreDashboard AS
SELECT
    s.student_name,
    sub.subject_name,
    e.exam_date,
    sc.score,
    CASE
        WHEN sc.score >= 90 THEN 'A'
        WHEN sc.score >= 80 THEN 'B'
        WHEN sc.score >= 70 THEN 'C'
        WHEN sc.score >= 60 THEN 'D'
        ELSE 'F'
    END AS grade
FROM Scores sc
JOIN Students s ON sc.student_id = s.student_id
JOIN Exams e ON sc.exam_id = e.exam_id
JOIN Subjects sub ON e.subject_id = sub.subject_id;

-- Use LIMIT for top scorers.
SELECT *
FROM ScoreDashboard
ORDER BY score DESC
LIMIT 10;

-- project18:
-- 18. Real Estate Listing Platform
-- Domain: Property Tech
-- Goal: Optimize listing search.
-- Requirements:
-- Tables: Properties, Agents, Clients, Bookings.
-- Index location, price, property_type.
create database realestate;
use realestate;
-- Agents table
CREATE TABLE Agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);

-- Clients table
CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);

-- Properties table
CREATE TABLE Properties (
    property_id INT PRIMARY KEY,
    agent_id INT NOT NULL,
    location VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    property_type VARCHAR(50) NOT NULL,
    bedrooms INT,
    bathrooms INT,
    size_sqft INT,
    FOREIGN KEY (agent_id) REFERENCES Agents(agent_id)
);
CREATE INDEX idx_location ON Properties(location);
CREATE INDEX idx_price ON Properties(price);
CREATE INDEX idx_property_type ON Properties(property_type);

-- Bookings table
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    property_id INT NOT NULL,
    client_id INT NOT NULL,
    booking_date DATE NOT NULL,
    status VARCHAR(50),
    FOREIGN KEY (property_id) REFERENCES Properties(property_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);
CREATE INDEX idx_booking_date ON Bookings(booking_date);
-- Agents
INSERT INTO Agents (agent_id, agent_name, contact_email) VALUES
(1, 'John Doe', 'john.doe@example.com'),
(2, 'Jane Smith', 'jane.smith@example.com');

-- Clients
INSERT INTO Clients (client_id, client_name, contact_email) VALUES
(1, 'Alice Johnson', 'alice.j@example.com'),
(2, 'Bob Lee', 'bob.lee@example.com');

-- Properties
INSERT INTO Properties (property_id, agent_id, location, price, property_type, bedrooms, bathrooms, size_sqft) VALUES
(101, 1, 'Downtown', 350000.00, 'Apartment', 2, 2, 900),
(102, 1, 'Suburbs', 450000.00, 'House', 4, 3, 2000),
(103, 2, 'Downtown', 300000.00, 'Studio', 1, 1, 600),
(104, 2, 'Uptown', 500000.00, 'Condo', 3, 2, 1200),
(105, 1, 'Suburbs', 380000.00, 'Apartment', 3, 2, 1100);

-- Bookings
INSERT INTO Bookings (booking_id, property_id, client_id, booking_date, status) VALUES
(1, 101, 1, '2025-07-01', 'Confirmed'),
(2, 103, 2, '2025-07-05', 'Pending'),
(3, 102, 1, '2025-07-10', 'Cancelled');

-- Normalize property and client data.
-- Denormalize for public-facing property search.
CREATE VIEW PropertySearchView AS
SELECT
    p.property_id,
    p.location,
    p.price,
    p.property_type,
    p.bedrooms,
    p.bathrooms,
    p.size_sqft,
    a.agent_name,
    a.contact_email AS agent_email
FROM Properties p
JOIN Agents a ON p.agent_id = a.agent_id;

-- Use LIMIT and ORDER BY for featured listings.
-- Example: Show top 5 most expensive properties in 'Downtown' area
SELECT *
FROM PropertySearchView
WHERE location = 'Downtown'
ORDER BY price DESC
LIMIT 5;
-- explain example to analyse query performance.
EXPLAIN
SELECT *
FROM PropertySearchView
WHERE location = 'Downtown'
ORDER BY price DESC
LIMIT 5;

-- project19:
-- 19. Insurance Policy Management System
-- Domain: Finance / Insurance
-- Goal: Track policy status and claims.
-- Requirements:
-- Tables: Policies, Clients, Claims, Agents.
-- Index claim_status, policy_type, claim_date.
create database inspolicy;
use inspolicy;
-- Agents table
CREATE TABLE Agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);

-- Clients table
CREATE TABLE Clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);

-- Policies table
CREATE TABLE Policies (
    policy_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    agent_id INT NOT NULL,
    policy_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (agent_id) REFERENCES Agents(agent_id)
);
CREATE INDEX idx_policy_type ON Policies(policy_type);
CREATE INDEX idx_policy_status ON Policies(status);

-- Claims table
CREATE TABLE Claims (
    claim_id INT PRIMARY KEY,
    policy_id INT NOT NULL,
    claim_date DATE NOT NULL,
    claim_amount DECIMAL(12,2) NOT NULL,
    claim_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (policy_id) REFERENCES Policies(policy_id)
);
CREATE INDEX idx_claim_status ON Claims(claim_status);
CREATE INDEX idx_claim_date ON Claims(claim_date);
-- Agents
INSERT INTO Agents (agent_id, agent_name, contact_email) VALUES
(1, 'Emily Carter', 'emily.carter@insurance.com'),
(2, 'Michael Brown', 'michael.brown@insurance.com');

-- Clients
INSERT INTO Clients (client_id, client_name, contact_email) VALUES
(1, 'Alice Walker', 'alice.walker@email.com'),
(2, 'John Davis', 'john.davis@email.com'),
(3, 'Sarah Lee', 'sarah.lee@email.com');

-- Policies
INSERT INTO Policies (policy_id, client_id, agent_id, policy_type, start_date, end_date, status) VALUES
(101, 1, 1, 'Health', '2023-01-01', '2024-01-01', 'Active'),
(102, 2, 1, 'Auto', '2023-03-15', '2024-03-15', 'Active'),
(103, 3, 2, 'Home', '2023-05-10', '2024-05-10', 'Lapsed'),
(104, 1, 2, 'Life', '2024-01-20', '2029-01-20', 'Active');

-- Claims
INSERT INTO Claims (claim_id, policy_id, claim_date, claim_amount, claim_status) VALUES
(201, 101, '2024-02-10', 1500.00, 'Under Review'),
(202, 102, '2024-03-05', 2500.00, 'Approved'),
(203, 103, '2024-04-15', 1200.00, 'Rejected'),
(204, 101, '2024-05-20', 800.00, 'Under Review'),
(205, 104, '2024-06-01', 10000.00, 'Approved');

-- Use JOIN and EXPLAIN to optimize queries.
EXPLAIN
SELECT 
    c.claim_id,
    c.policy_id,
    c.claim_date,
    c.claim_amount,
    c.claim_status,
    p.policy_type,
    cl.client_name,
    a.agent_name
FROM Claims c
JOIN Policies p ON c.policy_id = p.policy_id
JOIN Clients cl ON p.client_id = cl.client_id
JOIN Agents a ON p.agent_id = a.agent_id
WHERE c.claim_status = 'Under Review'
ORDER BY c.claim_date DESC
LIMIT 10;
-- Normalize client and policy data.
-- Denormalize for reporting on claims per agent.
CREATE VIEW ClaimsByAgent AS
SELECT 
    a.agent_id,
    a.agent_name,
    COUNT(c.claim_id) AS total_claims,
    SUM(c.claim_amount) AS total_claim_amount,
    SUM(CASE WHEN c.claim_status = 'Under Review' THEN 1 ELSE 0 END) AS claims_under_review
FROM Agents a
JOIN Policies p ON a.agent_id = p.agent_id
JOIN Claims c ON p.policy_id = c.policy_id
GROUP BY a.agent_id, a.agent_name;

-- Use LIMIT for claims under review.
SELECT 
    c.claim_id,
    c.policy_id,
    c.claim_date,
    c.claim_amount,
    c.claim_status,
    p.policy_type,
    cl.client_name,
    a.agent_name
FROM Claims c
JOIN Policies p ON c.policy_id = p.policy_id
JOIN Clients cl ON p.client_id = cl.client_id
JOIN Agents a ON p.agent_id = a.agent_id
WHERE c.claim_status = 'Under Review'
ORDER BY c.claim_date DESC
LIMIT 10;

-- project20:
-- 20. NGO Donation and Campaign Tracker
-- Domain: Nonprofit
-- Goal: Monitor donations and fundraising performance.
-- Requirements:
-- Tables: Donors, Donations, Campaigns.
-- Index campaign_id, donor_name, donation_date.
-- Normalize data into 3NF.
create database ngodonation;
use ngodonation;
-- Donors table
CREATE TABLE Donors (
    donor_id INT PRIMARY KEY,
    donor_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);
CREATE INDEX idx_donor_name ON Donors(donor_name);

-- Campaigns table
CREATE TABLE Campaigns (
    campaign_id INT PRIMARY KEY,
    campaign_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE
);

-- Donations table
CREATE TABLE Donations (
    donation_id INT PRIMARY KEY,
    donor_id INT NOT NULL,
    campaign_id INT NOT NULL,
    donation_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (donor_id) REFERENCES Donors(donor_id),
    FOREIGN KEY (campaign_id) REFERENCES Campaigns(campaign_id)
);
CREATE INDEX idx_campaign_id ON Donations(campaign_id);
CREATE INDEX idx_donation_date ON Donations(donation_date);
-- Donors
INSERT INTO Donors (donor_id, donor_name, contact_email) VALUES
(1, 'Alice Johnson', 'alice.johnson@email.com'),
(2, 'Bob Smith', 'bob.smith@email.com'),
(3, 'Charlie Lee', 'charlie.lee@email.com'),
(4, 'Diana Prince', 'diana.prince@email.com'),
(5, 'Ethan Hunt', 'ethan.hunt@email.com');

-- Campaigns
INSERT INTO Campaigns (campaign_id, campaign_name, start_date, end_date) VALUES
(101, 'Clean Water Initiative', '2024-01-01', '2024-12-31'),
(102, 'Education for All', '2024-03-01', '2024-11-30'),
(103, 'Healthcare Outreach', '2024-05-15', '2024-10-31');

-- Donations
INSERT INTO Donations (donation_id, donor_id, campaign_id, donation_date, amount) VALUES
(201, 1, 101, '2024-02-15', 500.00),
(202, 2, 101, '2024-02-20', 250.00),
(203, 3, 102, '2024-03-25', 1000.00),
(204, 4, 103, '2024-06-05', 750.00),
(205, 1, 102, '2024-07-10', 200.00),
(206, 5, 103, '2024-07-15', 300.00),
(207, 2, 101, '2024-08-01', 150.00),
(208, 3, 102, '2024-08-20', 500.00);

-- Denormalize for campaign-wise donation summaries.
CREATE VIEW CampaignDonationSummary AS
SELECT
    c.campaign_id,
    c.campaign_name,
    COUNT(d.donation_id) AS total_donations,
    SUM(d.amount) AS total_amount,
    MIN(d.donation_date) AS first_donation_date,
    MAX(d.donation_date) AS last_donation_date
FROM Campaigns c
LEFT JOIN Donations d ON c.campaign_id = d.campaign_id
GROUP BY c.campaign_id, c.campaign_name;

-- Use EXPLAIN to optimize group aggregations.
EXPLAIN
SELECT
    c.campaign_id,
    c.campaign_name,
    COUNT(d.donation_id) AS total_donations,
    SUM(d.amount) AS total_amount
FROM Campaigns c
LEFT JOIN Donations d ON c.campaign_id = d.campaign_id
GROUP BY c.campaign_id, c.campaign_name;

-- Use LIMIT for latest donations.
SELECT
    d.donation_id,
    don.donor_name,
    c.campaign_name,
    d.donation_date,
    d.amount
FROM Donations d
JOIN Donors don ON d.donor_id = don.donor_id
JOIN Campaigns c ON d.campaign_id = c.campaign_id
ORDER BY d.donation_date DESC
LIMIT 10;

