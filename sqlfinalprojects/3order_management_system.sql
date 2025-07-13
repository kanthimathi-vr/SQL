-- 3. Order Management System 
-- Objective: Store placed orders and track their statuses. 
-- Entities: 
-- • Users 
-- • Orders 
-- • Products 
-- • Order Items 

-- Tables: 
-- • orders (id, user_id, status, created_at) 
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- • order_items (id, order_id, product_id, quantity, price) 
CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL,  -- store price at time of order
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- SQL Skills: 
-- • Transactions 
START TRANSACTION;

-- Insert a new order for user_id = 1 (Alice)
INSERT INTO orders (user_id, status) VALUES (1, 'pending');

-- Get the last inserted order ID
SET @order_id = LAST_INSERT_ID();

-- Add items to the order (using fixed price at order time)
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(@order_id, 1, 1, 999.99),  -- iPhone
(@order_id, 3, 2, 149.99);  -- Nike Shoes

COMMIT;

START TRANSACTION;

INSERT INTO orders (user_id, status) VALUES (2, 'processing');
SET @order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(@order_id, 2, 1, 899.99);  -- Galaxy S22

COMMIT;

-- • JOINs and GROUP BY 
-- • Status tracking with enums 
-- • Query to get order history by user 
SELECT
    o.id AS order_id,
    o.status,
    o.created_at,
    p.name AS product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total_price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.user_id = 1
ORDER BY o.created_at DESC;
-- total spend by user
SELECT
    u.name,
    COUNT(o.id) AS total_orders,
    SUM(oi.quantity * oi.price) AS total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
GROUP BY u.id;
--  Get All Orders with Totals and Status
SELECT
    o.id AS order_id,
    u.name AS customer,
    o.status,
    o.created_at,
    SUM(oi.quantity * oi.price) AS order_total
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id
ORDER BY o.created_at DESC;
--  Update Order Status
UPDATE orders
SET status = 'shipped'
WHERE id = 1;  -- Update Alice's first order
-- Cancel an Order 
UPDATE orders
SET status = 'cancelled'
WHERE id = 2;

