-- 4. Inventory Tracking System 
-- Objective: Manage product stock levels and inventory history. 
-- Entities: 
-- • Products 
-- • Suppliers 
-- • Inventory Logs 
create database inventory;
use inventory;

-- Tables: 
-- • products (id, name, stock) 
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);
INSERT INTO products (name, price, stock) VALUES
('iPhone 14', 999.99, 100),
('Galaxy S22', 899.99, 80),
('Nike Air Max', 149.99, 200);
-- • suppliers (id, name) 
CREATE TABLE suppliers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT INTO suppliers (name) VALUES
('Apple Inc.'),
('Samsung Co.'),
('Nike Ltd.');

-- • inventory_logs (id, product_id, supplier_id, action, qty, 
-- timestamp)
CREATE TABLE inventory_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    supplier_id BIGINT UNSIGNED,
    action ENUM('restock', 'sale', 'return') NOT NULL,
    qty INT NOT NULL CHECK (qty > 0),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
);

-- SQL Skills: 
-- • Triggers to auto-update stock 
DELIMITER $$

CREATE TRIGGER trg_update_stock
AFTER INSERT ON inventory_logs
FOR EACH ROW
BEGIN
    IF NEW.action = 'restock' THEN
        UPDATE products SET stock = stock + NEW.qty WHERE id = NEW.product_id;
    ELSEIF NEW.action = 'sale' THEN
        UPDATE products SET stock = stock - NEW.qty WHERE id = NEW.product_id;
    ELSEIF NEW.action = 'return' THEN
        UPDATE products SET stock = stock + NEW.qty WHERE id = NEW.product_id;
    END IF;
END$$

DELIMITER ;
-- Restock iPhone (product_id=1) from Apple (supplier_id=1)
INSERT INTO inventory_logs (product_id, supplier_id, action, qty) 
VALUES (1, 1, 'restock', 20);

-- Sale of 5 Nike shoes (product_id=3)
INSERT INTO inventory_logs (product_id, action, qty)
VALUES (3, 'sale', 5);

-- Customer returns 1 Galaxy (product_id=2)
INSERT INTO inventory_logs (product_id, action, qty)
VALUES (2, 'return', 1);

-- • Reorder logic with CASE WHEN 
-- • Query to get stock status 
SELECT id, name, stock
FROM products;
SELECT 
    p.name AS product,
    s.name AS supplier,
    il.action,
    il.qty,
    il.timestamp
FROM inventory_logs il
LEFT JOIN products p ON il.product_id = p.id
LEFT JOIN suppliers s ON il.supplier_id = s.id
ORDER BY il.timestamp DESC;
SELECT 
    id,
    name,
    stock,
    CASE 
        WHEN stock < 50 THEN 'Reorder Needed'
        ELSE 'Sufficient Stock'
    END AS status
FROM products;


