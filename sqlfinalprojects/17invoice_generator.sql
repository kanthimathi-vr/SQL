-- 17. Invoice Generator 
-- Objective: Create invoices with multiple line items. 
create database invoice;
use invoice;

-- Entities: 
-- • Clients 
-- • Invoices 
-- • Invoice Items 
-- SQL Skills: 
-- • Subtotal/total calculations 
-- • JOINs between invoice and items 
-- Tables: 
-- • clients (id, name) 
-- • invoices (id, client_id, date) 
-- • invoice_items (invoice_id, description, quantity, rate) 


-- Clients table
CREATE TABLE clients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Invoices table
CREATE TABLE invoices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

-- Invoice Items table
CREATE TABLE invoice_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id BIGINT UNSIGNED NOT NULL,
    description VARCHAR(255) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    rate DECIMAL(10, 2) NOT NULL CHECK (rate > 0),
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);
-- Clients
INSERT INTO clients (name) VALUES
('Acme Corp'),
('Beta Ltd');

-- Invoices
INSERT INTO invoices (client_id, date) VALUES
(1, '2025-07-10'), -- Acme
(2, '2025-07-11'); -- Beta

-- Invoice Items
INSERT INTO invoice_items (invoice_id, description, quantity, rate) VALUES
(1, 'Website Design', 1, 1500.00),
(1, 'Hosting (12 months)', 1, 240.00),
(1, 'Maintenance (6 months)', 1, 300.00),
(2, 'SEO Services', 2, 500.00),
(2, 'Consulting', 5, 200.00);
--  Full Invoice Details With Totals

SELECT 
    i.id AS invoice_id,
    c.name AS client,
    i.date,
    ii.description,
    ii.quantity,
    ii.rate,
    (ii.quantity * ii.rate) AS line_total
FROM invoice_items ii
JOIN invoices i ON ii.invoice_id = i.id
JOIN clients c ON i.client_id = c.id
ORDER BY i.id, ii.id;
-- Subtotal / Total Per Invoice
SELECT 
    i.id AS invoice_id,
    c.name AS client,
    i.date,
    SUM(ii.quantity * ii.rate) AS total_amount
FROM invoice_items ii
JOIN invoices i ON ii.invoice_id = i.id
JOIN clients c ON i.client_id = c.id
GROUP BY i.id
ORDER BY i.id;
--  Invoice Breakdown for a Specific Client (e.g. 'Acme Corp')
SELECT 
    i.id AS invoice_id,
    i.date,
    ii.description,
    ii.quantity,
    ii.rate,
    (ii.quantity * ii.rate) AS line_total
FROM invoice_items ii
JOIN invoices i ON ii.invoice_id = i.id
JOIN clients c ON i.client_id = c.id
WHERE c.name = 'Acme Corp'
ORDER BY i.date;

