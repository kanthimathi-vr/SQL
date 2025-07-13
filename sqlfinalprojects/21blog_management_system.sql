-- 21. Blog Management System 
-- Objective: Store and manage blog posts and comments. 
create database blog;
use blog;

-- Entities: 
-- • Users 
-- • Posts 
-- • Comments 
-- SQL Skills: 
-- • Joins for comments with posts 
-- • Filter posts by user or date 
-- Tables: 
-- • users (id, name) 
-- • posts (id, user_id, title, content, published_date) 
-- • comments (id, post_id, user_id, comment_text, commented_at) 

-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Posts table
CREATE TABLE posts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    published_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Comments table
CREATE TABLE comments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    post_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    comment_text TEXT NOT NULL,
    commented_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Posts
INSERT INTO posts (user_id, title, content, published_date) VALUES
(1, 'First Post', 'This is Alice\'s first blog post.', '2025-07-01 10:00:00'),
(2, 'Bob\'s Thoughts', 'Some random thoughts by Bob.', '2025-07-02 14:30:00'),
(1, 'Second Post', 'Alice shares more info.', '2025-07-03 09:15:00');

-- Comments
INSERT INTO comments (post_id, user_id, comment_text, commented_at) VALUES
(1, 2, 'Nice post, Alice!', '2025-07-01 11:00:00'),
(1, 3, 'Thanks for sharing.', '2025-07-01 12:00:00'),
(2, 1, 'Interesting perspective, Bob.', '2025-07-02 16:00:00'),
(3, 3, 'Great follow-up post!', '2025-07-03 10:00:00');
-- Get All Comments with Post and User Info
SELECT 
    c.id AS comment_id,
    u.name AS commenter,
    p.title AS post_title,
    c.comment_text,
    c.commented_at
FROM comments c
JOIN users u ON c.user_id = u.id
JOIN posts p ON c.post_id = p.id
ORDER BY c.commented_at;
--  Filter Posts by a Specific User (e.g., Alice)
SELECT 
    p.id AS post_id,
    u.name AS author,
    p.title,
    p.published_date
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE u.name = 'Alice'
ORDER BY p.published_date DESC;
-- Filter Posts Published in July 2025
SELECT 
    p.id,
    u.name AS author,
    p.title,
    p.published_date
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE MONTH(p.published_date) = 7 AND YEAR(p.published_date) = 2025
ORDER BY p.published_date;
-- Count Comments Per Post
SELECT 
    p.id AS post_id,
    p.title,
    COUNT(c.id) AS comment_count
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
GROUP BY p.id
ORDER BY comment_count DESC;








