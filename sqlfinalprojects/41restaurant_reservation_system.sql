-- 41. Restaurant Reservation System 
-- Objective: Track reservations and table assignments. 
create database restaurant;
use restaurant;

-- Entities: 
-- • Tables 
-- • Guests 
-- • Reservations 
-- SQL Skills: 
-- • Overlap detection 
-- • Daily summary 
-- Tables: 
-- • tables (id, table_number, capacity) 
-- • guests (id, name) 
-- • reservations (id, guest_id, table_id, date, time_slot) 


-- Create tables table
CREATE TABLE tables (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL UNIQUE,
    capacity INT NOT NULL
);

-- Create guests table
CREATE TABLE guests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create reservations table
CREATE TABLE reservations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    guest_id BIGINT UNSIGNED NOT NULL,
    table_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    time_slot TIME NOT NULL, -- assuming 1-hour slots
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES tables(id) ON DELETE CASCADE
);
-- Insert tables
INSERT INTO tables (table_number, capacity) VALUES
(1, 2),
(2, 4),
(3, 6);

-- Insert guests
INSERT INTO guests (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana');

-- Insert reservations
INSERT INTO reservations (guest_id, table_id, date, time_slot) VALUES
(1, 1, '2024-07-13', '18:00:00'),
(2, 2, '2024-07-13', '19:00:00'),
(3, 1, '2024-07-13', '19:00:00'), -- same table as Alice, different time
(4, 3, '2024-07-14', '20:00:00');
-- Detect Overlapping Reservations for the Same Table
SELECT 
    r1.id AS res1_id,
    r2.id AS res2_id,
    t.table_number,
    r1.date,
    r1.time_slot AS slot1,
    r2.time_slot AS slot2
FROM reservations r1
JOIN reservations r2 ON 
    r1.table_id = r2.table_id 
    AND r1.date = r2.date
    AND r1.time_slot = r2.time_slot
    AND r1.id < r2.id
JOIN tables t ON r1.table_id = t.id;
-- Daily Reservation Summary
SELECT 
    r.date,
    COUNT(*) AS total_reservations,
    COUNT(DISTINCT r.table_id) AS tables_used
FROM reservations r
GROUP BY r.date
ORDER BY r.date;
--  Reservation List with Guest and Table Info
SELECT 
    g.name AS guest,
    t.table_number,
    t.capacity,
    r.date,
    r.time_slot
FROM reservations r
JOIN guests g ON r.guest_id = g.id
JOIN tables t ON r.table_id = t.id
ORDER BY r.date, r.time_slot;
