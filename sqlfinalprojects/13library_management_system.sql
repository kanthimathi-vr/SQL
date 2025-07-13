-- 13. Library Management System 
-- Objective: Manage books, members, borrow/return activity. 
create database library;
use library;

-- Entities: 
-- • Books 
-- • Members 
-- • Transactions 
-- Tables: 
-- • books (id, title, author) 
-- • members (id, name) 
-- • borrows (id, member_id, book_id, borrow_date, return_date) 
-- Drop tables if they exist (for rerun convenience)

-- Create books table
CREATE TABLE books (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL
);

-- Create members table
CREATE TABLE members (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create borrows table
CREATE TABLE borrows (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    member_id BIGINT UNSIGNED NOT NULL,
    book_id BIGINT UNSIGNED NOT NULL,
    borrow_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);
-- Insert books
INSERT INTO books (title, author) VALUES
('1984', 'George Orwell'),
('To Kill a Mockingbird', 'Harper Lee'),
('The Great Gatsby', 'F. Scott Fitzgerald'),
('Brave New World', 'Aldous Huxley');

-- Insert members
INSERT INTO members (name) VALUES
('Alice Johnson'),
('Bob Smith'),
('Charlie Lee');

-- Insert borrows
INSERT INTO borrows (member_id, book_id, borrow_date, return_date) VALUES
(1, 1, '2025-06-28', '2025-07-05'),  -- Returned on time
(2, 2, '2025-07-01', NULL),          -- Not returned
(3, 3, '2025-06-25', '2025-07-20');  -- Returned late

-- SQL Skills: 
-- • Joins and date logic 
-- • Fine calculation queries 
-- List All Borrowed Books (Returned + Not Returned)
SELECT 
    br.id AS borrow_id,
    m.name AS member_name,
    b.title AS book_title,
    br.borrow_date,
    br.return_date
FROM borrows br
JOIN members m ON br.member_id = m.id
JOIN books b ON br.book_id = b.id
ORDER BY br.borrow_date DESC;
-- B. Show Currently Borrowed Books (Not Returned Yet)
SELECT 
    m.name AS member_name,
    b.title AS book_title,
    br.borrow_date
FROM borrows br
JOIN members m ON br.member_id = m.id
JOIN books b ON br.book_id = b.id
WHERE br.return_date IS NULL;
--  Fine Calculation per Borrow
SELECT 
    m.name AS member_name,
    b.title AS book_title,
    br.borrow_date,
    COALESCE(br.return_date, CURRENT_DATE) AS actual_return_date,
    DATEDIFF(COALESCE(br.return_date, CURRENT_DATE), br.borrow_date) AS days_borrowed,
    GREATEST(DATEDIFF(COALESCE(br.return_date, CURRENT_DATE), br.borrow_date) - 14, 0) AS overdue_days,
    GREATEST(DATEDIFF(COALESCE(br.return_date, CURRENT_DATE), br.borrow_date) - 14, 0) * 1 AS fine_amount
FROM borrows br
JOIN members m ON br.member_id = m.id
JOIN books b ON br.book_id = b.id;
--  Books Borrowed by a Specific Member (e.g. Bob Smith)
SELECT 
    b.title,
    br.borrow_date,
    br.return_date
FROM borrows br
JOIN books b ON br.book_id = b.id
JOIN members m ON br.member_id = m.id
WHERE m.name = 'Bob Smith';













