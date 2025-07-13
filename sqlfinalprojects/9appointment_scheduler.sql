-- 9. Appointment Scheduler 
-- Objective: Track appointments booked by users.
create database appointment;
use appointment; 
-- Entities: 
-- • Users 
-- • Services 
-- • Appointments 

-- Tables: 
-- • users (id, name) 
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- • services (id, name) 
CREATE TABLE services (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO services (name) VALUES
('Haircut'),
('Massage'),
('Dental Checkup');

-- • appointments (id, user_id, service_id, appointment_time) 
CREATE TABLE appointments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    service_id BIGINT UNSIGNED NOT NULL,
    appointment_time DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (service_id) REFERENCES services(id),
    UNIQUE KEY uniq_user_time (user_id, appointment_time)  -- optional: no double-booking per user
);
INSERT INTO appointments (user_id, service_id, appointment_time) VALUES
(1, 1, '2025-07-15 10:00:00'),
(2, 2, '2025-07-15 11:00:00'),
(3, 3, '2025-07-15 12:30:00');

-- SQL Skills: 
-- • Time clash logic 
-- • Filters by date and service 
--  View All Appointments With User & Service Names
SELECT 
    a.id,
    u.name AS user,
    s.name AS service,
    a.appointment_time
FROM appointments a
JOIN users u ON a.user_id = u.id
JOIN services s ON a.service_id = s.id
ORDER BY a.appointment_time;
--  Filter Appointments by Date (2025-07-15)
SELECT 
    u.name AS user,
    s.name AS service,
    a.appointment_time
FROM appointments a
JOIN users u ON a.user_id = u.id
JOIN services s ON a.service_id = s.id
WHERE DATE(a.appointment_time) = '2025-07-15'
ORDER BY a.appointment_time;
--  Filter Appointments by Service (e.g., Massage)
SELECT 
    u.name AS user,
    a.appointment_time
FROM appointments a
JOIN users u ON a.user_id = u.id
JOIN services s ON a.service_id = s.id
WHERE s.name = 'Massage'
ORDER BY a.appointment_time;
--  Check for Time Clash for a User (Alice) at a New Slot
-- Check if Alice (id = 1) already has an appointment at '2025-07-15 10:00:00'
SELECT *
FROM appointments
WHERE user_id = 1 AND appointment_time = '2025-07-15 10:00:00';



