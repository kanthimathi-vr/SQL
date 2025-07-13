-- 33. Asset Management System 
-- Objective: Track company assets, users, and assignment history. 
create database asset;
use asset;

-- Entities: 
-- • Assets 
-- • Users 
-- • Assignments 
-- SQL Skills: 
-- • Current vs historical usage tracking 
-- • Asset availability queries 
-- Tables: 
-- • assets (id, name, category) 
-- • users (id, name) 
-- • assignments (asset_id, user_id, assigned_date, returned_date) 

CREATE TABLE assets (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL
);

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE assignments (
    asset_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    assigned_date DATE NOT NULL,
    returned_date DATE DEFAULT NULL,
    PRIMARY KEY (asset_id, assigned_date),
    FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CHECK (returned_date IS NULL OR returned_date >= assigned_date)
);
-- Assets
INSERT INTO assets (name, category) VALUES
('Laptop Dell XPS 13', 'Electronics'),
('iPhone 12', 'Mobile Devices'),
('Office Chair', 'Furniture');

-- Users
INSERT INTO users (name) VALUES
('John Doe'),
('Jane Smith'),
('Alice Johnson');

-- Assignments
INSERT INTO assignments (asset_id, user_id, assigned_date, returned_date) VALUES
(1, 1, '2025-07-01', NULL),        -- Laptop assigned to John, still with him
(2, 2, '2025-06-15', '2025-07-05'), -- iPhone assigned to Jane, returned
(2, 3, '2025-07-06', NULL),        -- iPhone assigned to Alice now
(3, 1, '2025-05-10', '2025-06-10'); -- Chair assigned to John, returned
--  List all current asset assignments (assets currently assigned, i.e., returned_date IS NULL)
SELECT 
    a.id AS asset_id,
    a.name AS asset_name,
    a.category,
    u.id AS user_id,
    u.name AS user_name,
    ass.assigned_date
FROM assignments ass
JOIN assets a ON ass.asset_id = a.id
JOIN users u ON ass.user_id = u.id
WHERE ass.returned_date IS NULL
ORDER BY ass.assigned_date DESC;
--  Get full assignment history for a specific asset
SELECT
    u.name AS user_name,
    ass.assigned_date,
    ass.returned_date
FROM assignments ass
JOIN users u ON ass.user_id = u.id
WHERE ass.asset_id = 2 -- example asset_id
ORDER BY ass.assigned_date DESC;
-- Find available assets (not currently assigned or returned)
SELECT 
    a.id,
    a.name,
    a.category
FROM assets a
LEFT JOIN assignments ass ON a.id = ass.asset_id AND ass.returned_date IS NULL
WHERE ass.asset_id IS NULL;
-- Count assets currently assigned per user
SELECT 
    u.id,
    u.name,
    COUNT(ass.asset_id) AS assets_assigned
FROM users u
LEFT JOIN assignments ass ON u.id = ass.user_id AND ass.returned_date IS NULL
GROUP BY u.id, u.name
ORDER BY assets_assigned DESC;

