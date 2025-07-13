-- 36. IT Support Ticket System 
-- Objective: Track support tickets and resolution time. 
create database support;
use support;

-- Entities: 
-- • Users 
-- • Tickets 
-- • Support Staff 
-- SQL Skills: 
-- • Average resolution time 
-- • Ticket volume by category 
-- Tables: 
-- • tickets (id, user_id, issue, status, created_at, resolved_at) 
-- • support_staff (id, name) 
-- • assignments (ticket_id, staff_id)
-- Users table (ticket requesters)
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Support staff table
CREATE TABLE support_staff (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Tickets table
CREATE TABLE tickets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    issue VARCHAR(255) NOT NULL, -- e.g., 'Login Issue', 'Hardware', 'Network'
    status ENUM('Open', 'In Progress', 'Resolved', 'Closed') DEFAULT 'Open',
    created_at DATETIME NOT NULL,
    resolved_at DATETIME DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Assignments table (which staff is assigned to which ticket)
CREATE TABLE assignments (
    ticket_id BIGINT UNSIGNED NOT NULL,
    staff_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (ticket_id, staff_id),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES support_staff(id) ON DELETE CASCADE
);
INSERT INTO users (name) VALUES
('Alice'), ('Bob'), ('Charlie');
INSERT INTO support_staff (name) VALUES
('Sarah'), ('David');
INSERT INTO tickets (user_id, issue, status, created_at, resolved_at) VALUES
(1, 'Login Issue', 'Resolved', '2024-06-01 09:00:00', '2024-06-01 10:30:00'),
(2, 'Hardware Failure', 'Closed', '2024-06-02 14:00:00', '2024-06-02 17:00:00'),
(3, 'Network Issue', 'Open', '2024-06-03 11:15:00', NULL),
(1, 'Software Crash', 'Resolved', '2024-06-04 10:00:00', '2024-06-04 12:00:00');
INSERT INTO assignments (ticket_id, staff_id) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 2);
-- Ticket Volume by Issue (Category)
SELECT issue, COUNT(*) AS ticket_count
FROM tickets
GROUP BY issue
ORDER BY ticket_count DESC;
--  Average Resolution Time (for resolved tickets)
SELECT 
    AVG(TIMESTAMPDIFF(MINUTE, created_at, resolved_at)) AS avg_resolution_minutes
FROM tickets
WHERE resolved_at IS NOT NULL;
-- Tickets with Assigned Staff and Status
SELECT 
    t.id AS ticket_id,
    u.name AS requester,
    t.issue,
    t.status,
    ss.name AS support_staff,
    t.created_at,
    t.resolved_at
FROM tickets t
JOIN users u ON t.user_id = u.id
JOIN assignments a ON t.id = a.ticket_id
JOIN support_staff ss ON a.staff_id = ss.id
ORDER BY t.created_at;
