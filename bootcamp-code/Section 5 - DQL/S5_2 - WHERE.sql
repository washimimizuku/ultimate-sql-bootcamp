USE ROLE SYSADMIN;
USE SCHEMA DEMO_DB.DEMO_SCHEMA;
USE WAREHOUSE XSMALL_WAREHOUSE;


-- Comparison operators =, !=, <>, >, >=, <, <=

SELECT 
    *
FROM 
    MOVIE
WHERE 
    GENRE <> 'Comedy'; -- can also use !=

SELECT 
    TITLE, GENRE, RATING
FROM 
    MOVIE
WHERE 
    RATING > 8;

SELECT 
    TITLE, GENRE, RATING
FROM 
    MOVIE
WHERE 
    RATING <= 8;

-- Logical Operators AND, OR & NOT

SELECT 
    MOVIE_ID, TITLE, GENRE, RATING
FROM 
    MOVIE
WHERE
    GENRE = 'Comedy' 
AND 
    RATING >= 7;

-- true  AND true   = true
-- true  AND false  = false
-- false AND true   = false
-- false AND false  = false

SELECT 
    MOVIE_ID, TITLE, GENRE, RATING
FROM 
    MOVIE
WHERE
    GENRE = 'Comedy' 
OR 
    RATING < 7;

-- true  OR true   = true
-- true  OR false  = true
-- false OR true   = true
-- false OR false  = false

SELECT 
    TITLE, GENRE, RATING, RUNTIME AS RUNTIME_IN_MINUTES
FROM 
    MOVIE
WHERE
   NOT GENRE = 'Comedy'
AND 
    RUNTIME > 189;

-- Which animation films scored higher than 6 as well as grossing over 1 million dollars?

SELECT 
    MOVIE_ID, TITLE, RATING, GROSS AS MILLIONS_DOLLARS
FROM 
    MOVIE
WHERE
    GENRE = 'Animation'
AND 
    RATING > 6
AND
    GROSS > 100;

-- Mixing OR and AND 

SELECT 
    TITLE, GENRE, RATING, RUNTIME AS RUNTIME_IN_MINUTES
FROM 
    MOVIE
WHERE
    (GENRE = 'Comedy' OR RATING < 7)
AND
    RUNTIME > 160;

SELECT 
    TITLE, GENRE, RUNTIME AS RUNTIME_IN_MINUTES, GROSS AS MILLIONS_DOLLARS
FROM 
    MOVIE
WHERE
    NOT (GENRE = 'Comedy' OR RATING < 7)
AND
    (RUNTIME > 170 OR GROSS > 900000000);

-- LIKE AND IN
SELECT 
    * 
FROM 
    MOVIE 
WHERE 
    TITLE LIKE 'The%';

SELECT 
    * 
FROM 
    MOVIE 
WHERE 
    GENRE IN ('Comedy', 'Horror', 'Drama');

SELECT 
    * 
FROM 
    MOVIE 
WHERE 
    GENRE NOT IN ('Comedy', 'Horror', 'Drama');
