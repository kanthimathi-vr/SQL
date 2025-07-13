-- 42. Vehicle Rental System 
-- Objective: Track vehicle availability and rentals. 
create database vehicle;
use vehicle;

-- Entities: 
-- • Vehicles 
-- • Customers 
-- • Rentals 
-- SQL Skills: 
-- • Duration-based charge calculation 
-- • Vehicle availability 
-- Tables: 
-- • vehicles (id, type, plate_number) 
-- • customers (id, name) 
-- • rentals (vehicle_id, customer_id, start_date, end_date) 


-- Create vehicles table
CREATE TABLE vehicles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    plate_number VARCHAR(20) NOT NULL UNIQUE
);

-- Create customers table
CREATE TABLE customers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create rentals table
CREATE TABLE rentals (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    vehicle_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    CHECK (end_date >= start_date)
);
-- Insert vehicles
INSERT INTO vehicles (type, plate_number) VALUES
('Car', 'ABC123'),
('Van', 'XYZ987'),
('Bike', 'BIK456');

-- Insert customers
INSERT INTO customers (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Insert rentals
INSERT INTO rentals (vehicle_id, customer_id, start_date, end_date) VALUES
(1, 1, '2024-07-01', '2024-07-05'),
(2, 2, '2024-07-03', '2024-07-07'),
(3, 3, '2024-07-10', '2024-07-12');
-- Calculate Rental Duration and Example Charges (e.g., $50 per day)
SELECT 
    r.id AS rental_id,
    c.name AS customer,
    v.plate_number,
    v.type,
    DATEDIFF(r.end_date, r.start_date) + 1 AS rental_days,
    (DATEDIFF(r.end_date, r.start_date) + 1) * 50 AS total_charge
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.id
JOIN customers c ON r.customer_id = c.id;
-- Check Available Vehicles on a Given Date
-- Replace '2024-07-04' with any date you want to check
SELECT *
FROM vehicles v
WHERE NOT EXISTS (
    SELECT 1
    FROM rentals r
    WHERE r.vehicle_id = v.id
    AND '2024-07-04' BETWEEN r.start_date AND r.end_date
);

-- List All Current Rentals
SELECT 
    v.plate_number,
    c.name AS customer,
    r.start_date,
    r.end_date
FROM rentals r
JOIN vehicles v ON r.vehicle_id = v.id
JOIN customers c ON r.customer_id = c.id
WHERE CURDATE() BETWEEN r.start_date AND r.end_date;
