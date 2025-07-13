-- 43. Product Return Management 
-- Objective: Store and manage product return requests. 
create database returnmanage;
use returnmanage;

-- Entities: 
-- • Orders 
-- • Return Requests 
-- SQL Skills: 
-- • JOIN orders with returns 
-- • Status reporting 
-- Tables: 
-- • orders (id, user_id, product_id) 
-- • returns (id, order_id, reason, status)

-- Create orders table
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL
);

-- Create returns table
CREATE TABLE returns (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    reason VARCHAR(255),
    status ENUM('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Sample data: insert into orders
INSERT INTO orders (user_id, product_id) VALUES
(1, 101),
(2, 102),
(3, 103),
(1, 104);

-- Sample data: insert into returns
INSERT INTO returns (order_id, reason, status) VALUES
(1, 'Damaged item', 'Pending'),
(2, 'Wrong size', 'Approved'),
(4, 'Not satisfied', 'Rejected');
-- Join orders with their return requests:
SELECT 
    o.id AS order_id,
    o.user_id,
    o.product_id,
    r.id AS return_id,
    r.reason,
    r.status
FROM orders o
LEFT JOIN returns r ON o.id = r.order_id
ORDER BY o.id;
-- Count returns by status:
SELECT 
    status,
    COUNT(*) AS count
FROM returns
GROUP BY status;
-- List all pending return requests:
SELECT 
    r.id AS return_id,
    o.id AS order_id,
    o.user_id,
    o.product_id,
    r.reason
FROM returns r
JOIN orders o ON r.order_id = o.id
WHERE r.status = 'Pending';
