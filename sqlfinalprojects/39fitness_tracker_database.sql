-- 39. Fitness Tracker Database 
-- Objective: Store workouts, users, and progress logs. 
create database fitness;
use fitness;

-- Entities: 
-- • Users 
-- • Workouts 
-- • Logs 
-- SQL Skills: 
-- • Weekly summary per user 
-- • JOINs for workout type 
-- Tables: 
-- • users (id, name) 
-- • workouts (id, name, type) 
-- • workout_logs (user_id, workout_id, duration, log_date) 


-- Create users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create workouts table
CREATE TABLE workouts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL -- e.g. Cardio, Strength, Flexibility
);

-- Create workout_logs table
CREATE TABLE workout_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    workout_id BIGINT UNSIGNED NOT NULL,
    duration INT NOT NULL, -- duration in minutes
    log_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
);

-- Insert users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Insert workouts
INSERT INTO workouts (name, type) VALUES
('Running', 'Cardio'),
('Cycling', 'Cardio'),
('Weight Lifting', 'Strength'),
('Yoga', 'Flexibility');

-- Insert workout logs
INSERT INTO workout_logs (user_id, workout_id, duration, log_date) VALUES
(1, 1, 30, '2024-07-01'),
(1, 2, 45, '2024-07-02'),
(1, 4, 20, '2024-07-04'),
(2, 3, 40, '2024-07-01'),
(2, 2, 35, '2024-07-03'),
(3, 1, 25, '2024-07-02'),
(3, 4, 30, '2024-07-05'),
(1, 3, 50, '2024-07-06');
-- Weekly workout summary per user (Total minutes)
SELECT 
    u.name AS user_name,
    YEARWEEK(wl.log_date, 1) AS year_week,
    SUM(wl.duration) AS total_minutes
FROM workout_logs wl
JOIN users u ON wl.user_id = u.id
GROUP BY u.id, YEARWEEK(wl.log_date, 1)
ORDER BY year_week, user_name;
-- All workouts by type per user
SELECT 
    u.name AS user_name,
    w.type AS workout_type,
    w.name AS workout_name,
    wl.duration,
    wl.log_date
FROM workout_logs wl
JOIN users u ON wl.user_id = u.id
JOIN workouts w ON wl.workout_id = w.id
ORDER BY u.name, wl.log_date;
-- Total time per workout type
SELECT 
    w.type AS workout_type,
    SUM(wl.duration) AS total_minutes
FROM workout_logs wl
JOIN workouts w ON wl.workout_id = w.id
GROUP BY w.type
ORDER BY total_minutes DESC;
