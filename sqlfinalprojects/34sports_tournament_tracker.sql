-- 34. Sports Tournament Tracker 
-- Objective: Organize teams, matches, and scores. 
create database sports;
use sports;

-- Entities: 
-- • Teams 
-- • Matches 
-- • Scores 
-- SQL Skills: 
-- • Win/loss stats 
-- • Leaderboard ranking 
-- Tables: 
-- • teams (id, name) 
-- • matches (id, team1_id, team2_id, match_date) 
-- • scores (match_id, team_id, score) 


CREATE TABLE teams (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE matches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    team1_id BIGINT UNSIGNED NOT NULL,
    team2_id BIGINT UNSIGNED NOT NULL,
    match_date DATE NOT NULL,
    FOREIGN KEY (team1_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (team2_id) REFERENCES teams(id) ON DELETE CASCADE,
    CHECK (team1_id <> team2_id)
);

CREATE TABLE scores (
    match_id BIGINT UNSIGNED NOT NULL,
    team_id BIGINT UNSIGNED NOT NULL,
    score INT NOT NULL CHECK (score >= 0),
    PRIMARY KEY (match_id, team_id),
    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
);
-- Teams
INSERT INTO teams (name) VALUES
('Red Warriors'),
('Blue Sharks'),
('Green Giants'),
('Yellow Tigers');

-- Matches
INSERT INTO matches (team1_id, team2_id, match_date) VALUES
(1, 2, '2025-07-01'),
(3, 4, '2025-07-02'),
(1, 3, '2025-07-05'),
(2, 4, '2025-07-06');

-- Scores (each match has two rows, one per team)
INSERT INTO scores (match_id, team_id, score) VALUES
(1, 1, 3), -- Red Warriors scored 3
(1, 2, 1), -- Blue Sharks scored 1
(2, 3, 2), -- Green Giants scored 2
(2, 4, 2), -- Yellow Tigers scored 2 (draw)
(3, 1, 1),
(3, 3, 4),
(4, 2, 0),
(4, 4, 5);

-- Win/Loss/Draw stats per team
SELECT 
    t.id,
    t.name,
    SUM(CASE WHEN s.score > opp.score THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN s.score < opp.score THEN 1 ELSE 0 END) AS losses,
    SUM(CASE WHEN s.score = opp.score THEN 1 ELSE 0 END) AS draws,
    COUNT(s.match_id) AS matches_played
FROM teams t
JOIN scores s ON t.id = s.team_id
JOIN scores opp ON s.match_id = opp.match_id AND s.team_id <> opp.team_id
GROUP BY t.id, t.name
ORDER BY wins DESC, draws DESC;
--  Leaderboard ranking by points (Win=3, Draw=1, Loss=0)
SELECT
    t.id,
    t.name,
    SUM(CASE WHEN s.score > opp.score THEN 3
             WHEN s.score = opp.score THEN 1
             ELSE 0 END) AS points,
    COUNT(s.match_id) AS matches_played,
    SUM(s.score) AS goals_for,
    SUM(opp.score) AS goals_against
FROM teams t
JOIN scores s ON t.id = s.team_id
JOIN scores opp ON s.match_id = opp.match_id AND s.team_id <> opp.team_id
GROUP BY t.id, t.name
ORDER BY points DESC, (SUM(s.score) - SUM(opp.score)) DESC;
--  List all matches with teams and scores
SELECT
    m.id AS match_id,
    m.match_date,
    t1.name AS team1,
    s1.score AS team1_score,
    t2.name AS team2,
    s2.score AS team2_score
FROM matches m
JOIN teams t1 ON m.team1_id = t1.id
JOIN teams t2 ON m.team2_id = t2.id
JOIN scores s1 ON m.id = s1.match_id AND s1.team_id = t1.id
JOIN scores s2 ON m.id = s2.match_id AND s2.team_id = t2.id
ORDER BY m.match_date;
