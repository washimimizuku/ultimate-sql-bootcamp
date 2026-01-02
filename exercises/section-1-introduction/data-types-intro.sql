-- DATA TYPES INTRODUCTION - Understanding Different Kinds of Data
-- This file helps you recognize and understand different data types in SQL
-- We're not creating tables yet (that's Section 2) - just learning to recognize data
-- ============================================
-- REQUIRED: This file uses the Star Wars database
-- Run with: duckdb data/databases/starwars.db < exercises/section-1-introduction/data-types-intro.sql
-- ============================================

-- WHAT ARE DATA TYPES?
-- Data types tell the database what kind of information is stored in each column
-- Just like in real life, different types of information need different treatment
-- Numbers can be added, text can be searched, dates can be compared

-- Let's look at different types of data in our Star Wars database

-- TEXT/STRING DATA (VARCHAR):
-- Names, descriptions, categories - anything with letters and words
SELECT name, eye_color, gender FROM characters LIMIT 5;

-- Notice: Text data is usually displayed without quotes in results
-- Text can contain letters, numbers, spaces, and special characters

-- NUMERIC DATA (INTEGER, DECIMAL):
-- Numbers that can be used for calculations
SELECT name, height, mass FROM characters LIMIT 5;

-- Notice: Numbers are displayed without quotes
-- Some numbers might show as NULL (we'll explain that soon)
-- Height and mass are numbers we could add, subtract, or compare

-- DATE DATA:
-- Information about when something happened
SELECT title, release_date FROM films;

-- Notice: Dates have a specific format (usually YYYY-MM-DD)
-- Dates can be compared (which is earlier/later) and calculated with

-- BOOLEAN DATA (TRUE/FALSE):
-- Simple yes/no, true/false values
-- Let's see some examples by looking at what data we have
-- Note: height is stored as text in this database, so we need to convert it
SELECT name, 
       CASE WHEN CAST(height AS INTEGER) > 180 THEN 'Tall' ELSE 'Not Tall' END as height_category
FROM characters 
WHERE height IS NOT NULL AND height != 'unknown'
LIMIT 5;

-- UNDERSTANDING NULL VALUES:
-- NULL means "no data" or "unknown" - it's not zero, it's not empty text
-- NULL is different from 0 (zero) or '' (empty string)

-- Let's see some NULL values in action
SELECT name, height, mass FROM characters WHERE height IS NULL LIMIT 5;

-- Notice: NULL values show up as blank or "NULL" in results
-- NULL means we don't know this character's height, not that they have no height

-- COMPARING DATA TYPES:
-- Let's see different types side by side
SELECT 
    name,           -- TEXT: Character names
    height,         -- NUMBER: Height in centimeters  
    mass,           -- NUMBER: Mass in kilograms
    eye_color       -- TEXT: Eye color
FROM characters 
LIMIT 8;

-- RECOGNIZING DATA TYPES IN RESULTS:
-- TEXT: Usually words, may contain spaces and punctuation
-- NUMBERS: Digits, may have decimal points, no quotes
-- DATES: Usually YYYY-MM-DD format
-- NULL: Shows as blank or "NULL"

-- Let's look at a planet to see more data types
SELECT 
    name,              -- TEXT: Planet name
    rotation_period,   -- NUMBER: Hours in a day
    orbital_period,    -- NUMBER: Days in a year  
    diameter,          -- NUMBER: Size of planet
    climate,           -- TEXT: Weather description
    terrain            -- TEXT: Landscape description
FROM planets 
LIMIT 3;

-- PRACTICAL IMPLICATIONS:
-- - You can do math with numbers: height + mass
-- - You can search text: names containing "Luke"
-- - You can compare dates: which film came first
-- - You need to handle NULL values specially

-- COMMON DATA TYPE PATTERNS:
-- Names, titles, descriptions → TEXT
-- Counts, measurements, prices → NUMBERS  
-- Birth dates, release dates → DATES
-- Yes/no questions → BOOLEAN
-- Missing information → NULL

-- WHAT WE'VE LEARNED:
-- 1. Data types determine what kind of information is stored
-- 2. TEXT contains words and characters
-- 3. NUMBERS can be used for calculations
-- 4. DATES represent points in time
-- 5. NULL means "no data" or "unknown"
-- 6. You can recognize data types by looking at the values

-- PRACTICE EXERCISE:
-- Look at these results and identify the data types:
SELECT title, episode_id, release_date FROM films;
-- title: TEXT (movie names)
-- episode_id: NUMBER (episode numbers)  
-- release_date: DATE (when movies were released)

SELECT name, hair_colors FROM species LIMIT 5;
-- name: TEXT (species names)
-- hair_colors: TEXT (hair color descriptions)

-- NEXT STEPS:
-- Now you understand what different types of data look like!
-- In Section 2, you'll learn how to create tables with specific data types
-- In Section 4, you'll learn how to work with different data types in queries