-- 22. Voting System 
-- Objective: Let users vote on topics and options. 
create database voting;
use voting;

-- Entities: 
-- • Polls 
-- • Options 
-- • Votes 
-- SQL Skills: 
-- • COUNT votes by option 
-- • Prevent duplicate votes per user 
-- Tables: 
-- • polls (id, question) 
-- • options (id, poll_id, option_text) 
-- • votes (user_id, option_id, voted_at) 


-- Users table (optional, but needed to track votes per user)
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Polls table
CREATE TABLE polls (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    question TEXT NOT NULL
);

-- Options table
CREATE TABLE options (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    poll_id BIGINT UNSIGNED NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE
);

-- Votes table (user_id + poll_id must be unique — one vote per user per poll)
CREATE TABLE votes (
    user_id BIGINT UNSIGNED NOT NULL,
    option_id BIGINT UNSIGNED NOT NULL,
    voted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, option_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (option_id) REFERENCES options(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Poll
INSERT INTO polls (question) VALUES
('What is your favorite programming language?');

-- Options for the poll
INSERT INTO options (poll_id, option_text) VALUES
(1, 'Python'),
(1, 'JavaScript'),
(1, 'Java'),
(1, 'C++');

-- Votes
INSERT INTO votes (user_id, option_id) VALUES
(1, 1), -- Alice votes Python
(2, 2), -- Bob votes JavaScript
(3, 1); -- Charlie votes Python
-- Count Votes per Option for a Poll
SELECT 
    o.option_text,
    COUNT(v.user_id) AS vote_count
FROM options o
LEFT JOIN votes v ON o.id = v.option_id
WHERE o.poll_id = 1
GROUP BY o.id
ORDER BY vote_count DESC;
-- Prevent Duplicate Votes (one vote per poll per user)
-- Check if a user already voted in a poll
SELECT 
    v.user_id,
    o.poll_id
FROM votes v
JOIN options o ON v.option_id = o.id
WHERE v.user_id = 1 AND o.poll_id = 1;
-- See Who Voted for What
SELECT 
    u.name AS user,
    p.question,
    o.option_text,
    v.voted_at
FROM votes v
JOIN users u ON v.user_id = u.id
JOIN options o ON v.option_id = o.id
JOIN polls p ON o.poll_id = p.id
ORDER BY v.voted_at;






