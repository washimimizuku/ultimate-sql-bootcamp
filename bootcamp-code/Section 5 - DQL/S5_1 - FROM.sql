USE ROLE SYSADMIN;
USE SCHEMA DEMO_DB.DEMO_SCHEMA;
USE WAREHOUSE XSMALL_WAREHOUSE;

-- One column
SELECT 
    TITLE 
FROM 
    MOVIE;

-- Multiple columns
SELECT 
    MOVIE_ID, 
    TITLE, 
    RELEASE_DATE
FROM 
    MOVIE;

-- All columns
SELECT 
    *
FROM 
    MOVIE;

-- All columns excluding
SELECT 
    * EXCLUDE GENRE
FROM 
    MOVIE;

-- Aliases
SELECT 
    MOVIE_ID AS ID,
    RATING AS STAR_RATING
FROM 
    MOVIE;

-- Including user-generated column in result set

SELECT 
    TITLE AS TITLE,
    'US' AS RELEASE_COUNTRY,
    ROUND(RATING * 10) || '%' AS RATING_PERCENTAGE
FROM 
    MOVIE;

CREATE TABLE MOVIE_US 
AS
SELECT 
    TITLE AS TITLE,
    'US' AS RELEASE_COUNTRY,
    ROUND(RATING * 10) || '%' AS RATING_PERCENTAGE
FROM 
    MOVIE;

SELECT 
    *
FROM 
    MOVIE_US;

-- DISTINCT
SELECT 
    DISTINCT GENRE 
FROM 
    MOVIE;

-- DISTINCT across multiple columns
SELECT 
    DISTINCT GENRE, RATING
FROM 
    MOVIE;

-- LIMIT
SELECT 
    *
FROM 
    MOVIE
LIMIT 
    10;

-- OFFSET
SELECT 
    *
FROM 
    MOVIE
LIMIT 
    10
OFFSET
    5;

-- Remove unrequired table 
DROP TABLE IF EXISTS MOVIE_US;