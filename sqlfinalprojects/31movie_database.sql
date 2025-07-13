-- 31. Movie Database 
-- Objective: Manage information about movies, genres, and ratings. 
create database movie;
use movie;
-- Entities: 
-- • Movies 
-- • Genres 
-- • Ratings 
-- SQL Skills: 
-- • AVG rating per movie 
-- • JOINs across genre and ratings 
-- Tables: 
-- • movies (id, title, release_year, genre_id) 
-- • genres (id, name) 
-- • ratings (user_id, movie_id, score)


CREATE TABLE genres (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE movies (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    release_year YEAR NOT NULL,
    genre_id BIGINT UNSIGNED,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE SET NULL
);

CREATE TABLE ratings (
    user_id BIGINT UNSIGNED NOT NULL,
    movie_id BIGINT UNSIGNED NOT NULL,
    score TINYINT UNSIGNED NOT NULL CHECK (score BETWEEN 1 AND 10),
    PRIMARY KEY (user_id, movie_id),
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);
-- Genres
INSERT INTO genres (name) VALUES 
('Action'), 
('Drama'), 
('Comedy');

-- Movies
INSERT INTO movies (title, release_year, genre_id) VALUES
('Inception', 2010, 1),
('The Godfather', 1972, 2),
('Superbad', 2007, 3);

-- Ratings (assume users 1, 2, 3)
INSERT INTO ratings (user_id, movie_id, score) VALUES
(1, 1, 9),
(2, 1, 8),
(3, 1, 10),
(1, 2, 10),
(2, 2, 9),
(1, 3, 7);
-- Get Average Rating per Movie with Genre Name
SELECT 
    m.id,
    m.title,
    g.name AS genre,
    ROUND(AVG(r.score), 2) AS avg_rating
FROM movies m
LEFT JOIN genres g ON m.genre_id = g.id
LEFT JOIN ratings r ON m.id = r.movie_id
GROUP BY m.id, m.title, g.name
ORDER BY avg_rating DESC;
-- List Movies by Genre
SELECT 
    m.title,
    m.release_year,
    g.name AS genre
FROM movies m
JOIN genres g ON m.genre_id = g.id
WHERE g.name = 'Action';
-- Get All Ratings for a Specific Movie
SELECT 
    r.user_id,
    r.score
FROM ratings r
WHERE r.movie_id = 1;  -- example: Inception movie_id = 1
-- List Top Rated Movies (avg rating >= 8)
SELECT 
    m.title,
    ROUND(AVG(r.score), 2) AS avg_rating
FROM movies m
JOIN ratings r ON m.id = r.movie_id
GROUP BY m.id, m.title
HAVING avg_rating >= 8
ORDER BY avg_rating DESC;





