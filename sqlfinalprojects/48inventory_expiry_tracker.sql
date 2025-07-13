-- 48. Inventory Expiry Tracker 
-- Objective: Monitor stock with expiry dates.
  create database inventoryexpiry;
  use inventoryexpiry;
-- Entities: 
-- • Products 
-- • Batches 
-- SQL Skills: 
-- • Expired stock alerts 
-- • Remaining stock query 
-- Tables: 
-- • products (id, name) 
-- • batches (id, product_id, quantity, expiry_date)


CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE batches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    expiry_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
INSERT INTO products (name) VALUES
('Milk'),
('Bread'),
('Eggs'),
('Cheese');

INSERT INTO batches (product_id, quantity, expiry_date) VALUES
(1, 100, '2025-07-10'),
(1, 50,  '2025-07-20'),
(2, 200, '2025-07-05'),
(3, 300, '2025-06-30'),
(4, 80,  '2025-08-15');
--  Alert: List all expired batches as of today
SELECT 
    b.id AS batch_id,
    p.name AS product_name,
    b.quantity,
    b.expiry_date
FROM batches b
JOIN products p ON b.product_id = p.id
WHERE b.expiry_date < CURDATE()
ORDER BY b.expiry_date;
-- Remaining stock per product (non-expired batches)
SELECT
    p.id AS product_id,
    p.name AS product_name,
    SUM(b.quantity) AS remaining_quantity
FROM products p
LEFT JOIN batches b ON p.id = b.product_id AND b.expiry_date >= CURDATE()
GROUP BY p.id, p.name;
-- Total stock including expired (for reference)
SELECT
    p.id AS product_id,
    p.name AS product_name,
    SUM(b.quantity) AS total_quantity
FROM products p
LEFT JOIN batches b ON p.id = b.product_id
GROUP BY p.id, p.name;

