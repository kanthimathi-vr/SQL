-- 5. Product Review and Rating System 
-- Objective: Allow users to submit reviews and ratings for products. 
create database review;
use review;
-- Entities: 
-- • Users 
-- • Products 
-- • Reviews 

-- Tables: 
-- • users (id, name) 
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- • products (id, name) 
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL
);
INSERT INTO products (name) VALUES
('iPhone 14'),
('Galaxy S22'),
('Nike Air Max');

-- • reviews (id, user_id, product_id, rating, review, created_at) 
CREATE TABLE reviews (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, product_id),  -- Prevent duplicate reviews
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
INSERT INTO reviews (user_id, product_id, rating, review) VALUES
(1, 1, 5, 'Amazing phone!'),
(2, 1, 4, 'Very good but expensive.'),
(3, 1, 5, 'Top notch performance.'),
(1, 2, 3, 'Decent but not great.'),
(2, 2, 4, 'Solid Android phone.'),
(3, 3, 5, 'Very comfortable shoes.');

-- SQL Skills: 
-- • Aggregate ratings using AVG and GROUP BY 
SELECT
    p.id,
    p.name,
    AVG(r.rating) AS avg_rating,
    COUNT(r.id) AS review_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
ORDER BY avg_rating DESC;

-- • Query to get top-rated products 
SELECT
    p.name,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(*) AS total_reviews
FROM products p
JOIN reviews r ON p.id = r.product_id
GROUP BY p.id
HAVING COUNT(*) >= 2
ORDER BY avg_rating DESC
LIMIT 5;

SELECT
    u.name AS user,
    r.rating,
    r.review,
    r.created_at
FROM reviews r
JOIN users u ON r.user_id = u.id
WHERE r.product_id = 1
ORDER BY r.created_at DESC;

-- • Prevent duplicate reviews by same user-product 
-- Error: Duplicate entry for user_id=1 and product_id=1
INSERT INTO reviews (user_id, product_id, rating, review) 
VALUES (1, 1, 4, 'Second review');  

