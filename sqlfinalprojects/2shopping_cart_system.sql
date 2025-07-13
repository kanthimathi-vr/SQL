-- 2. Shopping Cart System 
-- Objective: Design a schema and queries to manage a user's shopping cart. 
create database shopping;
use shopping;

-- Entities: 
-- • Users 
-- • Products 
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    image_url TEXT
);
INSERT INTO products (name, description, price, stock, image_url) VALUES
('iPhone 14', 'Latest Apple iPhone', 999.99, 50, 'iphone14.jpg'),
('Galaxy S22', 'Samsung flagship phone', 899.99, 30, 'galaxys22.jpg'),
('Nike Air Max', 'Popular Nike running shoes', 149.99, 100, 'airmax.jpg');

-- • Cart Items 
-- Tables: 
-- • users (id, name, email) 
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);
INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- • carts (id, user_id) 
CREATE TABLE carts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
-- One cart per user (user_id = 1 and 2)
INSERT INTO carts (user_id) VALUES
(1),  -- Alice
(2);  -- Bob

-- • cart_items (cart_id, product_id, quantity)
CREATE TABLE cart_items (
    cart_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);
-- Alice (cart_id = 1) adds iPhone and Nike shoes
INSERT INTO cart_items (cart_id, product_id, quantity) VALUES
(1, 1, 1),  -- iPhone 14
(1, 3, 2);  -- Nike Air Max

-- Bob (cart_id = 2) adds Galaxy S22
INSERT INTO cart_items (cart_id, product_id, quantity) VALUES
(2, 2, 1);  -- Galaxy S22

-- SQL Skills: 
-- • Composite primary keys 
-- • JOINS to retrieve product details in the cart 
SELECT
    ci.cart_id,
    p.name AS product_name,
    p.price,
    ci.quantity,
    (p.price * ci.quantity) AS total_price
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
WHERE ci.cart_id = 1;  -- Alice's cart

-- • SUM to calculate total cart value 
SELECT
    SUM(p.price * ci.quantity) AS cart_total
FROM cart_items ci
JOIN products p ON ci.product_id = p.id
WHERE ci.cart_id = 1;  -- Alice's cart

-- • INSERT, UPDATE, DELETE for cart operations 
INSERT INTO cart_items (cart_id, product_id, quantity)
VALUES (1, 1, 1)  -- iPhone again
ON DUPLICATE KEY UPDATE quantity = quantity + 1;
UPDATE cart_items
SET quantity = 5
WHERE cart_id = 1 AND product_id = 1;
DELETE FROM cart_items
WHERE cart_id = 1 AND product_id = 3;

-- Tables: 
-- • users (id, name, email) 
-- • carts (id, user_id) 
-- • cart_items (cart_id, product_id, quantity)

SHOW TABLES;
-- view all cart contents;
SELECT 
    u.name AS user,
    p.name AS product,
    ci.quantity,
    p.price,
    (p.price * ci.quantity) AS total
FROM cart_items ci
JOIN carts c ON ci.cart_id = c.id
JOIN users u ON c.user_id = u.id
JOIN products p ON ci.product_id = p.id;
