-- 37. Food Delivery Tracker 
-- Objective: Track restaurant orders, delivery agents, and delivery times. 
create  database food;
use food;
-- Entities: 
-- • Orders 
-- • Restaurants 
-- • Delivery Agents 
-- SQL Skills: 
-- • Delivery time analysis 
-- • Agent workload 
-- Tables: 
-- • orders (id, restaurant_id, user_id, placed_at, delivered_at) 
-- • delivery_agents (id, name) 
-- • deliveries (order_id, agent_id) 
-- Drop tables if they exist


-- Create users (who place the orders)
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create restaurants
CREATE TABLE restaurants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create delivery agents
CREATE TABLE delivery_agents (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create orders
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    placed_at DATETIME NOT NULL,
    delivered_at DATETIME DEFAULT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create deliveries (order assigned to agent)
CREATE TABLE deliveries (
    order_id BIGINT UNSIGNED NOT NULL,
    agent_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (agent_id) REFERENCES delivery_agents(id) ON DELETE CASCADE
);

-- Insert sample users
INSERT INTO users (name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Insert sample restaurants
INSERT INTO restaurants (name) VALUES
('Pizza Palace'), ('Sushi World'), ('Burger Barn');

-- Insert sample delivery agents
INSERT INTO delivery_agents (name) VALUES
('Ravi'), ('Sana');

-- Insert sample orders
INSERT INTO orders (restaurant_id, user_id, placed_at, delivered_at) VALUES
(1, 1, '2024-07-01 12:00:00', '2024-07-01 12:30:00'),
(2, 2, '2024-07-01 13:00:00', '2024-07-01 13:40:00'),
(3, 3, '2024-07-01 14:00:00', '2024-07-01 14:25:00'),
(1, 2, '2024-07-02 11:00:00', NULL), -- not delivered yet
(2, 1, '2024-07-02 11:30:00', '2024-07-02 12:05:00');

-- Insert deliveries
INSERT INTO deliveries (order_id, agent_id) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 2),
(5, 1);
-- Average Delivery Time (in minutes)
SELECT 
    AVG(TIMESTAMPDIFF(MINUTE, placed_at, delivered_at)) AS avg_delivery_time_minutes
FROM orders
WHERE delivered_at IS NOT NULL;
-- Agent Workload (Number of Deliveries)
SELECT 
    da.name AS agent_name,
    COUNT(d.order_id) AS deliveries_handled
FROM deliveries d
JOIN delivery_agents da ON d.agent_id = da.id
GROUP BY da.name
ORDER BY deliveries_handled DESC;
--  Recent Orders With Agent and Restaurant Info
SELECT 
    o.id AS order_id,
    r.name AS restaurant,
    u.name AS customer,
    da.name AS delivery_agent,
    o.placed_at,
    o.delivered_at
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.id
JOIN users u ON o.user_id = u.id
JOIN deliveries d ON o.id = d.order_id
JOIN delivery_agents da ON d.agent_id = da.id
ORDER BY o.placed_at DESC;
