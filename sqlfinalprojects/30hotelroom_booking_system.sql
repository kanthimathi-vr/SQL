-- 30. Hotel Room Booking System 
-- Objective: Manage bookings, availability, and rooms. 
create database hotel;
use hotel;

-- Entities: 
-- • Rooms 
-- • Guests 
-- • Bookings 
-- SQL Skills: 
-- • Overlap logic 
-- • Room availability query 
-- Tables: 
-- • rooms (id, number, type) 
-- • guests (id, name) 
-- • bookings (id, room_id, guest_id, from_date, to_date) 


CREATE TABLE rooms (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    number VARCHAR(20) NOT NULL UNIQUE,
    type ENUM('single', 'double', 'suite') NOT NULL
);

CREATE TABLE guests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE bookings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT UNSIGNED NOT NULL,
    guest_id BIGINT UNSIGNED NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    CONSTRAINT chk_dates CHECK (to_date > from_date),
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE
);

-- Rooms
INSERT INTO rooms (number, type) VALUES
('101', 'single'),
('102', 'double'),
('201', 'suite');

-- Guests
INSERT INTO guests (name) VALUES
('John Doe'),
('Jane Smith'),
('Alice Johnson');

-- Bookings
INSERT INTO bookings (room_id, guest_id, from_date, to_date) VALUES
(1, 1, '2025-07-10', '2025-07-15'),
(2, 2, '2025-07-12', '2025-07-14'),
(3, 3, '2025-07-20', '2025-07-25');
-- Find Overlapping Bookings for a Given Room and Date Range
SELECT *
FROM bookings
WHERE room_id = 1 -- example room
  AND NOT (to_date <= '2025-07-16' OR from_date >= '2025-07-20');
-- Query Available Rooms for a Given Date Range
SELECT r.*
FROM rooms r
LEFT JOIN bookings b ON r.id = b.room_id 
    AND NOT (b.to_date <= '2025-07-16' OR b.from_date >= '2025-07-20')
WHERE b.id IS NULL;
-- List All Bookings with Guest and Room Info
SELECT
    b.id AS booking_id,
    r.number AS room_number,
    r.type AS room_type,
    g.name AS guest_name,
    b.from_date,
    b.to_date
FROM bookings b
JOIN rooms r ON b.room_id = r.id
JOIN guests g ON b.guest_id = g.id
ORDER BY b.from_date DESC;
-- Check if a Guest Has Any Overlapping Bookings (to prevent double booking)
SELECT *
FROM bookings
WHERE guest_id = 1 -- example guest
  AND NOT (to_date <= '2025-07-16' OR from_date >= '2025-07-20');
