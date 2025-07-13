-- 8. Sales CRM Tracker 
-- Objective: Monitor leads and deals status across stages. 
create database salescrm;
use salescrm;

-- Entities: 
-- • Users 
-- • Leads 
-- • Deals 
-- • Statuses 

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

-- • leads (id, name, source) 
CREATE TABLE leads (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    source VARCHAR(50)
);
INSERT INTO leads (name, source) VALUES
('ACME Corp', 'Website'),
('Globex', 'Referral'),
('Soylent Inc.', 'Email Campaign');

-- • deals (id, lead_id, user_id, stage, amount, created_at) 
CREATE TABLE deals (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    lead_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    stage ENUM('new', 'contacted', 'proposal_sent', 'won', 'lost') NOT NULL,
    amount DECIMAL(10,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lead_id) REFERENCES leads(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
INSERT INTO deals (lead_id, user_id, stage, amount, created_at) VALUES
(1, 1, 'new', 5000.00, '2025-07-01'),
(2, 2, 'contacted', 12000.00, '2025-07-03'),
(3, 3, 'proposal_sent', 8000.00, '2025-07-05'),
(1, 1, 'won', 5000.00, '2025-07-10'),
(2, 2, 'lost', 12000.00, '2025-07-12');

-- SQL Skills: 
-- • CTEs or Window functions for deal progression 
-- • Filters by status/date 
-- View All Deals with User, Lead & Stage
SELECT 
    d.id AS deal_id,
    l.name AS lead_name,
    u.name AS sales_rep,
    d.stage,
    d.amount,
    d.created_at
FROM deals d
JOIN leads l ON d.lead_id = l.id
JOIN users u ON d.user_id = u.id
ORDER BY d.created_at DESC;
--  Total Deals and Revenue by Stage

SELECT 
    stage,
    COUNT(*) AS total_deals,
    SUM(amount) AS total_revenue
FROM deals
GROUP BY stage;
-- Pipeline Summary by Sales Rep
SELECT 
    u.name AS sales_rep,
    d.stage,
    COUNT(*) AS deals_count,
    SUM(d.amount) AS total_amount
FROM deals d
JOIN users u ON d.user_id = u.id
GROUP BY u.name, d.stage
ORDER BY u.name;
-- Deals Progression (Using Window Function)
WITH ranked_deals AS (
    SELECT 
        d.*, 
        ROW_NUMBER() OVER (PARTITION BY lead_id ORDER BY created_at DESC) AS rn
    FROM deals d
)
SELECT 
    rd.lead_id,
    l.name AS lead_name,
    rd.stage AS latest_stage,
    rd.amount,
    rd.created_at
FROM ranked_deals rd
JOIN leads l ON rd.lead_id = l.id
WHERE rd.rn = 1;

--  Filter Deals by Date Range and Status
SELECT 
    d.id,
    l.name AS lead_name,
    u.name AS sales_rep,
    d.stage,
    d.amount,
    d.created_at
FROM deals d
JOIN leads l ON d.lead_id = l.id
JOIN users u ON d.user_id = u.id
WHERE d.stage = 'won'
  AND d.created_at BETWEEN '2025-07-01' AND '2025-07-31';


