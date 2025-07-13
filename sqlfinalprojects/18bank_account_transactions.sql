-- 18. Bank Account Transactions 
-- Objective: Simulate banking transactions. 
create database banktxn;
use banktxn;

-- Entities: 
-- • Users 
-- • Accounts 
-- • Transactions 
-- SQL Skills: 
-- • CTE for balance calculation 
-- • Transaction logs 
-- Tables: 
-- • accounts (id, user_id, balance) 
-- • transactions (id, account_id, type, amount, timestamp) 

-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Accounts table
CREATE TABLE accounts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    balance DECIMAL(12, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Transactions table
CREATE TABLE transactions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    account_id BIGINT UNSIGNED NOT NULL,
    type ENUM('deposit', 'withdrawal') NOT NULL,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob');

-- Accounts
INSERT INTO accounts (user_id, balance) VALUES
(1, 0.00), -- Alice
(2, 0.00); -- Bob

-- Transactions
INSERT INTO transactions (account_id, type, amount, timestamp) VALUES
(1, 'deposit', 1000.00, '2025-07-01 10:00:00'),
(1, 'withdrawal', 200.00, '2025-07-02 12:00:00'),
(1, 'deposit', 500.00, '2025-07-03 15:30:00'),
(2, 'deposit', 1500.00, '2025-07-01 09:00:00'),
(2, 'withdrawal', 300.00, '2025-07-02 11:00:00');
--  Transaction Log With Account and User Info
SELECT 
    t.id AS txn_id,
    u.name AS user,
    a.id AS account_id,
    t.type,
    t.amount,
    t.timestamp
FROM transactions t
JOIN accounts a ON t.account_id = a.id
JOIN users u ON a.user_id = u.id
ORDER BY t.timestamp;
-- Running Balance for Each Transaction (Using CTE)
WITH txn_with_balance AS (
    SELECT 
        t.account_id,
        t.timestamp,
        t.type,
        t.amount,
        CASE 
            WHEN t.type = 'deposit' THEN t.amount 
            WHEN t.type = 'withdrawal' THEN -t.amount 
        END AS signed_amount
    FROM transactions t
)
SELECT 
    a.id AS account_id,
    u.name AS user,
    t.timestamp,
    t.type,
    t.amount,
    SUM(t.signed_amount) OVER (PARTITION BY t.account_id ORDER BY t.timestamp) AS running_balance
FROM txn_with_balance t
JOIN accounts a ON t.account_id = a.id
JOIN users u ON a.user_id = u.id
ORDER BY t.account_id, t.timestamp;
-- Final Balance Per Account
SELECT 
    a.id AS account_id,
    u.name AS user,
    SUM(CASE 
        WHEN t.type = 'deposit' THEN t.amount
        WHEN t.type = 'withdrawal' THEN -t.amount
    END) AS calculated_balance
FROM transactions t
JOIN accounts a ON t.account_id = a.id
JOIN users u ON a.user_id = u.id
GROUP BY a.id;
--  Update Account Balance Table (Optional Sync)
UPDATE accounts a
JOIN (
    SELECT 
        account_id,
        SUM(CASE 
            WHEN type = 'deposit' THEN amount
            WHEN type = 'withdrawal' THEN -amount
        END) AS balance
    FROM transactions
    GROUP BY account_id
) t ON a.id = t.account_id
SET a.balance = t.balance;
