-- project1:
-- 1. E-Commerce Product Catalog 
-- Objective: Build a catalog system to manage and retrieve product listings. 
create database ecommerce;
use ecommerce;
-- Tables: 
-- • categories (id, name) 
CREATE TABLE categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
-- • brands (id, name) 
CREATE TABLE brands (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- • products (id, name, description, price, stock, image_url, 
-- category_id, brand_id)
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    image_url TEXT,
    category_id BIGINT UNSIGNED,
    brand_id BIGINT UNSIGNED,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id)
);


-- Entities: 
-- • Categories (e.g., Electronics, Apparel) 
INSERT INTO categories (name) VALUES
('Electronics'),
('Apparel'),
('Home Appliances');

-- • Brands (e.g., Apple, Nike) 
INSERT INTO brands (name) VALUES
('Apple'),
('Nike'),
('Samsung'),
('LG');

-- • Products (name, price, stock, image, category, brand) 
INSERT INTO products (name, description, price, stock, image_url, category_id, brand_id) VALUES
('iPhone 14', 'Latest Apple iPhone', 999.99, 50, 'iphone14.jpg', 1, 1),
('Galaxy S22', 'Samsung flagship phone', 899.99, 30, 'galaxys22.jpg', 1, 3),
('Nike Air Max', 'Popular Nike running shoes', 149.99, 100, 'airmax.jpg', 2, 2),
('LG Washing Machine', 'Front-load washing machine', 499.99, 20, 'lg_washer.jpg', 3, 4),
('MacBook Air', 'Apple laptop', 1249.99, 40, 'macbookair.jpg', 1, 1);

-- SQL Skills: 
-- • Foreign keys for category and brand 
-- • Indexing for performance 
CREATE INDEX idx_category_id ON products(category_id);
CREATE INDEX idx_brand_id ON products(brand_id);
CREATE INDEX idx_price ON products(price);

-- • Filtering by price, brand, category 
SELECT * FROM products
WHERE price < 1000;
SELECT p.* FROM products p
JOIN brands b ON p.brand_id = b.id
WHERE b.name = 'Apple';
SELECT p.* FROM products p
JOIN categories c ON p.category_id = c.id
WHERE c.name = 'Electronics';

-- • Write queries to return product lists by category or brand 
SELECT c.name AS category, p.name AS product, p.price
FROM products p
JOIN categories c ON p.category_id = c.id
ORDER BY c.name;

SELECT b.name AS brand, p.name AS product, p.price
FROM products p
JOIN brands b ON p.brand_id = b.id
ORDER BY b.name;


































