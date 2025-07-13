-- 25. Product Wishlist System 
-- Objective: Let users save favorite products. 
create database pro_wishlist;
use pro_wishlist;

-- Entities: 
-- • Users 
-- • Products 
-- • Wishlist 
-- SQL Skills: 
-- • Many-to-many 
-- • Query popular wishlist items 
-- Tables: 
-- • users (id, name) 
-- • products (id, name) 
-- • wishlist (user_id, product_id)


-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Products table
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Wishlist table (many-to-many relationship)
CREATE TABLE wishlist (
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Products
INSERT INTO products (name) VALUES
('iPhone 14'), ('MacBook Air'), ('PlayStation 5'), ('Samsung Galaxy S22');

-- Wishlist entries
INSERT INTO wishlist (user_id, product_id) VALUES
(1, 1), -- Alice likes iPhone 14
(1, 2), -- Alice likes MacBook Air
(2, 1), -- Bob likes iPhone 14
(2, 3), -- Bob likes PS5
(3, 3), -- Charlie likes PS5
(3, 4); -- Charlie likes Galaxy S22
-- Show Users' Wishlists
SELECT 
    u.name AS user,
    p.name AS product
FROM wishlist w
JOIN users u ON w.user_id = u.id
JOIN products p ON w.product_id = p.id
ORDER BY u.name, p.name;
--  Most Wishlisted Products
SELECT 
    p.name AS product,
    COUNT(w.user_id) AS wishlist_count
FROM wishlist w
JOIN products p ON w.product_id = p.id
GROUP BY w.product_id
ORDER BY wishlist_count DESC;
-- Who Wishlisted a Specific Product (e.g., PS5)
SELECT 
    p.name AS product,
    u.name AS user
FROM wishlist w
JOIN products p ON w.product_id = p.id
JOIN users u ON w.user_id = u.id
WHERE p.name = 'PlayStation 5'
ORDER BY user;







