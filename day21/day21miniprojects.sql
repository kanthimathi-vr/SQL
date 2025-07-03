### 1. **Company Payroll Analytics**
-- Tables: employees, departments, salaries
-- Calculate total, average, min, and max salaries by department.
-- List departments with total salary above a threshold using HAVING.
-- Identify top 3 highest paid employees.
USE COMPANY1; 
SELECT 
    d.department_name,
    SUM(s.amount) AS total_salary,
    ROUND(AVG(s.amount),2) AS avg_salary,
    MIN(s.amount) AS min_salary,
    MAX(s.amount) AS max_salary
FROM salaries s
JOIN employees e ON s.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

SELECT 
    d.department_name,
    SUM(s.amount) AS total_salary
FROM salaries s
JOIN employees e ON s.employee_id = e.employee_id
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING SUM(s.amount) > 100000;

 SELECT 
    e.name AS employee_name,
    SUM(s.amount) AS total_earned
FROM salaries s
JOIN employees e ON s.employee_id = e.employee_id
GROUP BY e.employee_id, e.name
ORDER BY total_earned DESC
LIMIT 3;

### 2. **School Performance Dashboard**
-- Tables: students, classes, grades
-- Find average grade per student and per class.
-- List classes where the average grade is below a set value.
-- Identify students with the highest and lowest grades.
 CREATE DATABASE SCHOOL3;
 USE SCHOOL3;
-- Table: students
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(50)
);

-- Table: classes
CREATE TABLE classes (
    class_id INT PRIMARY KEY,
    class_name VARCHAR(50)
);

-- Table: grades
CREATE TABLE grades (
    grade_id INT PRIMARY KEY,
    student_id INT,
    class_id INT,
    grade DECIMAL(5,2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
    );
-- Students
INSERT INTO students (student_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana'),
(5, 'Ethan');

-- Classes
INSERT INTO classes (class_id, class_name) VALUES
(101, 'Math'),
(102, 'Science'),
(103, 'History'),
(104, 'English');

-- Grades
INSERT INTO grades (grade_id, student_id, class_id, grade) VALUES
(1, 1, 101, 85.5),
(2, 1, 102, 78.0),
(3, 1, 103, 92.0),
(4, 2, 101, 60.0),
(5, 2, 102, 65.5),
(6, 3, 101, 45.0),
(7, 3, 103, 55.0),
(8, 4, 102, 72.0),
(9, 4, 104, 88.0),
(10, 5, 101, 91.0),
(11, 5, 103, 94.0),
(12, 5, 104, 89.5);

 SELECT 
    s.name AS student_name,
    round(AVG(g.grade),2) AS average_grade
FROM grades g
JOIN students s ON g.student_id = s.student_id
GROUP BY s.student_id, s.name;

SELECT 
    c.class_name,
    round(AVG(g.grade),2) AS average_grade
FROM grades g
JOIN classes c ON g.class_id = c.class_id
GROUP BY c.class_id, c.class_name;

SELECT 
    c.class_name,
    AVG(g.grade) AS average_grade
FROM grades g
JOIN classes c ON g.class_id = c.class_id
GROUP BY c.class_id, c.class_name
HAVING AVG(g.grade) < 80;

SELECT 
    s.name AS student_name,
    g.grade,
    c.class_name
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN classes c ON g.class_id = c.class_id
ORDER BY g.grade DESC
LIMIT 1;

SELECT 
    s.name AS student_name,
    g.grade,
    c.class_name
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN classes c ON g.class_id = c.class_id
ORDER BY g.grade ASC
LIMIT 1;

### 3. **E-Commerce Sales Summary**
-- Tables: products, orders, order_items, customers
CREATE DATABASE ECOMMERCE1;
USE ECOMMERCE1;
-- Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2)
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Customers
INSERT INTO customers (customer_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Products
INSERT INTO products (product_id, product_name, price) VALUES
(101, 'Laptop', 1200.00),
(102, 'Mouse', 25.00),
(103, 'Keyboard', 45.00),
(104, 'Monitor', 250.00);

-- Orders
INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1001, 1, '2024-06-01'),
(1002, 1, '2024-06-15'),
(1003, 2, '2024-06-20'),
(1004, 3, '2024-06-25');

-- Order Items
INSERT INTO order_items (order_item_id, order_id, product_id, quantity) VALUES
(1, 1001, 101, 1),    -- Laptop
(2, 1001, 102, 2),    -- Mouse x2
(3, 1002, 103, 1),    -- Keyboard
(4, 1002, 104, 1),    -- Monitor
(5, 1003, 102, 3),    -- Mouse x3
(6, 1004, 104, 2);    -- Monitor x2

-- Show total sales per product and per customer.
SELECT 
    p.product_name,
    SUM(oi.quantity * p.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name;

SELECT 
    c.name AS customer_name,
    SUM(oi.quantity * p.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name;

-- List products with sales above a certain amount.
SELECT 
    p.product_name,
    SUM(oi.quantity * p.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity * p.price) > 500;

-- Identify customers with no orders (LEFT JOIN).
 SELECT c.name AS customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
 
### 4. **Hospital Department Metrics**
-- Tables: doctors, patients, departments, appointments
CREATE DATABASE HOSPITAL1;
USE HOSPITAL1;
-- Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

-- Doctors
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    doctor_id INT,
    patient_id INT,
    appointment_date DATE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);
-- Departments
INSERT INTO departments (department_id, department_name) VALUES
(1, 'Cardiology'),
(2, 'Neurology'),
(3, 'Pediatrics');

-- Doctors
INSERT INTO doctors (doctor_id, name, department_id) VALUES
(1, 'Dr. Smith', 1),
(2, 'Dr. Jones', 2),
(3, 'Dr. Kim', 1),
(4, 'Dr. Patel', 3);

-- Patients
INSERT INTO patients (patient_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana'),
(5, 'Ethan'),
(6, 'Fiona'),
(7, 'George'),
(8, 'Hannah');

-- Appointments
INSERT INTO appointments (appointment_id, doctor_id, patient_id, appointment_date) VALUES
(1, 1, 1, '2024-01-01'),
(2, 1, 2, '2024-01-02'),
(3, 2, 3, '2024-01-03'),
(4, 3, 4, '2024-01-04'),
(5, 1, 5, '2024-01-05'),
(6, 4, 6, '2024-01-06'),
(7, 4, 7, '2024-01-07'),
(8, 4, 8, '2024-01-08');

-- Count patients per department and per doctor.
SELECT 
    d.department_name,
    COUNT(DISTINCT a.patient_id) AS patient_count
FROM appointments a
JOIN doctors doc ON a.doctor_id = doc.doctor_id
JOIN departments d ON doc.department_id = d.department_id
GROUP BY d.department_name;

SELECT 
    doc.name AS doctor_name,
    COUNT(DISTINCT a.patient_id) AS patient_count
FROM appointments a
JOIN doctors doc ON a.doctor_id = doc.doctor_id
GROUP BY doc.doctor_id, doc.name;

-- Find doctors with the most appointments.
SELECT 
    doc.name AS doctor_name,
    COUNT(a.appointment_id) AS total_appointments
FROM appointments a
JOIN doctors doc ON a.doctor_id = doc.doctor_id
GROUP BY doc.doctor_id, doc.name
ORDER BY total_appointments DESC
LIMIT 1;

-- List departments where patient count exceeds 100.
 SELECT 
    d.department_name,
    COUNT(DISTINCT a.patient_id) AS patient_count
FROM appointments a
JOIN doctors doc ON a.doctor_id = doc.doctor_id
JOIN departments d ON doc.department_id = d.department_id
GROUP BY d.department_name
HAVING COUNT(DISTINCT a.patient_id) > 2;
 
### 5. **Library Borrowing Trends**
-- Tables: books, members, loans
-- Books
CREATE DATABASE LIBRARY1;
USE LIBRARY1;
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100)
);

-- Members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Loans
CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    book_id INT,
    member_id INT,
    loan_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);
-- Books
INSERT INTO books (book_id, title) VALUES
(1, '1984'),
(2, 'To Kill a Mockingbird'),
(3, 'The Great Gatsby'),
(4, 'Moby Dick');

-- Members
INSERT INTO members (member_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Loans
INSERT INTO loans (loan_id, book_id, member_id, loan_date) VALUES
(1, 1, 1, '2024-05-01'),
(2, 2, 1, '2024-05-03'),
(3, 1, 2, '2024-05-05'),
(4, 3, 3, '2024-05-06'),
(5, 1, 3, '2024-05-07'),
(6, 2, 3, '2024-05-08');


-- Count total loans per book and per member.
SELECT 
    b.title,
    COUNT(l.loan_id) AS total_loans
FROM books b
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title;

SELECT 
    m.name,
    COUNT(l.loan_id) AS total_loans
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.name;

-- Identify books borrowed more than N times.
SELECT 
    b.title,
    COUNT(l.loan_id) AS total_loans
FROM books b
JOIN loans l ON b.book_id = l.book_id
GROUP BY b.book_id, b.title
HAVING COUNT(l.loan_id) > 1;

-- List members who have never borrowed a book.
 SELECT m.name
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
WHERE l.loan_id IS NULL;


 
### 6. **Restaurant Order Analysis**
-- Tables: menu_items, orders, customers, order_details
CREATE DATABASE RESTAURANT1;
USE RESTAURANT1;
-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Menu Items
CREATE TABLE menu_items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100),
    price DECIMAL(10, 2)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Details
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    item_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);
-- Customers
INSERT INTO customers (customer_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Menu Items
INSERT INTO menu_items (item_id, item_name, price) VALUES
(1, 'Burger', 8.50),
(2, 'Pizza', 12.00),
(3, 'Pasta', 10.00),
(4, 'Salad', 6.00),
(5, 'Soup', 5.50);  -- This one will not be ordered

-- Orders
INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1001, 1, '2024-07-01'),
(1002, 2, '2024-07-02'),
(1003, 1, '2024-07-03'),
(1004, 3, '2024-07-04');

-- Order Details
INSERT INTO order_details (order_detail_id, order_id, item_id, quantity) VALUES
(1, 1001, 1, 2),  -- Burger x2
(2, 1001, 2, 1),  -- Pizza x1
(3, 1002, 3, 1),  -- Pasta x1
(4, 1002, 2, 2),  -- Pizza x2
(5, 1003, 4, 3),  -- Salad x3
(6, 1004, 1, 1);  -- Burger x1

-- Compute total revenue per menu item.
SELECT 
    m.item_name,
    SUM(od.quantity * m.price) AS total_revenue
FROM menu_items m
JOIN order_details od ON m.item_id = od.item_id
GROUP BY m.item_id, m.item_name;

-- List customers with the highest order totals.
SELECT 
    c.name AS customer_name,
    SUM(od.quantity * m.price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN menu_items m ON od.item_id = m.item_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- Find menu items never ordered.
 SELECT m.item_name
FROM menu_items m
LEFT JOIN order_details od ON m.item_id = od.item_id
WHERE od.item_id IS NULL;

### 7. **University Course Statistics**

-- Tables: courses, enrollments, students
CREATE DATABASE UNIVERSITY1;
USE UNIVERSITY1;
-- Courses
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

-- Students
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Enrollments
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade DECIMAL(5,2), -- Assume grade >= 50 is pass
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
-- Courses
INSERT INTO courses (course_id, course_name) VALUES
(1, 'Mathematics'),
(2, 'Physics'),
(3, 'Chemistry'),
(4, 'Philosophy'); -- No enrollments

-- Students
INSERT INTO students (student_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Enrollments
INSERT INTO enrollments (enrollment_id, student_id, course_id, grade) VALUES
(1, 1, 1, 85.0),   -- Alice - Math
(2, 2, 1, 78.0),   -- Bob - Math
(3, 3, 1, 90.0),   -- Charlie - Math
(4, 1, 2, 45.0),   -- Alice - Physics (failed)
(5, 2, 2, 52.0),   -- Bob - Physics
(6, 4, 3, 88.0);   -- Diana - Chemistry

-- Find the number of students per course.
SELECT 
    c.course_name,
    COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name;

-- List courses with no enrollments (LEFT JOIN).
SELECT 
    c.course_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.enrollment_id IS NULL;

-- Show courses where all students passed.
 SELECT 
    c.course_name
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
HAVING MIN(e.grade) >= 50;


### 8. **Retail Inventory & Supplier Summary**

-- Tables: products, suppliers, purchases
-- Suppliers
CREATE DATABASE RETAIL;
USE RETAIL;

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100)
);-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Purchases
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    product_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Suppliers
INSERT INTO suppliers (supplier_id, supplier_name) VALUES
(1, 'Acme Corp'),
(2, 'Best Supply Co'),
(3, 'Global Traders');

-- Products
INSERT INTO products (product_id, product_name, supplier_id) VALUES
(1, 'Paper', 1),
(2, 'Ink', 1),
(3, 'Stapler', 2),
(4, 'Markers', 2),
(5, 'Whiteboard', 3),
(6, 'Printer', 3),
(7, 'Scissors', 2); -- Never purchased

-- Purchases
INSERT INTO purchases (purchase_id, product_id, quantity, purchase_date) VALUES
(1, 1, 100, '2024-05-01'),
(2, 2, 50, '2024-05-03'),
(3, 3, 30, '2024-05-05'),
(4, 4, 25, '2024-05-06'),
(5, 5, 10, '2024-05-07'),
(6, 6, 5, '2024-05-08'),
(7, 3, 20, '2024-06-01'); -- Additional for Best Supply Co

-- Show total stock purchased per supplier.
SELECT 
    s.supplier_name,
    SUM(pur.quantity) AS total_stock_purchased
FROM purchases pur
JOIN products prod ON pur.product_id = prod.product_id
JOIN suppliers s ON prod.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.supplier_name;

-- List products never purchased.
SELECT 
    p.product_name
FROM products p
LEFT JOIN purchases pur ON p.product_id = pur.product_id
WHERE pur.purchase_id IS NULL;

-- Find supplier with the largest product portfolio.
 SELECT 
    s.supplier_name,
    COUNT(p.product_id) AS product_count
FROM suppliers s
JOIN products p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY product_count DESC
LIMIT 1;
 
### 9. **Fitness Club Member Engagement**
-- Tables: members, classes, attendance
CREATE DATABASE FITNESSCLUB;
USE FITNESSCLUB;
-- Members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Classes
CREATE TABLE classes (
    class_id INT PRIMARY KEY,
    class_name VARCHAR(100)
);
-- Attendance
CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY,
    member_id INT,
    class_id INT,
    attendance_date DATE,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);
-- Members
INSERT INTO members (member_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana'); -- No attendance

-- Classes
INSERT INTO classes (class_id, class_name) VALUES
(1, 'Yoga'),
(2, 'Zumba'),
(3, 'Pilates');

-- Attendance
INSERT INTO attendance (attendance_id, member_id, class_id, attendance_date) VALUES
(1, 1, 1, '2024-06-01'), -- Alice - Yoga
(2, 1, 2, '2024-06-02'), -- Alice - Zumba
(3, 2, 2, '2024-06-03'), -- Bob - Zumba
(4, 3, 3, '2024-06-04'), -- Charlie - Pilates
(5, 3, 2, '2024-06-05'), -- Charlie - Zumba
(6, 1, 2, '2024-06-06'); -- Alice - Zumba again

-- Count class attendance per member.
SELECT 
    m.name AS member_name,
    COUNT(a.attendance_id) AS total_attendance
FROM members m
LEFT JOIN attendance a ON m.member_id = a.member_id
GROUP BY m.member_id, m.name;

-- Identify members with no attendance (LEFT JOIN).
SELECT 
    m.name AS member_name
FROM members m
LEFT JOIN attendance a ON m.member_id = a.member_id
WHERE a.attendance_id IS NULL;

-- List classes with highest average attendance.
 SELECT 
    c.class_name,
    COUNT(a.member_id) AS total_attendance
FROM classes c
LEFT JOIN attendance a ON c.class_id = a.class_id
GROUP BY c.class_id, c.class_name
ORDER BY total_attendance DESC;


 
### 10. **Event Registration Reporting**
-- Tables: events, attendees, registrations
CREATE DATABASE EVENTREGISTRATION;
USE EVENTREGISTRATION;
-- Events
CREATE TABLE events (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(100)
);

-- Attendees
CREATE TABLE attendees (
    attendee_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Registrations
CREATE TABLE registrations (
    registration_id INT PRIMARY KEY,
    event_id INT,
    attendee_id INT,
    registration_date DATE,
    FOREIGN KEY (event_id) REFERENCES events(event_id),
    FOREIGN KEY (attendee_id) REFERENCES attendees(attendee_id)
);
-- Events
INSERT INTO events (event_id, event_name) VALUES
(1, 'Tech Conference'),
(2, 'Art Expo'),
(3, 'Health & Wellness Fair'),
(4, 'Startup Pitch Night'); -- No registrations

-- Attendees
INSERT INTO attendees (attendee_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Registrations
INSERT INTO registrations (registration_id, event_id, attendee_id, registration_date) VALUES
(1, 1, 1, '2024-06-01'),
(2, 1, 2, '2024-06-02'),
(3, 2, 1, '2024-06-03'),
(4, 3, 1, '2024-06-04'),
(5, 2, 3, '2024-06-05'),
(6, 3, 4, '2024-06-06');

-- Count registrations per event.
SELECT 
    e.event_name,
    COUNT(r.registration_id) AS total_registrations
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
GROUP BY e.event_id, e.event_name;

-- Find attendees who registered for most events.
SELECT 
    a.name AS attendee_name,
    COUNT(DISTINCT r.event_id) AS events_registered
FROM attendees a
JOIN registrations r ON a.attendee_id = r.attendee_id
GROUP BY a.attendee_id, a.name
ORDER BY events_registered DESC
LIMIT 1;

-- List events with no registrations.
 SELECT 
    e.event_name
FROM events e
LEFT JOIN registrations r ON e.event_id = r.event_id
WHERE r.registration_id IS NULL;

### 11. **IT Asset Management**
-- Tables: assets, employees, departments
CREATE DATABASE ITASSET;
USE ITASSET;
-- Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

-- Employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Assets
CREATE TABLE assets (
    asset_id INT PRIMARY KEY,
    asset_name VARCHAR(100),
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
-- Departments
INSERT INTO departments (department_id, department_name) VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Finance'),
(4, 'Marketing'); -- Will have no assets assigned

-- Employees
INSERT INTO employees (employee_id, name, department_id) VALUES
(1, 'Alice', 1),
(2, 'Bob', 1),
(3, 'Charlie', 2),
(4, 'Diana', 3),
(5, 'Eve', 4); -- Will not receive any asset

-- Assets
INSERT INTO assets (asset_id, asset_name, employee_id) VALUES
(1, 'Laptop', 1),
(2, 'Monitor', 1),
(3, 'Mouse', 1),
(4, 'Laptop', 2),
(5, 'Monitor', 3),
(6, 'Keyboard', 4);


-- Count assets assigned per department.
SELECT 
    d.department_name,
    COUNT(a.asset_id) AS total_assets
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN assets a ON e.employee_id = a.employee_id
GROUP BY d.department_id, d.department_name;

-- List employees with more than 2 assets.
SELECT 
    e.name AS employee_name,
    COUNT(a.asset_id) AS asset_count
FROM employees e
JOIN assets a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.name
HAVING COUNT(a.asset_id) > 2;

-- Show departments with no assigned assets.
 SELECT 
    d.department_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN assets a ON e.employee_id = a.employee_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(a.asset_id) = 0;

 
### 12. **Movie Rental Store Insights**
-- Tables: movies, rentals, customers
CREATE DATABASE MOVIE1;
USE MOVIE1;
-- Movies
CREATE TABLE movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100)
);

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Rentals
CREATE TABLE rentals (
    rental_id INT PRIMARY KEY,
    customer_id INT,
    movie_id INT,
    rental_date DATE,
    return_date DATE,
    due_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
);

-- Movies
INSERT INTO movies (movie_id, title) VALUES
(1, 'Inception'),
(2, 'Titanic'),
(3, 'The Matrix'),
(4, 'Interstellar'),
(5, 'The Godfather'); -- Never rented

-- Customers
INSERT INTO customers (customer_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

-- Rentals
INSERT INTO rentals (rental_id, customer_id, movie_id, rental_date, return_date, due_date) VALUES
(1, 1, 1, '2024-06-01', '2024-06-05', '2024-06-04'), -- Inception, returned 1 day late
(2, 2, 1, '2024-06-10', '2024-06-12', '2024-06-11'), -- Inception
(3, 1, 2, '2024-06-15', '2024-06-16', '2024-06-17'), -- Titanic, returned early
(4, 3, 3, '2024-06-18', NULL, '2024-06-20'),         -- Matrix, overdue
(5, 2, 4, '2024-06-19', '2024-06-22', '2024-06-21'); -- Interstellar


-- Find most and least rented movies.
-- Movie rental counts
SELECT 
    m.title,
    COUNT(r.rental_id) AS rental_count
FROM movies m
LEFT JOIN rentals r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
ORDER BY rental_count DESC;

SELECT 
    m.title,
    COUNT(r.rental_id) AS rental_count
FROM movies m
LEFT JOIN rentals r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
ORDER BY rental_count ASC
LIMIT 1;

SELECT 
    m.title,
    COUNT(r.rental_id) AS rental_count
FROM movies m
LEFT JOIN rentals r ON m.movie_id = r.movie_id
GROUP BY m.movie_id, m.title
ORDER BY rental_count DESC
LIMIT 1;


-- List customers with overdue rentals.
SELECT 
    c.name,
    r.movie_id,
    m.title,
    r.rental_date,
    r.due_date,
    r.return_date
FROM customers c
JOIN rentals r ON c.customer_id = r.customer_id
JOIN movies m ON r.movie_id = m.movie_id
WHERE r.return_date IS NULL AND r.due_date < CURRENT_DATE;

-- Show movies never rented.
 SELECT 
    m.title
FROM movies m
LEFT JOIN rentals r ON m.movie_id = r.movie_id
WHERE r.rental_id IS NULL;


### 13. **Bank Branch & Customer Statistics**
-- Tables: branches, customers, accounts, transactions
-- Branches
CREATE DATABASE BANK;
USE BANK;

CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL
);

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    branch_id INT,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

-- Accounts
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Transactions
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(10,2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
-- Branches
INSERT INTO branches (branch_id, branch_name) VALUES
(1, 'Downtown'),
(2, 'Uptown'),
(3, 'Suburb');

-- Customers
INSERT INTO customers (customer_id, name, branch_id) VALUES
(1, 'Alice', 1),
(2, 'Bob', 1),
(3, 'Charlie', 2),
(4, 'Diana', 2),
(5, 'Eve', 3); -- Eve has no account or transaction

-- Accounts
INSERT INTO accounts (account_id, customer_id, balance) VALUES
(1, 1, 5000.00), -- Alice
(2, 2, 3000.00), -- Bob
(3, 3, 7000.00), -- Charlie
(4, 4, 2000.00); -- Diana

-- Transactions
INSERT INTO transactions (transaction_id, account_id, amount, transaction_date) VALUES
(1, 1, 1000.00, '2024-06-01'),   -- Alice
(2, 2, -500.00, '2024-06-03'),   -- Bob
(3, 3, 2000.00, '2024-06-05'),   -- Charlie
(4, 4, -1000.00, '2024-06-07');  -- Diana



-- Count accounts and total balance per branch.
SELECT 
    b.branch_name,
    COUNT(a.account_id) AS total_accounts,
    SUM(a.balance) AS total_balance
FROM branches b
LEFT JOIN customers c ON b.branch_id = c.branch_id
LEFT JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY b.branch_id, b.branch_name;

-- List customers with no transactions.
SELECT 
    cu.name AS customer_name
FROM customers cu
LEFT JOIN accounts a ON cu.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE a.account_id IS NULL OR t.transaction_id IS NULL;


-- Find branches with the highest/lowest number of customers.
SELECT 
    b.branch_name,
    COUNT(c.customer_id) AS customer_count
FROM branches b
LEFT JOIN customers c ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY customer_count DESC;

SELECT 
    b.branch_name,
    COUNT(c.customer_id) AS customer_count
FROM branches b
LEFT JOIN customers c ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY customer_count DESC
LIMIT 1;

SELECT 
    b.branch_name,
    COUNT(c.customer_id) AS customer_count
FROM branches b
LEFT JOIN customers c ON b.branch_id = c.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY customer_count ASC
LIMIT 1;

### 14. **Clinic Patient Visit Analysis**
-- Tables: patients, visits, doctors
CREATE DATABASE CLINIC;
USE CLINIC;

-- Doctors table
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Patients table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Visits table
CREATE TABLE visits (
    visit_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);
-- Doctors
INSERT INTO doctors (doctor_id, name) VALUES
(1, 'Dr. Smith'),
(2, 'Dr. Adams'),
(3, 'Dr. Lee');  -- Will have no visits

-- Patients
INSERT INTO patients (patient_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Visits
INSERT INTO visits (visit_id, patient_id, doctor_id, visit_date) VALUES
(1, 1, 1, '2024-01-10'), -- Alice
(2, 1, 2, '2024-02-15'), -- Alice again
(3, 2, 1, '2024-03-05'), -- Bob
(4, 3, 2, '2024-04-20'); -- Charlie
-- Diana (patient_id=4) has no visits

-- Count visits per doctor and per patient.
SELECT 
    d.name AS doctor_name,
    COUNT(v.visit_id) AS total_visits
FROM doctors d
LEFT JOIN visits v ON d.doctor_id = v.doctor_id
GROUP BY d.doctor_id, d.name;

SELECT 
    p.name AS patient_name,
    COUNT(v.visit_id) AS total_visits
FROM patients p
LEFT JOIN visits v ON p.patient_id = v.patient_id
GROUP BY p.patient_id, p.name;


-- List patients with only one visit.
SELECT 
    p.name AS patient_name,
    COUNT(v.visit_id) AS visit_count
FROM patients p
JOIN visits v ON p.patient_id = v.patient_id
GROUP BY p.patient_id, p.name
HAVING COUNT(v.visit_id) = 1;

-- Show doctors with no patient visits.
  SELECT 
    d.name AS doctor_name
FROM doctors d
LEFT JOIN visits v ON d.doctor_id = v.doctor_id
WHERE v.visit_id IS NULL;

### 15. **Hotel Booking Dashboard**
-- Tables: rooms, bookings, guests
-- Calculate occupancy rates per room.
-- Find guests with multiple bookings.
-- List rooms never booked.
 CREATE DATABASE HOTEL;
 USE HOTEL;

-- Rooms table
CREATE TABLE rooms (
    room_id INT PRIMARY KEY,
    room_number VARCHAR(10),
    capacity INT
);

-- Guests table
CREATE TABLE guests (
    guest_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Bookings table
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);
-- Rooms
INSERT INTO rooms (room_id, room_number, capacity) VALUES
(1, '101', 2),
(2, '102', 2),
(3, '103', 1),
(4, '104', 3); -- never booked

-- Guests
INSERT INTO guests (guest_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

-- Bookings
INSERT INTO bookings (booking_id, guest_id, room_id, check_in, check_out) VALUES
(1, 1, 1, '2024-07-01', '2024-07-05'),  -- 4 nights
(2, 1, 1, '2024-07-10', '2024-07-12'),  -- 2 nights
(3, 2, 2, '2024-07-03', '2024-07-06'),  -- 3 nights
(4, 3, 3, '2024-07-01', '2024-07-02');  -- 1 night
-- room 104 never booked
-- Calculate occupancy rates per room.
SELECT 
    r.room_number,
    SUM(DATEDIFF(b.check_out, b.check_in)) AS nights_booked,
    30 AS total_days,
    ROUND(
        (IFNULL(SUM(DATEDIFF(b.check_out, b.check_in)), 0) / 30) * 100,
        2
    ) AS occupancy_rate_percent
FROM rooms r
LEFT JOIN bookings b ON r.room_id = b.room_id
GROUP BY r.room_id, r.room_number;

-- Find guests with multiple bookings.
SELECT 
    g.name AS guest_name,
    COUNT(b.booking_id) AS booking_count
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.name
HAVING COUNT(b.booking_id) > 1;

-- List rooms never booked.
SELECT 
    r.room_number
FROM rooms r
LEFT JOIN bookings b ON r.room_id = b.room_id
WHERE b.booking_id IS NULL;

 
### 16. **Online Learning Platform Statistics**
-- Tables: courses, users, enrollments, completions
CREATE DATABASE STATISTICS;
USE STATISTICS;

-- Courses
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

-- Users
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Enrollments
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    user_id INT,
    course_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Completions
CREATE TABLE completions (
    completion_id INT PRIMARY KEY,
    user_id INT,
    course_id INT,
    completion_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
-- Courses
INSERT INTO courses (course_id, course_name) VALUES
(1, 'SQL Basics'),
(2, 'Advanced Python'),
(3, 'Data Structures');

-- Users
INSERT INTO users (user_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Enrollments
INSERT INTO enrollments (enrollment_id, user_id, course_id) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 1),
(4, 3, 2),
(5, 4, 3); -- Diana enrolled but never completed

-- Completions
INSERT INTO completions (completion_id, user_id, course_id, completion_date) VALUES
(1, 1, 1, '2024-01-10'), -- Alice
(2, 1, 2, '2024-02-15'), -- Alice
(3, 2, 1, '2024-03-05'), -- Bob
(4, 3, 2, '2024-04-20'); -- Charlie
-- Diana has no completions

-- Count course completions per user.
SELECT 
    u.name AS user_name,
    COUNT(c.completion_id) AS total_completions
FROM users u
LEFT JOIN completions c ON u.user_id = c.user_id
GROUP BY u.user_id, u.name;

-- List courses with less than 5 completions.
SELECT 
    co.course_name,
    COUNT(c.completion_id) AS completion_count
FROM courses co
LEFT JOIN completions c ON co.course_id = c.course_id
GROUP BY co.course_id, co.course_name
HAVING COUNT(c.completion_id) < 5;

-- Identify users enrolled but never completed any course.
 SELECT 
    u.name AS user_name
FROM users u
JOIN enrollments e ON u.user_id = e.user_id
LEFT JOIN completions c ON u.user_id = c.user_id AND e.course_id = c.course_id
WHERE c.completion_id IS NULL
GROUP BY u.user_id, u.name;


 
### 17. **Municipal Service Requests**
-- Tables: requests, citizens, departments
CREATE DATABASE MUNICIPALITY;
USE MUNICIPALITY;

-- Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

-- Citizens
CREATE TABLE citizens (
    citizen_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Requests
CREATE TABLE requests (
    request_id INT PRIMARY KEY,
    citizen_id INT,
    department_id INT,
    request_date DATE,
    description TEXT,
    FOREIGN KEY (citizen_id) REFERENCES citizens(citizen_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
-- Departments
INSERT INTO departments (department_id, department_name) VALUES
(1, 'Sanitation'),
(2, 'Water Supply'),
(3, 'Road Maintenance'),
(4, 'Public Safety'); -- No requests

-- Citizens
INSERT INTO citizens (citizen_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana');

-- Requests
INSERT INTO requests (request_id, citizen_id, department_id, request_date, description) VALUES
(1, 1, 1, '2024-01-10', 'Missed garbage pickup'),
(2, 1, 2, '2024-02-15', 'Water leak'),
(3, 2, 1, '2024-03-05', 'Overflowing trash bin'),
(4, 3, 3, '2024-04-20', 'Pothole in road'),
(5, 1, 1, '2024-05-12', 'Uncollected waste');
-- Diana has no requests
-- Public Safety (dept_id 4) has no requests

-- Count requests per citizen and department.
SELECT 
    c.name AS citizen_name,
    COUNT(r.request_id) AS total_requests
FROM citizens c
LEFT JOIN requests r ON c.citizen_id = r.citizen_id
GROUP BY c.citizen_id, c.name;

-- List departments with no requests.
SELECT 
    d.department_name,
    COUNT(r.request_id) AS total_requests
FROM departments d
LEFT JOIN requests r ON d.department_id = r.department_id
GROUP BY d.department_id, d.department_name;

-- Find citizens with the highest number of requests.
 SELECT 
    d.department_name
FROM departments d
LEFT JOIN requests r ON d.department_id = r.department_id
WHERE r.request_id IS NULL;

### 18. **Warehouse Order Fulfillment**
-- Tables: orders, order_items, products, employees
CREATE DATABASE WAREHOUSE;
USE WAREHOUSE;

-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    stock INT
);

-- Employees
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    employee_id INT,
    order_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Order Items
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    fulfilled BOOLEAN,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Products
INSERT INTO products (product_id, product_name, stock) VALUES
(1, 'Widget A', 10),
(2, 'Gadget B', 0),     -- out of stock
(3, 'Tool C', 5),
(4, 'Device D', 0);     -- out of stock

-- Employees
INSERT INTO employees (employee_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie');

-- Orders
INSERT INTO orders (order_id, employee_id, order_date) VALUES
(1, 1, '2024-07-01'),
(2, 2, '2024-07-02'),
(3, 1, '2024-07-03'),
(4, 3, '2024-07-04');

-- Order Items
INSERT INTO order_items (item_id, order_id, product_id, quantity, fulfilled) VALUES
(1, 1, 1, 2, TRUE),
(2, 1, 2, 1, FALSE),   -- out of stock
(3, 2, 3, 1, TRUE),
(4, 2, 4, 1, FALSE),   -- out of stock
(5, 3, 1, 3, TRUE),
(6, 4, 3, 2, TRUE);


-- Count orders handled per employee.
SELECT 
    e.name AS employee_name,
    COUNT(o.order_id) AS total_orders
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.employee_id
GROUP BY e.employee_id, e.name;

-- Identify products frequently out of stock.
SELECT 
    p.product_name,
    COUNT(oi.item_id) AS failed_fulfillments
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.stock = 0 AND oi.fulfilled = FALSE
GROUP BY p.product_id, p.product_name
ORDER BY failed_fulfillments DESC;

-- Show employees with top fulfillment rates.
 SELECT 
    e.name AS employee_name,
    COUNT(CASE WHEN oi.fulfilled THEN 1 END) AS fulfilled_items,
    COUNT(oi.item_id) AS total_items,
    ROUND(
        (COUNT(CASE WHEN oi.fulfilled THEN 1 END) / COUNT(oi.item_id)) * 100,
        2
    ) AS fulfillment_rate_percent
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY e.employee_id, e.name
ORDER BY fulfillment_rate_percent DESC;

### 19. **Sales Team Performance Tracking**
-- Tables: salespeople, sales, regions
CREATE DATABASE COMPANY2;
USE COMPANY2;

-- Regions table
CREATE TABLE regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(100)
);

-- Salespeople table
CREATE TABLE salespeople (
    salesperson_id INT PRIMARY KEY,
    name VARCHAR(100),
    region_id INT,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- Sales table
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    salesperson_id INT,
    amount DECIMAL(10, 2),
    sale_date DATE,
    FOREIGN KEY (salesperson_id) REFERENCES salespeople(salesperson_id)
);
-- Regions
INSERT INTO regions (region_id, region_name) VALUES
(1, 'North'),
(2, 'South'),
(3, 'East'),
(4, 'West');  -- region with no sales yet

-- Salespeople
INSERT INTO salespeople (salesperson_id, name, region_id) VALUES
(1, 'Alice', 1),
(2, 'Bob', 2),
(3, 'Charlie', 3),
(4, 'Diana', 1),
(5, 'Eve', 4);  -- No sales yet

-- Sales
INSERT INTO sales (sale_id, salesperson_id, amount, sale_date) VALUES
(1, 1, 5000.00, '2024-01-10'),
(2, 1, 3000.00, '2024-02-15'),
(3, 2, 7000.00, '2024-01-20'),
(4, 3, 2000.00, '2024-03-10'),
(5, 1, 2500.00, '2025-01-10'),
(6, 2, 3000.00, '2025-01-12'),
(7, 3, 5000.00, '2025-01-15');
-- Eve (salesperson_id=5) has no sales
-- West (region_id=4) has no sales

-- Calculate total sales per region and per salesperson.
SELECT 
    r.region_name,
    SUM(s.amount) AS total_sales
FROM regions r
LEFT JOIN salespeople sp ON r.region_id = sp.region_id
LEFT JOIN sales s ON sp.salesperson_id = s.salesperson_id
GROUP BY r.region_id, r.region_name;

SELECT 
    sp.name AS salesperson_name,
    SUM(s.amount) AS total_sales
FROM salespeople sp
LEFT JOIN sales s ON sp.salesperson_id = s.salesperson_id
GROUP BY sp.salesperson_id, sp.name;

-- List salespeople with no sales in a region (LEFT JOIN).
SELECT 
    sp.name AS salesperson_name,
    r.region_name
FROM salespeople sp
JOIN regions r ON sp.region_id = r.region_id
LEFT JOIN sales s ON sp.salesperson_id = s.salesperson_id
WHERE s.sale_id IS NULL;

-- Identify regions with the highest sales growth.
 SELECT 
    r.region_name,
    SUM(CASE WHEN YEAR(s.sale_date) = 2024 THEN s.amount ELSE 0 END) AS sales_2024,
    SUM(CASE WHEN YEAR(s.sale_date) = 2025 THEN s.amount ELSE 0 END) AS sales_2025,
    (SUM(CASE WHEN YEAR(s.sale_date) = 2025 THEN s.amount ELSE 0 END) -
     SUM(CASE WHEN YEAR(s.sale_date) = 2024 THEN s.amount ELSE 0 END)) AS growth
FROM regions r
LEFT JOIN salespeople sp ON r.region_id = sp.region_id
LEFT JOIN sales s ON sp.salesperson_id = s.salesperson_id
GROUP BY r.region_id, r.region_name
ORDER BY growth DESC;

---
 
### 20. **Friend Referral Program**
-- Tables: users, referrals (user_id, referred_user_id), purchases
CREATE DATABASE REFERRAL;
USE REFERRAL;


-- Users
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Referrals
CREATE TABLE referrals (
    user_id INT,             -- the one who referred
    referred_user_id INT,    -- the person who was referred
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (referred_user_id) REFERENCES users(user_id)
);

-- Purchases
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2),
    purchase_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
-- Users
INSERT INTO users (user_id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'Diana'),
(5, 'Eve'),
(6, 'Frank');

-- Referrals (user_id referred referred_user_id)
INSERT INTO referrals (user_id, referred_user_id) VALUES
(1, 2),  -- Alice referred Bob
(1, 3),  -- Alice referred Charlie
(2, 4),  -- Bob referred Diana
(3, 5),  -- Charlie referred Eve
(1, 6);  -- Alice referred Frank

-- Purchases
INSERT INTO purchases (purchase_id, user_id, amount, purchase_date) VALUES
(1, 2, 100.00, '2024-01-10'),
(2, 4, 150.00, '2024-02-01'),
(3, 5, 200.00, '2024-03-15'),
(4, 6, 50.00, '2024-03-20');
-- Alice and Charlie made no purchases

-- Count number of referrals per user (self join).
SELECT 
    u.name AS referrer_name,
    COUNT(r.referred_user_id) AS referral_count
FROM users u
LEFT JOIN referrals r ON u.user_id = r.user_id
GROUP BY u.user_id, u.name;

-- List users who referred others but made no purchases.
SELECT 
    u.name AS referrer_name
FROM users u
JOIN referrals r ON u.user_id = r.user_id
LEFT JOIN purchases p ON u.user_id = p.user_id
WHERE p.purchase_id IS NULL
GROUP BY u.user_id, u.name;

-- Identify users with the most referred purchases.
 SELECT 
    u.name AS referrer_name,
    COUNT(p.purchase_id) AS referred_purchases
FROM users u
JOIN referrals r ON u.user_id = r.user_id
JOIN purchases p ON r.referred_user_id = p.user_id
GROUP BY u.user_id, u.name
ORDER BY referred_purchases DESC;

