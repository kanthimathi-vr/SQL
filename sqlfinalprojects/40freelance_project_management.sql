-- 40. Freelance Project Management 
-- Objective: Match freelancers with projects and track proposals. 
create database freelance;
use freelance;

-- Entities: 
-- • Freelancers 
-- • Projects 
-- • Proposals 
-- SQL Skills: 
-- • Bids and accepted proposals 
-- • Count projects per freelancer 
-- Tables: 
-- • freelancers (id, name, skill) 
-- • projects (id, client_name, title) 
-- • proposals (freelancer_id, project_id, bid_amount, status) 


-- Create freelancers table
CREATE TABLE freelancers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    skill VARCHAR(100) NOT NULL
);

-- Create projects table
CREATE TABLE projects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    title VARCHAR(150) NOT NULL
);

-- Create proposals table
CREATE TABLE proposals (
    freelancer_id BIGINT UNSIGNED NOT NULL,
    project_id BIGINT UNSIGNED NOT NULL,
    bid_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'accepted', 'rejected') NOT NULL DEFAULT 'pending',
    PRIMARY KEY (freelancer_id, project_id),
    FOREIGN KEY (freelancer_id) REFERENCES freelancers(id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);
-- Insert freelancers
INSERT INTO freelancers (name, skill) VALUES
('Alice', 'Web Development'),
('Bob', 'Graphic Design'),
('Charlie', 'Content Writing');

-- Insert projects
INSERT INTO projects (client_name, title) VALUES
('Acme Corp', 'Website Redesign'),
('TechNova', 'Logo Design'),
('GreenText', 'Blog Content Creation'),
('StartUpX', 'Landing Page Development');

-- Insert proposals
INSERT INTO proposals (freelancer_id, project_id, bid_amount, status) VALUES
(1, 1, 1500.00, 'accepted'),
(2, 2, 500.00, 'accepted'),
(3, 3, 300.00, 'accepted'),
(1, 4, 1200.00, 'pending'),
(2, 1, 1600.00, 'rejected'),
(3, 4, 1100.00, 'pending');

-- List accepted proposals with freelancer and project
SELECT 
    f.name AS freelancer,
    f.skill,
    p.title AS project_title,
    pr.bid_amount
FROM proposals pr
JOIN freelancers f ON pr.freelancer_id = f.id
JOIN projects p ON pr.project_id = p.id
WHERE pr.status = 'accepted';
--  Count of proposals per freelancer
SELECT 
    f.name AS freelancer,
    COUNT(pr.project_id) AS total_proposals
FROM freelancers f
LEFT JOIN proposals pr ON f.id = pr.freelancer_id
GROUP BY f.id;
-- Number of accepted projects per freelancer
SELECT 
    f.name AS freelancer,
    COUNT(*) AS accepted_projects
FROM proposals pr
JOIN freelancers f ON pr.freelancer_id = f.id
WHERE pr.status = 'accepted'
GROUP BY pr.freelancer_id;
--  Projects with multiple proposals
SELECT 
    p.title,
    COUNT(*) AS proposal_count
FROM proposals pr
JOIN projects p ON pr.project_id = p.id
GROUP BY pr.project_id
HAVING proposal_count > 1;

