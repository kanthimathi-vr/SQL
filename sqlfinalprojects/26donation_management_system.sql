-- 26. Donation Management System 
-- Objective: Track donations made to causes. 
create database donation;
use donation;

-- Entities: 
-- • Donors 
-- • Causes 
-- • Donations 
-- SQL Skills: 
-- • SUM of donations per cause 
-- • Ranking causes by funds 
-- Tables: 
-- • donors (id, name) 
-- • causes (id, title) 
-- • donations (id, donor_id, cause_id, amount, donated_at) 


-- Donors table
CREATE TABLE donors (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Causes table
CREATE TABLE causes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL
);

-- Donations table
CREATE TABLE donations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    donor_id BIGINT UNSIGNED NOT NULL,
    cause_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    donated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES donors(id) ON DELETE CASCADE,
    FOREIGN KEY (cause_id) REFERENCES causes(id) ON DELETE CASCADE
);
-- Donors
INSERT INTO donors (name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Causes
INSERT INTO causes (title) VALUES
('Education Fund'), ('Healthcare Support'), ('Disaster Relief');

-- Donations
INSERT INTO donations (donor_id, cause_id, amount, donated_at) VALUES
(1, 1, 100.00, '2025-07-10 09:00:00'),
(2, 1, 150.00, '2025-07-10 10:00:00'),
(1, 2, 200.00, '2025-07-11 11:00:00'),
(3, 2, 50.00,  '2025-07-11 12:00:00'),
(2, 3, 300.00, '2025-07-12 13:00:00'),
(3, 3, 250.00, '2025-07-12 14:00:00');
-- Total Donations Per Cause
SELECT 
    c.title AS cause,
    SUM(d.amount) AS total_donated
FROM donations d
JOIN causes c ON d.cause_id = c.id
GROUP BY d.cause_id
ORDER BY total_donated DESC;
-- Rank Causes by Total Donation Amount
SELECT 
    c.title AS cause,
    SUM(d.amount) AS total_donated,
    RANK() OVER (ORDER BY SUM(d.amount) DESC) AS rank_position
FROM donations d
JOIN causes c ON d.cause_id = c.id
GROUP BY d.cause_id;
-- Donations by a Specific Donor (e.g. Alice)
SELECT 
    d.donated_at,
    c.title AS cause,
    d.amount
FROM donations d
JOIN causes c ON d.cause_id = c.id
WHERE d.donor_id = 1
ORDER BY d.donated_at;
