-- 23. Messaging System 
-- Objective: Store user-to-user private messages. 
create database message;
use message;

-- Entities: 
-- • Users 
-- • Conversations 
-- • Messages 
-- SQL Skills: 
-- • Recent message retrieval 
-- • Threading messages by conversation 
-- Tables: 
-- • users (id, name) 
-- • conversations (id) 
-- • messages (id, conversation_id, sender_id, message_text, sent_at) 


-- Users table
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Conversations table (optional: can be user1_id, user2_id if you want 1-to-1 only)
CREATE TABLE conversations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
    -- could add participants table for group chat
);

-- Messages table
CREATE TABLE messages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT UNSIGNED NOT NULL,
    sender_id BIGINT UNSIGNED NOT NULL,
    message_text TEXT NOT NULL,
    sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);
-- Users
INSERT INTO users (name) VALUES
('Alice'), ('Bob'), ('Charlie');

-- Conversations (assume 1 conversation between Alice & Bob, 1 between Alice & Charlie)
INSERT INTO conversations (id) VALUES
(1), (2);

-- Messages
INSERT INTO messages (conversation_id, sender_id, message_text, sent_at) VALUES
(1, 1, 'Hey Bob, how are you?', '2025-07-13 10:00:00'),
(1, 2, 'I am good, Alice. You?', '2025-07-13 10:01:00'),
(1, 1, 'Doing great!', '2025-07-13 10:02:00'),
(2, 1, 'Hey Charlie, long time!', '2025-07-13 11:00:00'),
(2, 3, 'Yes, let\'s catch up soon!', '2025-07-13 11:01:00');
-- Get All Messages in a Conversation (Thread View)
SELECT 
    m.id,
    u.name AS sender,
    m.message_text,
    m.sent_at
FROM messages m
JOIN users u ON m.sender_id = u.id
WHERE m.conversation_id = 1
ORDER BY m.sent_at;
-- Get Latest Message Per Conversation
SELECT 
    c.id AS conversation_id,
    m.message_text,
    u.name AS sender,
    m.sent_at
FROM conversations c
JOIN (
    SELECT conversation_id, MAX(sent_at) AS latest
    FROM messages
    GROUP BY conversation_id
) latest_msg ON c.id = latest_msg.conversation_id
JOIN messages m ON m.conversation_id = latest_msg.conversation_id AND m.sent_at = latest_msg.latest
JOIN users u ON m.sender_id = u.id
ORDER BY latest_msg.latest DESC;
-- All Conversations Involving a Specific User
SELECT DISTINCT c.id AS conversation_id
FROM conversations c
JOIN messages m ON c.id = m.conversation_id
WHERE m.sender_id = 1; -- for example: Alice
