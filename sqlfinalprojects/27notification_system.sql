-- 27. Notification System 
-- Objective: Store user notifications and read status. 
create database notification;
use notification;

-- Entities: 
-- • Users 
-- • Notifications 
-- SQL Skills: 
-- • Unread count 
-- • Mark-as-read logic 
-- Tables: 
-- • notifications (id, user_id, message, status, created_at) 


-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Notifications table
CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    message TEXT NOT NULL,
    status ENUM('unread', 'read') DEFAULT 'unread',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Notifications
INSERT INTO notifications (user_id, message, status, created_at) VALUES
(1, 'Welcome to the platform, Alice!', 'unread', '2025-07-10 09:00:00'),
(1, 'Your profile was updated.', 'read', '2025-07-11 12:00:00'),
(2, 'New message received.', 'unread', '2025-07-12 14:00:00'),
(2, 'Your subscription is expiring soon.', 'unread', '2025-07-13 08:00:00'),
(3, 'New comment on your post.', 'read', '2025-07-13 09:00:00');
-- Count Unread Notifications per User
SELECT 
    u.name AS user,
    COUNT(n.id) AS unread_notifications
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id AND n.status = 'unread'
GROUP BY u.id;
--  Mark All Notifications as Read for a User (e.g., user_id = 2)
UPDATE notifications
SET status = 'read'
WHERE user_id = 2 AND status = 'unread';
--  Get All Notifications for a User (most recent first)
SELECT 
    message,
    status,
    created_at
FROM notifications
WHERE user_id = 1
ORDER BY created_at DESC;










