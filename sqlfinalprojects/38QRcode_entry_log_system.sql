-- 38. QR Code Entry Log System 
-- Objective: Store and track QR-based entry records. 
create database qr;
use qr;
-- Entities: 
-- • Users 
-- • Locations 
-- • Entry Logs 
-- SQL Skills: 
-- • Count entries per location 
-- • Filter by date/time 
-- Tables: 
-- • locations (id, name) 
-- • users (id, name) 
-- • entry_logs (id, user_id, location_id, entry_time) 
-- Drop tables if they already exist


-- Create locations table
CREATE TABLE locations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create entry_logs table
CREATE TABLE entry_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    entry_time DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE
);

-- Insert sample locations
INSERT INTO locations (name) VALUES
('Main Entrance'),
('Server Room'),
('R&D Lab');

-- Insert sample users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('David');

-- Insert sample entry logs
INSERT INTO entry_logs (user_id, location_id, entry_time) VALUES
(1, 1, '2024-07-01 08:00:00'),
(2, 1, '2024-07-01 08:15:00'),
(1, 2, '2024-07-01 08:45:00'),
(3, 1, '2024-07-01 09:00:00'),
(4, 3, '2024-07-02 10:30:00'),
(2, 3, '2024-07-02 11:00:00'),
(3, 2, '2024-07-03 08:30:00'),
(1, 1, '2024-07-03 09:00:00');
-- Count entries per location
SELECT 
    l.name AS location_name,
    COUNT(e.id) AS total_entries
FROM entry_logs e
JOIN locations l ON e.location_id = l.id
GROUP BY e.location_id
ORDER BY total_entries DESC;
--  Filter entries by specific date (e.g., 2024-07-01)
SELECT 
    u.name AS user_name,
    l.name AS location_name,
    e.entry_time
FROM entry_logs e
JOIN users u ON e.user_id = u.id
JOIN locations l ON e.location_id = l.id
WHERE DATE(e.entry_time) = '2024-07-01'
ORDER BY e.entry_time;
-- Entries in a time window (e.g., between 08:00 and 09:00)
SELECT 
    u.name AS user_name,
    l.name AS location_name,
    e.entry_time
FROM entry_logs e
JOIN users u ON e.user_id = u.id
JOIN locations l ON e.location_id = l.id
WHERE TIME(e.entry_time) BETWEEN '08:00:00' AND '09:00:00'
ORDER BY e.entry_time;
