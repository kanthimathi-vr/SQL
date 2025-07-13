-- 32. Online Forum System 
-- Objective: Handle forum threads, posts, and replies. 
create database online1;
use online1;

-- Entities: 
-- • Threads 
-- • Posts 
-- • Users 
-- SQL Skills: 
-- • Self joins for reply chains 
-- • Thread view aggregation 
-- Tables: 
-- • threads (id, title, user_id) 
-- • posts (id, thread_id, user_id, content, parent_post_id, 
-- posted_at) 


CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE threads (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE posts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    thread_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    content TEXT NOT NULL,
    parent_post_id BIGINT UNSIGNED DEFAULT NULL,
    posted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (thread_id) REFERENCES threads(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_post_id) REFERENCES posts(id) ON DELETE SET NULL
);
-- Users
INSERT INTO users (name) VALUES
('Alice'),
('Bob'),
('Charlie');

-- Threads
INSERT INTO threads (title, user_id) VALUES
('Welcome to the Forum', 1),
('General Discussion', 2);

-- Posts (parent_post_id = NULL means original post)
INSERT INTO posts (thread_id, user_id, content, parent_post_id, posted_at) VALUES
(1, 1, 'Hello everyone! This is the first thread.', NULL, '2025-07-13 10:00:00'),
(1, 2, 'Hi Alice! Glad to be here.', 1, '2025-07-13 10:10:00'),
(1, 3, 'Welcome Bob! Thanks for joining.', 2, '2025-07-13 10:15:00'),
(2, 2, 'What do you think about the new features?', NULL, '2025-07-13 11:00:00'),
(2, 1, 'I like them a lot!', 4, '2025-07-13 11:05:00');
--  View All Threads with Number of Posts and Original Poster
SELECT
    t.id,
    t.title,
    u.name AS thread_owner,
    COUNT(p.id) AS post_count
FROM threads t
JOIN users u ON t.user_id = u.id
LEFT JOIN posts p ON t.id = p.thread_id
GROUP BY t.id, t.title, u.name
ORDER BY t.id;
-- Get All Posts in a Thread (with reply chains shown by parent_post_id)
SELECT
    p.id,
    p.content,
    u.name AS author,
    p.parent_post_id,
    p.posted_at
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE p.thread_id = 1 -- example thread_id
ORDER BY p.posted_at;
-- SELECT
    p.id,
    p.content,
    u.name AS author,
    p.parent_post_id,
    p.posted_at
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE p.thread_id = 1 -- example thread_id
ORDER BY p.posted_at;
-- Show Posts with Replies Using Self Join
SELECT
    p1.id AS post_id,
    p1.content AS post_content,
    u1.name AS post_author,
    p2.id AS reply_id,
    p2.content AS reply_content,
    u2.name AS reply_author,
    p2.posted_at AS reply_time
FROM posts p1
LEFT JOIN posts p2 ON p2.parent_post_id = p1.id
LEFT JOIN users u1 ON p1.user_id = u1.id
LEFT JOIN users u2 ON p2.user_id = u2.id
WHERE p1.thread_id = 1
ORDER BY p1.posted_at, p2.posted_at;
-- Count Replies per Post
SELECT
    p.id AS post_id,
    p.content,
    COUNT(r.id) AS reply_count
FROM posts p
LEFT JOIN posts r ON r.parent_post_id = p.id
WHERE p.thread_id = 1
GROUP BY p.id, p.content
ORDER BY p.posted_at;
