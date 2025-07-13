-- 49. Payment Subscription Tracker 
-- Objective: Track recurring subscriptions and renewal dates. 
create database subscription;
use subscription;

-- Entities: 
-- • Users 
-- • Subscriptions 
-- SQL Skills: 
-- • Auto-renewal date logic 
-- • Expired subscription check 
-- Tables: 
-- • users (id, name) 
-- • subscriptions (id, user_id, plan_name, start_date, renewal_cycle) 


CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    plan_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    renewal_cycle ENUM('monthly', 'quarterly', 'yearly') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

INSERT INTO subscriptions (user_id, plan_name, start_date, renewal_cycle) VALUES
(1, 'Basic Plan', '2024-05-01', 'monthly'),
(2, 'Pro Plan', '2023-12-15', 'yearly'),
(3, 'Standard Plan', '2024-01-10', 'quarterly');
--  Calculate next renewal date per subscription
SELECT 
    s.id AS subscription_id,
    u.name AS user_name,
    s.plan_name,
    s.start_date,
    s.renewal_cycle,
    CASE s.renewal_cycle
        WHEN 'monthly' THEN DATE_ADD(s.start_date, INTERVAL TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) + 1 MONTH)
        WHEN 'quarterly' THEN DATE_ADD(s.start_date, INTERVAL (FLOOR(TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) / 3) + 1) * 3 MONTH)
        WHEN 'yearly' THEN DATE_ADD(s.start_date, INTERVAL TIMESTAMPDIFF(YEAR, s.start_date, CURDATE()) + 1 YEAR)
    END AS next_renewal_date
FROM subscriptions s
JOIN users u ON s.user_id = u.id;
--  Find subscriptions that have expired (next renewal date before today)
SELECT 
    s.id AS subscription_id,
    u.name AS user_name,
    s.plan_name,
    s.start_date,
    s.renewal_cycle,
    CASE s.renewal_cycle
        WHEN 'monthly' THEN DATE_ADD(s.start_date, INTERVAL TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) + 1 MONTH)
        WHEN 'quarterly' THEN DATE_ADD(s.start_date, INTERVAL (FLOOR(TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) / 3) + 1) * 3 MONTH)
        WHEN 'yearly' THEN DATE_ADD(s.start_date, INTERVAL TIMESTAMPDIFF(YEAR, s.start_date, CURDATE()) + 1 YEAR)
    END AS next_renewal_date
FROM subscriptions s
JOIN users u ON s.user_id = u.id
WHERE 
    CASE s.renewal_cycle
        WHEN 'monthly' THEN DATE_ADD(s.start_date, INTERVAL TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) + 1 MONTH)
        WHEN 'quarterly' THEN DATE_ADD(s.start_date, INTERVAL (FLOOR(TIMESTAMPDIFF(MONTH, s.start_date, CURDATE()) / 3) + 1) * 3 MONTH)
        WHEN 'yearly' THEN DATE_ADD(s.start_date, INTERVAL TIMESTAMPDIFF(YEAR, s.start_date, CURDATE()) + 1 YEAR)
    END < CURDATE();
