-- 46. Multi-Tenant SaaS Database 
-- Objective: Handle multiple clients (tenants) on same schema. 
create database saas;
use saas;

-- Entities: 
-- • Tenants 
-- • Users 
-- • Data 
-- SQL Skills: 
-- • Tenant isolation by foreign key 
-- • Query partitioning 
-- Tables: 
-- • tenants (id, name) 
-- • users (id, name, tenant_id) 
-- • data (id, tenant_id, content)


CREATE TABLE tenants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    tenant_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE TABLE data (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tenant_id BIGINT UNSIGNED NOT NULL,
    content TEXT NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);
INSERT INTO tenants (name) VALUES
('Tenant Alpha'),
('Tenant Beta');

INSERT INTO users (name, tenant_id) VALUES
('Alice', 1),
('Bob', 1),
('Charlie', 2),
('Diana', 2);

INSERT INTO data (tenant_id, content) VALUES
(1, 'Alpha: Report 1'),
(1, 'Alpha: Report 2'),
(2, 'Beta: Invoice 1'),
(2, 'Beta: Invoice 2');
-- Select all users for a specific tenant (e.g., tenant_id = 1)
SELECT id, name 
FROM users 
WHERE tenant_id = 1;
-- Retrieve all data entries belonging to a tenant (e.g., tenant_id = 2)
SELECT id, content 
FROM data 
WHERE tenant_id = 2;
--  Join users with their tenant data for tenant isolation
SELECT 
    u.id AS user_id, 
    u.name AS user_name, 
    t.name AS tenant_name, 
    d.content AS data_content
FROM users u
JOIN tenants t ON u.tenant_id = t.id
LEFT JOIN data d ON d.tenant_id = u.tenant_id
WHERE u.tenant_id = 1
ORDER BY u.id, d.id;
-- Count users per tenant
SELECT 
    t.name AS tenant_name,
    COUNT(u.id) AS user_count
FROM tenants t
LEFT JOIN users u ON t.id = u.tenant_id
GROUP BY t.id, t.name;
