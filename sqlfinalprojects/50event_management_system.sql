-- 50. Event Management System 
-- Objective: Organize and track event participants. 
create database eventmanage;
use eventmanage;

-- Entities: 
-- • Events 
-- • Attendees 
-- SQL Skills: 
-- • Event-wise participant count 
-- • Capacity alerts 
-- Tables: 
-- • events (id, title, max_capacity) 
-- • attendees (event_id, user_id, registered_at)


CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    max_capacity INT UNSIGNED NOT NULL
);

CREATE TABLE attendees (
    event_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    registered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, user_id),
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie'),
('Diana'),
('Ethan');

INSERT INTO events (title, max_capacity) VALUES
('Tech Conference 2025', 3),
('Music Festival', 5),
('Art Workshop', 2);

INSERT INTO attendees (event_id, user_id, registered_at) VALUES
(1, 1, '2025-06-01 10:00:00'),
(1, 2, '2025-06-01 11:00:00'),
(1, 3, '2025-06-01 12:00:00'),
(2, 2, '2025-07-15 09:00:00'),
(2, 4, '2025-07-15 09:15:00'),
(3, 5, '2025-08-20 14:00:00');
-- Event-wise participant count
SELECT 
    e.id AS event_id,
    e.title,
    COUNT(a.user_id) AS participant_count,
    e.max_capacity
FROM events e
LEFT JOIN attendees a ON e.id = a.event_id
GROUP BY e.id, e.title, e.max_capacity;
-- Events exceeding or reaching max capacity (capacity alerts)
SELECT 
    e.id AS event_id,
    e.title,
    COUNT(a.user_id) AS participant_count,
    e.max_capacity,
    CASE 
        WHEN COUNT(a.user_id) >= e.max_capacity THEN 'Capacity reached/exceeded'
        ELSE 'Capacity available'
    END AS status
FROM events e
LEFT JOIN attendees a ON e.id = a.event_id
GROUP BY e.id, e.title, e.max_capacity
HAVING participant_count >= e.max_capacity;
